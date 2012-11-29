#import "CartoTile.h"

@implementation CartoTile


#pragma mark - MKOverlay delegate

@synthesize boundingMapRect, coordinate;

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return NO;
}

@end
