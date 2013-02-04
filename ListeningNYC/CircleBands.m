#import "CircleBands.h"
#import "Utils.h"

@implementation CircleBands

#pragma mark - Datasource

@synthesize datasource;

#pragma mark - Customisation

@synthesize circleDiameter, circleHoleDiameter, numberOfBands, hueScalarMin, hueScalarMax, drawMask;

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:NO];
        self.circleDiameter = frame.size.width;
        self.circleHoleDiameter = 10.0f;
        self.numberOfBands = 20;
        self.hueScalarMin = 0.0f;
        self.hueScalarMax = 1.0f;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setOpaque:NO];
        self.circleDiameter = self.frame.size.width;
        self.circleHoleDiameter = 10.0f;
        self.numberOfBands = 20;
        self.hueScalarMin = 0.5f;
        self.hueScalarMax = 0.0f;
        self.drawMask = false;
    }
    return self;
}

#pragma mark - Drawing

- (void)drawCircle:(CGSize)size at:(CGPoint)point  {
    CGRect imageBounds = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    CGRect bounds = [self bounds];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat alignStroke;
    CGFloat resolution;
    CGMutablePathRef path;
    CGRect drawRect;
    UIColor *color;
    CGImageRef maskImage;
    NSData *data;
    CGDataProviderRef provider;
    CGLayerRef masklayer;
    resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
    CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
    
    // Layer 1
    CGContextSaveGState(context);
    context = CGBitmapContextCreate(NULL, roundf(bounds.size.width), roundf(bounds.size.height), 8, roundf(bounds.size.width), NULL, kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
    
//    // Mask
    alignStroke = 0.0f;
    path = CGPathCreateMutable();
    drawRect = CGRectMake(point.x, point.y, size.width - 10.0f, size.height - 10.0f);
    drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
    drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
    drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
    drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
    CGPathAddEllipseInRect(path, NULL, drawRect);
    color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    [color setFill];
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
    data = [NSData dataWithBytes:CGBitmapContextGetData(context) length:roundf(bounds.size.width) * roundf(bounds.size.height)];
    provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    maskImage = CGImageMaskCreate(roundf(bounds.size.width), roundf(bounds.size.height), 8, 8, roundf(bounds.size.width), provider, NULL, 0);
    CGDataProviderRelease(provider);
    CGContextRelease(context);
    UIGraphicsPopContext();
    context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, imageBounds, maskImage);
    CGImageRelease(maskImage);
    masklayer = CGLayerCreateWithContext(context, bounds.size, NULL);
    context = CGLayerGetContext(masklayer);
    UIGraphicsPushContext(context);
    CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
    
    // circle
    alignStroke = 0.0f;
    path = CGPathCreateMutable();
    drawRect = CGRectMake(point.x, point.y, size.width, size.height);
    drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
    drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
    drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
    drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
    CGPathAddEllipseInRect(path, NULL, drawRect);
    color = [UIColor colorWithRed:0.0f green:0.799f blue:0.624f alpha:1.0f];
    [color setFill];
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
    UIGraphicsPopContext();
    context = UIGraphicsGetCurrentContext();
    CGContextDrawLayerInRect(context, imageBounds, masklayer);
    CGLayerRelease(masklayer);
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect {
//    for (int i=0; i<self.numberOfBands; i++) {
//        float bandDiameter = [Utils mapFloat:i inputMin:0 inputMax:numberOfBands-1 outputMin:self.circleDiameter outputMax:self.circleHoleDiameter];
//        float bandPosition = (circleDiameter - bandDiameter) / 2.0f;
//        float bandAlpha = 1.0f;
//        if (self.datasource && [self.datasource respondsToSelector:@selector(alphaForBand:of:)]) {
//            bandAlpha = [self.datasource alphaForBand:i of:self.numberOfBands];
//        }
//        UIColor *debugColor = [UIColor colorWithHue:[Utils mapFloat:i inputMin:0 inputMax:numberOfBands-1 outputMin:self.hueScalarMin outputMax:self.hueScalarMax] saturation:1.0f brightness:1.0f alpha:bandAlpha];
//        [self drawCircle:CGSizeMake(bandDiameter, bandDiameter) at:CGPointMake(bandPosition, bandPosition)];
//    }
    
    CGRect imageBounds = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    CGRect bounds = [self bounds];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat alignStroke;
    CGFloat resolution;
    CGMutablePathRef path;
    CGRect drawRect;
    UIColor *color;
    CGImageRef maskImage;
    NSData *data;
    CGDataProviderRef provider;
    CGLayerRef masklayer;
    resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
    CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
    
    
    for (int i=0; i<self.numberOfBands; i++) {
        // Layer 1
        CGContextSaveGState(context);
        context = CGBitmapContextCreate(NULL, roundf(bounds.size.width), roundf(bounds.size.height), 8, roundf(bounds.size.width), NULL, kCGImageAlphaOnly);
        UIGraphicsPushContext(context);
        CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
        
        // properties
        float bandDiameter = [Utils mapFloat:i inputMin:0 inputMax:numberOfBands-1 outputMin:self.circleDiameter outputMax:self.circleHoleDiameter];
        float maskDiameter = [Utils mapFloat:i+1 inputMin:0 inputMax:numberOfBands-1 outputMin:self.circleDiameter outputMax:self.circleHoleDiameter];
        float bandPosition = (circleDiameter - bandDiameter) / 2.0f;
        float makePosition = (circleDiameter - maskDiameter) / 2.0f;
        float bandAlpha = 1.0f;
        if (self.datasource && [self.datasource respondsToSelector:@selector(alphaForBand:of:)]) {
            bandAlpha = [self.datasource alphaForBand:i of:self.numberOfBands];
        }
        UIColor *bandColor = [UIColor colorWithHue:[Utils mapFloat:i inputMin:0 inputMax:numberOfBands-1 outputMin:self.hueScalarMin outputMax:self.hueScalarMax] saturation:1.0f brightness:1.0f alpha:bandAlpha];
        
        // mask
        alignStroke = 0.0f;
        path = CGPathCreateMutable();
        drawRect = CGRectMake(makePosition, makePosition,maskDiameter, maskDiameter);
        drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
        drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
        drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
        drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
        CGPathAddEllipseInRect(path, NULL, drawRect);
        color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        [color setFill];
        CGContextAddPath(context, path);
        CGContextFillPath(context);
        CGPathRelease(path);
        data = [NSData dataWithBytes:CGBitmapContextGetData(context) length:roundf(bounds.size.width) * roundf(bounds.size.height)];
        provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
        maskImage = CGImageMaskCreate(roundf(bounds.size.width), roundf(bounds.size.height), 8, 8, roundf(bounds.size.width), provider, NULL, 0);
        CGDataProviderRelease(provider);
        CGContextRelease(context);
        UIGraphicsPopContext();
        context = UIGraphicsGetCurrentContext();
        CGContextClipToMask(context, imageBounds, maskImage);
        CGImageRelease(maskImage);
        masklayer = CGLayerCreateWithContext(context, bounds.size, NULL);
        context = CGLayerGetContext(masklayer);
        UIGraphicsPushContext(context);
        CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
        
        // circle
        alignStroke = 0.0f;
        path = CGPathCreateMutable();
        drawRect = CGRectMake(bandPosition, bandPosition, bandDiameter, bandDiameter);
        drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
        drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
        drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
        drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
        CGPathAddEllipseInRect(path, NULL, drawRect);
        [bandColor setFill];
        CGContextAddPath(context, path);
        CGContextFillPath(context);
        CGPathRelease(path);
        UIGraphicsPopContext();
        context = UIGraphicsGetCurrentContext();
        CGContextDrawLayerInRect(context, imageBounds, masklayer);
        CGLayerRelease(masklayer);
        CGContextRestoreGState(context);
    }
    
    CGContextRestoreGState(context);

}


- (void)oldDrawRect:(CGRect)rect
{
    CGRect imageBounds = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    CGRect bounds = [self bounds];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat alignStroke;
    CGFloat resolution;
    CGMutablePathRef path;
    CGRect drawRect;
    UIColor *color;
    CGImageRef maskImage;
    NSData *data;
    CGDataProviderRef provider;
    CGLayerRef masklayer;
    resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
    CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
    
    CGContextSaveGState(context);
    context = CGBitmapContextCreate(NULL, roundf(bounds.size.width), roundf(bounds.size.height), 8, roundf(bounds.size.width), NULL, kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
    
    alignStroke = 0.0f;
    path = CGPathCreateMutable();
    float holePosition = (self.circleDiameter - self.circleHoleDiameter) / 2.0f;
    drawRect = CGRectMake(holePosition, holePosition, self.circleHoleDiameter, self.circleHoleDiameter);
    drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
    drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
    drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
    drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
    CGPathAddEllipseInRect(path, NULL, drawRect);
    color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    [color setFill];
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
    data = [NSData dataWithBytes:CGBitmapContextGetData(context) length:roundf(bounds.size.width) * roundf(bounds.size.height)];
    provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    maskImage = CGImageMaskCreate(roundf(bounds.size.width), roundf(bounds.size.height), 8, 8, roundf(bounds.size.width), provider, NULL, 0);
    CGDataProviderRelease(provider);
    CGContextRelease(context);
    UIGraphicsPopContext();
    context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, imageBounds, maskImage);
    CGImageRelease(maskImage);
    masklayer = CGLayerCreateWithContext(context, bounds.size, NULL);
    context = CGLayerGetContext(masklayer);
    UIGraphicsPushContext(context);
    CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
    
    // remove this when masking is in place!
    //BOOL drawMask = true;
    
    for (int i=0; i<self.numberOfBands; i++) {
        if (self.drawMask) {
            alignStroke = 0.0f;
            path = CGPathCreateMutable();
            float bandDiameter = [Utils mapFloat:i inputMin:0 inputMax:numberOfBands-1 outputMin:self.circleDiameter outputMax:self.circleHoleDiameter];
            float bandPosition = (circleDiameter - bandDiameter) / 2.0f;
            float bandAlpha = 1.0f;
            if (self.datasource && [self.datasource respondsToSelector:@selector(alphaForBand:of:)]) {
                bandAlpha = [self.datasource alphaForBand:i of:self.numberOfBands];
            }
            //UIColor *debugColor = [UIColor colorWithHue:[Utils mapFloat:i inputMin:0 inputMax:numberOfBands-1 outputMin:self.hueScalarMin outputMax:self.hueScalarMax] saturation:1.0f brightness:1.0f alpha:bandAlpha];
            UIColor *debugColor = [UIColor whiteColor];
            drawRect = CGRectMake(bandPosition, bandPosition, bandDiameter, bandDiameter);
            drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
            drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
            drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
            drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
            CGPathAddEllipseInRect(path, NULL, drawRect);
            color = [UIColor colorWithRed:0.0f green:0.799f blue:0.624f alpha:1.0f];
            color = debugColor;
            [color setFill];
            CGContextAddPath(context, path);
            CGContextFillPath(context);
            CGPathRelease(path);
        }
        
        alignStroke = 0.0f;
        path = CGPathCreateMutable();
        float bandDiameter = [Utils mapFloat:i inputMin:0 inputMax:numberOfBands-1 outputMin:self.circleDiameter outputMax:self.circleHoleDiameter];
        float bandPosition = (circleDiameter - bandDiameter) / 2.0f;
        float bandAlpha = 1.0f;
        if (self.datasource && [self.datasource respondsToSelector:@selector(alphaForBand:of:)]) {
            bandAlpha = [self.datasource alphaForBand:i of:self.numberOfBands];
        }
        UIColor *debugColor = [UIColor colorWithHue:[Utils mapFloat:i inputMin:0 inputMax:numberOfBands-1 outputMin:self.hueScalarMin outputMax:self.hueScalarMax] saturation:1.0f brightness:1.0f alpha:bandAlpha];
        drawRect = CGRectMake(bandPosition, bandPosition, bandDiameter, bandDiameter);
        drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
        drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
        drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
        drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
        CGPathAddEllipseInRect(path, NULL, drawRect);
        color = [UIColor colorWithRed:0.0f green:0.799f blue:0.624f alpha:1.0f];
        color = debugColor;
        [color setFill];
        CGContextAddPath(context, path);
        CGContextFillPath(context);
        CGPathRelease(path);

    }
    
    
    UIGraphicsPopContext();
    context = UIGraphicsGetCurrentContext();
    CGContextDrawLayerInRect(context, imageBounds, masklayer);
    CGLayerRelease(masklayer);
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);

}

@end