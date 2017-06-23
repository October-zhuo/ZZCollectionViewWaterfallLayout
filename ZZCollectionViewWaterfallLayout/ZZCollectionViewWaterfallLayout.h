//
//  ZZCollectionViewWaterfallLayout.h
//  ZZCollectionViewWaterfallLayout
//
//  Created by qdhl on 2017/6/16.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 流水布局协议
 */
@protocol ZZCollectionViewWaterfallLayoutProtocol <NSObject>

/**
 布局必须实现的协议。返回每个collectionview的cell的size。
 collectionview：要显示的view
 layout：瀑布流布局layout
 index：需要布局的cell的索引
 */
@required
- (CGSize)collectionview:(UICollectionView *)collectionview layout:(UICollectionViewLayout *)layout sizeForItemAtindex:(NSIndexPath *)index;

@optional
/**
 返回对应section中要排列的列数。如果不实现该方法，就使用columCount。
 collectionview：要显示的view
 layout：瀑布流布局layout
 section：需要布局的section的索引
 */
- (NSInteger)collectionview:(UICollectionView *)collectionview layout:(UICollectionViewLayout *)layout columCountAtSection:(NSInteger)section;
/**
 返回对应section中最小的列间距。如果不实现该方法，就使用minColumSpace。
 collectionview：要显示的view
 layout：瀑布流布局layout
 section：需要布局的section的索引
 */
- (CGFloat)collectionview:(UICollectionView *)collectionview layout:(UICollectionViewLayout *)layout minColumSpaceAtSection:(NSInteger)section;
/**
 返回对应section中最小的行间距。如果不实现该方法，就使用minItemSpace。
 collectionview：要显示的view
 layout：瀑布流布局layout
 section：需要布局的section的索引
 */
- (CGFloat)collectionview:(UICollectionView *)collectionview layout:(UICollectionViewLayout *)layout minItemSpaceAtSection:(NSInteger)section;
/**
 返回对应section中footer的高度。如果不实现该方法，就使用footerHeight。
 collectionview：要显示的view
 layout：瀑布流布局layout
 section：需要布局的section的索引
 */
- (CGFloat)collectionview:(UICollectionView *)collectionview layout:(UICollectionViewLayout *)layout headerHeightAtSection:(NSInteger)section;
/**
 返回对应section中header的高度。如果不实现该方法，就使用headerHeight。
 collectionview：要显示的view
 layout：瀑布流布局layout
 section：需要布局的section的索引
 */
- (CGFloat)collectionview:(UICollectionView *)collectionview layout:(UICollectionViewLayout *)layout footerHeightAtSection:(NSInteger)section;
@end

@interface ZZCollectionViewWaterfallLayout : UICollectionViewLayout
/**
 瀑布流布局的列数，默认是3；
 */
@property (nonatomic, assign)NSInteger columCount;
/**
 瀑布流布局的最小列间距，默认是10；
 */
@property (nonatomic, assign)CGFloat minColumSpace;
/**
 瀑布流布局的最小行间距，默认是10；
 */
@property (nonatomic, assign)CGFloat minItemSpace;
/**
 瀑布流布局的header高度,默认是40；
 */
@property (nonatomic ,assign)CGFloat headerHeight;
/**
 瀑布流布局的footer高度，默认是40；
 */
@property (nonatomic, assign)CGFloat footerHeight;

@end
