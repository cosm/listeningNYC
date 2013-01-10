#import "AppDelegate.h"

@implementation AppDelegate

#pragma mark - Location

@synthesize locationManager, currentLocation, previousLocation;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.previousLocation = oldLocation;
    self.currentLocation = newLocation;
    // fire a notication is different
    if (oldLocation.coordinate.latitude != newLocation.coordinate.latitude || oldLocation.coordinate.longitude != newLocation.coordinate.longitude) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:newLocation, @"newLocation", oldLocation, @"oldLocation", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdatedNotification object:nil userInfo:userInfo];
    }
}

#pragma mark - Application

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // styles
    [[UINavigationBar appearance]   setBackgroundImage:[UIImage imageNamed:@"UINavigationBackground"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                UITextAttributeTextColor: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0],
                          UITextAttributeTextShadowColor: [UIColor colorWithRed:0.0f green:0.0 blue:0.0f alpha:0.8],
                         UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                     UITextAttributeFont: [UIFont fontWithName:@"Helvetica-Light" size:22.0f]
     }];
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"ToolbarBackground"]];
    [[UITabBar appearance] setTintColor:[UIColor clearColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor] }
                                             forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"SegmentDivider"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"SegmentDivider"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

    [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"SegementBackgroundUnselected"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"SegementBackgroundSelected"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    // location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kapplicationWillResignActive object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.locationManager stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.locationManager startUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.locationManager startUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidBecomeActive object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.locationManager stopUpdatingLocation];
}

@end
