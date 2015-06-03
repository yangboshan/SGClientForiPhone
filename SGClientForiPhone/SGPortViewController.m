//
//  SGPortViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/18.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGPortViewController.h"
#import "SGPortPageBussiness.h"
#import "SGPortPageDataModel.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"


@interface SGPortViewController ()

@property(nonatomic,strong) NSArray* result;
@property(nonatomic,assign) float width;
@property(nonatomic,assign) float cubicleWidth;

@property(nonatomic,assign) BOOL showAll;

@end

@implementation SGPortViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSString* n = [self.deviceName isEqual:[NSNull null]] ? @"" : self.deviceName;
    self.title = [NSString stringWithFormat:@"%@虚端子图",n];
    
    self.showAll = NO;
    
    __weak typeof(self) weakSelf = self;
    
    [[SGPortPageBussiness sharedSGPortPageBussiness] setController:self];
    [[SGPortPageBussiness sharedSGPortPageBussiness] setMultiFlag:NO];
    [[SGPortPageBussiness sharedSGPortPageBussiness] setCableType:self.cableType];
    [[SGPortPageBussiness sharedSGPortPageBussiness] queryResultWithType:0 portId:self.portId complete:^(NSArray *result) {
        SGPortPageDataModel*model = result[0];
        NSString* n = model ? model.mainDeviceName : @"";
        weakSelf.title = [NSString stringWithFormat:@"%@虚端子图",n];
        weakSelf.result = result;
        [weakSelf loadSVG];
    }];
}

-(void)loadSVG{
    
    margin_x_ = 20;
    margin_y_ = 50;
    cWidth_   = 240;
    cHeight_  = 30;
    linelen_  = 150;
    offsetY_ = 0;
    
    NSMutableString* svgStr = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" standalone=\"no\"?><!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">"];
    
    [svgStr appendString:@"<svg width=\"##@@@##\" height=\"++@@@++\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">"];
    
    [svgStr appendString:@"<defs><style type=\"text/css\"><![CDATA[ rect {fill:white;stroke:black;stroke-width:2;opacity:0.1;}]]></style>"];
    
    [svgStr appendString:@"<marker id=\"triangle\" viewBox=\"0 0 10 10\" refX=\"0\" refY=\"5\" markerUnits=\"strokeWidth\" markerWidth=\"5\" markerHeight=\"4\" orient=\"auto\"> <path d=\"M 0 0 L 10 5 L 0 10 z\" /> </marker></defs>"];
    
    self.cubicleWidth = MAX([self getCubicleWidth:self.result[0]], [self getCubicleWidth:self.result[1]]);
    self.cubicleWidth+=20;
    
    if ([self.cableType rangeOfString:@"GOOSE"].location!=NSNotFound) {
        [svgStr appendString:[self generateDrawString:self.result[0]]];
    }
    if ([self.cableType rangeOfString:@"SV"].location!=NSNotFound) {
        [svgStr appendString:[self generateDrawString:self.result[1]]];
    }
    [svgStr appendString:@"</svg>"];
    
    NSString* result = [NSString stringWithString:svgStr];
    
    result = [result stringByReplacingOccurrencesOfString:@"++@@@++" withString:[NSString stringWithFormat:@"%f",offsetY_+200]];
    result = [result stringByReplacingOccurrencesOfString:@"##@@@##" withString:[NSString stringWithFormat:@"%f",self.width]];
    
    result = [result stringByReplacingOccurrencesOfString:@"(null)" withString:@"--"];
    
    NSData *svgData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                        objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:@"vport.svg"];
    [svgData writeToFile:dbPath atomically:YES];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [[NSURL alloc] initFileURLWithPath:resourcePath isDirectory:YES];
    [self.webView   loadData:svgData
                    MIMEType:@"image/svg+xml"
            textEncodingName:@"UTF-8"
                     baseURL:baseURL];
    
}


float margin_x_ = 20;
float margin_y_ = 50;
float cWidth_   = 240;
float cHeight_  = 30;
float linelen_  = 150;
float offsetY_ = 0;


-(BOOL)checkIfExists:(SGPortPageDataModel*)model{
    BOOL flag = NO;
    for(SGPortPageChildData* child in model.leftChilds){
        if (child.mainProDes.count||child.cntedProDes.count) {
            flag = YES;
        }
    }
    
    for(SGPortPageChildData* child in model.rightChilds){
        if (child.mainProDes.count||child.cntedProDes.count) {
            flag = YES;
        }
    }
    return flag;
}

-(float)getCubicleWidth:(SGPortPageDataModel*)dataModel{
    
    NSMutableArray* lensSet1 = [NSMutableArray array];
    NSMutableArray* lensSet2 = [NSMutableArray array];
    
    float deviceLen = [self getMaxLength:dataModel.mainDeviceName];
    
    if(dataModel.leftChilds.count){
        for(SGPortPageChildData *child in dataModel.leftChilds){
            
            if ([self getMaxLength:child.cntedDeviceName]>deviceLen) {
                deviceLen = [self getMaxLength:child.cntedDeviceName];
            }
            
            
            for(int i = 0; i < child.mainProDes.count; i++){
                [lensSet1 addObject:[NSNumber numberWithFloat:[self getMaxLength2:child.mainProDes[i]]]];
            }
            [lensSet1 addObject:@0];
        }
    }
    if(dataModel.rightChilds.count){
        for(SGPortPageChildData *child in dataModel.rightChilds){
            
            if ([self getMaxLength:child.cntedDeviceName]>deviceLen) {
                deviceLen = [self getMaxLength:child.cntedDeviceName];
            }
            
            for(int i = 0; i < child.mainProDes.count; i++){
                [lensSet2 addObject:[NSNumber numberWithFloat:[self getMaxLength2:child.mainProDes[i]]]];
            }
            [lensSet2 addObject:@0];
        }
    }
    
    float max = 0;
    for(int i = 0; i < MAX(lensSet1.count,lensSet2.count);i++){
        float len = ((i < lensSet1.count)?[lensSet1[i] floatValue]:0) + ((i < lensSet2.count)?[lensSet2[i] floatValue]:0);
        if (len > max) {
            max = len;
        }
    }
    
    return MAX(max, deviceLen);
}
-(NSString*)generateDrawString:(SGPortPageDataModel*)dataModel{
    
    if (![self checkIfExists:dataModel]) {
        return @"";
    }
    
    NSMutableString *svgStr = [NSMutableString new];
    
    if ([dataModel.type isEqualToString:@"1"]) {
        [svgStr appendString:[NSString stringWithFormat:@"<line x1=\"%f\" y1=\"%f\" x2=\"%f\" y2=\"%f\" style=\"stroke-dasharray: 9, 5;stroke: gray; stroke-width: 2;\"/>",margin_x_,
                              offsetY_-5,
                              margin_x_ + 2000,
                              offsetY_]];
    }
    
    BOOL hasLeft = NO;//是否有左连接
    BOOL hasRight = NO;//是否有右连接
    
    NSUInteger leftTotal = 0; //中间设备内左边列表数目
    NSUInteger rightTotal = 0;//中间设备内右边列表数目
    
    float maxLeft = 0; //中间设备内左边列表最长长度
    float maxRight = 0;//中间设备内右边列表最长长度
    
    float maxLeftL = 0; //左连接设备的最长长度
    float maxRightR = 0;//右连接设备的最长长度
    
    if(dataModel.leftChilds.count){
        
        for(SGPortPageChildData *child in dataModel.leftChilds){
            if (child.mainProDes.count) {
                hasLeft = YES;
            }
            
            leftTotal += child.mainProDes.count;
        }
    }
    
    if (dataModel.rightChilds.count) {
        
        for(SGPortPageChildData *child in dataModel.rightChilds){
            
            if (child.mainProDes.count) {
                hasRight = YES;
            }
            
            rightTotal += child.mainProDes.count;
        }
    }
    
    
    maxLeft = self.cubicleWidth;
    maxRight = self.cubicleWidth;
    maxLeftL = self.cubicleWidth;
    maxRightR = self.cubicleWidth;
    
    if ( margin_x_ + maxLeft + maxLeftL + maxRight + maxRightR + 2*linelen_ + 100 > self.width) {
        self.width = margin_x_ + maxLeft + maxLeftL + maxRight + maxRightR + 2*linelen_ + 100;
    }
    
    //画主屏
    
    //左右最多行数
    NSUInteger mainHeight = MAX(leftTotal, rightTotal);
    float height = 0;
    
    //计算整体高度
    if (mainHeight == leftTotal) {
        height = dataModel.leftChilds.count*40 + (dataModel.leftChilds.count - 1)*cHeight_ + mainHeight*cHeight_;
    }
    if (mainHeight == rightTotal) {
        height = dataModel.rightChilds.count*40 + (dataModel.rightChilds.count - 1)*cHeight_ + mainHeight*cHeight_;
    }
    
    //主设左边距
    float margin = (hasLeft)? margin_x_ + maxLeftL + linelen_ : margin_x_;
    
    //设备名称宽度
    float titleL = [self getMaxLength:dataModel.mainDeviceName];
    
    //取最长宽度
    float width = MAX(titleL, self.cubicleWidth);
    
    NSString* type = [dataModel.type isEqualToString:@"0"] ? @"GOOSE虚端子连接" : @"SV虚端子连接";
    [svgStr appendString:DrawText(margin_x_,
                                  margin_y_ + offsetY_ - 20 ,18,
                                  @"gray",
                                  @"italic",
                                  type)];
    
    //画主设
    [svgStr appendString:DrawRectWD(margin,
                                   margin_y_ + offsetY_,
                                   width,
                                   height-10,dataModel.mainPortId)];
    
    //主设名称
    [svgStr appendString:DrawText(margin,
                                  margin_y_ + offsetY_ + 20 ,17,
                                  @"white",
                                  @"italic",
                                  dataModel.mainDeviceName)];
    
    
    //画左边
    if (hasLeft) {
        float offsetLeft = margin_y_ + offsetY_;
        
        for(SGPortPageChildData *child in dataModel.leftChilds){
            
            if (!child.mainProDes.count) {
                continue;
            }
            
            [svgStr appendString:DrawRect(margin_x_,
                                          offsetLeft,
                                          maxLeftL,
                                          (child.cntedProDes.count+1)*cHeight_ )];
            
            [svgStr appendString:DrawText(margin_x_,
                                          offsetLeft + 20 ,17,
                                          @"white",
                                          @"italic",
                                          child.cntedDeviceName)];
            
            NSInteger index = 0;
            offsetLeft += 40;
            for(NSString* proDes in child.mainProDes){
                
                [svgStr appendString:DrawTextR(margin_x_ + maxLeftL -10,
                                               offsetLeft,11,
                                               @"white",
                                               @"italic",
                                               child.cntedProDes[index])];
                
                [svgStr appendString:DrawText(margin_x_ + maxLeftL + linelen_,
                                              offsetLeft,11,
                                              @"white",
                                              @"italic",
                                              proDes)];
                
                [svgStr appendString:DrawLineArrow(margin_x_ + maxLeftL + 5,
                                                   offsetLeft-2,
                                                   margin_x_ + maxLeftL + linelen_-15,
                                                   offsetLeft-2,@"")];
                
                [svgStr appendString:DrawCircle(margin_x_ + maxLeftL+5,offsetLeft-2,3.0)];
                [svgStr appendString:DrawCircle(margin_x_ + maxLeftL + linelen_-5,offsetLeft-2,3.0)];
                
                [svgStr appendString:DrawText(margin_x_ + maxLeftL + linelen_-60,
                                              offsetLeft-10,11,
                                              @"gray",
                                              @"italic",
                                              child.centerPortId)];
                
                [svgStr appendString:DrawText(margin_x_ + maxLeftL + 5,
                                              offsetLeft-10,11,
                                              @"gray",
                                              @"italic",
                                              child.cntedPortId)];
                
                
                offsetLeft += cHeight_;
                index++;
            }
            offsetLeft+=cHeight_;
        }
    }
    
    //画右边
    if (hasRight) {
        float offsetRight = margin_y_ + offsetY_;
        
        for(SGPortPageChildData *child in dataModel.rightChilds){
            if (!child.mainProDes.count) {
                continue;
            }
            
            [svgStr appendString:DrawRect(margin + width + linelen_,
                                          offsetRight,
                                          maxRightR,
                                          (child.cntedProDes.count+1)*cHeight_ )];
            
            [svgStr appendString:DrawText(margin + width + linelen_,
                                          offsetRight + 20 ,17,
                                          @"white",
                                          @"italic",
                                          child.cntedDeviceName)];
            offsetRight += 40;
            NSInteger index = 0;
            for(NSString* proDes in child.mainProDes){
                
                [svgStr appendString:DrawTextR(margin + width -10,
                                               offsetRight,11,
                                               @"white",
                                               @"italic",
                                               proDes)];
                
                [svgStr appendString:DrawText(margin + width + linelen_,
                                              offsetRight,11,
                                              @"white",
                                              @"italic",
                                              child.cntedProDes[index])];
                
                [svgStr appendString:DrawLineArrow(margin + width + 5,
                                                   offsetRight-2,
                                                   margin + width + linelen_-15,
                                                   offsetRight-2,@"")];
                [svgStr appendString:DrawCircle(margin + width+5,offsetRight-2,3.0)];
                [svgStr appendString:DrawCircle(margin + width + linelen_-5,offsetRight-2,3.0)];
                
                
                [svgStr appendString:DrawText(margin + width + 5,
                                              offsetRight-10,11,
                                              @"gray",
                                              @"italic",
                                              child.centerPortId)];
                
                [svgStr appendString:DrawText(margin + width + linelen_- 60,
                                              offsetRight-10,11,
                                              @"gray",
                                              @"italic",
                                              child.cntedPortId)];
                
                
                offsetRight += cHeight_;
                index++;
            }
            offsetRight+=cHeight_;
        }
    }
    
    
    offsetY_ += height;
    offsetY_ += 100;
    
    return svgStr;
}

-(float)getMaxLengthForList:(NSArray*)proDes{
    
    float maxLength = 0;
    
    for(NSString* item in proDes){
        
        float len = [item sizeWithFont:[UIFont systemFontOfSize:11.0]].width;
        
        if (len > maxLength) {
            maxLength = len;
        }
    }
    return maxLength;
}

-(float)getMaxLength:(NSString*)sta{
    return [sta sizeWithFont:[UIFont systemFontOfSize:17.0]].width;
}

-(float)getMaxLength2:(NSString*)sta{
    return [sta sizeWithFont:[UIFont systemFontOfSize:11.0]].width;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString* _url = [request URL].description;
    NSLog(@"%@",_url);
    
    if ([_url rangeOfString:@"@@@@"].location != NSNotFound) {
        
        CATransition *animation = [CATransition animation];
        animation.delegate = self;
        animation.duration = 0.5;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = @"cube";
        
        NSString *portId = [[_url componentsSeparatedByString:@"@@@@"] objectAtIndex:1];
        
        __weak typeof(self) weakSelf = self;
        [[SGPortPageBussiness sharedSGPortPageBussiness] setController:self];
        
        if (!self.showAll) {
            
            [[SGPortPageBussiness sharedSGPortPageBussiness] queryResultWithType:1 portId:portId complete:^(NSArray *result) {
                weakSelf.result = result;
                [weakSelf loadSVG];
            }];
            
            self.showAll = YES;
            animation.subtype = kCATransitionFromLeft;
            
        }else{
            [[SGPortPageBussiness sharedSGPortPageBussiness] queryResultWithType:0 portId:portId complete:^(NSArray *result) {
                weakSelf.result = result;
                [weakSelf loadSVG];
            }];
            
            self.showAll = NO;
            animation.subtype = kCATransitionFromRight;
        }
        
        
        [[self.view layer] addAnimation:animation forKey:@"animation"];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
@end