#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"

@interface MeasureViewController : UIViewController

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *dbAButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *dbCButton;
@property float dBA;
@property float dBC;

@end
