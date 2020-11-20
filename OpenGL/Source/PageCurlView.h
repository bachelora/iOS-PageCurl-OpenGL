//
//  PageCurlView.h
//  OpenGL
//
//  Created by Mahoone on 2020/8/3.
//  Copyright © 2020 Mahoone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageCurlView;

@protocol PageCurlViewProtocol <NSObject>
@optional

///开始
- (void)pageCurlViewBeginDragging:(PageCurlView * _Nonnull )pageCurlView;

///拖动中
- (void)pageCurlViewDidDragging:(PageCurlView * _Nonnull )pageCurlView direction:(CGPoint)direction;

///结束,YES则翻牌成功，NO则翻牌失败
- (void)pageCurlViewEndDragging:(PageCurlView * _Nonnull )pageCurlView success:(BOOL)success;

@end


NS_ASSUME_NONNULL_BEGIN

@interface PageCurlView : UIView

@property (nonatomic, weak, nullable) id <PageCurlViewProtocol> delegate;

///卷曲的半径
@property(nonatomic,assign)CGFloat radius;

///必须使用此方法初始化
-(instancetype)initWithFrontImage:(UIImage*)front backImage:(UIImage*)back frame:(CGRect)frame;

///往指定的方向 卷曲
-(void)curlToDirection:(CGPoint)direction;

-(void)reset;

@end

NS_ASSUME_NONNULL_END
