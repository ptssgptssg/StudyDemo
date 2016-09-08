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

@interface PTDecoder () {
    NSInteger videostream;
    NSArray *videostreams;
    AVFrame *videoFrame;
}
@end

@implementation PTDecoder

- (BOOL)openFile:(NSString *)path
           error:(NSError *__autoreleasing *)perror {
    _isNetwork = isNetworkPath(path);
    if (_isNetwork) {
        avformat_network_init();
    }
    
    AVFormatContext *formatCtx = avformat_alloc_context();
    
    if (avformat_open_input(&formatCtx, [path cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL) != 0) {
        if (formatCtx) {
            avformat_free_context(formatCtx);
        }
        NSLog(@"Couldn't open input stream.\n");
        return NO;
    }
    
    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        avformat_close_input(&formatCtx);
        printf("Couldn't find stream information.\n");
        return NO;
    }
    
    videostream = -1;
    videostreams = collectStreams(formatCtx, AVMEDIA_TYPE_VIDEO);
    
    for (NSNumber *number in videostreams) {
        
        NSUInteger iStream = number.integerValue;
        if ((formatCtx->streams[iStream]->disposition & AV_DISPOSITION_ATTACHED_PIC) == 0) {
            
            AVCodecContext *codecCtx = formatCtx->streams[iStream]->codec;
            AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
            
            if (!codec) {
                NSLog(@"Codec not found.");
                return NO;
            }
            
            if (avcodec_open2(codecCtx, codec, NULL) < 0) {
                NSLog(@"Counld not open codec.");
                return NO;
            }
            
            videoFrame = av_frame_alloc();
            if (!videoFrame) {
                avcodec_close(codecCtx);
                return NO;
            }
        }
    }
    
    return YES;
}

+ (void)initialize {
    av_register_all();
}

@end
