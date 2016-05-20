//
//  MNUserCollectionsVC.m
//  MaxNews
//
//  Created by luomeng on 16/5/13.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNUserCollectionsVC.h"
#import "MNNewsCell.h"
#import "News.h"
#import "MNNewsDetailVC.h"

static NSString * const kCellId = @"newsCell";

@interface MNUserCollectionsVC () <
  UITableViewDelegate,
  UITableViewDataSource
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource; // [News]
@property (nonatomic, strong) NSArray *collections;
@end

@implementation MNUserCollectionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
    
    [self fetchMyCollections];
}

- (void)buildUI {
    self.navigationItem.title = NSLocalizedString(@"我的收藏", nil);
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 90;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MNNewsCell class] forCellReuseIdentifier:kCellId];
    [self.view addSubview:self.tableView];
}

- (void)fetchMyCollections {
    MLUser *currentUser = [MLUser currentUser];
    BOOL isLinkedUser = [MLAnonymousUtils isLinkedWithUser:currentUser];
    if (!currentUser || isLinkedUser) {
        [SVProgressHUD showErrorWithStatus:@"请先登录!"];
        return;
    }

    MLQuery *collectQuery = [MLQuery queryWithClassName:@"UserCollection"];
    [collectQuery whereKey:@"collectedByUserID" equalTo:currentUser.objectId];
    [collectQuery includeKey:@"collectedNews"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [collectQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"获取收藏失败，请稍后再试!"];
            });
        } else {
            if (objects.count <= 0) {
                [SVProgressHUD showInfoWithStatus:@"您还没有收藏！"];
                return;
            }
            
            self.collections = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
            });            
        }
    }];
}

- (void)showNewsDetail:(News *)news {
    MNNewsDetailVC *detailVC = [[MNNewsDetailVC alloc] init];
    detailVC.newsToShow = news;
    MNUserCollectionsVC *__weak weakSelf = self;
    detailVC.commentSuccessBlock = ^{
        [weakSelf.tableView reloadData];
    };
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UITableView delegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.collections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    MLObject *collectObj = self.collections[indexPath.row];
    News *news = collectObj[@"collectedNews"];
    [cell configCellWithNews:news];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MLObject *collectObj = self.collections[indexPath.row];
    News *news = collectObj[@"collectedNews"];
    
    [self showNewsDetail:news];
}

@end
