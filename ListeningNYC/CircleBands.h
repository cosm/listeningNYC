#import <UIKit/UIKit.h>

@protocol CircleBandsDatasource <NSObject>
@optional
- (float)alphaForBand:(int)bandIndex of:(int)totalBands;
@end

@interface CircleBands : UIView

// datasource
@property (nonatomic, weak) id<CircleBandsDatasource> datasource;

// customisation
@property float isDisabled;
@property float circleDiameter;
@property float circleHoleDiameter;
@property int numberOfBands;
@property float hueScalarMin;
@property float hueScalarMax;
@property BOOL drawMask; // <-- remove me when masking in place

// image
- (void)saveImageOnNextRender:(NSString *)path;
- (UIImage *)renderAsImage;

@end
