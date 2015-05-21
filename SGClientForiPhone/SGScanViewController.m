//
//  SGScanViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGScanViewController.h"
#import "PureLayout.h"
#import "SGCubicleViewController.h"
#import "SGCablePageBussiness.h"

#define Line_Width 220
@interface SGScanViewController ()<UIAlertViewDelegate>{
    
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}


@property (strong,nonatomic) AVCaptureDevice * device;
@property (strong,nonatomic) AVCaptureDeviceInput * input;
@property (strong,nonatomic) AVCaptureMetadataOutput * output;
@property (strong,nonatomic) AVCaptureSession * session;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer * preview;

@property (nonatomic,strong) UIImageView * line;
@property (nonatomic,strong) UIImageView* rectImageView;

@end

@implementation SGScanViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"扫描";
    
    self.rectImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.rectImageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:self.rectImageView];
    
    [self.rectImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.rectImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.rectImageView autoSetDimension:ALDimensionWidth toSize:Line_Width];
    [self.rectImageView autoSetDimension:ALDimensionHeight toSize:Line_Width];
    
    UIButton* lightBtn = [UIButton new];
    lightBtn.alpha = 0.6;
    [lightBtn setBackgroundImage:[UIImage imageNamed:@"icon_light_off"] forState:UIControlStateNormal];
    [lightBtn addTarget:self action:@selector(lightAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightBtn];

    [lightBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:70];
    [lightBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20];

    [lightBtn autoSetDimension:ALDimensionWidth toSize:40];
    [lightBtn autoSetDimension:ALDimensionHeight toSize:40];
    
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.rectImageView.frame), CGRectGetMinY(self.rectImageView.frame), Line_Width, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}

-(void)lightAction:(UIButton*)sender{
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]) {
        return;
    }
    
    if(device.torchMode == AVCaptureTorchModeOff){
        
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
        [sender setBackgroundImage:[UIImage imageNamed:@"icon_light_on"] forState:UIControlStateNormal];
    }else{
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        [sender setBackgroundImage:[UIImage imageNamed:@"icon_light_off"] forState:UIControlStateNormal];
    }
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(CGRectGetMinX(self.rectImageView.frame), CGRectGetMinY(self.rectImageView.frame) + 2*num, Line_Width, 2);
        if (2*num == Line_Width) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(CGRectGetMinX(self.rectImageView.frame), CGRectGetMinY(self.rectImageView.frame) + 2*num, Line_Width, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}
-(void)afterwardsClean{
    
    [timer invalidate];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]) {
        return;
    }
    
    if(device.torchMode == AVCaptureTorchModeOn){
        
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupCamera];
    [self setOrientationForCamara:self.interfaceOrientation];
}
- (void)setupCamera
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame =CGRectMake(0,0,ScreenWidth,ScreenHeight);
    [self.view.layer insertSublayer:self.preview atIndex:0];

    
    [_session startRunning];
}

-(void)dealloc{
    NSLog(@"");
}

-(void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    self.preview.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame),  CGRectGetHeight(self.view.frame));
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    NSLog(@"--------------------->>>>>>>>%@",stringValue);
    
    [_session stopRunning];
    
    if (stringValue.length>=2) {
        if ([[stringValue substringToIndex:2] isEqualToString:@"C:"]) {
            NSArray* a = [[stringValue substringFromIndex:2] componentsSeparatedByString:@"."];
            
            
            NSInteger cubicileId = [[SGCablePageBussiness sharedSGCablePageBussiness] queryCubicleIdByInfo:a[0]];
            NSInteger cableId = [[SGCablePageBussiness sharedSGCablePageBussiness] queryCableIdByInfo:a[1]];
            
            SGCubicleViewController* cubicleController = (SGCubicleViewController*)[self.tabBarController.viewControllers[0] viewControllers][0];
            [cubicleController.navigationController popToRootViewControllerAnimated:NO];
            [cubicleController scanModeWithCubicleId:cubicileId withCableId:cableId];
            self.tabBarController.selectedIndex = 0;
            
        }else if ([[stringValue substringToIndex:2] isEqualToString:@"F:"]){
            SGCubicleViewController* cubicleController = (SGCubicleViewController*)[self.tabBarController.viewControllers[0] viewControllers][0];
            [cubicleController.navigationController popToRootViewControllerAnimated:NO];
            [cubicleController scanModeWithPortId:@""];
            self.tabBarController.selectedIndex = 0;
            
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:stringValue delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:stringValue delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [_session startRunning];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    [self setOrientationForCamara:toInterfaceOrientation];
}

-(void)setOrientationForCamara:(UIInterfaceOrientation)orientation{
    
    AVCaptureConnection *previewLayerConnection=self.preview.connection;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
        case UIInterfaceOrientationUnknown:
            break;
    }
}


@end

