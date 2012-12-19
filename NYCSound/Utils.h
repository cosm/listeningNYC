// Utils.h
//
// Contains generic functions, algorthyms & static resources
// which are used through out the app. For simplicity, everything
// is a class method
//
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
+ (void)layoutViewsHTMLStyle:(NSArray *)views inRect:(CGRect)area withSpacing:(CGSize)spacing;
+ (void)layoutViewsVerticalCenterStyle:(NSArray *)views inRect:(CGRect)rect spacingMin:(float)spacingMin spacingMax:(float)spacingMax;
+ (void)flipChildUIImageViewsIn:(NSArray *)views whichExceed:(CGPoint)point;

// Tags
/// creates tag view and returns each tag view in a array.
/// the tag view are internally layout but are not layed out relative
/// to each other
+ (NSMutableArray *)createTagViews:(NSArray *)tags;
+ (NSMutableArray *)createSmallTagViews:(NSArray *)tags;
+ (NSMutableArray *)createBiggerTagViews:(NSArray *)tags;
+ (NSMutableArray *)tags;
+ (void)saveTags;
+ (NSMutableArray *)findTagsIn:(NSString *)string;

// String
+ (NSString*)describe:(id)obj;
+ (NSString*)describeArray:(NSArray *)arr;
+ (NSString*)describeDictionary:(NSDictionary *)dict;
+ (NSString *)replaceDates:(NSString*)str;

// Array
+ (void)addObjectsWhenNotADuplicate:(NSArray *)objects to:(NSMutableArray *)arr;
+ (BOOL)addObjectWhenNotADuplicate:(id)obj to:(NSMutableArray *)arr;

// Date
+ (ISO8601DateFormatter *)dateFormmater;

// Color
+ (UIColor *)randomColor;

// Math
+ (float)mapFloat:(float)value inputMin:(float)inputMin inputMax:(float)inputMax outputMin:(float)outputMin outputMax:(float)outputMax;
+ (float)mapFloat:(float)value inputMin:(float)inputMin inputMax:(float)inputMax outputMin:(float)outputMin outputMax:(float)outputMax clamp:(BOOL)clamp;
+ (float)randomFloatFrom:(float)min to:(float)max;
+ (float)clampFloat:(float)value min:(float)min max:(float)max;

@end
