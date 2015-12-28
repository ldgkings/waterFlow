//
//  DGWaterFlowView.h
//  waterFlow
//
//  Created by LDG on 15/12/28.
//  Copyright © 2015年 ldg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
     DGWaterFlowViewMarginTypeTop,
     DGWaterFlowViewMarginTypeBottom,
     DGWaterFlowViewMarginTypeLeft,
     DGWaterFlowViewMarginTypeRight,
     DGWaterFlowViewMarginTypeRow, // 行间距
     DGWaterFlowViewMarginTypeColumn, // 列间距
} DGWaterFlowViewMarginType;


@class DGWaterFlowView,DGWaterFlowViewCell;

/**
 * 数据源
 */
@protocol DGWaterFlowViewDataSource <NSObject>
@required

- (NSInteger)numberOfCellsInWaterFlowView:(DGWaterFlowView *)waterFlowView;

- (DGWaterFlowViewCell *)waterFlowView:(DGWaterFlowView *)waterFlowView cellAtIndex:(NSInteger)index;

@optional- (NSInteger)numberOfColumnsInWaterFlowView:(DGWaterFlowView *)waterFlowView;

@end

/**
 * 代理
 */
@protocol DGWaterFlowViewDelegate <UIScrollViewDelegate>

@optional

- (void)waterFlowView:(DGWaterFlowView *)waterFlowView didSelectAtIndex:(NSInteger)index;

- (CGFloat)waterFlowView:(DGWaterFlowView *)waterFlowView heightAtIndex:(NSInteger)index;

// 设置各个间距
- (CGFloat)waterFlowView:(DGWaterFlowView *)waterFlowView marginForType:(DGWaterFlowViewMarginType)type;
@end

@interface DGWaterFlowView : UIScrollView

@property (nonatomic,weak) id<DGWaterFlowViewDataSource>  dataSource;
@property (nonatomic,weak) id<DGWaterFlowViewDelegate>  delegate;

- (CGFloat)cellWidth; // cell的宽度
- (void)reloadData;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end