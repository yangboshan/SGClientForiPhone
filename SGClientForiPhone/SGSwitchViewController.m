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



#define DrawWhiteCircle(x,y,r) [NSString stringWithFormat:@"<circle cx=\"%f\" cy=\"%f\" r=\"%f\" style=\"fill:none;stroke:white;stroke-width:1;fill-opacity:1.0\" />",x,y,r]
#define DrawPolyline(x1,y1,x2,y2,x3,y3) [NSString stringWithFormat:@"<polyline points=\"%f,%f %f,%f %f,%f\" style=\"fill:none;stroke:gray;stroke-width:1\" marker-start=\"url(#triangle)\" />",x1,y1,x2,y2,x3,y3]


@interface SGSwitchViewController ()

@property(nonatomic,assign) float leftMargin;
@property(nonatomic,assign) float marginOffset;

@property(nonatomic,assign) float topMargin;


@property(nonatomic,assign) float offsetY;
@property(nonatomic,assign) float offsetX;


@end

@implementation SGSwitchViewController

-(instancetype)init{
    
    if (self = [super init]) {
        
        _leftMargin = 300;
        _marginOffset = 20;
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
    
    [svgStr appendString:@"<marker id=\"triangle\" viewBox=\"0 0 20 10\" refX=\"0\" refY=\"5\" markerUnits=\"strokeWidth\" markerWidth=\"15\" markerHeight=\"10\" orient=\"auto\"> <path d=\"M 0 5 L 20 0 L 20 10 z\" /> </marker></defs>"];
    
    [svgStr appendString:[self generateSvg]];
    [svgStr appendString:@"</svg>"];
    NSString* result = [NSString stringWithString:svgStr];
    result = [result stringByReplacingOccurrencesOfString:@"++@@@++" withString:[NSString stringWithFormat:@"%f",(self.offsetY < self.offsetX) ? self.offsetX : self.offsetY]];
    result = [result stringByReplacingOccurrencesOfString:@"##@@@##" withString:[NSString stringWithFormat:@"%f",self.offsetX]];
    result = [result stringByReplacingOccurrencesOfString:@"(null)" withString:@"--"];
    
    NSData *svgData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                        objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:@"switch.svg"];
    [svgData writeToFile:dbPath atomically:YES];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [[NSURL alloc] initFileURLWithPath:resourcePath isDirectory:YES];
    [self.webView   loadData:svgData
                    MIMEType:@"image/svg+xml"
            textEncodingName:@"UTF-8"
                     baseURL:baseURL];
}

-(NSString*)generateSvg{
    
    //port列表
    NSArray* list  = [[SGSwitchBussiness sharedSGSwitchBussiness] queryAllPortListByDeviceId:self.deviceId];
    NSMutableString* svgStr = [NSMutableString string];

    //单行数目
    int rowCount = ceil(list.count/2.0);
    
    int halfRowCount  = ceil(rowCount/2.0);
    
    float baseLength = 50;
    float lineOffset = 35;
    float textMargin = 15;
    

    float halfHeight = baseLength + lineOffset * halfRowCount;
    float circleMargin = 20;
    float circleD = 60;
    
    

    //矩形
    float mainWidth = circleMargin * (rowCount + 1) + circleD * rowCount;
    self.offsetX = mainWidth + 2 * self.leftMargin;
    self.offsetY = self.topMargin * 2 + circleD * 3 + halfHeight * 2;
    
    [svgStr appendString:DrawRect(self.leftMargin,
                                  self.topMargin + halfHeight,
                                  mainWidth,
                                  circleD * 3)];
    
    
    CGSize size = [[[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:self.deviceId] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];

    //设备
    [svgStr appendString:DrawText(self.leftMargin + mainWidth / 2.0 - size.width / 2.0,
                                  self.topMargin + halfHeight + circleD + 30,17,
                                  @"white",
                                  @"italic",
                                  [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:self.deviceId])];
    

    //**********************************************************************************************************************
    //画左上
    int topLeftOffset = 0;
    for(int i = 1; i <= halfRowCount; i++){
        float offsetCircleX = self.leftMargin + i * circleMargin + (i - 0.5) * circleD;
        float offsetCircleY = self.topMargin + halfHeight + circleD/2.0;
        
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
        NSString* retV = [self getConnectionDescByInfosetList:[[SGSwitchBussiness sharedSGSwitchBussiness] queryPortConnectionInfoByPort1:[a[0] port_id] port2:[a[1] port_id]] ports:a];
        
        if (retV) {
            
            topLeftOffset++;
            
            [svgStr appendString:DrawPolyline(self.marginOffset, self.topMargin + halfHeight - baseLength - lineOffset * topLeftOffset,
                                              offsetCircleX, self.topMargin + halfHeight - baseLength - lineOffset * topLeftOffset,
                                              offsetCircleX, self.topMargin + halfHeight)];
            
            
            [svgStr appendString:DrawText(self.marginOffset + textMargin,
                                          self.topMargin + halfHeight - baseLength - lineOffset * topLeftOffset - 5,15,
                                          @"gray",
                                          @"italic",
                                          retV)];
        }
    }
    //**********************************************************************************************************************
    //画右上
    int topRightOffset = 0;
    for(int i = rowCount; i >= halfRowCount + 1; i--){
        
        float offsetCircleX = self.leftMargin + i * circleMargin + (i - 0.5) * circleD;
        float offsetCircleY = self.topMargin + halfHeight + circleD/2.0;

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
        
        
        NSString* retV = [self getConnectionDescByInfosetList:[[SGSwitchBussiness sharedSGSwitchBussiness] queryPortConnectionInfoByPort1:[a[0] port_id] port2:[a[1] port_id]] ports:a];
        
        if (retV) {
            topRightOffset++;
            
            [svgStr appendString:DrawPolyline(2*self.leftMargin + mainWidth - self.marginOffset, self.topMargin + halfHeight - baseLength - lineOffset * topRightOffset,
                                              offsetCircleX, self.topMargin + halfHeight - baseLength - lineOffset * topRightOffset,
                                              offsetCircleX, self.topMargin + halfHeight)];
            
            [svgStr appendString:DrawTextR(2*self.leftMargin + mainWidth - self.marginOffset - textMargin,
                                          self.topMargin + halfHeight - baseLength - lineOffset * topRightOffset - 5,15,
                                          @"gray",
                                          @"italic",
                                          retV)];
        }
    }
    //**********************************************************************************************************************
    //画左下
    float bottomLeftOffset = 0;
    
    for(int i = 1; i <= halfRowCount; i++){
        
        float offsetCircleX = self.leftMargin + i * circleMargin + (i - 0.5) * circleD;
        float offsetCircleY = self.topMargin +halfHeight + circleD*3 - circleD/2.0;
        
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
        
        NSString* retV = [self getConnectionDescByInfosetList:[[SGSwitchBussiness sharedSGSwitchBussiness] queryPortConnectionInfoByPort1:[a[0] port_id] port2:[a[1] port_id]] ports:a];
        
        if (retV) {
            
            bottomLeftOffset++;
            
            [svgStr appendString:DrawPolyline(self.marginOffset, self.topMargin + halfHeight + circleD * 3 + baseLength +  lineOffset * bottomLeftOffset,
                                              offsetCircleX, self.topMargin + halfHeight + circleD * 3 + baseLength +  lineOffset * bottomLeftOffset,
                                              offsetCircleX, self.topMargin + halfHeight + circleD * 3)];
            
            [svgStr appendString:DrawText(self.marginOffset + textMargin,
                                           self.topMargin + halfHeight + circleD * 3 + baseLength +  lineOffset * bottomLeftOffset - 5,15,
                                           @"gray",
                                           @"italic",
                                           retV)];
        }
        
    }
    
    //**********************************************************************************************************************
    //画右下
    float bottomRightOffset = 0;
    
    for(int i = rowCount; i >= halfRowCount + 1; i--){
        float offsetCircleX = self.leftMargin + i * circleMargin + (i - 0.5) * circleD;
        float offsetCircleY = self.topMargin +halfHeight + circleD*3 - circleD/2.0;
        
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
        
        NSString* retV = [self getConnectionDescByInfosetList:[[SGSwitchBussiness sharedSGSwitchBussiness] queryPortConnectionInfoByPort1:[a[0] port_id] port2:[a[1] port_id]] ports:a];
        
        if (retV) {
            
            bottomRightOffset++;
            
            [svgStr appendString:DrawPolyline(2*self.leftMargin + mainWidth - self.marginOffset, self.topMargin + halfHeight + circleD * 3 + baseLength +  lineOffset * bottomRightOffset,
                                              offsetCircleX, self.topMargin + halfHeight + circleD * 3 + baseLength +  lineOffset * bottomRightOffset,
                                              offsetCircleX, self.topMargin + halfHeight + circleD * 3)];
            
            [svgStr appendString:DrawTextR(2*self.leftMargin + mainWidth - self.marginOffset - textMargin,
                                          self.topMargin + halfHeight + circleD * 3 + baseLength +  lineOffset * bottomRightOffset - 5,15,
                                          @"gray",
                                          @"italic",
                                          retV)];
        }
        
    }
    
    return svgStr;
}


- (NSString*)getConnectionDescByInfosetList:(NSArray*)infosets ports:(NSArray*)ports{
    
    NSString* retV = nil;
    NSMutableDictionary* retD = [NSMutableDictionary dictionary];
    NSMutableArray* chain = [@[@"txiedport_id",@"switch1_rxport_id",@"switch1_txport_id",@"rxiedport_id"] mutableCopy];
    
    if(infosets){
        SGInfoSetItem* infoset = infosets[0];
        if (![infoset.switch2_id isEqualToString:@"0"]) {
            [chain insertObject:@"switch2_rxport_id" atIndex:chain.count - 1];
            [chain insertObject:@"switch2_txport_id" atIndex:chain.count - 1];
        }
        
        if (![infoset.switch3_id isEqualToString:@"0"]) {
            [chain insertObject:@"switch3_rxport_id" atIndex:chain.count - 1];
            [chain insertObject:@"switch3_txport_id" atIndex:chain.count - 1];
        }
        
        if (![infoset.switch4_id isEqualToString:@"0"]) {
            [chain insertObject:@"switch4_rxport_id" atIndex:chain.count - 1];
            [chain insertObject:@"switch4_txport_id" atIndex:chain.count - 1];
        }
        
        for(SGPortInfo* port in ports){
            for(SGInfoSetItem* infoset in infosets){
                for(NSString* connecter in chain){
                    if ([[infoset valueForKey:connecter] isEqualToString:port.port_id]){
                        if ([connecter containsString:@"tx"]) {
                            
                            retD[@"mainTxPort"] = port.port_id;
                            retD[@"ctedRxPort"] = [infoset valueForKey:chain[[chain indexOfObject:connecter] + 1]];
                            
                            NSString* field = [self getCntedDeviceIdByField:connecter infoset:infoset];
                            retD[@"ctedDeviceId"] = [infoset valueForKey:field];
                        }
                        if ([connecter containsString:@"rx"]) {
                            retD[@"mainRxPort"] = port.port_id;
                            retD[@"ctedTxPort"] = [infoset valueForKey:chain[[chain indexOfObject:connecter] - 1]];
                        }
                    }
                }
            }
        }
        
        NSString* device = [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:retD[@"ctedDeviceId"]];
        NSString* portTx = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:retD[@"ctedTxPort"]];
        portTx = [portTx stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        if ([[portTx substringToIndex:1] isEqualToString:@"-"]) {
            portTx = [portTx substringFromIndex:1];
        }
        NSString* portRx = [[SGSwitchBussiness sharedSGSwitchBussiness] queryPortById:retD[@"ctedRxPort"]];
        retV = [NSString stringWithFormat:@"%@   %@/%@",device,portTx,portRx];
    }

    return  retV;
}

- (NSString*)getCntedDeviceIdByField:(NSString*)field infoset:(SGInfoSetItem*)infoset{
    
    NSString* tmp = [[field componentsSeparatedByString:@"_"] firstObject];
    int index =  [[tmp substringFromIndex:tmp.length - 1] intValue];
    index++;
    
    NSString* deviceField = [NSString stringWithFormat:@"switch%d_id",index];
    if (![[infoset valueForKey:deviceField] isEqualToString:@"0"]) {
        return [NSString stringWithFormat:@"switch%d_id",index];
    }
    return @"rxied_id";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
