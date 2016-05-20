//
//  MNNewsViewController.m
//  MaxNews
//
//  Created by luomeng on 16/5/11.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNNewsViewController.h"
#import "MNSettingsViewController.h"
#import "News.h"
#import "MNNewsCell.h"
#import "MNHotNewsView.h"
#import "MNNewsDetailVC.h"

static NSInteger const kCateContainerHeight = 40;
static NSInteger const kShowCategoryCount = 6;
static NSInteger const kTableHeaderViewTag = 3009;
static CGFloat const kHotNewsViewHeight = 200.0;

@interface MNNewsViewController () <UITableViewDelegate,
 UITableViewDataSource,
 UIScrollViewDelegate
>
@property (nonatomic, strong) NSArray *categories; // 新闻分类，[MLObject]
@property (nonatomic, strong) UIButton *lastSelectedBtn;
@property (nonatomic, strong) UIScrollView *categoryContainer;

@property (nonatomic, strong) UIScrollView *contentContainer;
@property (nonatomic, strong) NSMutableArray *tableViews;
@property (nonatomic, strong) NSMutableDictionary *pageControls;
@property (nonatomic, strong) NSMutableDictionary *dataSources;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MNNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildUI];
    
    [self fetchData];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = NSLocalizedString(@"MaxNews", nil);
    
    UIImage *oriainalImg = [ImageNamed(@"btn_nav_personal_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:oriainalImg style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    self.categoryContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenW, kCateContainerHeight)];
    self.categoryContainer.showsHorizontalScrollIndicator = false;
    [self.view addSubview:self.categoryContainer];
    
    CGFloat contentOffsetY = CGRectGetMaxY(self.categoryContainer.frame);
    CGFloat contentHeight = CGRectGetHeight(self.view.frame) - contentOffsetY - 64;
    CGRect contentFrame = CGRectMake(0, contentOffsetY, screenW, contentHeight);
    self.contentContainer = [[UIScrollView alloc] initWithFrame:contentFrame];
    self.contentContainer.showsHorizontalScrollIndicator = false;
    self.contentContainer.pagingEnabled = YES;
    self.contentContainer.delegate = self;
    [self.view addSubview:self.contentContainer];
}

- (UIScrollView *)tableHeaderView {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kHotNewsViewHeight)];
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.pagingEnabled = YES;
    scrollView.tag = kTableHeaderViewTag;
    scrollView.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hotNewsTapGesture:)];
    [scrollView addGestureRecognizer:tapGesture];
    
    return scrollView;
}

- (UITableView *)tableViewWithFrame:(CGRect)frame {
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 90.0;
    tableView.tableHeaderView = [self tableHeaderView];
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:[MNNewsCell class] forCellReuseIdentifier:@"cell"];
    return tableView;
}

- (void)configCategoryScrollViewContainer {
    
    CGFloat btnW = CGRectGetWidth(self.view.bounds) / kShowCategoryCount;
    CGFloat btnH = kCateContainerHeight;
    self.categoryContainer.contentSize = CGSizeMake(self.categories.count * btnW, btnH);
    
    CGFloat tableW = CGRectGetWidth(self.view.bounds);
    CGFloat tableH = CGRectGetHeight(self.contentContainer.bounds);
    self.contentContainer.contentSize = CGSizeMake(self.categories.count * tableW, tableH);
    
    NSInteger i = 0;
    self.tableViews = [[NSMutableArray alloc] init];
    for (MLObject *cateObject in self.categories) {
        CGFloat btnX = btnW * i;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, 0, btnW, btnH)];
        [btn setTitle:cateObject[@"categoryName"] forState:UIControlStateNormal];
        [btn setTitleColor:kNavigationBGColor forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(touchedCategoryBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i + 1000;
        [self.categoryContainer addSubview:btn];
        
        CGFloat tableX = tableW * i;
        UITableView *tableView = [self tableViewWithFrame:CGRectMake(tableX, 0, tableW, tableH)];
        [self.contentContainer addSubview:tableView];
        tableView.backgroundColor = [UIColor whiteColor];
        [self.tableViews addObject:tableView];
        
        
        if (i == 0) {
            self.lastSelectedBtn = btn;
            [self touchedCategoryBtn:btn];
        }
        
        i ++;
    }
}

- (void)fetchData {
    self.pageControls = [[NSMutableDictionary alloc] init];
    self.dataSources = [[NSMutableDictionary alloc] init];
    
    // 查询 MaxLeap 云平台数据
    // 方法1. 不子类化 MLObject
    [SVProgressHUD showWithStatus:@"Loading..."];
    MLQuery *cateQuery = [MLQuery queryWithClassName:@"Category"];
    [cateQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error && objects.count <= 0) {
            [SVProgressHUD showErrorWithStatus:@"获取分类信息失败"];
        } else {
            self.categories = objects;
            [self configCategoryScrollViewContainer];
        }
    }];
}

- (void)fetchNewsWithCategoryID:(NSString *)categoryID {
    
    [self contentScrollToSelectedRect];
    NSArray *objects = self.dataSources[categoryID];
    if (objects) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"loading..."];
    });
    // 方法2: 子类化 MLObject, News 对应MaxLeap云平台数据库表格News
    MLQuery *newsQuery = [News query];
    [newsQuery whereKey:@"belongCategoryID" equalTo:categoryID];
    [newsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"获取新闻数据失败"];
        } else {
            [self.dataSources setObject:objects forKey:categoryID];
            
            [self configHotNewsScrollView];
            
            [self refreshContent];
            
        }
    }];
}

- (void)contentScrollToSelectedRect {
    NSUInteger index = [self currentSelectedIndex];
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat rectX = screenW * index;
    CGFloat rectH = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.categoryContainer.bounds) - 64;
    CGRect rect = CGRectMake(rectX , 0, screenW, rectH);
    [self.contentContainer scrollRectToVisible:rect animated:NO];
}

- (void)refreshContent {
    UITableView *currentTableView = [self currentShowedTableView];
    [currentTableView reloadData];
}

- (UITableView *)currentShowedTableView {
    NSInteger index = [self currentSelectedIndex];
    return index < self.tableViews.count ? self.tableViews[index] : nil;
}

- (NSUInteger)currentSelectedIndex {
    if (!self.lastSelectedBtn) {
        return 0;
    }
    NSUInteger index = self.lastSelectedBtn.tag - 1000;
    return index;
}

- (NSString *)currentCategoryId {
    NSUInteger index = [self currentSelectedIndex];
    if (index < self.categories.count) {
        MLObject *cateObj = self.categories[index];
        return cateObj.objectId;
    }
    return @"";
}

- (NSArray *)currentDataSource {
    NSString *currentCateId = [self currentCategoryId];
    NSArray *currentDataSource = self.dataSources[currentCateId];
    return currentDataSource;
}

- (UIScrollView *)currentHeaderScrollView {
    UITableView *currentTable = [self currentShowedTableView];
    UIScrollView *scrollView = [currentTable viewWithTag:kTableHeaderViewTag];
    return scrollView;
}

- (UIPageControl *)currentPageControl {
    NSString *currentCateId = [self currentCategoryId];
    return self.pageControls[currentCateId];
}

- (void)configHotNewsScrollView {
    NSString *currentCateId = [self currentCategoryId];
    NSArray *currentDataSource = self.dataSources[currentCateId];
    
    UIScrollView *hotNewsScrollView = [self currentHeaderScrollView];
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    hotNewsScrollView.contentSize = CGSizeMake(screenW * (currentDataSource.count + 2), kHotNewsViewHeight);
    
    for (NSInteger i = 0; i <= currentDataSource.count + 1; i ++) {
        News *hotNews;
        if (i == 0) {
            hotNews = currentDataSource.lastObject;
        } else if (i == currentDataSource.count + 1) {
            hotNews = currentDataSource.firstObject;
        } else {
            hotNews = currentDataSource[i - 1];
        }
        CGFloat hotX = screenW * i;
        CGRect hotRect = CGRectMake(hotX, 0, screenW, kHotNewsViewHeight);
        MNHotNewsView *hotNewsView = [[MNHotNewsView alloc] initWithFrame:hotRect];
        [hotNewsView configContentWithHotNews:hotNews];
        
        [hotNewsScrollView addSubview:hotNewsView];
    }
    
    // page control
    UIPageControl *pageControl = [self hotNewsPageControl];
    [[self currentShowedTableView] addSubview:pageControl];
    [self.pageControls setObject:pageControl forKey:[self currentCategoryId]];
    
    // hotNewsView 初始状态设置
    pageControl.currentPage = 0;
    CGRect rectInit = [self rectToShowForCurrentPage:1];
    [hotNewsScrollView scrollRectToVisible:rectInit animated:NO];
    
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

- (UIPageControl *)hotNewsPageControl {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat controlW = 100;
    CGFloat controlH = 30;
    CGFloat controlX = screenW - controlW;
    CGFloat controlY = kHotNewsViewHeight - controlH;
    CGRect rectInHeader = CGRectMake(controlX, controlY, controlW, controlH);
    CGRect rectInTable = [[self currentHeaderScrollView] convertRect:rectInHeader toView:[self currentShowedTableView]];
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:rectInTable];
    pageControl.numberOfPages = [self currentDataSource].count;
    pageControl.currentPage = 0;
    [pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
    return pageControl;
}

- (void)pageControlChanged:(UIPageControl *)pageControl {
    NSInteger currentPage = pageControl.currentPage;
    CGRect rectToShow = [self rectToShowForCurrentPage:currentPage];
    [[self currentHeaderScrollView] scrollRectToVisible:rectToShow animated:YES];
}

- (CGRect)rectToShowForCurrentPage:(NSInteger)currentPage {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGRect rectToShow = CGRectMake(currentPage * screenW, 0, screenW, kHotNewsViewHeight);
    return rectToShow;
}

- (void)synchronismCategoryContainerSelectedBtnIndex:(NSInteger)index {
    NSInteger btnTag = index + 1000;
    UIButton *btn = [self.categoryContainer viewWithTag:btnTag];
    
    [self touchedCategoryBtn:btn];
}

#pragma mark - actions
- (void)timerAction:(NSTimer *)timer {
    CGFloat offsetX = [self currentHeaderScrollView].contentOffset.x;
    NSInteger currentPage = offsetX / self.view.bounds.size.width;
    NSInteger newPage = currentPage + 1;
    CGRect rectToShow = [self rectToShowForCurrentPage:newPage];
    [[self currentHeaderScrollView] scrollRectToVisible:rectToShow animated:YES];
    
    NSInteger controlPage = newPage - 1;
    if (controlPage >= [self currentPageControl].numberOfPages) {
        controlPage = 0;
    }
    
    [self currentPageControl].currentPage = controlPage;
}

- (void)hotNewsTapGesture:(UITapGestureRecognizer *)tapGesture {
    UIScrollView *scrollHeader = (UIScrollView *)tapGesture.view;
    NSInteger index = scrollHeader.contentOffset.x / self.view.bounds.size.width;
    
    NSArray *dataSource = [self currentDataSource];
    if (dataSource.count <= 0) {
        return;
    }
    
    News *hotNews;
    if (index == 0) {
        hotNews = dataSource.lastObject;
    } else if (index >= dataSource.count + 1) {
        hotNews = dataSource.firstObject;
    } else {
        hotNews = dataSource[index - 1];
    }
    
    [self showNewsDetail:hotNews];
}

- (void)showSettingsAction:(id)sender {
    MNSettingsViewController *settingsVC = [[MNSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)touchedCategoryBtn:(UIButton *)btn {
    self.lastSelectedBtn.selected = NO;
    btn.selected = !btn.selected;
    self.lastSelectedBtn = btn;
    
    NSInteger index = btn.tag - 1000;
    MLObject *category = self.categories[index];
    [self fetchNewsWithCategoryID:category.objectId];
    
    if (index < 3) {
        [self scrollCategoryContainerToLeft];
    }
    
    if (index >= 3) {
        [self scrollCategoryContainerToRight];
    }
}

- (void)scrollCategoryContainerToLeft {
    [self.categoryContainer scrollRectToVisible:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kCateContainerHeight) animated:YES];
}

- (void)scrollCategoryContainerToRight {
    [self.categoryContainer scrollRectToVisible:CGRectMake(CGRectGetWidth(self.view.bounds) / kShowCategoryCount, 0, CGRectGetWidth(self.view.bounds), kCateContainerHeight) animated:YES];
}

- (void)showNewsDetail:(News *)news {
    MNNewsDetailVC *newsDetailVC = [[MNNewsDetailVC alloc] init];
    newsDetailVC.newsToShow = news;
    newsDetailVC.hidesBottomBarWhenPushed = YES;
    MNNewsViewController *__weak weakSelf = self;
    newsDetailVC.commentSuccessBlock = ^() {
        [weakSelf refreshContent];
    };
    [self.navigationController pushViewController:newsDetailVC animated:YES];
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == kTableHeaderViewTag) {
        CGFloat offsetX = scrollView.contentOffset.x;
        NSInteger currentPage = offsetX / self.view.bounds.size.width;
        
        if (currentPage == 0) {
            CGRect lastRect = [self rectToShowForCurrentPage:[self currentDataSource].count];
            [[self currentHeaderScrollView] scrollRectToVisible:lastRect animated:NO];
        } else if (currentPage > [self currentPageControl].numberOfPages) {
            CGRect rectReset = [self rectToShowForCurrentPage:1];
            [[self currentHeaderScrollView] scrollRectToVisible:rectReset animated:NO];
        }
        
        NSInteger minPage = 0;
        NSInteger maxPage = [self currentPageControl].numberOfPages;
        currentPage = currentPage < minPage ? minPage : currentPage;
        currentPage = currentPage > maxPage ? 1 : currentPage;
        
        currentPage = currentPage == 0 ? maxPage : currentPage;
        [self currentPageControl].currentPage = currentPage - 1;
    } else if (scrollView == self.contentContainer) {
        CGFloat offsetX = scrollView.contentOffset.x;
        NSInteger currentPage = offsetX / self.view.bounds.size.width;
        [self synchronismCategoryContainerSelectedBtnIndex:currentPage];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView.tag == kTableHeaderViewTag) {
        CGFloat offsetX = scrollView.contentOffset.x;
        NSInteger currentPage = offsetX / self.view.bounds.size.width;
        if (currentPage > [self currentPageControl].numberOfPages) {
            CGRect rectReset = [self rectToShowForCurrentPage:1];
            [[self currentHeaderScrollView] scrollRectToVisible:rectReset animated:NO];
        }
    }
}

#pragma mark - UITableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self currentDataSource].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    News *news = [self currentDataSource][indexPath.row];
    [cell configCellWithNews:news];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    News *selectedNews = [self currentDataSource][indexPath.row];
    [self showNewsDetail:selectedNews];
}

@end
