//
//  ViewController.m
//  OpenGL
//
//  Created by Mahoone on 2020/8/3.
//  Copyright © 2020 Mahoone. All rights reserved.
//

#import "ViewController.h"
#import "PageCurlView.h"
@interface ViewController ()<PageCurlViewProtocol>
{
    PageCurlView *page;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBlueColor;
    
    UIButton *button = [UIButton.alloc initWithFrame:CGRectMake(10, 20, 50, 50)];;
    [button setTitle:@"Reset" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:button];
    [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];

    UIImage *back = [UIImage imageNamed:@"back.png"];
    UIImage *front = [UIImage imageNamed:@"fornt.png"];
    page = [PageCurlView.alloc initWithFrontImage:front backImage:back frame:CGRectMake(100, 200, 150, 250)];
//    page.delegate = self;
    [self.view addSubview:page];
    
//    [page curlToDirection:CGPointMake(180, -140)];
}

//Reset
-(void)btnClick{
    [page reset];
}

#pragma mark - delegate
-(void)pageCurlViewEndDragging:(PageCurlView *)pageCurlView success:(BOOL)success{
    NSLog(@"===========EndDragging===success:%d",success);
}

-(void)pageCurlViewDidDragging:(PageCurlView *)pageCurlView direction:(CGPoint)direction{
    NSLog(@"====DidDragging===directon:%@",NSStringFromCGPoint(direction));
}

-(void)pageCurlViewBeginDragging:(PageCurlView *)pageCurlView{
    NSLog(@"=========BeginDragging");
}

@end
