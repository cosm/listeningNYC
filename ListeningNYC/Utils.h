// Utils.h
//
// Contains generic functions, algorthyms & static resources
// which are used through out the app. For simplicity, everything
// is a class method
//
#import <Foundation/Foundation.h>
@class ISO8601DateFormatter;
@class COSMFeedModel;
@class COSMDatastreamModel;
@class OHAttributedLabel;

@interface Utils : NSObject

// UI
+ (void)alertUsingJSON:(id)JSON orTitle:(NSString *)fallbackTile message:(NSString*)messageOrNil;
+ (void)alert:(NSString *)title message:(NSString *)messageOrNil;
+ (void)addSubviews:(NSArray *)views toView:(UIView *)view;
+ (void)layoutViewsHTMLStyle:(NSArray *)views inRect:(CGRect)area withSpacing:(CGSize)spacing;
+ (void)layoutViewsVerticalCenterStyle:(NSArray *)views inRect:(CGRect)rect spacingMin:(float)spacingMin spacingMax:(float)spacingMax;
+ (void)flipChildUIImageViewsIn:(NSArray *)views whichExceed:(CGPoint)point;
+ (void)setY:(float)y to:(UIView *)view;
+ (void)setX:(float)y to:(UIView *)view;
+ (void)setWidth:(float)width to:(UIView *)view;
+ (void)setHeight:(float)height to:(UIView *)view;

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
+ (NSMutableArray *)tagArrayWithoutMachineTags:(NSArray *)tags;
/// @returns Tags stripped
+ (NSMutableArray *)tagsArrayWithBannedTags:(NSArray *)tags;
+ (NSArray *)bannedWords;

// String
+ (NSString*)describe:(id)obj;
+ (NSString*)describeArray:(NSArray *)arr;
+ (NSString*)describeDictionary:(NSDictionary *)dict;
+ (NSString *)replaceDates:(NSString*)str;
+ (BOOL)string:(NSString *)testString contains:(NSString *)searchString;

// Array
+ (void)addObjectsWhenNotADuplicate:(NSArray *)objects to:(NSMutableArray *)arr;
+ (BOOL)addObjectWhenNotADuplicate:(id)obj to:(NSMutableArray *)arr;

// Number
+ (NSInteger)nextIncrementingIntegerForDomain:(NSString *)domain;

// Date
+ (ISO8601DateFormatter *)dateFormmater;

// Color
+ (UIColor *)randomColor;

// Math
+ (float)mapFloat:(float)value inputMin:(float)inputMin inputMax:(float)inputMax outputMin:(float)outputMin outputMax:(float)outputMax;
+ (float)mapFloat:(float)value inputMin:(float)inputMin inputMax:(float)inputMax outputMin:(float)outputMin outputMax:(float)outputMax clamp:(BOOL)clamp;
+ (float)mapQuinticEaseOut:(float)value inputMin:(float)inputMin inputMax:(float)inputMax outputMin:(float)outputMin outputMax:(float)outputMax clamp:(BOOL)clamp;
+ (float)randomFloatFrom:(float)min to:(float)max;
+ (float)clampFloat:(float)value min:(float)min max:(float)max;

// Device
+ (NSString *)deviceGUID;
+ (NSString *)versionString;
+ (NSString *)platformString;
+ (NSString *)platformStringRaw;

// COSM
// deleting
+ (void)deleteFeedFromDisk:(COSMFeedModel*)feed withExtension:(NSString *)extension;
+ (void)deleteFeedFromDisk:(COSMFeedModel *)feed withName:(NSString *)name extension:(NSString *)extension;
// saving
+ (void)saveFeedToDisk:(COSMFeedModel*)feed withExtension:(NSString *)extension;
+ (void)saveUnsyncedFeedToDisk:(COSMFeedModel*)feed withExtension:(NSString *)extension;
+ (void)saveFeedToDisk:(COSMFeedModel *)feed withName:(NSString *)name extension:(NSString *)extension;
// loading
+ (NSMutableArray *)loadFeedsFromDiskWithExtension:(NSString *)extension;
+ (NSMutableArray *)loadFeedsFromDisk;
+ (COSMDatastreamModel *)datastreamWithId:(NSString *)cosmId in:(COSMFeedModel*)feed;
+ (float)mapDbToAlpha:(float)input;
+ (float)alphaForBand:(int)index in:(COSMFeedModel*)feed;
+ (float)dbForBand:(int)index in:(COSMFeedModel*)feed;
+ (NSString *)valueOfMachineTag:(NSString *)machineTag;
+ (NSString *)dataTimeOfRecording:(COSMFeedModel *)feed;
+ (NSArray *)userTagsForRecording:(COSMFeedModel *)feed;
+ (NSString *)historyCellImagePathForFeed:(COSMFeedModel *)feed;

/// returns nil if there is no image stored
+ (UIImage *)historyCellImageForFeed:(COSMFeedModel *)feed;
+ (void)describeFeed:(COSMFeedModel*)feed usingAttributedLabel:(OHAttributedLabel *)label;

@end