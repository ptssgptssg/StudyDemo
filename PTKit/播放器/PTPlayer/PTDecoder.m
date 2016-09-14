//
//  PTDecoder.m
//  PTKit
//
//  Created by 彭腾 on 16/9/6.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTDecoder.h"
#import <libavformat/avformat.h>
#import <libavcodec/avcodec.h>
#import <libswscale/swscale.h>

static BOOL isNetworkPath(NSString *path) {
    NSRange range = [path rangeOfString:@":"];
    if (range.location == NSNotFound) {
        return NO;
    }
    NSString *scheme = [path substringToIndex:range.location];
    if ([scheme isEqualToString:@"file"]) {
        return NO;
    }
    return YES;
}

static NSArray *collectStreams(AVFormatContext *formatCtx, enum AVMediaType codecType) {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < formatCtx->nb_streams; i++) {
        if (codecType == formatCtx->streams[i]->codec->codec_type) {
            [array addObject:[NSNumber numberWithInteger:i]];
        }
    }
    return [array copy];
}

static NSData *copyFrameData(UInt8 *src, int linesize, int width, int height) {
    width = MIN(linesize, width);
    NSMutableData *md = [NSMutableData dataWithLength:width * height];
    Byte *dst = md.mutableBytes;
    for (NSUInteger i = 0; i < height; i++) {
        memcpy(dst, src, width);
        dst += width;
        src += linesize;
    }
    return md;
}

static NSString *errorMsg(PTMovieError errorCode) {
    switch (errorCode) {
        case PTMovieErrorNone:
            return @"";
        case PTMovieErrorOpenFile:
            return @"Couldn't open file ";
        case PTMovieErrorStreamNotFound:
            return @"Couldn't find stream";
        case PTMovieErrorStreamInfoNotFound:
            return @"Couldn't find stream information";
        case PTMovieErrorCodecNotFound:
            return @"Couldn't find codec";
        case PTMovieErrorOpenCodec:
            return @"Couldn't open codec";
        case PTMovieErrorAllocateFrame:
            return @"Couldn't allocate frame";
        case PTMovieErrorDecodeVideo:
            return @"Couldn't decode video";
    }
}

@interface PTMovieFrame()
@property (readwrite, nonatomic) CGFloat position;
@property (readwrite, nonatomic) CGFloat duration;
@end

@implementation PTMovieFrame
@end

@interface PTVideoFrame()
@property (readwrite, nonatomic) NSUInteger width;
@property (readwrite, nonatomic) NSUInteger height;
@end

@implementation PTVideoFrame
@end

@interface PTVideoFrameYUV()
@property (readwrite, nonatomic, strong) NSData *bytesY;
@property (readwrite, nonatomic, strong) NSData *bytesU;
@property (readwrite, nonatomic, strong) NSData *bytesV;
@end

@implementation PTVideoFrameYUV
@end

@interface PTDecoder () {
    //每个AVStream存储一个视频/音频流的相关数据；每个AVStream对应一个AVCodecContext，存储该视频/音频流使用解码方式的相关数据
    //AVFormatContext主要存储视音频封装格式中包含的信息
    AVFormatContext *formatCtx;
    //每个AVCodecContext中对应一个AVCodec，包含该视频/音频对应的解码器。每种解码器都对应一个AVCodec结构
    AVCodecContext *codecCtx;
    //AVCodec是存储编解码器信息的结构体
    AVCodec *codec;
    //解码后数据：AVFrame AVFrame结构体一般用于存储原始数据（即非压缩数据，例如对视频来说是YUV，RGB，对音频来说是PCM），此外还包含了一些相关的信息。比如说，解码的时候存储了宏块类型表，QP表，运动矢量表等数据。编码的时候也存储了相关的数据。
    AVFrame *videoFrame;
    NSInteger videostream;
    NSArray *videostreams;
}
@end

@implementation PTDecoder

+ (void)initialize {
    av_register_all();
}

- (BOOL)openInput:(NSString *)path {
    _isNetwork = isNetworkPath(path);
    
    if (_isNetwork) {
        avformat_network_init();
    }
    
    formatCtx = avformat_alloc_context();
    //函数执行成功的话，其返回值大于等于0。
    if (avformat_open_input(&formatCtx, [path cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL) < 0) {
        if (formatCtx) {
            avformat_free_context(formatCtx);
            errorMsg(PTMovieErrorOpenFile);
            return NO;
        }
    }
    //函数正常执行后返回值大于等于0
    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        avformat_close_input(&formatCtx);
        errorMsg(PTMovieErrorStreamNotFound);
        return NO;
    }
    
    videostream = -1;
    videostreams = collectStreams(formatCtx, AVMEDIA_TYPE_VIDEO);
    
    for (NSNumber *number in videostreams) {
        
        NSUInteger iStream = number.integerValue;
        
        if ((formatCtx->streams[iStream]->disposition & AV_DISPOSITION_ATTACHED_PIC) == 0) {
            
            codecCtx = formatCtx->streams[iStream]->codec;
            codec = avcodec_find_decoder(codecCtx->codec_id);
            
            if (!codec) {
                errorMsg(PTMovieErrorCodecNotFound);
            }
            
            if (avcodec_open2(codecCtx, codec, NULL) < 0) {
                errorMsg(PTMovieErrorOpenCodec);
            }
            
            videoFrame = av_frame_alloc();
            if (!videoFrame) {
                avcodec_close(codecCtx);
                errorMsg(PTMovieErrorAllocateFrame);
            }
        }
    }
    
    return YES;
}

- (NSArray *)decodeFrames {
    if (videostream == -1) {
        return nil;
    }
    //AVPacket是存储压缩编码数据相关信息的结构体
    AVPacket *packet;
    
    NSMutableArray *result = [NSMutableArray array];

    while (av_read_frame(formatCtx, packet) > 0) {
        
        if (packet->stream_index == videostream) {
            
            int gotframe = 0;
            /**
             *  解码一帧视频数据。输入一个压缩编码的结构体AVPacket，输出一个解码后的结构体AVFrame
             *
             *  @param codecCtx   编解码上下文环境，定义了编解码操作的一些细节
             *  @param videoFrame 输出参数
             *  @param gotframe   该值为0表明没有图像可以解码，否则表明有图像可以解码
             *  @param packet     输入参数，包含待解码数据。
             *
             *  @return 小于0解码失败
             */
            int ret = avcodec_decode_video2(codecCtx, videoFrame, &gotframe, packet);
            
            if (ret < 0) {
                errorMsg(PTMovieErrorDecodeVideo);
                break;
            }
            
            if (gotframe) {
                PTVideoFrame *frame;
                
                PTVideoFrameYUV *yuvFrame = [[PTVideoFrameYUV alloc]init];
                yuvFrame.bytesY = copyFrameData(videoFrame->data[0], videoFrame->linesize[0], codecCtx->width, codecCtx->height);
                yuvFrame.bytesU = copyFrameData(videoFrame->data[1], videoFrame->linesize[1], codecCtx->width/2, codecCtx->height/2);
                yuvFrame.bytesV = copyFrameData(videoFrame->data[2], videoFrame->linesize[2], codecCtx->width/2, codecCtx->height/2);
                
                frame = yuvFrame;
                if (frame) {
                    [result addObject:frame];
                }
            }
        }
    }
    
    return result;
}

@end
