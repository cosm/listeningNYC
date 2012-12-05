#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

/// Protocol
@class RadarViewController;
@protocol RadarViewControllerDatasource
@optional
- (NSArray *)opacityValues:(RadarViewController *)radarViewController;
@end

/// Class
@interface RadarViewController : GLKViewController<GLKViewDelegate>

@property (nonatomic, weak) id<RadarViewControllerDatasource> datasource;

// Interface
- (void)update;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;

// GL
@property (nonatomic, strong) GLKBaseEffect *projectionMatrixEffect;

// Timer
@property (nonatomic, strong) NSTimer *updateSweeperTimer;
- (void)updaterSweeper;

@end
