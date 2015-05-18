//
//  SGCableViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/17.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGCableViewController.h"
#import "SGCablePageBussiness.h"
#import "SGGenerateCubicleSvg.h"
#import "SGFiberViewController.h"



@interface SGCableViewController ()<UIWebViewDelegate>

@property (nonatomic,strong) NSDictionary* data;
@property (nonatomic,assign) BOOL isScanMode;


@property (nonatomic,strong) NSArray* type0listSorted;
@property (nonatomic,strong) NSArray* type1list;
@property (nonatomic,strong) NSArray* type2list;
@property (nonatomic,strong) NSArray* mergedCubicles;

@end

@implementation SGCableViewController


-(instancetype)initWithCubicleData:(NSDictionary *)cubicleData withCubicleId:(NSInteger)cubicleId withCableId:(NSInteger)cableId{
    if (self = [super init]) {
        _scannedCubicleId = cubicleId;
        _scannedCableId = cableId;
        _cubicleData = cubicleData;
        
        _isScanMode = YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //如果是扫码动作 直接跳过进入下一级界面
    if (_isScanMode) {
        _isScanMode = NO;
        SGCablePageBussiness* bussiness = [SGCablePageBussiness sharedSGCablePageBussiness];
        id cable = [bussiness queryCalbleInfoWithCableId:_scannedCableId];
        
        SGFiberViewController *fiber = [SGFiberViewController new];
        
        [fiber setCableId:[NSString stringWithFormat:@"%d",_scannedCableId]];
        [fiber setCubicleId:[NSString stringWithFormat:@"%d",_scannedCubicleId]];
        [fiber setCableName:[cable valueForKey:@"cable_name"]];
        [fiber setCableType:[[cable valueForKey:@"cable_type"] integerValue]];
        
        fiber.type0listSorted = self.type0listSorted;
        fiber.type1list = self.type1list;
        fiber.type2list = self.type2list;
        fiber.mergedCubicles = self.mergedCubicles;
        fiber.cubicleData = self.cubicleData;
        [self.navigationController pushViewController:fiber animated:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@连接图",self.cubicleData[@"name"]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString* _url = [request URL].description;
    
    NSLog(@"%@",_url);
    if ([_url rangeOfString:@"@@@@"].location != NSNotFound) {
        
        NSString *retValue = [[_url componentsSeparatedByString:@"@@@@"] objectAtIndex:1];
        NSArray* retList = [retValue componentsSeparatedByString:@"*"];
        
        NSString* cableName = retList[0];
        NSString* cableId   = retList[1];
        NSString* type      = retList[3];
        
        SGFiberViewController *fiber = [SGFiberViewController new];
        
        [fiber setCableId:cableId];
        [fiber setCableName:cableName];
        [fiber setCableType:[type integerValue]];
        [fiber setCubicleId:self.cubicleData[@"id"]];
        
        fiber.type0listSorted = self.type0listSorted;
        fiber.type1list = self.type1list;
        fiber.type2list = self.type2list;
        fiber.mergedCubicles = self.mergedCubicles;
        fiber.cubicleData = self.cubicleData;
        
        [self.navigationController pushViewController:fiber animated:YES];
    }
    return YES;
}

-(id)getRandomFullLengthItemWithList:(NSArray*)list{
    for(NSArray *a in list){
        if (a.count>2) {
            return a;
        }
    }
    return nil;
}

-(SGCableTmpItem*)getGLCableWithConnection:(NSArray*)conn{
    
    NSUInteger index;
    
    for(int i = 0; i < conn.count;i++){
        if ([[conn[i] valueForKey:@"cubicle_id"] isEqualToString:self.cubicleData[@"id"]]) {
            index = i;
            break;
        }
    }
    
    SGCableTmpItem *item = [SGCableTmpItem new];
    [item setCableId:[conn[index+1] valueForKey:@"cable_id"]];
    [item setCableName:[conn[index+1] valueForKey:@"cable_name"]];
    [item setCubicleName:[conn[index+1] valueForKey:@"cubicle_name"]];
    [item setCubicleId:[conn[index+1] valueForKey:@"cubicle_id"]];
    return item;
}

//生成SVG文件
-(void)drawSvgFileOnWebview{
    
    self.data = [[SGCablePageBussiness sharedSGCablePageBussiness] queryCablelistWithCubicleId:[self.cubicleData[@"id"] integerValue]];
    
    NSArray* type0 = self.data[@"type0"];
    NSInteger index = 0;
    
    id item = [self getRandomFullLengthItemWithList:type0];
    
    if ([[[item[1] valueForKey:@"cable_name"] uppercaseString] rangeOfString:@"GL"].location!=NSNotFound) {
        index = 1;
    }
    
    type0 = [type0 sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if (index == 1) {
            if([[obj1[1] valueForKey:@"cable_id"] integerValue] < [[obj2[1] valueForKey:@"cable_id"] integerValue]){
                return NSOrderedAscending;
            }
            if([[obj1[1] valueForKey:@"cable_id"] integerValue] > [[obj2[1] valueForKey:@"cable_id"] integerValue]){
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }else{
            if([[obj1[[obj1 count] - 1] valueForKey:@"cable_id"] integerValue] < [[obj2[[obj2 count] - 1] valueForKey:@"cable_id"] integerValue]){
                return NSOrderedAscending;
            }
            if([[obj1[[obj1 count] - 1] valueForKey:@"cable_id"] integerValue] > [[obj2[[obj2 count] - 1] valueForKey:@"cable_id"] integerValue]){
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }
    }];
    
    
    self.type0listSorted = type0;
    self.type1list = [self.data valueForKey:@"type1"];
    self.type2list = [self.data valueForKey:@"type2"];
    
    
    SGGenerateCubicleSvg *g = [SGGenerateCubicleSvg new];
    g.type0listSorted = self.type0listSorted;
    g.type1list = self.type1list;
    g.type2list = self.type2list;
    g.cubicleData = self.cubicleData;
    
    NSString* result = [g getCubicleSvgStr];
    
    NSData *svgData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                        objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:@"cable.svg"];
    [svgData writeToFile:dbPath atomically:YES];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [[NSURL alloc] initFileURLWithPath:resourcePath isDirectory:YES];
    [self.webView   loadData:svgData
                    MIMEType:@"image/svg+xml"
            textEncodingName:@"UTF-8"
                     baseURL:baseURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

