#import "MapWebViewController.h"

@interface MapWebViewController ()

@end

@implementation MapWebViewController

#pragma mark - JS Bridge

@synthesize mapIsReady;

- (void)createMap {
    NSString *javascript = [NSString stringWithFormat:@"listeningNYC = new ListeningNYC()"];
    [self.webview stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)mapDidCreate {
    self.mapIsReady = true;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapDidLoad)]) {
        [self.delegate mapDidLoad];
    }
}

- (void)featureClicked:(id)data {
    if (self.delegate && [self.delegate respondsToSelector:@selector(featureClicked:)]) {
        [self.delegate featureClicked:data];
    }
}

#pragma mark - Map Controls

- (void)setMapLocation:(CLLocation *)location {
    //location.horizontalAccuracy
    NSString *javascript = [NSString stringWithFormat:@"listeningNYC.updateUserPosition(%f, %f, 13)", location.coordinate.latitude, location.coordinate.longitude];
    [self.webview stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)setMapQueryType:(NSString *)queryType {
    // can be none, all, likeonly, dislikeonly
    NSString *javascript = [NSString stringWithFormat:@"listeningNYC.setQueryType('%@')", queryType];
    [self.webview stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)setMapIsTracking:(BOOL)isTracking {
    NSString *javascript = [NSString stringWithFormat:@"listeningNYC.isTrackingEnabled = %@", (isTracking) ? @"true" : @"false"];
    [self.webview stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)setMapZoom:(NSNumber *)level {
    NSString *javascript = [NSString stringWithFormat:@"listeningNYC.map.setZoom(%@)", [level stringValue]];
    [self.webview stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)setMapDisplayLocationCircle:(BOOL)yN {
    NSString *javascript = [NSString stringWithFormat:@"listeningNYC.setDisplayLocationCircle(%@)", (yN) ? @"true" : @"false"];
    [self.webview stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark - UI

@synthesize webview;

#pragma mark - Web View Delegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"webView:didFailLoadWithError: %@", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // ignore normal requests
    if (![request.URL.scheme isEqualToString:@"bridge"]) {
        return [request.URL.path.lastPathComponent isEqualToString:@"map.html"];
    }
    
    // deserialize the request JSON
    NSString *JSONString = [request.URL.fragment stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSError *error = nil;
    id json = [NSJSONSerialization  JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
        NSLog(@"Could not parse JSON");
    }
    
    id event = [json valueForKey:@"event"];
    if (event) {
        if ([event isKindOfClass:[NSString class]]) {
            if ([event isEqualToString:@"mapDidCreate"]) {
                [self mapDidCreate];
            } else if ([event isEqualToString:@"cartoFeatureClick"]) {
                [self featureClicked:[json valueForKey:@"data"]];
            }
        }
    }
    
    id log = [json objectForKey:@"log"];
    if (log) {
        if ([log isKindOfClass:[NSString class]]) {
            NSLog(@"Javascript Log: %@", log);
        } else if ([log isKindOfClass:[NSArray class]]) {
            NSMutableString *logOutput = [[NSMutableString alloc] init];
            [log enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [logOutput appendString:[NSString stringWithFormat:@"%@ ", obj]];
            }];
            NSLog(@"Javascript Log: %@", logOutput);
        } else {
            NSLog(@"Javascript Log: %@", log);
        }
    }
    
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self createMap];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

#pragma mark - Life Cycle

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.webview.scrollView.bounces = NO;
    self.webview.delegate = self;
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"public/map" ofType:@"html"] isDirectory:NO]]];
}

- (void)viewWillUnload {
    NSLog(@"View is unloading!");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
