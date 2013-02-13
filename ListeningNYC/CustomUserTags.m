#import "CustomUserTags.h"
#import "Utils.h"

@implementation CustomUserTags

#pragma mark - data

@synthesize tags;

- (void)loadTags {
    self.tags = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Custom Tags"]];
    [Utils describeArray:self.tags];
}

- (void)saveTags {
    if (self.tags) {
        [self.tags sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [[NSUserDefaults standardUserDefaults] setObject:self.tags forKey:@"Custom Tags"];
        [Utils describeArray:self.tags];
    }
}


@end
