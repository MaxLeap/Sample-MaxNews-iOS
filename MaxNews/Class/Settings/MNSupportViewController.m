//
//  MNSupportViewController.m
//  MaxNews
//
//  Created by luomeng on 16/5/11.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNSupportViewController.h"
#import <MLHelpCenter/MLHelpCenter.h>

@interface MNSupportViewController () <
  UITableViewDataSource,
  UITableViewDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation MNSupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildUI];
    
    self.dataSource = @[
            NSLocalizedString(@"FAQ", nil),
            NSLocalizedString(@"Ask Support(Email)", nil),
            NSLocalizedString(@"Ask Support(Chat with us)", nil)
                        ];
}

- (void)buildUI {
    self.view.backgroundColor = UIColorFromRGBA(242, 242, 242, 1);
    
    self.navigationItem.title = NSLocalizedString(@"Support", nil);
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - row actions

- (void)toSendEmail {
    [SVProgressHUD showErrorWithStatus:@"Please set up your support email"];
}

- (void)toShowFAQ {
    [SVProgressHUD showSuccessWithStatus:@"你随时可以在MaxLeap后台动态配置这些FAQ。"];
    [[MLHelpCenter sharedInstance] showFAQs:self];
}

- (void)toChatWithUs {
    [[MLHelpCenter sharedInstance] showConversation:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self toShowFAQ];
    } else if (indexPath.row == 1) {
        [self toSendEmail];
    } else if (indexPath.row == 2) {
        [self toChatWithUs];
    }
}

@end
