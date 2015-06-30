//
//  SGDeviceViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/6/23.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGDeviceViewController.h"
#import "SGDeviceBussiness.h"
#import "SGEntity.h"

@implementation SGDeviceEntity
@end

@interface SGDeviceViewController ()

@property(nonatomic,assign) float leftMargin;
@property(nonatomic,assign) float topMargin;

@property(nonatomic,assign) float cubicleWidth;
@property(nonatomic,assign) float cubicleHeight;
@property(nonatomic,assign) float cubicleMargin;
@property(nonatomic,assign) float lineLength;

@property(nonatomic,assign) float offsetY;
@property(nonatomic,assign) float offsetX;

@end



@implementation SGDeviceViewController

-(instancetype)init{
    
    if (self = [super init]) {
        
        _leftMargin = 20;
        _topMargin = 50;
        _cubicleWidth   = 380;
        _cubicleHeight  = 70;
        _cubicleMargin  = 30;
        _lineLength     = 200;
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
    
    result = [result stringByReplacingOccurrencesOfString:@"++@@@++" withString:[NSString stringWithFormat:@"%f",self.offsetY + 200]];
    result = [result stringByReplacingOccurrencesOfString:@"##@@@##" withString:[NSString stringWithFormat:@"%f",self.offsetX + 200]];
    
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
 
    NSArray* list  = [[SGDeviceBussiness sharedSGDeviceBussiness] queryInfoSetListByDeviceId:self.deviceId];
    NSArray* leftList = list[0];
    NSArray* rightList = list[1];
    NSMutableString* svgStr = [NSMutableString string];

#pragma mark - 绘制中间设备
    //画中间设备
    float height = [self getMainHeightByLeftList:[leftList valueForKeyPath:@"@distinctUnionOfObjects.group"]
                                       rightList:[rightList valueForKeyPath:@"@distinctUnionOfObjects.group"]];
    self.offsetY = height;
    
    float margin = (leftList.count) ? self.leftMargin + self.lineLength + self.cubicleWidth : self.leftMargin;
    //画主设
    [svgStr appendString:DrawRect(margin,
                                    self.topMargin,
                                    self.cubicleWidth,
                                    height)];
    //主设名称
    [svgStr appendString:DrawText(margin + 100,
                                  self.topMargin + height/2.0 ,17,
                                  @"white",
                                  @"italic",
                                  [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:self.deviceId])];

    float textOffset = 5;
    float groupOffset = 15;
    float arrowOffset = 18;
    
#pragma mark - 绘制左边连接
    //画左边
    if (leftList.count) {
        self.offsetX = self.leftMargin + self.cubicleWidth * 2 + self.lineLength + 100;
        int leftOffset = 0;
        for(int i = 0; i < leftList.count; i++){

            SGInfoSetItem* infoset = leftList[i];
            NSString* deviceName = ([infoset.txied_id isEqualToString:self.deviceId]) ?
            [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:infoset.rxied_id] :
            [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:infoset.txied_id];
            
            float offsetY = self.topMargin + (self.cubicleHeight + self.cubicleMargin) * leftOffset + self.cubicleHeight/2.0;

            [svgStr appendString:DrawRect(self.leftMargin,
                                          self.topMargin + (self.cubicleHeight + self.cubicleMargin) * leftOffset,
                                          self.cubicleWidth,
                                          self.cubicleHeight)];
            
            [svgStr appendString:DrawText(self.leftMargin + 100,
                                          offsetY ,17,
                                          @"white",
                                          @"italic",
                                          deviceName)];
            
            //处理Group信息
            int iplus = i; iplus++;
            if (iplus <= leftList.count) {
                
                SGInfoSetItem* nextInfoset;

                if (iplus!=leftList.count) {
                    nextInfoset = leftList[iplus];
                }
                
                //group
                
                
                NSString* portL;
                NSString* portR;
                NSString* groupL;
                NSString* groupR;
                
                if ([infoset.txied_id isEqualToString:self.deviceId]) {
                    portR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.txiedport_id];
                    portL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.rxiedport_id];
                }else{
                    portR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.rxiedport_id];
                    portL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.txiedport_id];
                }
                
                if ([infoset.group isEqualToString:nextInfoset.group]) {
                    
                    

                    if ([nextInfoset.txied_id isEqualToString:self.deviceId]) {
                        groupR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:nextInfoset.txiedport_id];
                        groupL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:nextInfoset.rxiedport_id];
                    }else{
                        groupR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:nextInfoset.rxiedport_id];
                        groupL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:nextInfoset.txiedport_id];
                    }
                    
                    [svgStr appendString:DrawTextR(self.leftMargin + self.cubicleWidth,
                                                   offsetY - groupOffset + textOffset ,17,
                                                   @"white",
                                                   @"italic",
                                                   portL)];
                    
                    [svgStr appendString:DrawTextL(self.leftMargin + self.cubicleWidth + self.lineLength,
                                                   offsetY - groupOffset + textOffset ,17,
                                                   @"white",
                                                   @"italic",
                                                   portR)];
                    
                    [svgStr appendString:DrawTextR(self.leftMargin + self.cubicleWidth,
                                                   offsetY + groupOffset + textOffset ,17,
                                                   @"white",
                                                   @"italic",
                                                   groupL)];
                    
                    [svgStr appendString:DrawTextL(self.leftMargin + self.cubicleWidth + self.lineLength,
                                                   offsetY+ groupOffset + textOffset ,17,
                                                   @"white",
                                                   @"italic",
                                                   groupR)];

                    [svgStr appendString:DrawLineArrow(self.leftMargin + self.cubicleWidth,
                                                       offsetY + groupOffset,
                                                       self.leftMargin + self.cubicleWidth + self.lineLength - arrowOffset,
                                                       offsetY + groupOffset,@"")];
                    
                    [svgStr appendString:DrawLineArrow(self.leftMargin + self.cubicleWidth + self.lineLength,
                                                       offsetY - groupOffset,
                                                       self.leftMargin + self.cubicleWidth + arrowOffset,
                                                       offsetY - groupOffset,@"")];
                    i++;
                
                //非group
                }else{
                    
                    [svgStr appendString:DrawTextR(self.leftMargin + self.cubicleWidth,
                                                  offsetY + 5,17,
                                                  @"white",
                                                  @"italic",
                                                  portL)];
                    
                    [svgStr appendString:DrawTextL(self.leftMargin + self.cubicleWidth + self.lineLength,
                                                  offsetY + 5,17,
                                                  @"white",
                                                  @"italic",
                                                  portR)];
                    
                    if ([infoset.txied_id isEqualToString:self.deviceId]) {
                        
                        [svgStr appendString:DrawLineArrow(self.leftMargin + self.cubicleWidth + self.lineLength,
                                                           offsetY,
                                                           self.leftMargin + self.cubicleWidth + arrowOffset,
                                                           offsetY,@"")];
                    }else{
                        
                        [svgStr appendString:DrawLineArrow(self.leftMargin + self.cubicleWidth,
                                                           offsetY,
                                                           self.leftMargin + self.cubicleWidth + self.lineLength - arrowOffset,
                                                           offsetY,@"")];
                    }
                }
            }
            leftOffset++;
        }
    }
    
#pragma mark - 绘制右边连接
    
    if (rightList.count) {
        
        float offsetRight = self.leftMargin + self.cubicleWidth * 2 + self.lineLength;
        NSArray* mergeList = [self generateSwitchMergeList:rightList];
        
        float right = ([self getMaxLevel:rightList] + 1) * (self.cubicleWidth + self.lineLength);
        
        self.offsetX += right;
        
        
#pragma mark -   绘制右边连接交换机部分
        for(int i = 0; i < mergeList.count; i++){
            NSArray* c = mergeList[i];
            
            for(int j = 0; j < c.count; j++){
                
                SGDeviceEntity* entity = c[j];
                
                if (![entity.groupId isEqualToString:@"0"]) {
                    [svgStr appendString:DrawRect(offsetRight + i * (self.cubicleWidth + self.lineLength) + self.lineLength,
                                                  self.topMargin + (self.cubicleHeight + self.cubicleMargin) * [self preCount:c entity:entity],
                                                  self.cubicleWidth,
                                                  self.cubicleHeight*entity.count + self.cubicleMargin * (entity.count - 1))];
                    
                    [svgStr appendString:DrawText(offsetRight + i * (self.cubicleWidth + self.lineLength) + self.lineLength + 100,
                                                  self.topMargin + (self.cubicleHeight + self.cubicleMargin) * [self preCount:c entity:entity] + (self.cubicleHeight*entity.count + self.cubicleMargin * (entity.count - 1))/2.0 ,17,
                                                  @"white",
                                                  @"italic",
                                                  [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:entity.groupId])];
                    
                    
                    int level = i + 1;
                    NSString* field = [NSString stringWithFormat:@"switch%d_id ",level];
                    NSString* format = [NSString stringWithFormat:@"%@ == '%@'",field,entity.groupId];
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:format];
                    NSArray* list = [rightList filteredArrayUsingPredicate:predicate];
                    
                    // -----> 发送
                    NSString* portL;
                    NSString* portR;
                    NSString* groupL;
                    NSString* groupR;
                    
                    NSString* preTxField = [NSString stringWithFormat:@"switch%d_txport_id",level-1];
                    NSString* rxField = [NSString stringWithFormat:@"switch%d_rxport_id",level];
                    
                    BOOL hasGroup = NO;
                    for(SGInfoSetItem* infoset in list){
                        
                        if ([infoset.txied_id isEqualToString:self.deviceId]) {
                            if (level == 1) {
                                
                                portL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.txiedport_id];
                                portR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.switch1_rxport_id];
                                
                            }else{
                                portL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:[infoset valueForKey:preTxField]];
                                portR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:[infoset valueForKey:rxField]];
                            }
                            break;
                        }
                    }
                    
                    //<----- 接受
                    for(SGInfoSetItem* infoset in list){
                        if ([infoset.rxied_id isEqualToString:self.deviceId]) {
                            hasGroup = YES;
                            if (level == 1) {
 
                                groupL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.rxiedport_id];
                                groupR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.switch1_txport_id];
                                
                            }else{
                                groupL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:[infoset valueForKey:preTxField]];
                                groupR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:[infoset valueForKey:rxField]];
                            }
                            break;
                        }
                    }
                    
                    float offsetY = self.topMargin + (self.cubicleHeight + self.cubicleMargin) * [self preCount:c entity:entity] + (self.cubicleHeight*entity.count + self.cubicleMargin * (entity.count - 1))/2.0;
                    
                    if (hasGroup) {
                        
                        [svgStr appendString:DrawTextR(offsetRight + i * (self.cubicleWidth + self.lineLength),
                                                       offsetY - groupOffset + textOffset ,17,
                                                       @"white",
                                                       @"italic",
                                                       portL)];
                        
                        [svgStr appendString:DrawTextL(offsetRight + i * (self.cubicleWidth + self.lineLength) + self.lineLength,
                                                       offsetY - groupOffset + textOffset ,17,
                                                       @"white",
                                                       @"italic",
                                                       portR)];
                        
                        [svgStr appendString:DrawTextR(offsetRight + i * (self.cubicleWidth + self.lineLength),
                                                       offsetY + groupOffset + textOffset ,17,
                                                       @"white",
                                                       @"italic",
                                                       groupL)];
                        
                        [svgStr appendString:DrawTextL(offsetRight + i * (self.cubicleWidth + self.lineLength) + self.lineLength,
                                                       offsetY + groupOffset + textOffset ,17,
                                                       @"white",
                                                       @"italic",
                                                       groupR)];
                        
                        [svgStr appendString:DrawLineArrow(offsetRight + i * (self.cubicleWidth + self.lineLength),
                                                           offsetY - groupOffset,
                                                           offsetRight + i * (self.cubicleWidth + self.lineLength) + self.lineLength - arrowOffset,
                                                           offsetY - groupOffset,@"")];
                        
                        [svgStr appendString:DrawLineArrow(offsetRight + i * (self.cubicleWidth + self.lineLength) + self.lineLength,
                                                           offsetY + groupOffset,
                                                           offsetRight + i * (self.cubicleWidth + self.lineLength) + arrowOffset,
                                                           offsetY + groupOffset,@"")];
                        
                    }else{
                    
                        
                        
                        [svgStr appendString:DrawTextR(offsetRight + i * (self.cubicleWidth + self.lineLength),
                                                       offsetY,17,
                                                       @"white",
                                                       @"italic",
                                                       portL)];
                        
                        [svgStr appendString:DrawLineArrow(offsetRight + i * (self.cubicleWidth + self.lineLength),
                                                           offsetY - 5,
                                                           offsetRight + i * (self.cubicleWidth + self.lineLength) + self.lineLength - arrowOffset,
                                                           offsetY - 5,@"")];
                        
                        [svgStr appendString:DrawTextL(offsetRight + i * (self.cubicleWidth + self.lineLength) + self.lineLength,
                                                       offsetY,17,
                                                       @"white",
                                                       @"italic",
                                                       portR)];
                    }
                }
            }
        }
        
#pragma mark -   绘制右边连接末端设备
        
        int rightOffset = 0;
        for(int i = 0; i < rightList.count; i++){
            
            
            SGInfoSetItem* infoset = rightList[i];
            
            NSString* deviceName = ([infoset.txied_id isEqualToString:self.deviceId]) ?
            [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:infoset.rxied_id] :
            [[SGDeviceBussiness sharedSGDeviceBussiness] queryDeviceById:infoset.txied_id];
            
            float offsetY = self.topMargin + (self.cubicleHeight + self.cubicleMargin) * rightOffset + self.cubicleHeight/2.0;
            NSUInteger currentLevel = [self getItemLevel:infoset];
            
            
            [svgStr appendString:DrawRect(offsetRight + (self.cubicleWidth + self.lineLength)*currentLevel  + self.lineLength,
                                          self.topMargin + (self.cubicleHeight + self.cubicleMargin) * rightOffset,
                                          self.cubicleWidth,
                                          self.cubicleHeight)];
            
            [svgStr appendString:DrawText(offsetRight + (self.cubicleWidth + self.lineLength)*currentLevel + self.lineLength + 100,
                                          offsetY ,17,
                                          @"white",
                                          @"italic",
                                          deviceName)];
            
            //处理Group信息
            int iplus = i; iplus++;
            if (iplus <= rightList.count) {
                
                SGInfoSetItem* nextInfoset;
                
                if (iplus!=rightList.count) {
                    nextInfoset = rightList[iplus];
                }
                
                //group
                float textOffset = 5;
                
                NSString* portL;
                NSString* portR;
                NSString* groupL;
                NSString* groupR;
                
                NSString* switch_txiedport_id = [NSString stringWithFormat:@"switch%lu_txport_id",(unsigned long)currentLevel];
                NSString* switch_rxiedport_id = [NSString stringWithFormat:@"switch%lu_rxport_id",(unsigned long)currentLevel];

                if ([infoset.txied_id isEqualToString:self.deviceId]) {
                    
                    portL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:[infoset valueForKey:switch_txiedport_id]];
                    portR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.rxiedport_id];
                }else{
                    portL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:[infoset valueForKey:switch_rxiedport_id]];
                    portR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:infoset.txiedport_id];
                }
                
                if ([infoset.group isEqualToString:nextInfoset.group]) {
                    
                    float groupOffset = 15;
                    
                    if ([nextInfoset.txied_id isEqualToString:self.deviceId]) {
                        groupL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:[nextInfoset valueForKey:switch_txiedport_id]];
                        groupR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:nextInfoset.rxiedport_id];
                    }else{
                        groupL = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:[nextInfoset valueForKey:switch_rxiedport_id]];
                        groupR = [[SGDeviceBussiness sharedSGDeviceBussiness] queryPortById:nextInfoset.txiedport_id];
                    }
                    
                    [svgStr appendString:DrawTextR(offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel,
                                                   offsetY - groupOffset + textOffset ,17,
                                                   @"white",
                                                   @"italic",
                                                   portL)];
                    
                    [svgStr appendString:DrawTextL(offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel + self.lineLength,
                                                   offsetY - groupOffset + textOffset ,17,
                                                   @"white",
                                                   @"italic",
                                                   portR)];
                    
                    [svgStr appendString:DrawTextR(offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel,
                                                   offsetY + groupOffset + textOffset ,17,
                                                   @"white",
                                                   @"italic",
                                                   groupL)];
                    
                    [svgStr appendString:DrawTextL(offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel + self.lineLength,
                                                   offsetY+ groupOffset + textOffset ,17,
                                                   @"white",
                                                   @"italic",
                                                   groupR)];
                    
                    [svgStr appendString:DrawLineArrow(offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel,
                                                       offsetY + groupOffset,
                                                       offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel + self.lineLength - arrowOffset,
                                                       offsetY + groupOffset,@"")];
                    
                    [svgStr appendString:DrawLineArrow(offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel + self.lineLength,
                                                       offsetY - groupOffset,
                                                       offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel + arrowOffset,
                                                       offsetY - groupOffset,@"")];
                    i++;
                    
                    //非group
                }else{
                    
                    [svgStr appendString:DrawTextR(offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel,
                                                   offsetY + 5,17,
                                                   @"white",
                                                   @"italic",
                                                   portL)];
                    
                    [svgStr appendString:DrawLineArrow(offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel,
                                                       offsetY,
                                                       offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel + self.lineLength - arrowOffset,
                                                       offsetY,@"")];
                    
                    [svgStr appendString:DrawTextL(offsetRight + (self.cubicleWidth+self.lineLength)*currentLevel + self.lineLength,
                                                   offsetY + 5,17,
                                                   @"white",
                                                   @"italic",
                                                   portR)];
                }
            }
            rightOffset++;
        }
    }


    return svgStr;
}

#pragma mark -

//交换机 向上垂直间隔
-(NSUInteger)preCount:(NSArray*)columnList entity:(SGDeviceEntity*)entity{
    
    NSUInteger index = [columnList indexOfObject:entity];
    NSUInteger count = 0;
    
    for(int i = 0; i < index; i++){
        SGDeviceEntity * entityTmp = columnList[i];
        count += entityTmp.count;
    }
    return count;
}




//获取每一条数据的交换机层级
-(NSUInteger)getItemLevel:(SGInfoSetItem*)infoSetItem{
    for(int i = 4; i >= 1; i--){
        if (![[infoSetItem valueForKey:[NSString stringWithFormat:@"switch%d_id",i]] isEqualToString:@"0"]) {
            return i;
        };
    }
    return 0;
}

//绘图的水平最大层级
-(NSUInteger)getMaxLevel:(NSArray*)rightList{
    
    NSUInteger max = 0;
    
    for(int i = 0; i < rightList.count; i++){
        NSUInteger tmp =  [self getItemLevel:rightList[i]];
        if (tmp > max) {
            max = tmp;
        }
    }
    return max;
}


//交换机Cubicle数据
-(NSArray*)generateSwitchMergeList:(NSArray*)rightList{
    
    NSMutableArray* retList = [NSMutableArray array];
    NSInteger maxLevel = [self getMaxLevel:rightList];
    
    NSMutableArray* rightTmp = [rightList mutableCopy];
    NSMutableArray* removed = [NSMutableArray array];
    
    for(int i = 0; i < rightTmp.count; i++){
        
        SGInfoSetItem* infoset = rightTmp[i];
        if (i > 0) {
            int p = i - 1;
            SGInfoSetItem *infosetPre = rightTmp[p];
            if ([infoset.group isEqualToString:infosetPre.group]) {
                [removed addObject:infosetPre];
            }
        }
    }
    
    [rightTmp removeObjectsInArray:removed];
    
    
    for(int i = 1; i <= maxLevel; i++){
        
        NSArray* switchList = [rightTmp valueForKey:[NSString stringWithFormat:@"switch%d_id",i]];
        NSArray* columnList = [self generatePerColumnList:switchList];
        [retList addObject:columnList];
    }
    
    return retList;
}

//右侧  每一列Cubicle数据
-(NSArray*)generatePerColumnList:(NSArray*)list{
    
    NSMutableArray* retList = [NSMutableArray array];

    NSString* groupId = @"";
    NSString* groupIdTmp = @"";
    NSUInteger count = 0;
    
    
    for(int i = 0; i<list.count;i++){
        
        groupIdTmp = list[i];

        if ([groupIdTmp isEqualToString:@"0"]) {
            
            SGDeviceEntity* entity = [SGDeviceEntity new];
            entity.groupId = groupIdTmp;
            entity.count = 1;
            
            [retList addObject:entity];
            
        }else{
            if (![groupIdTmp isEqualToString:groupId]) {
                count = 0;
                groupId = groupIdTmp;
                SGDeviceEntity* entity = [SGDeviceEntity new];
                entity.groupId = groupId;
                count++;
                entity.count = count;

                [retList addObject:entity];
                
            }else{
                count++;
                SGDeviceEntity* entity = retList[retList.count-1];
                entity.count = count;
            }
        }
    }
    
    return retList;
}

//获取中间设备高度
-(float)getMainHeightByLeftList:(NSArray*)leftList rightList:(NSArray*)rightList{
    
    return (leftList.count > rightList.count) ?
    leftList.count * self.cubicleHeight + (leftList.count - 1) * self.cubicleMargin :
    rightList.count * self.cubicleHeight + (rightList.count - 1) * self.cubicleMargin;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
