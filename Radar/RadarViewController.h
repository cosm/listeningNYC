#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface RadarViewController : GLKViewController<GLKViewDelegate>

// Interface
- (void)update;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;

// GL
@property (nonatomic, strong) GLKBaseEffect *projectionMatrixEffect;

// Timer
@property (nonatomic, strong) NSTimer *updateSweeperTimer;
- (void)updaterSweeper;

@end
