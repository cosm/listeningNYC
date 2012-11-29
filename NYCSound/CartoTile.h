#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CartoTile : NSObject<MKOverlay>

// MKOverlay delegate
@property (nonatomic, readonly) MKMapRect boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (BOOL)intersectsMapRect:(MKMapRect)mapRect;

@end
