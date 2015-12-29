//
//  ViewController.m
//  waterFlow
//
//  Created by LDG on 15/12/28.
//  Copyright © 2015年 ldg. All rights reserved.
//

#import "ViewController.h"
#import "DGWaterFlowView.h"
#import "DGWaterFlowViewCell.h"

@interface ViewController ()<DGWaterFlowViewDataSource,DGWaterFlowViewDelegate>
@property (nonatomic,strong) DGWaterFlowView * waterFlowView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    DGWaterFlowView *waterFlowView = [[DGWaterFlowView alloc] init];
    waterFlowView.dataSource = self;
    waterFlowView.delegate = self;
    waterFlowView.frame = self.view.bounds;
    [self.view addSubview:waterFlowView];
    self.waterFlowView = waterFlowView;
    
    [waterFlowView reloadData];
}

#pragma mark - 数据源方法
- (NSInteger)numberOfCellsInWaterFlowView:(DGWaterFlowView *)waterFlowView
{
    return 50;
}

- (DGWaterFlowViewCell *)waterFlowView:(DGWaterFlowView *)waterFlowView cellAtIndex:(NSInteger)index
{
    
    static NSString *ID = @"cell";

    DGWaterFlowViewCell *cell = [self.waterFlowView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DGWaterFlowViewCell alloc] init];
        cell.identifier = ID;
    }
    cell.backgroundColor = DGRandomColor;
    return cell;
}

#pragma mark - 代理方法
- (CGFloat)waterFlowView:(DGWaterFlowView *)waterFlowView heightAtIndex:(NSInteger)index
{
    switch (index % 3 ) {
        case 0: return 50;
        case 2: return 70;
        case 1: return 100;
        default: return 150;
    }
}

- (CGFloat)waterFlowView:(DGWaterFlowView *)waterFlowView marginForType:(DGWaterFlowViewMarginType)type
{
    switch (type) {
         case DGWaterFlowViewMarginTypeBottom:
         case DGWaterFlowViewMarginTypeTop:
         case DGWaterFlowViewMarginTypeLeft:
         case DGWaterFlowViewMarginTypeRight:
            return 5;
        default: return 10;
    }
}

- (void)waterFlowView:(DGWaterFlowView *)waterFlowView didSelectAtIndex:(NSInteger)index
{
    NSLog(@"%ld",index);

}

@end
