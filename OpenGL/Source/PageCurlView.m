//
//  PageCurlView.m
//  OpenGL
//
//  Created by Mahoone on 2020/8/3.
//  Copyright © 2020 Mahoone. All rights reserved.
//

#import "PageCurlView.h"
#import "OpenGLView.h"

#define kRadiusDefault    (10)

typedef NS_ENUM(NSInteger,Region) {
    RegionTopLeft = 0b0101,
    RegionTopCenter = 0b1001,
    RegionTopRight = 0b1101,
    RegionLeftCenter = 0b0110,
    RegionRightCenter = 0b1110,
    RegionBottomLeft = 0b0111,
    RegionBottomCenter = 0b1011,
    RegionBottomRight = 0b1111,
    RegionCenter = 0b1010 //ignore
};



@interface PageCurlView()
{
@private
    OpenGLView *gkView;
    Region _region;
    CGPoint _startPoint;
}
@end

@implementation PageCurlView

-(instancetype)initWithFrontImage:(UIImage*)front backImage:(UIImage*)back frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        CGFloat topInset = frame.size.height/3;
        CGFloat leftInset = frame.size.width/2;
        gkView = [OpenGLView alloc];
        gkView.front = back;
        gkView.back = front;
        gkView.frontFacing = NO;
        gkView.centerFrame = CGRectMake(leftInset, topInset,frame.size.width, frame.size.height);
        gkView = [gkView initWithFrame:CGRectMake(-leftInset, -topInset, frame.size.width+2*leftInset, frame.size.height+2*topInset)];

        gkView.backgroundColor = [UIColor clearColor];
        self.radius = kRadiusDefault;
        [self addSubview:gkView];
        
        CGFloat x=5,y=10,w=20,h=30;
        gkView.pFrames = @[[NSValue valueWithCGRect:CGRectMake(x,y,w,h)],
                           [NSValue valueWithCGRect:CGRectMake(frame.size.width-x-w, frame.size.height-y-h, w,h)],
                           [NSValue valueWithCGRect:CGRectMake(x, frame.size.height-y-h, w,h)],
                           [NSValue valueWithCGRect:CGRectMake(frame.size.width-x-w, y, w,h)],
                          ];
    }
    return self;
}

-(void)reset{
    gkView.frontFacing = NO;
    self.userInteractionEnabled = YES;
    [self curlToDirection:CGPointZero];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(pageCurlViewBeginDragging:)]) {
        [self.delegate pageCurlViewBeginDragging:self];
    }
    
    _startPoint  = [touches.anyObject locationInView:self];
    _region = [self regionFromPoint:_startPoint];
   
    CGPoint start;
    switch (_region) {
        case RegionTopLeft:
            start = CGPointZero;
            break;
        case RegionTopCenter:
            start = CGPointMake(_startPoint.x, 0);
            break;
        case RegionTopRight:
             start = CGPointMake(self.bounds.size.width, 0);
            break;
        case RegionLeftCenter:
            start = CGPointMake(0,_startPoint.y);
            break;
        case RegionRightCenter:
            start = CGPointMake(self.bounds.size.width,_startPoint.y);
            break;
        case RegionBottomLeft:
            start = CGPointMake(0,self.bounds.size.height);
            break;
        case RegionBottomCenter:
            start = CGPointMake(_startPoint.x,self.bounds.size.height);
            break;
        case RegionBottomRight:
            start = CGPointMake(self.bounds.size.width,self.bounds.size.height);
            break;
        default:
            return;
    }
    NSLog(@"===touchesBegan=%@===",NSStringFromCGPoint(_startPoint));
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    if (!self.userInteractionEnabled) {
        return;
    }
    
    CGPoint location  = [touches.anyObject locationInView:self];

    switch (_region) {
        case RegionTopCenter:case RegionBottomCenter:
            location.x = _startPoint.x;
            break;
        case RegionRightCenter:case RegionLeftCenter:
            location.y = _startPoint.y;
            break;
        case RegionCenter:
            return;
        default:
            break;
    }
    
    CGPoint dir = CGPointMake(location.x-_startPoint.x, -location.y+_startPoint.y);
    if (fabs(dir.x) >= self.bounds.size.width*0.75 || fabs(dir.y) >= self.bounds.size.height*0.75) {//成功翻牌
        dir = CGPointZero;
        gkView.frontFacing = YES;
        if ([self.delegate respondsToSelector:@selector(pageCurlViewEndDragging:success:)] && self.userInteractionEnabled) {
            [self.delegate pageCurlViewEndDragging:self success:YES];
        }
        self.userInteractionEnabled = NO;//禁止再次操作
    }
    
    [self curlToDirection:dir];
    
    if ([self.delegate respondsToSelector:@selector(pageCurlViewDidDragging:direction:)] && self.userInteractionEnabled) {
        [self.delegate pageCurlViewDidDragging:self direction:gkView.direction];
    }
}

-(void)curlToDirection:(CGPoint)direction{
    gkView.radius = self.radius;
    gkView.direction = direction;
    [gkView render];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"==touchesEnded");
    [self curlBack];
}

-(void)curlBack{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self curlToDirection:CGPointZero];
        
        if ([self.delegate respondsToSelector:@selector(pageCurlViewEndDragging:success:)] && self.userInteractionEnabled) {
            [self.delegate pageCurlViewEndDragging:self success:NO];
        }
    });
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"==touchesCancelled");
    [self curlBack];
}

-(Region)regionFromPoint:(CGPoint) point{
    int x = 0;
    int y = 0;
    
    if (point.x < self.bounds.size.width / 3) {
        x = 1;
    }else if (point.x < self.bounds.size.width * 2 / 3) {
        x = 2;
    }else{
        x = 3;
    }
    
    if (point.y < self.bounds.size.height / 3) {
        y = 1;
    }else if (point.y < self.bounds.size.height * 2 / 3) {
        y = 2;
    }else{
        y = 3;
    }
    
    return (x<<2) | y;
}

@end
