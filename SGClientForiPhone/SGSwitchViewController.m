//
//  SGSwitchViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/8/24.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGSwitchViewController.h"
#import "SGSwitchBussiness.h"
#import "SGDeviceBussiness.h"



#define DrawWhiteCircle(x,y,r) [NSString stringWithFormat:@"<circle cx=\"%f\" cy=\"%f\" r=\"%f\" style=\"fill:#0061b0;stroke:white;stroke-width:1;fill-opacity:0.0\" />",x,y,r]

@interface SGSwitchViewController ()

@property(nonatomic,assign) float leftMargin;
@property(nonatomic,assign) float topMargin;


@property(nonatomic,assign) float offsetY;
@property(nonatomic,assign) float offsetX;

@end

@implementation SGSwitchViewController

-(instancetype)init{
    
    if (self = [super init]) {
        
        _leftMargin = 20;
        _topMargin = 50;
        _offsetY = _topMargin;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView setScalesPageToFit:YES];
    
    self.title = [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:self.deviceId];
    
}

-(void)drawSvgFileOnWebview{
    
    NSMutableString* svgStr = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" standalone=\"no\"?><!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">"];
    
    [svgStr appendString:@"<svg width=\"##@@@##\" height=\"++@@@++\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">"];
    
    [svgStr appendString:@"<defs><style type=\"text/css\"><![CDATA[ rect {fill:white;stroke:black;stroke-width:2;opacity:0.1;}]]></style>"];
    
    [svgStr appendString:@"<marker id=\"triangle\" viewBox=\"0 0 10 10\" refX=\"0\" refY=\"5\" markerUnits=\"strokeWidth\" markerWidth=\"7\" markerHeight=\"10\" orient=\"auto\"> <path d=\"M 0 0 L 10 5 L 0 10 z\" /> </marker></defs>"];
    
    [svgStr appendString:[self generateSvg]];
    [svgStr appendString:@"</svg>"];
    NSString* result = [NSString stringWithString:svgStr];
    result = [result stringByReplacingOccurrencesOfString:@"++@@@++" withString:[NSString stringWithFormat:@"%f",(self.offsetY < self.offsetX) ? self.offsetX : self.offsetY]];
    result = [result stringByReplacingOccurrencesOfString:@"##@@@##" withString:[NSString stringWithFormat:@"%f",self.offsetX]];
    result = [result stringByReplacingOccurrencesOfString:@"(null)" withString:@"--"];
    
    NSData *svgData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                        objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:@"device.svg"];
    [svgData writeToFile:dbPath atomically:YES];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [[NSURL alloc] initFileURLWithPath:resourcePath isDirectory:YES];
    [self.webView   loadData:svgData
                    MIMEType:@"image/svg+xml"
            textEncodingName:@"UTF-8"
                     baseURL:baseURL];
}

-(NSString*)generateSvg{
    
    NSArray* list  = [[SGSwitchBussiness sharedSGSwitchBussiness] queryAllPortListByDeviceId:self.deviceId];
    NSMutableString* svgStr = [NSMutableString string];

    int rowCount = ceil(list.count/2.0);
    
    float circleMargin = 20;
    float circleD = 60;
    
    float cubicleWidth = 100;
    float cubicleHeight = 60;
    float cubicleLineLen = 100;

    //矩形
    
    float mainWidth = circleMargin * (rowCount + 1) + circleD * rowCount;
    self.offsetX = mainWidth + 2 * self.leftMargin;
    self.offsetY = self.topMargin * 2 + circleD * 3 + cubicleLineLen * 2 + cubicleHeight * 2;
    
    [svgStr appendString:DrawRect(self.leftMargin,
                                  self.topMargin + cubicleHeight + cubicleLineLen,
                                  mainWidth,
                                  circleD * 3)];
    
    
    CGSize size = [[[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:self.deviceId] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];

    //设备
    [svgStr appendString:DrawText(self.leftMargin + mainWidth / 2.0 - size.width / 2.0,
                                  self.topMargin + cubicleHeight + cubicleLineLen + circleD + 30,17,
                                  @"white",
                                  @"italic",
                                  [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:self.deviceId])];
    
    //上排
    for(int i = 1; i <= rowCount; i++){
        
        float offsetCircleX = self.leftMargin + i * circleMargin + (i - 0.5) * circleD;
        float offsetCircleY = self.topMargin + cubicleHeight + cubicleLineLen + circleD/2.0;

        [svgStr appendString:DrawWhiteCircle(offsetCircleX,
                                             offsetCircleY,
                                             circleD/2.0)];
        NSArray* a = list[i-1];
        for(int i = 0; i < 2; i++){
            SGPortInfo *p = a[i];
            [svgStr appendString:DrawText(offsetCircleX + 10 - circleD/2.0 ,
                                          offsetCircleY + i * 20,
                                          17,
                                          @"white",
                                          @"italic",
                                          p.name)];
        }
    }
    
    //下排
    for(int i = 1; i <= list.count - rowCount; i++){
        
        float offsetCircleX = self.leftMargin + i * circleMargin + (i - 0.5) * circleD;
        float offsetCircleY = self.topMargin + cubicleHeight + cubicleLineLen + circleD*3 - circleD/2.0;
        
        [svgStr appendString:DrawWhiteCircle(offsetCircleX,
                                             offsetCircleY,
                                             circleD/2.0)];
        NSArray* a = list[list.count - rowCount + i - 1];
        for(int i = 0; i < 2; i++){
            SGPortInfo *p = a[i];
            [svgStr appendString:DrawText(offsetCircleX + 10 - circleD/2.0 ,
                                          offsetCircleY + i * 20,
                                          17,
                                          @"white",
                                          @"italic",
                                          p.name)];
        }
        
    }
    
    
    return svgStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
