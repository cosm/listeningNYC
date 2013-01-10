#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *previousLocation;
#define kLocationUpdatedNotification @"LocationUpdated"

// applicaton
@property (strong, nonatomic) UIWindow *window;
#define kApplicationDidBecomeActive @"ApplicationDidBecomeActive"
#define kapplicationWillResignActive @"applicationWillResignActive"
@end
