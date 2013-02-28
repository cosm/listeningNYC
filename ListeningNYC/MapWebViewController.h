#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

/// Protocol
@protocol MapWebViewControllerDelegate <NSObject>
@optional
- (void)mapDidLoad;
- (void)featureClicked:(id)data;
@end

@interface MapWebViewController : UIViewController<UIWebViewDelegate>

// Delegate
@property (nonatomic, weak) id<MapWebViewControllerDelegate> delegate;

// JS Bridge
@property BOOL mapIsReady;

// Map Controls
- (void)setMapLocation:(CLLocation *)location;
- (void)setMapLocation:(CLLocation *)location zoomLevel:(float)zoom;
- (void)setMapQueryType:(NSString *)queryType;
- (void)setMapIsTracking:(BOOL)isTracking;
- (void)setMapZoom:(NSNumber *)level;
- (void)setMapDisplayLocationCircle:(BOOL)yN;

// Map Query
- (CLLocationCoordinate2D)queryMapLocation;

// UI
@property (nonatomic, weak) IBOutlet UIWebView *webview;

// Web View Delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewDidStartLoad:(UIWebView *)webView;

@end
