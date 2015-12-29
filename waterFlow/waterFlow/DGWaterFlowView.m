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

@interface DGWaterFlowView ()
/** 所有cell的frames */
@property (nonatomic,strong) NSMutableArray  *cellFrames;
/** 一个索引对应一个cell */
@property (nonatomic,strong) NSMutableDictionary * displayingCells;
/** 缓存池 */
@property (nonatomic,strong) NSMutableSet * resuableCells;

@end

@implementation DGWaterFlowView
@dynamic delegate;

#pragma mark - 懒加载
- (NSMutableSet *)resuableCells
{
    if (_resuableCells == nil) {
        self.resuableCells = [NSMutableSet set];
    }
    return _resuableCells;
}

- (NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        self.cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells
{
    if (_displayingCells == nil) {
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

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
   __block DGWaterFlowViewCell *resuableCell = nil;
    [self.resuableCells enumerateObjectsUsingBlock:^(DGWaterFlowViewCell *cell, BOOL * _Nonnull stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            resuableCell = cell;
            *stop = YES;
        }
    }];
    
    if (resuableCell) {
        [self.resuableCells removeObject:resuableCell];
    }
    
    return resuableCell;
}

// 计算出所有cell的frame摆上去
- (void)reloadData
{
    
    // 移除正在展示的cell
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 清楚所有的cell
    [self.displayingCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.resuableCells removeAllObjects];
    
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
        //添加到数组中
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        // 更新最短的那一个最大的Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
        
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

/**
 * 布局子控件（UIScrolerView 在滚动的时候一直调用这个方法）
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSInteger  numberOfcells = self.cellFrames.count;
    // 遍历数组中的frame如果发现要显示cell就向数据源索要cell
    for (int i = 0; i <numberOfcells ; i++) {
        // 取出i位置对应的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        // 优先从字典中取出cell
        DGWaterFlowViewCell *cell = self.displayingCells[@(i)];
        
        if ([self isInScreen:cellFrame]) { // 在屏幕上
            if (cell == nil) {
                cell = [self.dataSource waterFlowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                self.displayingCells[@(i)] = cell;
            }
        }else{ // 不在屏幕上
            if (cell) {
                // 把cell重屏幕上移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                // 放入缓存池
                [self.resuableCells addObject:cell];
            }
        }
    }
}

#pragma mark - 事件处理
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
   if (![self.delegate respondsToSelector:@selector(waterFlowView:didSelectAtIndex:)]) return;
 
    UITouch *touch = [touches anyObject];
    CGPoint point= [touch locationInView:self];

    
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, DGWaterFlowViewCell *cell , BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    if (selectIndex) {
        [self.delegate waterFlowView:self didSelectAtIndex:selectIndex.unsignedLongValue];
    }
    
}

#pragma mark - 私有方法

/**
 * 判断cell是否在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame
{
    return   (self.contentOffset.y < CGRectGetMaxY(frame) && (self.contentOffset.y + self.bounds.size.height) > CGRectGetMinY(frame));
}

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
