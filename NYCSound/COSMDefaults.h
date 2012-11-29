#import <Foundation/Foundation.h>

// Singleton
@interface COSMDefaults : NSObject;

// should not be needed
+ (COSMDefaults *)sharedInstance;

+ (UIColor *)colorForKey:(NSString *)key;
+ (NSString *)cosmGUID;


@end
