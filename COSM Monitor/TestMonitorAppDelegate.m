#import "TestMonitorAppDelegate.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "COSMDefaults.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation TestMonitorAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    // Setup UI
    [[UINavigationBar appearance]   setBackgroundImage:[UIImage imageNamed:@"UINavigationBackground"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                UITextAttributeTextColor: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0],
                          UITextAttributeTextShadowColor: [UIColor colorWithRed:0.0f green:0.0 blue:0.0f alpha:0.8],
                         UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                     UITextAttributeFont: [UIFont fontWithName:@"Helvetica-Light" size:22.0f]
     }];
    
    [[UIToolbar appearance]         setBackgroundImage:[UIImage imageNamed:@"UINavigationBackground"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance]   setTintColor:[COSMDefaults colorForKey:@"grey"]];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
