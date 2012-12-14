#import <Foundation/Foundation.h>
@class ISO8601DateFormatter;
@class LoadingViewController;

@interface Utils : NSObject

// UI
+ (void)alertUsingJSON:(id)JSON orTitle:(NSString *)fallbackTile message:(NSString*)messageOrNil;
+ (void)alert:(NSString *)title message:(NSString *)messageOrNil;
/// to remove this added LoadingViewController do [self.loadingViewController.view removeFromSuperview];
+ (LoadingViewController*)loadingViewControllerOn:(UIViewController*)viewController withTitle:(NSString *)title;
+ (void)addSubviews:(NSArray *)views toView:(UIView *)view;
+ (void)layoutViews:(NSArray *)views inRect:(CGRect)area withSpacing:(CGSize)spacing;
+ (UIColor *)randomColor;

// Tags
/// creates tag view and returns each tag view in a array.
/// the tag view are internally layout but are not layed out relative
/// to each other
+ (NSMutableArray *)createTagViews:(NSArray *)tags;

// String
+ (NSString*)describe:(id)obj;
+ (NSString*)describeArray:(NSArray *)arr;
+ (NSString*)describeDictionary:(NSDictionary *)dict;
+ (NSString *)replaceDates:(NSString*)str;

// Date
+ (ISO8601DateFormatter *)dateFormmater;

// Math
+ (float)mapFloat:(float)value inputMin:(float)inputMin inputMax:(float)inputMax outputMin:(float)outputMin outputMax:(float)outputMax;
+ (float)mapFloat:(float)value inputMin:(float)inputMin inputMax:(float)inputMax outputMin:(float)outputMin outputMax:(float)outputMax clamp:(BOOL)clamp;
+ (float)randomFloatFrom:(float)min to:(float)max;

@end
