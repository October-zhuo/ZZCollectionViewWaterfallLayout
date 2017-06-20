//
//  ZZCollectionViewWaterfallLayout.m
//  ZZCollectionViewWaterfallLayout
//
//  Created by qdhl on 2017/6/16.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZCollectionViewWaterfallLayout.h"

///需要进行合并的cell frame个数。每20个合并一次
#define kUnionCount 20

@interface ZZCollectionViewWaterfallLayout()
///遵守瀑布流协议的代理
@property (nonatomic, weak)id<ZZCollectionViewWaterfallLayoutProtocol> ZZDelegate;
///存储cell布局属性的数组
@property (nonatomic, strong)NSMutableArray *itemAttributeArray;
///存储瀑布流每列列高的数组
@property (nonatomic, strong)NSMutableArray *columHeightArray;
///存储frame元素合并后元素的数组
@property (nonatomic, strong)NSMutableArray *unionRectArray;
@end

@implementation ZZCollectionViewWaterfallLayout

- (id<ZZCollectionViewWaterfallLayoutProtocol>)ZZDelegate{
    return (id<ZZCollectionViewWaterfallLayoutProtocol>)self.collectionView.delegate;
}

///初始化
- (instancetype)init{
    if (self = [super init]) {
        _minItemSpace = 10;
        _minColumSpace = 10;
        _columCount = 3;
    }
    return self;
}

#pragma mark - override method
- (void)prepareLayout{
    [self.itemAttributeArray removeAllObjects];
    [self.columHeightArray removeAllObjects];
    
    //init columHeightArray
    for (int i = 0; i < _columCount; i ++) {
        [self.columHeightArray addObject:@0];
    }
    //计算每个cell的宽度
    CGFloat itemWidth = (self.collectionView.bounds.size.width - (self.columCount + 2) * self.minColumSpace)/(CGFloat)self.columCount;
    
    NSInteger sections = [self.collectionView numberOfSections];
    for (int section = 0; section < sections; section ++) {
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        for (int idx = 0; idx < items; idx ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
            CGSize itemSize = [self.ZZDelegate collectionview:self.collectionView layout:self sizeForItemAtindex:indexPath];
            CGFloat itemHeight = itemSize.height * itemWidth/itemSize.width;
            NSInteger colum = [self findNextColum];
            CGFloat yOffset = [self.columHeightArray[colum] floatValue] + self.minItemSpace;
            CGFloat xOffset = (colum + 1)* self.minColumSpace + colum * itemWidth;
            CGRect frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
            UICollectionViewLayoutAttributes *attibutes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attibutes.frame = frame;
            //存储cell的布局属性
            [self.itemAttributeArray addObject:attibutes];
            //存储最新的列高度
            self.columHeightArray[colum] = @(yOffset + itemHeight);
        }
    }
    
    //将小的cell frame进行合并。每20个frame合并一次。最后不足20个元素的时候，单独合并一次。
    NSInteger index = 0;
    NSInteger attibutesCount = self.itemAttributeArray.count;
    while (index < attibutesCount) {
        CGRect rect = ((UICollectionViewLayoutAttributes *)self.itemAttributeArray[index]).frame;
        NSInteger endIndex = MIN(index + kUnionCount, attibutesCount);
        for (NSInteger i = index + 1; i < endIndex; i ++) {
            rect = CGRectUnion(rect, ((UICollectionViewLayoutAttributes *)self.itemAttributeArray[i]).frame);
        }
        [self.unionRectArray addObject:[NSValue valueWithCGRect:rect]];
        index = endIndex;
    }
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.itemAttributeArray[indexPath.row];
}

///根据将要显示的区域位置，返回cell的布局属性。该方法中会将已经合并的cell的布局属性进行拆分，单独取出每一个属性，存放进数组中，最后返回数组。
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSInteger begin = 0;
    NSInteger end = self.unionRectArray.count;
    
    NSMutableDictionary *cellAttibutesDict = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < self.unionRectArray.count; i ++) {
        if (CGRectIntersectsRect(rect, [self.unionRectArray[i] CGRectValue])) {
            begin = i * kUnionCount;
            break;
        }
    }
    
    for (int j = (int)self.unionRectArray.count - 1; j >= 0 ; j --) {
        if (CGRectIntersectsRect(rect, [self.unionRectArray[j] CGRectValue])) {
            end = MIN((j +1) * kUnionCount, self.itemAttributeArray.count);
            break;
        }
    }
    
    for (NSInteger i = begin; i < end; i ++) {
        UICollectionViewLayoutAttributes *attitubes = self.itemAttributeArray[i];
        if (CGRectIntersectsRect(rect, attitubes.frame)) {
            cellAttibutesDict[attitubes.indexPath] = attitubes;
        }
    }
    
    NSArray *result = cellAttibutesDict.allValues;
    return result;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    CGRect oldbounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldbounds)) {
        return  YES;
    }else{
        return NO;
    }
}

///返回collectionview的contentsize。是整个collectionview可以滚动的size。不是可视的size。
- (CGSize)collectionViewContentSize{
    CGFloat width = self.collectionView.bounds.size.width;
    CGFloat height = 0;
    for (int i = 0; i < _columCount; i ++) {
        if (height < [self.columHeightArray[i] floatValue]) {
            height = [self.columHeightArray[i] floatValue];
        }
    }
    return CGSizeMake(width, height);
}

///在瀑布流布局中寻找下一个元素应该摆放的列。即寻找高低最小的列。
- (NSInteger)findNextColum{
    NSInteger colum = 0;
    CGFloat minHeight = [self.columHeightArray[0] floatValue];
    for (int i = 0; i < _columCount; i ++) {
        if (minHeight > [self.columHeightArray[i] floatValue]) {
            minHeight = [self.columHeightArray[i] floatValue];
            colum = i;
        }
    }
    return colum;
}

#pragma mark - 懒加载
- (NSMutableArray *)itemAttributeArray{
    if (!_itemAttributeArray) {
        _itemAttributeArray = [[NSMutableArray alloc] init];
    }
    return _itemAttributeArray;
}

- (NSMutableArray *)columHeightArray{
    if (!_columHeightArray) {
        _columHeightArray = [[NSMutableArray alloc] init];
    }
    return _columHeightArray;
}

- (NSMutableArray *)unionRectArray{
    if (!_unionRectArray) {
        _unionRectArray = [[NSMutableArray alloc] init];
    }
    return _unionRectArray;
}
@end
