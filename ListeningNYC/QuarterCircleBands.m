#import "QuarterCircleBands.h"

@implementation QuarterCircleBands

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:NO];
        self.circleDiameter = self.circleDiameter * 2.0f;
        self.circleHoleDiameter = self.circleHoleDiameter * 2;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setOpaque:NO];
        self.circleDiameter = self.circleDiameter * 2.0f;
        self.circleHoleDiameter = self.circleHoleDiameter * 2;
    }
    return self;
}
@end
