//
//  OpenGLView.h
//  OpenGL
//
//  Created by Mahoone on 2020/8/3.
//  Copyright © 2020 Mahoone. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface OpenGLView : UIView
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint       _framebuffer;
    GLuint       _renderbuffer;
    GLuint       _vbo;
    
    GLuint _m,_n;
    GLuint _textureFront,_textureBack;

}

@property(nonatomic,strong)NSArray <NSValue*>*pFrames;

@property(nonatomic,assign)BOOL frontFacing;

@property(nonatomic,strong)UIImage *front;
@property(nonatomic,strong)UIImage *back;
@property(nonatomic,assign)CGRect centerFrame;


- (void)render;

@property(nonatomic,assign)CGFloat radius;
@property(nonatomic,assign)CGPoint direction;

@end

NS_ASSUME_NONNULL_END
