//
//  ZZCollectionViewWaterfallLayout.m
//  ZZCollectionViewWaterfallLayout
//
//  Created by qdhl on 2017/6/16.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZCollectionViewWaterfallLayout.h"

#define kUnionCount 20

@interface ZZCollectionViewWaterfallLayout()
@property (nonatomic, weak)id<ZZCollectionViewWaterfallLayoutProtocol> ZZdelegate;
@property (nonatomic, strong)NSMutableArray *itemAttributeArray;
@property (nonatomic, strong)NSMutableArray *columHeightArray;
@property (nonatomic, strong)NSMutableArray *unionRectArray;
@end

@implementation ZZCollectionViewWaterfallLayout

- (id<ZZCollectionViewWaterfallLayoutProtocol>)ZZdelegate{
    return (id<ZZCollectionViewWaterfallLayoutProtocol>)self.collectionView.delegate;
}

- (instancetype)init{
    if (self = [super init]) {
        _minItemSpace = 10;
        _minColumSpace = 10;
        _columCount = 3;
    }
    return self;
}

- (void)prepareLayout{
    [self.itemAttributeArray removeAllObjects];
    [self.columHeightArray removeAllObjects];
    
    //init columHeightArray
    for (int i = 0; i < _columCount; i ++) {
        [self.columHeightArray addObject:@0];
    }
    
    CGFloat itemWidth = (self.collectionView.bounds.size.width - (self.columCount + 2) * self.minColumSpace)/(CGFloat)self.columCount;
    
    NSInteger sections = [self.collectionView numberOfSections];
    for (int section = 0; section < sections; section ++) {
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        for (int idx = 0; idx < items; idx ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
            CGSize itemSize = [self.ZZdelegate collectionview:self.collectionView layout:self sizeForItemAtindex:indexPath];
            CGFloat itemHeight = itemSize.height * itemWidth/itemSize.width;
            NSInteger colum = [self findNextColum];
            CGFloat yOffset = [self.columHeightArray[colum] floatValue] + self.minItemSpace;
            CGFloat xOffset = (colum + 1)* self.minColumSpace + colum * itemWidth;
            CGRect frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
            UICollectionViewLayoutAttributes *attibutes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attibutes.frame = frame;
            [self.itemAttributeArray addObject:attibutes];
            self.columHeightArray[colum] = @(yOffset + itemHeight);
        }
    }
    
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
