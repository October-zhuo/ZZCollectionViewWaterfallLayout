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

NSString *const ZZCollectionViewWaterfallLayoutHeader = @"ZZCollectionViewWaterfallLayoutHeader";
NSString *const ZZCollectionViewWaterfallLayoutFooter = @"ZZCollectionViewWaterfallLayoutFooter";

@interface ZZCollectionViewWaterfallLayout()
///遵守瀑布流协议的代理
@property (nonatomic, weak)id<ZZCollectionViewWaterfallLayoutProtocol> ZZDelegate;
///存储cell布局属性的数组
@property (nonatomic, strong)NSMutableArray *itemAttributeArray;
///存储header布局属性的数组
@property (nonatomic, strong)NSMutableArray *headerAttributeArray;
///存储footer布局属性的数组
@property (nonatomic, strong)NSMutableArray *footerAttributeArray;
///存储不同section布局属性的数组
@property (nonatomic, strong)NSMutableArray *sectionAttibuteArray;
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
        _headerHeight = 40;
        _footerHeight = 40;
    }
    return self;
}

#pragma mark - override setter
- (void)setColumCount:(NSInteger)columCount{
    if (columCount != _columCount) {
        _columCount = columCount;
        [self invalidateLayout];
    }
}

- (void)setMinItemSpace:(CGFloat)minItemSpace{
    if (minItemSpace != _minItemSpace) {
        _minItemSpace = minItemSpace;
        [self invalidateLayout];
    }
}

- (void)setMinColumSpace:(CGFloat)minColumSpace{
    if (minColumSpace != _minItemSpace) {
        _minItemSpace = minColumSpace;
        [self invalidateLayout];
    }
}

- (void)setFooterHeight:(CGFloat)footerHeight{
    if (footerHeight != _footerHeight) {
        _footerHeight = footerHeight;
        [self invalidateLayout];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight{
    if (headerHeight != _headerHeight) {
        _headerHeight = headerHeight;
        [self invalidateLayout];
    }
}

#pragma mark - override collectionview method
- (void)prepareLayout{
    [self.columHeightArray removeAllObjects];
    [self.itemAttributeArray removeAllObjects];
    [self.headerAttributeArray removeAllObjects];
    [self.footerAttributeArray removeAllObjects];
    [self.sectionAttibuteArray removeAllObjects];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    ///初始化列高度
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex ++) {
        
        NSInteger myColumCount = 0;
        if ([self.ZZDelegate respondsToSelector:@selector(collectionview:layout:columCountAtSection:)]) {
            myColumCount = [self.ZZDelegate collectionview:self.collectionView layout:self columCountAtSection:sectionIndex];
        }else{
            myColumCount = _columCount;
        }
        NSMutableArray *tempHeightArray = [[NSMutableArray alloc] init];
        for (NSInteger columIndex = 0; columIndex < myColumCount; columIndex ++) {
            tempHeightArray[columIndex] = @0;
        }
        [self.columHeightArray addObject:tempHeightArray];
    }
    
    
    ///计算每个section的属性
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex ++) {
        
        //计算基础数据
        NSInteger myColumCount = 0;
        if ([self.ZZDelegate respondsToSelector:@selector(collectionview:layout:columCountAtSection:)]) {
            myColumCount = [self.ZZDelegate collectionview:self.collectionView layout:self columCountAtSection:sectionIndex];
        }else{
            myColumCount = _columCount;
        }
        
        CGFloat myMinColumSpace = 0.0;
        if ([self.ZZDelegate respondsToSelector:@selector(collectionview:layout:minColumSpaceAtSection:)]) {
            myMinColumSpace = [self.ZZDelegate collectionview:self.collectionView layout:self minColumSpaceAtSection:sectionIndex];
        }else{
            myMinColumSpace = _minColumSpace;
        }
        
        CGFloat myMinItemSpace = 0.0;
        if ([self.ZZDelegate respondsToSelector:@selector(collectionview:layout:minItemSpaceAtSection:)]) {
            myMinItemSpace = [self.ZZDelegate collectionview:self.collectionView layout:self minItemSpaceAtSection:sectionIndex];
        }else{
            myMinItemSpace = _minItemSpace;
        }
        
        CGFloat myHeaderViewHeight = 0.0;
        if ([self.ZZDelegate respondsToSelector:@selector(collectionview:layout:headerHeightAtSection:)]) {
            myHeaderViewHeight = [self.ZZDelegate collectionview:self.collectionView layout:self headerHeightAtSection:sectionIndex];
        }else{
            myHeaderViewHeight = _headerHeight;
        }
        
        
        CGFloat myFooterViewHeight = 0.0;
        if ([self.ZZDelegate respondsToSelector:@selector(collectionview:layout:footerHeightAtSection:)]) {
            myFooterViewHeight = [self.ZZDelegate collectionview:self.collectionView layout:self footerHeightAtSection:sectionIndex];
        }else{
            myFooterViewHeight = _footerHeight;
        }
        
        //计算每个cell的宽度
        CGFloat itemWidth = (self.collectionView.bounds.size.width - (myColumCount + 1) * myMinColumSpace)/(CGFloat)myColumCount;
        
         ///计算header的attribute
        if (myHeaderViewHeight > 0) {
            UICollectionViewLayoutAttributes *headerAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ZZCollectionViewWaterfallLayoutHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
            headerAttribute.frame = CGRectMake(0, 0, self.collectionView.bounds.size.width, myHeaderViewHeight);
            self.headerAttributeArray[sectionIndex] = headerAttribute;
            [self.itemAttributeArray addObject:headerAttribute];
            
            //init columHeightArray
            for (int i = 0; i < myColumCount; i ++) {
                CGFloat height = CGRectGetMaxY(headerAttribute.frame);
                self.columHeightArray[sectionIndex][i] = @(height);
            }
        }
        
        ///计算每个item的attribute
        NSInteger sections = [self.collectionView numberOfSections];
        NSMutableArray *tempItemAttributes = [[NSMutableArray alloc] init];
        for (int section = 0; section < sections; section ++) {
            NSInteger items = [self.collectionView numberOfItemsInSection:section];
            for (int idx = 0; idx < items; idx ++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
                CGSize itemSize = [self.ZZDelegate collectionview:self.collectionView layout:self sizeForItemAtindex:indexPath];
                CGFloat itemHeight = itemSize.height * itemWidth/itemSize.width;
                NSInteger colum = [self findNextColumAtSection:sectionIndex];
                CGFloat yOffset = [self.columHeightArray[sectionIndex][colum] floatValue] + self.minItemSpace;
                CGFloat xOffset = (colum + 1)* self.minColumSpace + colum * itemWidth;
                CGRect frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
                UICollectionViewLayoutAttributes *attibutes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attibutes.frame = frame;
                //存储cell的布局属性
                [self.itemAttributeArray addObject:attibutes];
                //存储最新的列高度
                self.columHeightArray[sectionIndex][colum] = @(yOffset + itemHeight);
                [tempItemAttributes addObject:attibutes];
            }
        }
        [self.sectionAttibuteArray addObject:tempItemAttributes];
        
        ///计算footerView的attribute
        if (myFooterViewHeight > 0) {
            UICollectionViewLayoutAttributes *footerAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ZZCollectionViewWaterfallLayoutHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
            NSInteger colum = [self findHeightestColumAtSection:sectionIndex];
            CGFloat yOffset = [self.columHeightArray[sectionIndex][colum] floatValue] + self.minItemSpace;
            footerAttribute.frame = CGRectMake(0, yOffset, self.collectionView.bounds.size.width, myFooterViewHeight);
            self.footerAttributeArray[sectionIndex] = footerAttribute;
            [self.itemAttributeArray addObject:footerAttribute];
            
            //init columHeightArray
            for (int i = 0; i < myColumCount; i ++) {
                self.columHeightArray[sectionIndex][i] =  @(CGRectGetMaxY(footerAttribute.frame));
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
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.sectionAttibuteArray[indexPath.section][indexPath.row];
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
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (NSInteger i = 0; i < sectionCount; i++) {
        //计算基础数据
        NSInteger myColumCount = 0;
        if ([self.ZZDelegate respondsToSelector:@selector(collectionview:layout:columCountAtSection:)]) {
            myColumCount = [self.ZZDelegate collectionview:self.collectionView layout:self columCountAtSection:i];
        }else{
            myColumCount = _columCount;
        }
        
        for (int j = 0; j < myColumCount; j ++) {
            if (height < [self.columHeightArray[i][j] floatValue]) {
                height = [self.columHeightArray[i][j] floatValue];
            }
        }

    }
    return CGSizeMake(width, height);
}

///在瀑布流布局中寻找下一个元素应该摆放的列。即寻找高低最小的列。
- (NSInteger)findNextColumAtSection:(NSInteger) section{
    NSInteger colum = 0;
    CGFloat minHeight = [self.columHeightArray[section][0] floatValue];
    for (int i = 0; i < _columCount; i ++) {
        if (minHeight > [self.columHeightArray[section][i] floatValue]) {
            minHeight = [self.columHeightArray[section][i] floatValue];
            colum = i;
        }
    }
    return colum;
}

- (NSInteger)findHeightestColumAtSection:(NSInteger) section{
    NSInteger colum = 0;
    CGFloat maxHeight = [self.columHeightArray[section][0] floatValue];
    for (int i = 0; i < _columCount; i ++) {
        if (maxHeight < [self.columHeightArray[section][i] floatValue]) {
            maxHeight = [self.columHeightArray[section][i] floatValue];
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

- (NSMutableArray *)headerAttributeArray{
    if (!_headerAttributeArray) {
        _headerAttributeArray = [[NSMutableArray alloc] init];
    }
    return _headerAttributeArray;
}

- (NSMutableArray *)footerAttributeArray{
    if (!_footerAttributeArray) {
        _footerAttributeArray = [[NSMutableArray alloc] init];
    }
    return _footerAttributeArray;
}

- (NSMutableArray *)sectionAttibuteArray{
    if (!_sectionAttibuteArray) {
        _sectionAttibuteArray = [[NSMutableArray alloc] init];
    }
    return _sectionAttibuteArray; 
}
@end
