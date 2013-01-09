#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

/// Protocol
@protocol MapWebViewControllerDelegate <NSObject>
@optional
- (void)mapDidLoad;
@end

@interface MapWebViewController : UIViewController<UIWebViewDelegate>

// Delegate
@property (nonatomic, weak) id<MapWebViewControllerDelegate> delegate;

// JS Bridge
@property BOOL mapIsReady;

// Map Controls
- (void)setMapLocation:(CLLocation *)location;
- (void)setMapQueryType:(NSString *)queryType;
- (void)setMapIsTracking:(BOOL)isTracking;
- (void)setZoom:(NSNumber *)level;

// UI
@property (nonatomic, weak) IBOutlet UIWebView *webview;

// Web View Delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewDidStartLoad:(UIWebView *)webView;

@end
