//
//  PTMovieGLView.m
//  PTKit
//
//  Created by 彭腾 on 16/9/18.
//  Copyright © 2016年 PT. All rights reserved.
//

#import "PTMovieGLView.h"
#import <OpenGLES/ES2/gl.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const vertexShaderString = SHADER_STRING(
                                                   attribute vec4 position;
                                                   attribute vec2 texcoord;
                                                   uniform mat4 modelViewProjectionMatrix;
                                                   varying vec2 v_texcoord;
                                                   
                                                   void main() {
                                                       gl_Position = modelViewProjectionMatrix * position;
                                                       v_texcoord = texcoord.xy;
                                                   }
                                                   );

NSString *const yuvFragmentShaderString = SHADER_STRING(
                                                        varying highp vec2 v_texcoord;
                                                        uniform sampler2D s_texture_y;
                                                        uniform sampler2D s_texture_u;
                                                        uniform sampler2D s_texture_v;
                                                        
                                                        void main() {
                                                            highp float y = texture2D(s_texture_y, v_texcoord).r;
                                                            highp float u = texture2D(s_texture_y, v_texcoord).r - 0.5;
                                                            highp float v = texture2D(s_texture_y, v_texcoord).r - 0.5;
                                                            
                                                            highp float r = y + 1.402 * v;
                                                            highp float g = y - 0.344 * u - 0.714 * v;
                                                            highp float b = y + 1.772 * u;
                                                            /**
                                                             *  输出的颜色用于随后的像素操作
                                                             */
                                                            gl_FragColor = vec4(r,g,b,1.0);
                                                        }
                                                        );

/*
 在OpenGL整个程序的初始化阶段（一般是init()函数），做以下工作。
 1、顶点着色程序的源代码和片段作色程序的源代码要分别保存到一个字符数组里面；
 2、使用glCreateshader()分别创建一个顶点着色器对象和一个片段着色器对象；
 3、使用glShaderSource()分别将顶点着色程序的源代码字符数组绑定到顶点着色器对象，将片段着色程序的源代码字符数组绑定到片段着色器对象；
 4、使用glCompileShader()分别编译顶点着色器对象和片段着色器对象；
 5、使用glCreaterProgram()创建一个（着色）程序对象；
 6、使用glAttachShader()分别将顶点着色器对象和片段着色器对象附加到（着色）程序对象上；
 7、使用glLinkProgram()对（着色）程序对象执行链接操作
 8、使用glValidateProgram()对（着色）程序对象进行正确性验证
 9、最后使用glUseProgram()将OpenGL渲染管道切换到着色器模式，并使用刚才做好的（着色）程序对象。
 然后，才可以提交顶点。
 */
static GLuint compileShader(GLenum type, NSString *shaderString) {
    GLint status;
    const GLchar *sources = (GLchar *)shaderString.UTF8String;
    
    GLuint shader = glCreateShader(type);
    if (shader == 0 || shader == GL_INVALID_ENUM) {
        return 0;
    }
    
    glShaderSource(shader, 1, &sources, NULL);
    glCompileShader(shader);
    /**
     *  获取编译情况
     */
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

static BOOL validateProgram(GLuint prog) {
    GLint status;
    //检测program中包含的执行段在给定的当前OpenGL状态下是否可执行
    glValidateProgram(prog);
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == GL_FALSE) {
        return NO;
    }
    return YES;
}

static void mat4f_LoadOrtho(float left, float right, float bottom, float top, float near, float far, float* mout) {
    float r_l = right - left;
    float t_b = top - bottom;
    float f_n = far - near;
    float tx = - (right + left) / (right - left);
    float ty = - (top + bottom) / (top - bottom);
    float tz = - (far + near) / (far - near);
    
    mout[0] = 2.0f / r_l;
    mout[1] = 0.0f;
    mout[2] = 0.0f;
    mout[3] = 0.0f;
    
    mout[4] = 0.0f;
    mout[5] = 2.0f / t_b;
    mout[6] = 0.0f;
    mout[7] = 0.0f;
    
    mout[8] = 0.0f;
    mout[9] = 0.0f;
    mout[10] = -2.0f / f_n;
    mout[11] = 0.0f;
    
    mout[12] = tx;
    mout[13] = ty;
    mout[14] = tz;
    mout[15] = 1.0f;
}


@protocol PTMovieGLRenderer <NSObject>

- (BOOL)isValid;

- (NSString *)fragmentShader;

- (void)resolveUniforms:(GLuint)program;

- (void)setFrame:(PTVideoFrame *)frame;

- (BOOL)prepareRender;

@end

@interface PTMovieGLRenderer_YUV : NSObject<PTMovieGLRenderer> {
    GLint _uniformSamplers[3];
    GLuint _textures[3];
}
@end

@implementation PTMovieGLRenderer_YUV

- (BOOL)isValid {
    return (_textures[0] != 0);
}

- (NSString *)fragmentShader {
    return yuvFragmentShaderString;
}

- (void)resolveUniforms:(GLuint)program {
    _uniformSamplers[0] = glGetUniformLocation(program, "s_texture_y");
    _uniformSamplers[1] = glGetUniformLocation(program, "s_texture_u");
    _uniformSamplers[2] = glGetUniformLocation(program, "s_texture_v");
}

- (void)setFrame:(PTVideoFrame *)frame {
    PTVideoFrameYUV *yuvFrame = (PTVideoFrameYUV *)frame;
    
    assert(yuvFrame.bytesY.length == yuvFrame.width * yuvFrame.height);
    assert(yuvFrame.bytesU.length == (yuvFrame.width * yuvFrame.height) / 4);
    assert(yuvFrame.bytesV.length == (yuvFrame.width * yuvFrame.height) / 4);
    
    const NSUInteger frameWidth = frame.width;
    const NSUInteger frameHeight = frame.height;
    /**
     *  对齐像素字节
     */
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if (_textures[0] == 0) {
        /**
         *  生成纹理
         */
        glGenTextures(3, _textures);
    }
    
    const UInt8 *pixels[3] = {yuvFrame.bytesY.bytes, yuvFrame.bytesU.bytes, yuvFrame.bytesV.bytes};
    const NSUInteger widths[3] = {frameWidth, frameWidth/2, frameWidth/2};
    const NSUInteger heights[3] = {frameHeight, frameHeight/2, frameHeight/2};
    
    for (int i = 0; i < 3; i++) {
        /**
         *  允许建立一个绑定到目标纹理的有名称的纹理,选择纹理对象
         *
         *  @param target#>   纹理被绑定的目标，它只能取值GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D或者GL_TEXTURE_CUBE_MAP description#>
         *  @param texture#> 纹理的名称，并且，该纹理的名称在当前的应用中不能被再次使用 description#>
         *
         *  @return <#return value description#>
         */
        glBindTexture(GL_TEXTURE_2D, _textures[i]);
        /**
         *  根据指定的参数，生成一个2D纹理
         *
         *  @param target#>         指定目标纹理，这个值必须是GL_TEXTURE_2D description#>
         *  @param level#>          执行细节级别。0是最基本的图像级别，n表示第N级贴图细化级别 description#>
         *  @param internalformat#> 指定纹理中的颜色组件。可选的值有GL_ALPHA,GL_RGB,GL_RGBA,GL_LUMINANCE, GL_LUMINANCE_ALPHA 等几种 description#>
         *  @param width#>          指定纹理图像的宽度，必须是2的n次方。纹理图片至少要支持64个材质元素的宽度 description#>
         *  @param height#>         指定纹理图像的高度，必须是2的m次方。纹理图片至少要支持64个材质元素的高度 description#>
         *  @param border#>         指定边框的宽度。必须为0。 description#>
         *  @param format#>         像素数据的颜色格式, 不需要和internalformatt取值必须相同。可选的值参考internalformat description#>
         *  @param type#>           指定像素数据的数据类型。可以使用的值有GL_UNSIGNED_BYTE,GL_UNSIGNED_SHORT_5_6_5,GL_UNSIGNED_SHORT_4_4_4_4,GL_UNSIGNED_SHORT_5_5_5_1 description#>
         *  @param pixels#>         指定内存中指向图像数据的指针 description#>
         *
         *  @return <#return value description#>
         */
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_LUMINANCE,
                     widths[i],
                     heights[i],
                     0,
                     GL_LUMINANCE,
                     GL_UNSIGNED_BYTE,
                     pixels[i]);
        /**
         *  纹理过滤函数,图象从纹理图象空间映射到帧缓冲图象空间(映射需要重新构造纹理图像,这样就会造成应用到多边形上的图像失真),这时就可用glTexParmeteri()函数来确定如何把纹理象素映射成像素.
         *
         *  @param target#> GL_TEXTURE_2D:操作2D纹理 description#>
         *  @param pname#>  GL_TEXTURE_MAG_FILTER:放大过滤 GL_TEXTURE_MIN_FILTER:缩小过滤 GL_TEXTURE_WRAP_S:S方向上的贴图模式 GL_TEXTURE_WRAP_T:T方向的贴图模式 description#>
         *  @param param#>  GL_LINEAR:线性过滤, 使用距离当前渲染像素中心最近的4个纹素加权平均值  GL_CLAMP_TO_EDGE:表示OpenGL只画图片一次，剩下的部分将使用图片最后一行像素重复 description#>
         *
         *  @return <#return value description#>
         */
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
}

- (BOOL)prepareRender {
    if (_textures[0] == 0) {
        return NO;
    }
    
    for (int i = 0; i < 3; i++) {
        /**
         *  选择当前活跃的纹理单元
         */
        glActiveTexture(GL_TEXTURE0 + i);
        /**
         *  允许建立一个绑定到目标纹理的有名称的纹理
         */
        glBindTexture(GL_TEXTURE_2D, _textures[i]);
        /**
         *  对纹理采样器变量进行设置
         */
        glUniform1i(_uniformSamplers[i], i);
    }
    
    return YES;
}

- (void)dealloc {
    if (_textures[0]) {
        glDeleteTextures(3, _textures);
    }
}

@end

enum {
    ATTRIBUTE_VERTEX,
   	ATTRIBUTE_TEXCOORD,
};

@interface PTMovieGLView () {
    PTDecoder               *_decoder;
    EAGLContext             *_context;
    /**
     *  创建一个帧缓冲区对象
     */
    GLuint                  _framebuffer;
    /**
     *  创建一个渲染缓冲区对象
     */
    GLuint                  _renderbuffer;
    GLint                   _backingWidth;
    GLint                   _backingHeight;
    GLuint                  _program;
    GLint                   _uniformMatrix;
    GLfloat                 _vertices[8];
    id<PTMovieGLRenderer>   _renderer;
}
@end

@implementation PTMovieGLView

- (id)initWithFrame:(CGRect)frame decoder:(PTDecoder *)decoder {
    self = [super initWithFrame:frame];
    if (self) {
        _decoder = decoder;
        
        _renderer = [[PTMovieGLRenderer_YUV alloc]init];

        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        /**
         *  kEAGLDrawablePropertyRetainedBacking为FALSE表示不想保持呈现的内容，因此在下一次呈现时，应用程序必须完全重绘一次。将该设置为 TRUE 对性能和资源影像较大，因此只有当renderbuffer需要保持其内容不变时，我们才设置 kEAGLDrawablePropertyRetainedBacking为TRUE。
         */
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

        _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context || ![EAGLContext setCurrentContext:_context]) {
            self = nil;
            return nil;
        }
        /**
         *  创建一个帧染缓冲区对象
         */
        glGenFramebuffers(1, &_framebuffer);
        /**
         *  创建一个渲染缓冲区对象
         */
        glGenRenderbuffers(1, &_renderbuffer);
        /**
         *  将该帧染缓冲区对象绑定到管线上
         */
        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
        /**
         *  将该渲染缓冲区对象绑定到管线上
         */
        glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
        /**
         *  为绘制缓冲区分配存储区，此处将CAEAGLLayer的绘制存储区作为绘制缓冲区的存储区
         */
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        /**
         *  获取绘制缓冲区的像素宽度
         */
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
        /**
         *  获取绘制缓冲区的像素高度
         */
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
        /**
         *  绑定绘制缓冲区到帧缓冲区
         */
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
        /**
         *  检查当前帧缓存的关联图像和帧缓存参数。这个函数不能在glBegin()/glEnd()之间调用。Target参数必须为GL_FRAMEBUFFER。它返回一个非零值。如果所有要求和准则都满足，它返回GL_FRAMEBUFFER_COMPLETE。否则，返回一个相关错误代码告诉我们哪条准则没有满足。
         */
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE) {
            self = nil;
            return nil;
        }
        /**
         * GL_NO_ERROR              没有错误
           GL_INVALID_ENUM          枚举参数超出范围
           GL_INVALID_VALUE         数值参数超出范围
           GL_INVALID_OPERATION     在当前状态中非法操作
           GL_OUT_OF_MEMORY         内存不足，无法执行该命令
         */
        GLenum glError = glGetError();
        if (GL_NO_ERROR != glError) {
            self = nil;
            return nil;
        }
        
        if (![self loadShaders]) {
            self = nil;
            return nil;
        }
        
        _vertices[0] = -1.0f;
        _vertices[1] = -1.0f;
        _vertices[2] =  1.0f;
        _vertices[3] = -1.0f;
        _vertices[4] = -1.0f;
        _vertices[5] =  1.0f;
        _vertices[6] =  1.0f;
        _vertices[7] =  1.0f;
    }
    return self;
}

- (BOOL)loadShaders {
    BOOL result = NO;
    GLuint vertShader = 0, fragShader = 0;
    //创建着色器程序
    _program = glCreateProgram();
    //顶点着色器
    vertShader = compileShader(GL_VERTEX_SHADER, vertexShaderString);
    //片元着色器
    fragShader = compileShader(GL_FRAGMENT_SHADER, _renderer.fragmentShader);
    //加入顶点着色器
    glAttachShader(_program, vertShader);
    //加入片元着色器
    glAttachShader(_program, fragShader);
    //把program的顶点属性索引与顶点shader中的变量名进行绑定
    glBindAttribLocation(_program, ATTRIBUTE_VERTEX, "position");
    //把program的顶点属性索引与顶点shader中的变量名进行绑定
    glBindAttribLocation(_program, ATTRIBUTE_TEXCOORD, "texcoord");
    //连接程序对象。如果任何类型为GL_VERTEX_SHADER的shader对象连接到program,它将产生在“可编程顶点处理器”上可执行的程 序；如果任何类型为GL_FRAGMENT_SHADER的shader对象连接到program,它将产生在“可编程片断处理器”上可执行的程序
    glLinkProgram(_program);
    
    GLint status;
    //获取program对象的参数值
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        
    }
    
    result = validateProgram(_program);
    //获取指向着色器中uMVPMatrix的index
    _uniformMatrix = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    [_renderer resolveUniforms:_program];
    
    return result;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)updateVertices {
    const BOOL  fit     = (self.contentMode == UIViewContentModeScaleAspectFit);
    const float width   = _decoder.frameWidth;
    const float height  = _decoder.frameHeight;
    const float dH      = (float)_backingHeight / height;
    const float dW      = (float)_backingWidth / width;
    const float dd      = fit ? MIN(dH, dW) : MAX(dH, dW);
    const float h       = (height * dd / (float)_backingHeight);
    const float w       = (width * dd / (float)_backingWidth);
    
    _vertices[0] = -w;
    _vertices[1] = -h;
    _vertices[2] =  w;
    _vertices[3] = -h;
    _vertices[4] = -w;
    _vertices[5] =  h;
    _vertices[6] =  w;
    _vertices[7] =  h;
}

- (void)layoutSubviews {
    [self updateVertices];
    [self render:nil];
}

- (void)render:(PTVideoFrame *)frame {
    static const GLfloat texCoords[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    [EAGLContext setCurrentContext:_context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    /**
     *  glViewport(GLint x,GLint y,GLsizei width,GLsizei height)为其函数原型。
        X，Y————以像素为单位，指定了视口的左下角（在第一象限内，以（0，0）为原点的）位置。
        width，height————表示这个视口矩形的宽度和高度，根据窗口的实时变化重绘窗口。
     */
    glViewport(0, 0, _backingWidth, _backingHeight);
    /**
     *  清空当前颜色
     */
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    /**
     *  清除缓冲
        GL_DEPTH_BUFFER_BIT     深度缓冲
        GL_STENCIL_BUFFER_BIT   模板缓冲
        GL_COLOR_BUFFER_BIT     当前可写的颜色缓冲
     */
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(_program);
    
    if (frame) {
        [_renderer setFrame:frame];
    }
    
    if ([_renderer prepareRender]) {
        GLfloat modelviewProj[16];
        mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, modelviewProj);
        glUniformMatrix4fv(_uniformMatrix, 1, GL_FALSE, modelviewProj);
        
        glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0, _vertices);
        glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
        glVertexAttribPointer(ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, 0, 0, texCoords);
        glEnableVertexAttribArray(ATTRIBUTE_TEXCOORD);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
