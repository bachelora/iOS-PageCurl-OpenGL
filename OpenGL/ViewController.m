//
//  ViewController.m
//  OpenGL
//
//  Created by Mahoone on 2020/8/3.
//  Copyright © 2020 Mahoone. All rights reserved.
//

#import "ViewController.h"
#import "PageCurlView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.grayColor;
    PageCurlView *page = [PageCurlView.alloc initWithFrame:CGRectMake(100, 200, 150, 250)];
    [self.view addSubview:page];
//    page.backgroundColor = UIColor.blueColor;
    // Do any additional setup after loading the view.
}


@end
