#import <UIKit/UIKit.h>
@class TestMeasure;

@interface TestMonitorViewController : UIViewController

// data
@property (nonatomic, strong) TestMeasure *measure;

// IB
@property (nonatomic, weak) IBOutlet UILabel *dBValue;
@property (nonatomic, weak) IBOutlet UILabel *dBAValue;
@property (nonatomic, weak) IBOutlet UILabel *dBCValue;
@property (nonatomic, weak) IBOutlet UILabel *peakdBValue;
@property (nonatomic, weak) IBOutlet UILabel *peakdBAValue;
@property (nonatomic, weak) IBOutlet UILabel *peakdBCValue;
- (IBAction)touched:(id)sender;

// Utils
@property (nonatomic, strong) NSTimer *updateTimer;

// Life cycle
- (void)update;

@end
