//
//  ViewController.m
//  UIWebViewTest
//
//  Created by Tang Qiao on 12-4-10.
//  Copyright (c) 2012年 Netease. All rights reserved.
//

#import "ViewController.h"
#import "JrtzSignature.h"

@interface ViewController ()<UIWebViewDelegate>
@end

@implementation ViewController
@synthesize webView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.


    [self setupNavigationItem];
    // [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];

    // [self createLocalUIWebView];
    [self createUIWebView];

}


#pragma mark - UI
- (void)setupNavigationItem{
    // 后退按钮
    UIButton * goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goBackButton setImage:[UIImage imageNamed:@"backbutton"] forState:UIControlStateNormal];
    [goBackButton addTarget:self action:@selector(goBackAction:) forControlEvents:UIControlEventTouchUpInside];
    goBackButton.frame = CGRectMake(0, 0, 30, StatusBarAndNavigationBarHeight);
    UIBarButtonItem * goBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    
    UIBarButtonItem * jstoOc = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStyleDone target:self action:@selector(localHtmlClicked)];
    self.navigationItem.leftBarButtonItems = @[goBackButtonItem,jstoOc];
    
    // 刷新按钮
    UIButton * refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setImage:[UIImage imageNamed:@"webRefreshButton"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    refreshButton.frame = CGRectMake(0, 0, 30, StatusBarAndNavigationBarHeight);
    UIBarButtonItem * refreshButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    
    UIBarButtonItem * ocToJs = [[UIBarButtonItem alloc] initWithTitle:@"调仓" style:UIBarButtonItemStyleDone target:self action:@selector(ocToJs)];
    self.navigationItem.rightBarButtonItems = @[refreshButtonItem, ocToJs];
    
    self.navigationController.navigationBar.translucent = YES;
}

#pragma mark - KVO
//kvo 监听进度 必须实现此方法
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == self.webView) {
        
        // NSLog(@"网页加载进度 = %f",self.webView.estimatedProgress);
        // self.progressView.progress = self.webView.estimatedProgress;
        // if (self.webView.estimatedProgress >= 1.0f) {
        //     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //         self.progressView.progress = 0;
        //     });
        // }
        
    }else if([keyPath isEqualToString:@"title"]
             && object == webView){
        self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - Getter
- (UIProgressView *)progressView {
    UIProgressView *_progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, StatusBarAndNavigationBarHeight + 2, self.view.frame.size.width, 2)];
    _progressView.tintColor = [UIColor blueColor];
    _progressView.trackTintColor = [UIColor clearColor];
    return _progressView;
}

- (void)createLocalUIWebView {
    NSString * path = [[NSBundle mainBundle] bundlePath];
    NSURL * baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString * htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:(NSUTF8StringEncoding) error:nil];
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
}

- (void)createUIWebView {
    // 1.创建webview
    // CGFloat width = self.view.frame.size.width;
    // CGFloat height = self.view.frame.size.height;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    // 注意：这里需要设置委托
    webView.delegate = self;  

    webView.scalesPageToFit = YES;
    webView.scrollView.scrollEnabled = YES;
    
    
    // 2.1 创建一个远程URL
    // NSURL *remoteURL = [NSURL URLWithString:@"http://www.baidu.com"];
    // NSURL *remoteURL = [NSURL URLWithString:@"https://sdp-dev.test.investoday.net/#/stockDiagnosis?StockCode=000001&AppId=001&AccountId=10123&ProdId=001&Right=0&ShowQuotes=1"];
    NSURL *remoteURL = [NSURL URLWithString:@"https://sdp-dev.test.investoday.net/#/stockDiagnosis?StockCode=000001&AppId=001&AccountId=10123&ProdId=001&Right=0"];
    
    // 3.创建Request
    NSURLRequest *request =[NSURLRequest requestWithURL:remoteURL];
    // 4.加载网页
    [webView loadRequest:request];
    // 5.最后将webView添加到界面
    [self.view addSubview:webView];
    self.webView = webView;
}

#pragma mark - Event Handle
- (void)goBackAction:(id)sender{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        return;
    }
}
- (void)localHtmlClicked{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}
- (void)refreshAction:(id)sender{
    [self.webView reload];
}

//OC调用JS
- (void)ocToJs{
    //changeColor()是JS方法名，completionHandler是异步回调block
    NSString *jsString = [NSString stringWithFormat:@"changeColor('%@')", @"Js颜色参数"];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
    
    //改变字体大小 调用原生JS方法
    NSString *jsFont = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", arc4random()%99 + 100];
    [self.webView stringByEvaluatingJavaScriptFromString:jsFont];
    
    NSString * path =  [[NSBundle mainBundle] pathForResource:@"girl" ofType:@"png"];
    NSString *jsPicture = [NSString stringWithFormat:@"changePicture('%@','%@')", @"pictureId",path];
    [self.webView stringByEvaluatingJavaScriptFromString:jsPicture];
}

//2.在webView加载完成后 获得webView内容高度
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}


- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

// - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//     NSURL * url = [request URL];
//     if ([[url scheme] isEqualToString:@"youdao"]) {
//         UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:@"test" message:[url absoluteString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
//         [alertView show];
//         return NO;
//     }
//     return YES;
// }

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[[request URL]  absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    if([requestString isEqualToString:@"jrtz://getSecretId"])
    {   
        NSString *promptCode = [NSString stringWithFormat:@"JrtzIOSSignature.getSecretId(\"%@\");",SECRET_ID];
        NSString *secretId =[self.webView stringByEvaluatingJavaScriptFromString:promptCode];
        NSLog(@"response secretId:%@", secretId);
        return NO;
    }

    if ([requestString hasPrefix:@"jrtz://signature"]) 
    {
        NSMutableDictionary *param = [self queryStringToDictionary:requestString];
        NSLog(@"requestParam:%@",[param description]);
        
        NSString *signature = [JrtzSignature jrtzSignatureWithCurrentDateUTC:[param objectForKey:@"currentDateUTC"] Product:[param objectForKey:@"product"] StringToSign:[param objectForKey:@"stringToSign"]];
        NSString *promptCode2 = [NSString stringWithFormat:@"JrtzIOSSignature.%@(\"%@\");",[param objectForKey:@"method"], signature];
        [self.webView stringByEvaluatingJavaScriptFromString:promptCode2];
        return NO;
    }
    return YES;
}

// 获取参数转字典
- (NSMutableDictionary*)queryStringToDictionary:(NSString*)string {
    NSArray *el = [string componentsSeparatedByString:@"?"];
    NSString *params = [el objectAtIndex:1];
    NSMutableArray *elements = (NSMutableArray*)[params componentsSeparatedByString:@"&"];
    NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:[elements count]];
    for(NSString *e in elements) {
        NSArray *pair = [e componentsSeparatedByString:@"="];
        [retval setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
    }
    return retval;
}

// - (void)evaluatingJavaScriptFromString:(NSString*)param{
//     [self.webView stringByEvaluatingJavaScriptFromString:param];
// }

- (IBAction)addContent:(id)sender {
    NSString * js = @" var p = document.createElement('p'); p.innerText = 'new Line';document.body.appendChild(p);";
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}


- (void)dealloc {
    [webView release];
    [super dealloc];
    //移除观察者
    [webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
}
@end
