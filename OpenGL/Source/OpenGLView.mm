//
//  OpenGLView.m
//  OpenGL
//
//  Created by Mahoone on 2020/8/3.
//  Copyright © 2020 Mahoone. All rights reserved.
//

#import "OpenGLView.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "../glm/glm.hpp"
#import "../glm/gtc/matrix_transform.hpp"
#import "../glm/gtc/type_ptr.hpp"

@interface OpenGLView ()
{
    GLuint _programId;
}
@end

@implementation OpenGLView


#pragma mark - Life Cycle
- (void)dealloc {
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    
    _context = nil;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])){
        [self setup];
    }
    
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self render];
}

#pragma mark - Override

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

// 申请缓存
- (void)setupBuffer {
    // 创建 绑定 渲染缓存
    glGenRenderbuffers(1, &_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    // 该方法最好在绑定渲染后立即设置，不然后面会被绑定为深度渲染缓存
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    
    // 创建 绑定帧缓存
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    // 在帧缓存 和 渲染缓存创建 和 绑定结束后需要
    // 渲染缓存作为帧缓存的某种（颜色、深度、模板）附件
    glFramebufferRenderbuffer(
                              //帧缓冲区类型
                              GL_FRAMEBUFFER,
                              //缓冲附件类型
                              GL_COLOR_ATTACHMENT0,
                              //渲染缓冲区类型
                              GL_RENDERBUFFER,
                              //渲染缓冲句柄
                              _renderbuffer);
    
    // 深度缓存
    GLint width;
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    glViewport(0, 0, width, height);
    
    GLuint _depthRenderBuffer;
    // 申请深度渲染缓存
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    // 设置深度测试的存储信息
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    // 关联深度缓冲到帧缓冲区
    // 将渲染缓存挂载到GL_DEPTH_ATTACHMENT这个挂载点上
    glFramebufferRenderbuffer(
                              GL_FRAMEBUFFER,
                              GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER,
                              _depthRenderBuffer);
    // GL_RENDERBUFFER绑定的是深度测试渲染缓存，所以要绑定回色彩渲染缓存
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    // 检查帧缓存状态
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Error: Frame buffer is not completed.");
        exit(1);
    }
}
#pragma mark - Setup
- (void)setup {
    self.userInteractionEnabled = false;
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = NO;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    NSAssert(_context && [EAGLContext setCurrentContext:_context], @"初始化GL环境失败");
   
    [self setupBuffer];
   
    _programId = [self createProgramWithVertexShader:@"VertexShader.glsl" fragmentShader:@"FragmentShader.glsl"];

    _m = self.certerFrame.size.width/10;
    _n = self.certerFrame.size.height/10;
    CGSize size = self.certerFrame.size;
    GLfloat x = -size.width/2;
    GLfloat y = -size.height/2;
    GLfloat vertices[] = {
        x,               y, 0,       0,
        GLfloat(x+size.width/_m), y, GLfloat(1.0/_m),  0,
        GLfloat(x+size.width/_m), GLfloat(y+size.height/_n), GLfloat(1.0/_m),  GLfloat(1.0/_n),
        x,               GLfloat(y+size.height/_n), 0,      GLfloat( 1.0/_n)
    };
   
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STREAM_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);//解绑
    
    glActiveTexture(GL_TEXTURE1);
    _textureBack = [self generateTexture];
    [self copyTo:_textureBack fromImage:self.back];
    
    glActiveTexture(GL_TEXTURE0);
    _textureFront = [self generateTexture];
    [self copyTo:_textureFront fromImage:self.front];
}

- (void)copyTo:(GLuint)textureId fromImage:(UIImage*)image
{
  
    UIImage *backPageImage = image;
    
    glBindTexture(GL_TEXTURE_2D, textureId);
    
    size_t width = CGImageGetWidth(backPageImage.CGImage);
    size_t height = CGImageGetHeight(backPageImage.CGImage);
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGRect r = CGRectMake(0, 0, width, height);
    CGContextClearRect(context, r);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, width, 0);
    CGContextScaleCTM(context, -1, 1);
    CGContextDrawImage(context, r, backPageImage.CGImage);
    CGContextRestoreGState(context);
    GLubyte *textureData = (GLubyte *)CGBitmapContextGetData(context);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    CGContextRelease(context);
}


#pragma mark - Shaders

- (GLuint)loadShader:(NSString *)filename type:(GLenum)type
{
    GLuint shader = glCreateShader(type);
    
    if (shader == 0) {
        return 0;
    }
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    const GLchar *shaderSource = [shaderString cStringUsingEncoding:NSUTF8StringEncoding];
    
    glShaderSource(shader, 1, &shaderSource, NULL);
    glCompileShader(shader);
    
    GLint success = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    
    if (success == 0) {
        char errorMsg[2048];
        glGetShaderInfoLog(shader, sizeof(errorMsg), NULL, errorMsg);
        NSString *errorString = [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding];
        NSLog(@"Failed to compile %@: %@", filename, errorString);
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

- (GLuint)createProgramWithVertexShader:(NSString *)vertexShaderFilename fragmentShader:(NSString *)fragmentShaderFilename
{
   
    GLuint vertexShader = [self loadShader:vertexShaderFilename type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self loadShader:fragmentShaderFilename type:GL_FRAGMENT_SHADER];
    GLuint prog = glCreateProgram();
    
    glAttachShader(prog, vertexShader);
    glAttachShader(prog, fragmentShader);
    glLinkProgram(prog);
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    GLint linked = 0;
    glGetProgramiv(prog, GL_LINK_STATUS, &linked);
    if (linked == 0) {
        glDeleteProgram(prog);
        return 0;
    }
    
    return prog;
}

/*
#pragma mark - Private
- (BOOL)checkFramebuffer:(NSError *__autoreleasing *)error {
    // 检查 framebuffer 是否创建成功
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSString *errorMessage = nil;
    BOOL result = NO;
    
    switch (status)
    {
        case GL_FRAMEBUFFER_UNSUPPORTED:
            errorMessage = @"framebuffer不支持该格式";
            result = NO;
            break;
        case GL_FRAMEBUFFER_COMPLETE:
           // NSLog(@"framebuffer 创建成功");
            result = YES;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            errorMessage = @"Framebuffer不完整 缺失组件";
            result = NO;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
            errorMessage = @"Framebuffer 不完整, 附加图片必须要指定大小";
            result = NO;
            break;
        default:
            // 一般是超出GL纹理的最大限制
            errorMessage = @"未知错误 error !!!!";
            result = NO;
            break;
    }
    
    NSLog(@"%@",errorMessage ? errorMessage : @"");
    *error = errorMessage ? [NSError errorWithDomain:@"com.colin.error"
                                                code:status
                                            userInfo:@{@"ErrorMessage" : errorMessage}] : nil;
    
    return result;
}*/

-(void)startTimer{
    [self endTimer];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    [_displayLink addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
}

-(void)endTimer{
    if (_displayLink) {
       // [_displayLink invalidate];
       // _displayLink = nil;
    }
}

- (void)render {
  
    glDisable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    const CGFloat *color = CGColorGetComponents(self.backgroundColor.CGColor);
    if (color == NULL) {
        color = (CGFloat[]){1, 1, 1,1};
    }
    glClearColor(color[0], color[1], color[2], color[3]);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    glUseProgram(_programId);
    glUniform1i(glGetUniformLocation(_programId, "s_front"),0);
    glUniform1i(glGetUniformLocation(_programId, "s_back"),1);
    
    
    int u_mn = glGetUniformLocation(_programId, "u_mn");
    CGSize size = self.certerFrame.size;
    glUniform4f(u_mn,_m,_n,size.width,size.height);
    
    CGFloat x = self.frame.size.width/2;
    CGFloat y = self.frame.size.height/2;
    glm::mat4 ortho =  glm::ortho(-x,x,-y,y, (CGFloat)-100.f, (CGFloat)100.0f);
    
   
    int u_mvpMatrix = glGetUniformLocation(_programId, "u_mvpMatrix");
    glUniformMatrix4fv(u_mvpMatrix, 1,GL_FALSE, glm::value_ptr(ortho));
    
    int directionId = glGetUniformLocation(_programId, "direction");
    glm::vec2 dir(self.direction.x,self.direction.y);
    
    
    glm::vec2 normalDir = glm::normalize(dir);
    glUniform3f(directionId, normalDir.x, normalDir.y, self.radius);
    
    CGFloat _xx = dir.x >= 0 ? -1  : 1;
    CGFloat _yy = dir.y >= 0 ? -1  : 1;
    glm::vec2 startP = glm::vec2(_xx *self.certerFrame.size.width/2, _yy*self.certerFrame.size.height/2);
    
    
    startP += 0.7f * dir ;
    int pointId = glGetUniformLocation(_programId, "point");
    glUniform2f(pointId,startP.x,startP.y);
    
    
    glBindBuffer(GL_ARRAY_BUFFER,_vbo);
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(0,2, GL_FLOAT, GL_FALSE,4*sizeof(GLfloat),(void*)0);
    glVertexAttribPointer(1,2, GL_FLOAT, GL_FALSE,4*sizeof(GLfloat),(void*)(2*sizeof(GLfloat)));
        
    glDrawArraysInstanced(GL_TRIANGLE_FAN, 0, 4,_m*_n);
    
    // 做完所有绘制操作后，最终呈现到屏幕上
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


- (GLuint)generateTexture
{
   
    GLuint tex;
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return tex;
}
@end