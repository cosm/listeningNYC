#import <Foundation/Foundation.h>
@class ISO8601DateFormatter;
@class LoadingViewController;

@interface Utils : NSObject
// UI
+ (void)alertUsingJSON:(id)JSON orTitle:(NSString *)fallbackTile message:(NSString*)messageOrNil;
+ (void)alert:(NSString *)title message:(NSString *)messageOrNil;
// to remove this loading view do [self.loadingViewController.view removeFromSuperview];
+ (LoadingViewController*)loadingViewControllerOn:(UIViewController*)viewController withTitle:(NSString *)title;

// String
+ (NSString*)describe:(id)obj;
+ (NSString*)describeArray:(NSArray *)arr;
+ (NSString*)describeDictionary:(NSDictionary *)dict;
+ (NSString *)replaceDates:(NSString*)str;

// Date
+ (ISO8601DateFormatter *)dateFormmater;

@end
