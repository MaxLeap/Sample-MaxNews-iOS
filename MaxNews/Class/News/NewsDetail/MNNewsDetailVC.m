//
//  MNNewsDetailVC.m
//  MaxNews
//
//  Created by luomeng on 16/5/13.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNNewsDetailVC.h"
#import "News.h"
#import <MaxSocialShare/MaxSocialShare.h>
#import "MNCommentCell.h"

static CGFloat const kBottomContainerH = 50.0f;
static CGFloat const kTableCellHeight = 90.0f;

static NSInteger const kCollectBtnTag = 5001;
static NSInteger const kSendBtnTag = 5002;

@interface MNNewsDetailVC () <UITextFieldDelegate,
 UITableViewDelegate,
 UITableViewDataSource,
 UIWebViewDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *clearHTMLString;
@property (nonatomic, strong) NSMutableArray *commentList; // [Comment]

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *bottomContainer;
@property (nonatomic, strong) UITextField *inputCommentField;
@property (nonatomic, strong) UIButton *collectOrSendBtn;

@property (nonatomic, assign) BOOL hasCompleteLoadComment;
@property (nonatomic, assign) BOOL hasFinishLoadContent;
@property (nonatomic, assign) BOOL hasForceRefresh; // 强制刷新一遍，fix UI Bug
@end

@implementation MNNewsDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
    
    [self loadNewsData];
    
    [self addObservers];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShowNotify:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHiddenNotify:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)buildUI {
    self.navigationItem.title = NSLocalizedString(@"News Detail", nil);
    
    UIImage *originalImg = [ImageNamed(@"btn_nav_share_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:originalImg style:UIBarButtonItemStylePlain target:self action:@selector(shareAction:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
    self.webView.delegate = self;
    
    CGRect tableFrame = CGRectMake(0, 0, screenW, screenH - kBottomContainerH);
    [self buildTableViewWithFrame:tableFrame];
    
    CGRect bottomContainerFrame = CGRectMake(0, screenH - kBottomContainerH - 64, screenW, kBottomContainerH);
    [self buildBottomContainerWithFrame:bottomContainerFrame];
}

- (void)buildTableViewWithFrame:(CGRect)frame {
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = kTableCellHeight;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[MNCommentCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
}

- (void)buildBottomContainerWithFrame:(CGRect)frame {
    self.bottomContainer = [[UIView alloc] initWithFrame:frame];
    self.bottomContainer.backgroundColor = UIColorFromRGBA(240, 242, 245, 1);
    [self.view addSubview:self.bottomContainer];
    
    CGFloat collectBtnW = 40;
    CGFloat inputFieldH = 40;
    CGFloat containerW = frame.size.width;
    CGFloat inputFieldW = containerW - collectBtnW - 5 * 3;
    self.inputCommentField = [[UITextField alloc] initWithFrame:CGRectMake(5, (kBottomContainerH - inputFieldH) / 2, inputFieldW, inputFieldH)];
    self.inputCommentField.delegate = self;
    self.inputCommentField.layer.cornerRadius = 8;
    self.inputCommentField.clipsToBounds = YES;
    self.inputCommentField.backgroundColor = [UIColor whiteColor];
    
    self.collectOrSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.inputCommentField.frame) + 5, (kBottomContainerH - collectBtnW) / 2, collectBtnW, collectBtnW)];
    [self.collectOrSendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.collectOrSendBtn setTitleColor:kNavigationBGColor forState:UIControlStateHighlighted];
    [self.collectOrSendBtn addTarget:self action:@selector(collectOrSendAction:) forControlEvents:UIControlEventTouchUpInside];
    [self configButtonIsCollectionState:YES];
    
    [self.bottomContainer addSubview:self.inputCommentField];
    [self.bottomContainer addSubview:self.collectOrSendBtn];
}

- (void)loadNewsData {
    NSString *contentLink = self.newsToShow.contentLink;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:contentLink] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
    
    [SVProgressHUD showWithStatus:@"loading..."];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error) {
            [SVProgressHUD showErrorWithStatus:@"加载失败"];
        } else {
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *filtedHtml = [self filteHtmlString:htmlString];
            [self.webView loadHTMLString:filtedHtml baseURL:nil];

            self.clearHTMLString = filtedHtml;
            
            [self loadCommentsForTheNews];
        }
    }];
    [dataTask resume];
}

- (void)loadCommentsForTheNews {
    
    // comment 表格中有一个Pointer->MLUser 字段， 查找时 指明include字段
    MLQuery *commentQuery = [MLQuery queryWithClassName:@"Comment"];
    [commentQuery includeKey:@"fromUser"];
    [commentQuery includeKey:@"commentedNews"];
    [commentQuery whereKey:@"belongNewsID" equalTo:self.newsToShow.objectId];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.hasCompleteLoadComment = YES;
        
        NSArray *sortedComments = [objects sortedArrayUsingComparator:^NSComparisonResult(MLObject *obj1, MLObject *obj2) {
            NSDate *date1 = obj1.createdAt;
            NSDate *date2 = obj2.createdAt;
            return [date2 compare:date1];
        }];
        
        self.commentList = [sortedComments mutableCopy];
        
        [self refreshContent];
    }];
}

- (void)refreshContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hasFinishLoadContent && self.hasCompleteLoadComment) {
            [SVProgressHUD dismiss];
            NSLog(@"============reload");
        }
        
        [self.tableView reloadData];
    });
}

- (NSString *)filteHtmlString:(NSString *)html {
    NSArray *filterDics = @[
            @{@"<div sax-type=\"sax_5\"" : @"</div>"},
            @{@"<nav class=\"sinaHead\"" : @"</nav>"},
            @{@"<aside>" : @"</aside>"},
            @{@"<section class=\"art_share_btn\">" : @"</body>"}
                            ];
    
    NSMutableString *result = [html mutableCopy];
    NSInteger i = 0;
    for (NSDictionary *filterDic in filterDics) {
        NSString *startStr = filterDic.allKeys.firstObject;
        NSString *endStr = filterDic.allValues.firstObject;
        
        NSScanner *scanner = [NSScanner scannerWithString:result];
        NSString *text = @"";
        while ([scanner isAtEnd] == NO) {
            // find start of tag
            [scanner scanUpToString:startStr intoString: NULL];
            // find end of tag
            [scanner scanUpToString:endStr intoString: &text];
            
            NSRange range = [result rangeOfString:[NSString stringWithFormat:@"%@%@", text, endStr]];
            if (i == filterDics.count - 1) {
                range = [result rangeOfString:text];
            }
            
            if (range.location != NSNotFound) {
                [result deleteCharactersInRange:range];
            }
        }
        
        i ++;
    }
    
    return result;
}

#pragma mark - actions
- (void)shareAction:(UIBarButtonItem *)item {
    
    [self.inputCommentField resignFirstResponder];
    
    [SVProgressHUD showWithStatus:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 腾讯，微博，微信都支持以下字段
        MLShareItem *webpageItem = [MLShareItem itemWithMediaType:MLSContentMediaTypeWebpage];
        webpageItem.title = self.newsToShow.newsTitle;
        webpageItem.detail = self.newsToShow.newsTitle;
        webpageItem.webpageURL = [NSURL URLWithString:self.newsToShow.contentLink];
        webpageItem.previewImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.newsToShow.previewImageLink]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            //        [MaxSocialShare shareItem:webpageItem completion:^(MLSActivityType activityType, BOOL completed, NSError * _Nullable activityError) {
            //            NSLog(@"error = %@", activityError);
            //            if (completed) {
            //                [SVProgressHUD showSuccessWithStatus:@"分享成功!"];
            //            } else {
            //                [SVProgressHUD showErrorWithStatus:@"分享失败!"];
            //            }
            //        }];
            
            // 若要兼容iPad， 需要container
            MaxSocialContainer *container = [MaxSocialContainer containerWithRect:self.view.frame inView:self.view];
            [MaxSocialShare shareItem:webpageItem withContainer:container completion:^(MLSActivityType activityType, BOOL completed, NSError * _Nullable activityError) {
                NSLog(@"error = %@", activityError);
                if (completed) {
                    [SVProgressHUD showSuccessWithStatus:@"分享成功!"];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"分享失败!"];
                }
            }];
        });
    });
}

- (MLUser *)currentNotLinkedUser {
    MLUser *currentUser = [MLUser currentUser];
    BOOL isLinkedUser = [MLAnonymousUtils isLinkedWithUser:currentUser];
    if (!currentUser || isLinkedUser) {
        return nil;
    }
    return currentUser;
}

- (void)collectOrSendAction:(UIButton *)button {
    if (button.tag == kCollectBtnTag) {
        [self collectTheNews];
    } else {
        NSString *comment = [self.inputCommentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (comment.length) {
            // 创建评论
            [self commentTheNews:comment];
        } else {
            [SVProgressHUD showErrorWithStatus:@"请先输入评论内容!"];
        }
    }
}

- (void)collectTheNews {
    MLUser *currentUser = [self currentNotLinkedUser];
    if (!currentUser) {
        [SVProgressHUD showErrorWithStatus:@"没有登录，不能收藏!"];
        return;
    }
    
    MLObject *collectionObj = [MLObject objectWithClassName:@"UserCollection"];
    collectionObj[@"collectedNews"] = self.newsToShow; // 在表格该字段为 Point 类型
    collectionObj[@"collectedByUserID"] = currentUser.objectId;
    [collectionObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"收藏成功，可以在个人收藏列表中查看!"];
        } else {
            [SVProgressHUD showErrorWithStatus:@"收藏失败，请稍后再试!"];
        }
    }];
}

- (void)commentTheNews:(NSString *)comment {
    MLUser *currentUser = [self currentNotLinkedUser];
    if (!currentUser) {
        [SVProgressHUD showErrorWithStatus:@"没有登录不能评论!"];
        return;
    }
    
    // 保存comment
    MLObject *commentObj = [MLObject objectWithClassName:@"Comment"];
    commentObj[@"belongNewsID"] = self.newsToShow.objectId;
    commentObj[@"commentedNews"] = self.newsToShow;
    commentObj[@"commentContent"] = comment;
    commentObj[@"fromUserId"] = currentUser.objectId;
    commentObj[@"fromUser"] = currentUser; // comment 表格中有一个Pointer->MLUser 字段
    [commentObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"评论成功！"];
            self.inputCommentField.text = @"";
            [self.inputCommentField resignFirstResponder];
            [self configButtonIsCollectionState:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.commentList insertObject:commentObj atIndex:0];
                [self.tableView reloadData];
            });
            
            // 文章的评论计数加1
            self.newsToShow.commentCount ++;
            [self.newsToShow saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded && self.commentSuccessBlock) {
                    self.commentSuccessBlock();
                }
            }];
        } else {
            [SVProgressHUD showErrorWithStatus:@"评论失败，请稍后再试!"];
        }
    }];
}

- (void)keyBoardWillShowNotify:(NSNotification *)notify {
    NSDictionary *userInfo = notify.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyBoardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyBoardH = keyBoardRect.size.height;
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    [UIView animateWithDuration:duration animations:^{
        self.bottomContainer.frame = CGRectMake(0, height - keyBoardH - kBottomContainerH, width, kBottomContainerH);
    } completion:^(BOOL finished) {
        [self configButtonIsCollectionState:false];
    }];
}

- (void)keyBoardWillHiddenNotify:(NSNotification *)notify {
    NSDictionary *userInfo = notify.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    [UIView animateWithDuration:duration animations:^{
        self.bottomContainer.frame = CGRectMake(0, height - kBottomContainerH, width, kBottomContainerH);
    } completion:^(BOOL finished) {
        [self configButtonIsCollectionState:true];
    }];
}

- (void)configButtonIsCollectionState:(BOOL)isCollectState {
    NSString *inputString = [self.inputCommentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (inputString.length) {
        isCollectState = NO;
    }
    
    if (isCollectState) {
        self.collectOrSendBtn.tag = kCollectBtnTag;
        [self.collectOrSendBtn setTitle:@"收藏" forState:UIControlStateNormal];
    } else {
        self.collectOrSendBtn.tag = kSendBtnTag;
        [self.collectOrSendBtn setTitle:@"发送" forState:UIControlStateNormal];
    }
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MLObject *commentObj = self.commentList[indexPath.row];
    
    [cell configCellWithComment:commentObj];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGSize contentSize = self.webView.scrollView.contentSize;
    return contentSize.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.clearHTMLString.length <= 0) {
        return nil;
    }
    
    CGSize contentSize = self.webView.scrollView.contentSize;
    self.webView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    self.webView.scrollView.scrollEnabled = false;
    
    return self.webView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGPoint offset = scrollView.contentOffset;
        if (offset.y > CGRectGetHeight(self.view.frame) / 3 && !_hasForceRefresh) {
            _hasForceRefresh = true;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *content = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (content.length) {
        [self commentTheNews:content];
    }
    
    textField.text = @"";
    [textField resignFirstResponder];
    
    return true;
}

#pragma mark - UIWebView delegate 

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.hasFinishLoadContent = YES;
    
    [self refreshContent];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"load error"];
    
    self.hasFinishLoadContent = YES;

    [self refreshContent];
}

@end
