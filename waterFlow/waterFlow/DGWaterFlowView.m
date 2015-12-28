//
//  DGWaterFlowView.m
//  waterFlow
//
//  Created by LDG on 15/12/28.
//  Copyright © 2015年 ldg. All rights reserved.
//


#define DGWaterFlowViewDefaultNumberOfColumns 3
#define DGWaterFlowViewDefaultCellHeight 70
#define DGWaterFlowViewDefaultMargin 10

#import "DGWaterFlowView.h"
#import "DGWaterFlowViewCell.h"

@implementation DGWaterFlowView
@dynamic delegate;

#pragma mark - 公共方法

- (CGFloat)cellWidth
{
    NSInteger numberOfColumns = [self numberOfColumn];
    CGFloat leftM = [self marginWithType:DGWaterFlowViewMarginTypeLeft];
    CGFloat rightM = [self marginWithType:DGWaterFlowViewMarginTypeRight];
    CGFloat columnM = [self marginWithType:DGWaterFlowViewMarginTypeColumn];
    return (self.bounds.size.width - leftM - rightM - (numberOfColumns - 1)*columnM) / numberOfColumns;
}
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return nil;
}

// 计算出所有cell的frame摆上去
- (void)reloadData
{

   // cell的个数
   NSInteger numberOfCells = [self.dataSource numberOfCellsInWaterFlowView:self];
   NSInteger numberOfColumns = [self numberOfColumn];

    // 间距
    CGFloat topM = [self marginWithType:DGWaterFlowViewMarginTypeTop];
    CGFloat leftM = [self marginWithType:DGWaterFlowViewMarginTypeLeft];
    CGFloat bottomM = [self marginWithType:DGWaterFlowViewMarginTypeBottom];
    CGFloat rowM = [self marginWithType:DGWaterFlowViewMarginTypeRow];
    CGFloat columnM = [self marginWithType:DGWaterFlowViewMarginTypeColumn];
    
    CGFloat cellW = [self cellWidth];

    // 用一个C语言数组存放每列的最大y值（oc的要包装成对象，麻烦）
//    CGFloat maxOfColumns[numberOfColumns] = {0,0,0}; // 这样初始化是错误的，因为后面的是确定的是而前面是变量
    // 所以遍历初始化
    
    // 用一个C语言数组存放所有列的最大Y值
    CGFloat maxYOfColumns[numberOfColumns];
    for (int i = 0; i<numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    // 计算所有cell的frame
    for (int i = 0; i<numberOfCells; i++) {
       CGFloat cellH = [self heightAtIndex:i];
     // 默认第o列是最短的那一列
        NSInteger cellColumn = 0;
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];

        for (int j=1; j<numberOfColumns; j++) {
            if (maxYOfColumns[j]< maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        
        CGFloat cellX = (cellW + columnM) * cellColumn + leftM;
        CGFloat cellY = 0;
        if (maxYOfCellColumn == 0.0) { // 首行
            cellY = topM;
        }else{
            cellY = maxYOfCellColumn + rowM;
        }

        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        DGLog(@" %d --%@",i,NSStringFromCGRect(cellFrame));
        // 更新最短的那一个最大的Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
        
        DGWaterFlowViewCell *cell = [self.dataSource waterFlowView:self cellAtIndex:i];
        cell.frame = cellFrame;
        [self addSubview:cell];
    }
    
    // 设置scrollerView的contensize让他可以滚
    CGFloat contentH = maxYOfColumns[0] ;
    for (int i = 1 ; i<numberOfColumns; i++) {
        if (maxYOfColumns[i]>contentH) {
            contentH = maxYOfColumns[i];
        }
    }
    contentH += bottomM;
    self.contentSize = CGSizeMake(0, contentH);
}

#pragma mark - 私有方法
- (CGFloat)marginWithType:(DGWaterFlowViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterFlowView:marginForType:)]) {
        return [self.delegate waterFlowView:self marginForType:type];
    }else{
        return DGWaterFlowViewDefaultMargin;
    }
}

- (CGFloat)heightAtIndex:(int)index
{
    if ([self.delegate respondsToSelector:@selector(waterFlowView:heightAtIndex:)]) {
        return  [self.delegate waterFlowView:self heightAtIndex:index];
    }else{
        return DGWaterFlowViewDefaultCellHeight;
    }
}

- (NSInteger)numberOfColumn
{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterFlowView:)]) {
       return [self.dataSource numberOfColumnsInWaterFlowView:self];
    }else
    {
        return DGWaterFlowViewDefaultNumberOfColumns;
    }
}


@end
