//
//  ViewController.m
//  SearchBarTest
//
//  Created by qdhl on 2017/6/22.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong)UISearchBar *searchBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, 50)];
    [self.view addSubview:_searchBar];
}



@end
