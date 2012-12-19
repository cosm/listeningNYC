#import <UIKit/UIKit.h>

@interface MapWebViewController : UIViewController<UIWebViewDelegate>

// UI
@property (nonatomic, weak) IBOutlet UIWebView *webview;

// web view delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewDidStartLoad:(UIWebView *)webView;

@end
