//
//  SGBaseDrawViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseDrawViewController.h"
#import "PureLayout.h"


@interface SGBaseDrawViewController ()

@end

@implementation SGBaseDrawViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.webView.userInteractionEnabled = YES;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    [self drawSvgFileOnWebview];
    
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    
    
}

-(void)drawSvgFileOnWebview{}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

@end
