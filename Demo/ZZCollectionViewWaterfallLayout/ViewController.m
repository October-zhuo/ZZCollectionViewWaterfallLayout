//
//  ViewController.m
//  ZZCollectionViewWaterfallLayout
//
//  Created by qdhl on 2017/6/16.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ViewController.h"
#import "ZZCollectionViewWaterfallLayout.h"
#import "ZZCollectionViewCell.h"

#define kCellCount 100
#define kCellID @"kCellID"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, ZZCollectionViewWaterfallLayoutProtocol>
@property (nonatomic, strong)UICollectionView *collectionview;
@property (nonatomic, strong)NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDataArrayIfNeeded];
    
    ZZCollectionViewWaterfallLayout *layout = [[ZZCollectionViewWaterfallLayout alloc] init];
    layout.columCount = 2;
    
    _collectionview = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionview.delegate = self;
    _collectionview.dataSource = self;
    [_collectionview registerClass:[ZZCollectionViewCell class] forCellWithReuseIdentifier:kCellID];
    _collectionview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionview];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return kCellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZZCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.imageView.image = self.dataArray[indexPath.row % 10];
    return cell;
}

- (NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)loadDataArrayIfNeeded{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 10; i ++) {
            NSString *tempString = [NSString stringWithFormat:@"Image-%zd",i];
            UIImage *image = [UIImage imageNamed:tempString];
            [_dataArray addObject:image];
        }
    }
}

- (CGSize)collectionview:(UICollectionView *)collectionview layout:(UICollectionViewLayout *)layout sizeForItemAtindex:(NSIndexPath *)index{
    UIImage *image = self.dataArray[index.row % 10];
    return image.size;
}
@end
