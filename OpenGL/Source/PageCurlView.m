//
//  PageCurlView.m
//  OpenGL
//
//  Created by Mahoone on 2020/8/3.
//  Copyright © 2020 Mahoone. All rights reserved.
//

#import "PageCurlView.h"
#import "OpenGLView.h"

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


typedef NS_ENUM(NSInteger,TouchState) {
    TouchStateBegin,
    TouchStateMove,
    TouchStateEnd
};

@interface PageCurlView()
{
@private
    OpenGLView *gkView;
    Region _region;
    CGPoint _startPoint;
    TouchState _touchState;
}
@end

@implementation PageCurlView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        CGFloat topInset = frame.size.height/3;
        CGFloat leftInset = frame.size.width/2;
        gkView = [OpenGLView alloc];
        gkView.front = [UIImage imageNamed:@"back.png"];
        gkView.back = [UIImage imageNamed:@"fornt.png"];
        gkView.certerFrame = CGRectMake(leftInset, topInset,frame.size.width, frame.size.height);
        gkView = [gkView initWithFrame:CGRectMake(-leftInset, -topInset, frame.size.width+2*leftInset, frame.size.height+2*topInset)];
        
        gkView.backgroundColor = [UIColor clearColor];
        [self addSubview:gkView];
    }
    return self;
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    _touchState = TouchStateBegin;
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
//gkView.isDraging = YES;
//[gkView startTimer];
    

    NSLog(@"===touchesBegan=%@===",NSStringFromCGPoint(_startPoint));
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    CGPoint location  = [touches.anyObject locationInView:self];

    //NSLog(@"touchesMoved===%@",NSStringFromCGPoint(location));
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
    
    gkView.radius = 10;
    gkView.direction = CGPointMake(location.x-_startPoint.x, -location.y+_startPoint.y);
    
    
    [gkView render];
    
     _touchState = TouchStateMove;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"==touchesEnded");
    [gkView endTimer];
//    gkView.isDraging = NO;
//    if (_touchState == TouchStateBegin || _region == RegionCenter) {
//        _touchState = TouchStateEnd;
//        return;
//    }
//    _touchState = TouchStateEnd;
//    [self uncurlPageAnimated:YES completion:^{
//    }];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"==touchesCancelled");
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
