//
//  CodeViewController.m
//  Coding
//
//  Created by apple on 2018/7/4.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "CodeViewController.h"
#import <WebKit/WKWebView.h>
#import "WebContentManager.h"

@interface CodeViewController ()<WKNavigationDelegate>
@property(nonatomic,strong)WKWebView *webContentView;
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicator;
@end

@implementation CodeViewController

#pragma mark - Init
+ (CodeViewController *)codeVCWithProject:(Project *)project andCodeFile:(CodeFile *)codeFile {
    CodeViewController *vc = [[CodeViewController alloc] init];
    vc.myProject = project;
    vc.myCodeFile = codeFile;
    return vc;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColorTableBG;
    self.title = self.isReadMe ? @"README" : [[_myCodeFile.path componentsSeparatedByString:@"/"] lastObject];
    
    //webView显示内容
    _webContentView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _webContentView.navigationDelegate = self;
    [self.view addSubview:_webContentView];
    
    //webView加载指示
    _activityIndicator = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:
                          UIActivityIndicatorViewStyleGray];
    _activityIndicator.hidesWhenStopped = YES;
    [_activityIndicator setCenter:CGPointMake(CGRectGetWidth(_webContentView.frame)/2, CGRectGetHeight(_webContentView.frame)/2)];
    [_webContentView addSubview:_activityIndicator];
    [_webContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self sendRequest];
    
}

#pragma mark - Request Data
- (void)sendRequest {
    [self.view beginLoading];
    __weak typeof(self) weakSelf = self;
    if (_isReadMe) {
        [[Coding_NetAPIManager sharedManager] request_ReadMeOfProject:_myProject andBlock:^(id data, NSError *error) {
            [weakSelf doSomethingWithResponse:data andError:error];
        }];
    } else {
        
    }
}

#pragma mark - Private Actions
- (void)doSomethingWithResponse:(id)data andError:(NSError *)error {
    [self.view endLoading];
    if ([data isKindOfClass:[CodeFile class]]) {
        self.myCodeFile = data;
        [self refreshCodeViewData];
    } else {
        self.myCodeFile = [CodeFile codeFileWithMDStr:data];
        [self refreshCodeViewData];
    }
    BOOL hasError = (error != nil && error.code != 1204);
    [self.view configBlankPage:EaseBlankPageTypeCode hasData:(data != nil) hasError:hasError reloadButtonBlock:^(id sender) {
        [self sendRequest];
    }];
    self.webContentView.hidden = hasError;
    [self configRightNavBtn];
}

- (void)refreshCodeViewData {
    if ([_myCodeFile.file.mode isEqualToString:@"image"]) {
         NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@u/%@/p/%@/git/raw/%@/%@", [NSObject baseURLStr], _myProject.owner_user_name, _myProject.name, _myCodeFile.ref, _myCodeFile.file.path]];
        [_webContentView loadRequest:[NSURLRequest requestWithURL:imageUrl]];
    } else if ([@[@"file", @"sym_link", @"executable"] containsObject:_myCodeFile.file.mode]) {
        NSString *contentStr = [WebContentManager codePatternedWithContent:_myCodeFile isEdit:NO];
        [_webContentView loadHTMLString:contentStr baseURL:nil];
    }
}

- (void)configRightNavBtn {
    if (!self.navigationItem.rightBarButtonItem) {
        if (_isReadMe) {
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tweetBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(goToEditVC)] animated:NO];
        }else{
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(rightNavBtnClicked)] animated:NO];
        }
    }
}

#pragma mark - Button Actions
- (void)goToEditVC {
    
}

- (void)rightNavBtnClicked {
    
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

@end
