//
//  MNSettingsViewController.m
//  MaxNews
//
//  Created by luomeng on 16/5/11.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNSettingsViewController.h"
#import "MCPersonalViewController.h"
#import "MNSupportViewController.h"
#import "MNUserCollectionsVC.h"
#import "MNCommentListVC.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kCellID = @"cellID";

@interface MNSettingsViewController () <
 UITableViewDelegate,
 UITableViewDataSource
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *tableDataSource;
@property (nonatomic, strong) UIButton *loginInfoBtn;
@property (nonatomic, strong) UIImageView *userIconImgView;
@end

@implementation MNSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableDataSource = @[
            @[@"收藏文章", @"评论记录"],
            @[@"支持帮助", @"版本"]
                             ];
    
    [self buildUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self hasLoggedIn]) {
        [self.loginInfoBtn setTitle:@"账号信息" forState:UIControlStateNormal];
        
        NSURL *iconURL = [NSURL URLWithString:[[MLUser currentUser] objectForKey:@"iconUrl"]];
        [self.userIconImgView sd_setImageWithURL:iconURL placeholderImage:ImageNamed(@"ic_personal_head")];
    } else {
        [self.loginInfoBtn setTitle:@"登录 / 注册" forState:UIControlStateNormal];
        
        self.userIconImgView.image = ImageNamed(@"ic_personal_head");
    }
}

- (void)buildUI {
    self.navigationItem.title = NSLocalizedString(@"个人中心", nil);
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 56.0f;
    self.tableView.tableHeaderView = [self tableHeaderView];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = UIColorFromRGBA(245, 245, 245, 1);
    [self.view addSubview:self.tableView];
}

- (UIView *)tableHeaderView {
    CGRect headerFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 200);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    
    CAGradientLayer *bgLayer = [[CAGradientLayer alloc] init];
    bgLayer.colors = @[(id)UIColorFromRGBA(255, 119, 0, 1).CGColor, (id)UIColorFromRGBA(252, 175, 113, 1).CGColor];
    bgLayer.startPoint = CGPointMake(0, 0);
    bgLayer.endPoint = CGPointMake(0, 1);
    bgLayer.frame = headerFrame;
    [headerView.layer addSublayer:bgLayer];
    
    BOOL hasLoggedIn = [self hasLoggedIn];
    CGFloat userImgWidth = 75;
    CGFloat userOffSetY = 30;
    CGFloat userImgX = (CGRectGetWidth(self.view.bounds) - userImgWidth) / 2;
    CGRect userPlaceholderFrame = CGRectMake(userImgX, userOffSetY, userImgWidth, userImgWidth);
    [headerView addSubview:[self userIconWithFrame:userPlaceholderFrame hasLoggedIn:hasLoggedIn]];
    
    CGFloat btnW = 150;
    CGFloat btnH = 35;
    CGFloat btnX = (CGRectGetWidth(self.view.bounds) - btnW) / 2;
    CGFloat btnY = CGRectGetMaxY(userPlaceholderFrame) + 25;
    CGRect infoFrame = CGRectMake(btnX, btnY, btnW, btnH);
    NSString *btnTitle = hasLoggedIn ? @"账号信息" : @"登录 / 注册";
    [headerView addSubview:[self loginBtnWithTitle:btnTitle frame:infoFrame]];
    
    return headerView;
}

- (BOOL)hasLoggedIn {
    MLUser *currentUser = [MLUser currentUser];
    if (!currentUser || [MLAnonymousUtils isLinkedWithUser:currentUser]) {
        return NO;
    }
    return YES;
}

- (UIImageView *)userIconWithFrame:(CGRect)frame hasLoggedIn:(BOOL)hasLogged {
    UIImageView *userPlaceholder = [[UIImageView alloc] initWithFrame:frame];
    userPlaceholder.layer.cornerRadius = frame.size.width / 2;
    userPlaceholder.clipsToBounds = YES;
    if (hasLogged) {
        MLUser *currentUser = [MLUser currentUser];
        NSURL *iconURL = [NSURL URLWithString:[currentUser objectForKey:@"iconUrl"]];
        [userPlaceholder sd_setImageWithURL:iconURL placeholderImage:ImageNamed(@"ic_personal_head")];
    } else {
        userPlaceholder.image = ImageNamed(@"ic_personal_head");
    }
    
    self.userIconImgView = userPlaceholder;
    return userPlaceholder;
}

- (UIButton *)loginBtnWithTitle:(NSString *)title frame:(CGRect)frame {
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setBackgroundImage:[UIImage imageWithColor:kNavigationBGColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(252, 175, 113, 1)] forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.layer.cornerRadius = frame.size.height / 2;
    btn.clipsToBounds = YES;
    [btn addTarget:self action:@selector(showPersionalViewController) forControlEvents:UIControlEventTouchUpInside];
    
    self.loginInfoBtn = btn;
    return btn;
}

- (NSString *)currentVersionInfo {
    NSString *infoPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *infoDic = [NSDictionary dictionaryWithContentsOfFile:infoPath];
    NSString *versionInfo = infoDic[@"CFBundleShortVersionString"];
    NSString *buildInfo = infoDic[@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ (%@)", versionInfo, buildInfo];
}

#pragma mark - actions

- (void)showPersionalViewController {
    MCPersonalViewController *personalVC = [[MCPersonalViewController alloc] initWithNibName:@"MCPersonalViewController" bundle:nil];
    [self.navigationController pushViewController:personalVC animated:YES];
}

- (void)showSupport {
    MNSupportViewController *supportVC = [[MNSupportViewController alloc] init];
    [self.navigationController pushViewController:supportVC animated:YES];
}

- (void)showUserCollections {
    MLUser *currentUser = [MLUser currentUser];
    BOOL isLinked = [MLAnonymousUtils isLinkedWithUser:currentUser];
    if (!currentUser || isLinked) {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        return;
    }
    
    MNUserCollectionsVC *collectionVC = [[MNUserCollectionsVC alloc] init];
    [self.navigationController pushViewController:collectionVC animated:YES];
}

- (void)showCommentHistory {
    MLUser *currentUser = [MLUser currentUser];
    BOOL isLinked = [MLAnonymousUtils isLinkedWithUser:currentUser];
    if (!currentUser || isLinked) {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        return;
    }

    MNCommentListVC *commentListVC = [[MNCommentListVC alloc] init];
    [self.navigationController pushViewController:commentListVC animated:YES];
}


#pragma mark - UITableView Delegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionDatas = self.tableDataSource[section];
    return sectionDatas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section ? 8.0 : 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = section ? 8.0f : 0.01f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), headerHeight)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    NSString *cellTitle = self.tableDataSource[indexPath.section][indexPath.row];
    cell.textLabel.text = cellTitle;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.imageView.image = nil;
    UIView *versionView = [cell.contentView viewWithTag:9009];
    [versionView removeFromSuperview];
    
    if ([cellTitle isEqualToString:@"版本"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *versionLabel = [[UILabel alloc] init];
        versionLabel.tag = 9009;
        versionLabel.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 15 - 150, 0, 150, 56.0f);
        versionLabel.textAlignment = NSTextAlignmentRight;
        versionLabel.text = [self currentVersionInfo];
        [cell.contentView addSubview:versionLabel];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self showUserCollections];
        } else {
            [self showCommentHistory];
        }
    } else {
        if (indexPath.row == 0) {
            [self showSupport];
        }
    }
}

@end
