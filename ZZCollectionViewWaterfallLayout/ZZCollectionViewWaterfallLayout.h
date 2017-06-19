//
//  ZZCollectionViewWaterfallLayout.h
//  ZZCollectionViewWaterfallLayout
//
//  Created by qdhl on 2017/6/16.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZZCollectionViewWaterfallLayoutProtocol <NSObject>

@required
- (CGSize)collectionview:(UICollectionView *)collectionview layout:(UICollectionViewLayout *)layout sizeForItemAtindex:(NSIndexPath *)index;

@end

@interface ZZCollectionViewWaterfallLayout : UICollectionViewLayout
@property (nonatomic, assign)NSInteger columCount;
@property (nonatomic, assign)CGFloat minColumSpace;
@property (nonatomic, assign)CGFloat minItemSpace;

@end
