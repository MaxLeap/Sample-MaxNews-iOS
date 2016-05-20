//
//  MNCommentListVC.m
//  MaxNews
//
//  Created by luomeng on 16/5/16.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNCommentListVC.h"
#import "MNCommentListCell.h"

@interface MNCommentListVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *commentList;
@property (nonatomic, strong) NSMutableDictionary *commentedNews;
@end

@implementation MNCommentListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
    
    [self fetchMyCommentLists];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor greenColor];
    self.navigationItem.title = @"我的评论";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 110.0f;
    [self.tableView registerClass:[MNCommentListCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
}

- (void)fetchMyCommentLists {
    MLUser *currentUser = [MLUser currentUser];
    BOOL isLinked = [MLAnonymousUtils isLinkedWithUser:currentUser];
    if (!currentUser || isLinked) {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        return;
    }
    
    // Comment 表格中有两个Pointer 字段，查找时需指明 includeKey
    MLQuery *commentQuery = [MLQuery queryWithClassName:@"Comment"];
    [commentQuery whereKey:@"fromUserId" equalTo:currentUser.objectId];
    [commentQuery includeKey:@"fromUser"];
    [commentQuery includeKey:@"commentedNews"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count <= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:@"暂无评论!"];
            });
        } else {
            
            NSArray *sortedComments = [objects sortedArrayUsingComparator:^NSComparisonResult(MLObject *obj1, MLObject *obj2) {
                NSDate *date1 = obj1.createdAt;
                NSDate *date2 = obj2.createdAt;
                return [date2 compare:date1];
            }];
            self.commentList = sortedComments;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                
                [self.tableView reloadData];
            });
        }
    }];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNCommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MLObject *commentObj = self.commentList[indexPath.row];
    [cell updateContentWithCommentObj:commentObj];
    return cell;
}

@end
