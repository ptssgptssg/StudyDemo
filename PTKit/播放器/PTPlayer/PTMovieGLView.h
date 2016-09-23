//
//  PTMovieGLView.h
//  PTKit
//
//  Created by 彭腾 on 16/9/18.
//  Copyright © 2016年 PT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTDecoder.h"

@interface PTMovieGLView : UIView

- (id)initWithFrame:(CGRect)frame
            decoder:(PTDecoder *)decoder;

- (void)render:(PTVideoFrame *)frame;

@end
