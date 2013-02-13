#import <Foundation/Foundation.h>

@interface CustomUserTags : NSObject

// data
@property (nonatomic, strong) NSMutableArray *tags;
- (void)loadTags;
- (void)saveTags;

@end
