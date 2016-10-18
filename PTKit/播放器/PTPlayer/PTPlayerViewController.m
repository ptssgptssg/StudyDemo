//
//  PTPlayerViewController.m
//  PTKit
//
//  Created by 彭腾 on 16/9/7.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTPlayerViewController.h"
#import "PTDecoder.h"
#import "PTMovieGLView.h"

@interface PTPlayerViewController () {
    PTDecoder *_decoder;
    dispatch_queue_t _dispatchQueue;
    NSMutableArray *_videoFrames;
    PTMovieGLView *_glView;
}
@end

@implementation PTPlayerViewController

+ (id)movieViewControllerWithContentPath:(NSString *)path {
    return [[PTPlayerViewController alloc]initWithContentPath:path];
}

- (id)initWithContentPath:(NSString *)path {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        __weak PTPlayerViewController *weakSelf = self;
        
        PTDecoder *decoder = [[PTDecoder alloc]init];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [decoder openInput:path];
            
            __strong PTPlayerViewController *strongSelf = weakSelf;
            if (strongSelf) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [strongSelf setMovieDecoder:decoder];
                });
            }
        });
    }
    return self;
}

- (void)play {
    
    [self asyncDecodeFrames];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });
}

- (void)pause {
    
}

- (void)setMovieDecoder:(PTDecoder *)decoder {
    
    if (decoder) {
        
        _decoder        = decoder;
        _dispatchQueue  = dispatch_queue_create("com.decoder.queue", DISPATCH_QUEUE_SERIAL);
        _videoFrames    = [NSMutableArray array];
        
        if (self.isViewLoaded) {
            [self setupPresentView];
            [self play];
        }
    }
}

- (void)setupPresentView {
    
    CGRect bounds = self.view.bounds;
    
    if (_decoder) {
        _glView = [[PTMovieGLView alloc]initWithFrame:bounds decoder:_decoder];
    }
    
    _glView.contentMode = UIViewContentModeScaleAspectFit;
    _glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.view insertSubview:_glView atIndex:0];
}

- (void)asyncDecodeFrames {
    __weak PTPlayerViewController *weakSelf = self;
    __weak PTDecoder *weakDecoder = _decoder;
    
    dispatch_async(_dispatchQueue, ^{
        
        BOOL good = YES;
        while (good) {
            
            good = NO;
            
            @autoreleasepool {
                
                __strong PTDecoder *decoder = weakDecoder;
                
                if (decoder) {
                    
                    NSArray *frames = [decoder decodeFrames];
                    if (frames.count) {
                        
                        __strong PTPlayerViewController *strongSelf = weakSelf;
                        if (strongSelf) {
                            good = [strongSelf addFrames:frames];
                        }
                    }
                }
            }
        }
    });
}

- (BOOL)addFrames:(NSArray *)frames {
    if (_decoder) {
        
        @synchronized(_videoFrames) {
            
            for (PTMovieFrame *frame in frames) {
                if (frame.type == PTMovieFrameTypeVideo) {
                    [_videoFrames addObject:frame];
                }
            }
        }
    }
    return YES;
}

- (void)tick {
    if (_videoFrames.count > 0) {
        [_glView render:_videoFrames[0]];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
