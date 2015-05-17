//
//  SGCubicleViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGCubicleViewController.h"
#import "SGMainPageBussiness.h"

#import "SGRoomCell.h"
#import "SGSectionHeaderView.h"

#import "XMLReader.h"
#import "PureLayout.h"
#import "UIViewController+NJKFullScreenSupport.h"



@interface SGCubicleViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,SGRoomCellDelegate>

@property (nonatomic,strong) NSArray* roomList;
@property (nonatomic,strong) UICollectionView* roomView;
@property (nonatomic,assign) CGSize itemSize;
@property (nonatomic) NJKScrollFullScreen *scrollProxy;


@end

#define kCellIdentifier @"SGRoomCell"
#define kSectionHeader  @"SGSectionHeaderView"


@implementation SGCubicleViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initialSetup];
    
}

-(void)initialSetup{
    
    self.title = [[SGUtility getCurrentDB] componentsSeparatedByString:@"."][0];
    
    NSError* error;
    NSString   *strXml = [[SGMainPageBussiness sharedSGMainPageBussiness] queryDevicelistForAllInnerRoom];
    NSDictionary *dict = [XMLReader dictionaryForXMLString:strXml error:&error];
    self.roomList = [ [dict objectForKey:@"root"] objectForKey:@"room"];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.roomView];
    
    self.roomView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.roomView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [self.roomView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.roomView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.roomView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    
    if (CGRectGetWidth(self.view.frame) > CGRectGetHeight(self.view.frame)) {
        self.itemSize = CGSizeMake((ScreenWidth - 15*4) /3., 200);
    }else{
        self.itemSize = CGSizeMake((ScreenWidth - 15*3) /2., 200);
    }
    
    _scrollProxy = [[NJKScrollFullScreen alloc] initWithForwardTarget:self];
    self.roomView.delegate = (id)_scrollProxy;
    _scrollProxy.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //设置数据库后 reload数据
    self.title = [[SGUtility getCurrentDB] componentsSeparatedByString:@"."][0];
    
    if ([SGUtility getDBChangeFlag]) {
        
        NSError* error;
        NSString   *strXml = [[SGMainPageBussiness sharedSGMainPageBussiness] queryDevicelistForAllInnerRoom];
        NSDictionary *dict = [XMLReader dictionaryForXMLString:strXml error:&error];
        self.roomList = [ [dict objectForKey:@"root"] objectForKey:@"room"];
        [self.roomView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_scrollProxy reset];
    [self showNavigationBar:animated];
    [self showTabBar:animated];
}


#pragma mark - UICollectionView delegate & datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    id cubicle = [[self.roomList objectAtIndex:section] objectForKey:@"cubicle"];
    
    if ([cubicle isKindOfClass:[NSDictionary class]]) {
        return 1;
    } else {
        return [(NSArray*)cubicle count];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return self.roomList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SGRoomCell *cell = (SGRoomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    id cubicles = [[self.roomList objectAtIndex:indexPath.section] objectForKey:@"cubicle"];
    
    if ([cubicles isKindOfClass:[NSArray class]]) {
        [cell setData:[cubicles objectAtIndex:indexPath.row]];
        [cell setDelegate:self];
    }
    if ([cubicles isKindOfClass:[NSDictionary class]]) {
        [cell setData:cubicles];
        [cell setDelegate:self];
    }
    
    return cell;
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                       layout:(UICollectionViewLayout *)collectionViewLayout
       insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        SGSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSectionHeader forIndexPath:indexPath];
        header.roomLabel.text = [[self.roomList objectAtIndex:indexPath.section] objectForKey:@"name"];
        reusableview = header;
    }
    return reusableview;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(CGRectGetWidth(self.view.frame), 60);
}

//cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.itemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {

    return 15;
}


-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    if (size.width>size.height) {
        self.itemSize = CGSizeMake((size.width - 15*4) /3., 200);
    }else{
        self.itemSize = CGSizeMake((size.width - 15*3) /2., 200);
    }
    
    [self.roomView reloadData];
    
    [_scrollProxy reset];
    [self showNavigationBar:YES];
    [self showTabBar:YES];
}

#pragma cell - delegate

-(void)cellDidSeletedWithCubicleId:(NSDictionary*)cubicleData{
    
 
}


#pragma mark NJKScrollFullScreenDelegate

- (void)resetBars
{
    [_scrollProxy reset];
    [self showNavigationBar:NO];
    [self showTabBar:NO];
}

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollUp:(CGFloat)deltaY
{
    [self moveNavigationBar:deltaY animated:YES];
    [self moveTabBar:-deltaY animated:YES]; // move to revese direction
}

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollDown:(CGFloat)deltaY
{
    [self moveNavigationBar:deltaY animated:YES];
    [self moveTabBar:-deltaY animated:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp:(NJKScrollFullScreen *)proxy
{
    [self hideNavigationBar:YES];
    [self hideTabBar:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown:(NJKScrollFullScreen *)proxy
{
    [self showNavigationBar:YES];
    [self showTabBar:YES];
}

#pragma mark - property


-(UICollectionView*)roomView{
    
    if (!_roomView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _roomView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,ScreenWidth,ScreenHeight)
                                           collectionViewLayout:flowLayout];
        
        [_roomView registerNib:[UINib nibWithNibName:kSectionHeader bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeader];
        
        [_roomView registerClass:[SGRoomCell class] forCellWithReuseIdentifier:kCellIdentifier];
        
        [_roomView setBackgroundColor:[UIColor whiteColor]];
        [_roomView setDelegate:self];
        [_roomView setDataSource:self];
    }
    return _roomView;
}


@end
