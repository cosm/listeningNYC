#import "Utils.h"
#import "ISO8601DateFormatter.h"
#import "LoadingViewController.h"

#define kTAG_SMALL_MAX_LENGTH 100.0f
#define kTAG_SMALL_TEXT_SIZE 10.0f
#define kTAG_SMALL_PADDING_TOP_OR_BOTTOM 4.0f
#define kTAG_SMALL_PADDING_LEFT 4.0f
#define kTAG_SMALL_PADDING_RIGHT 12.0f

@implementation Utils

#pragma mark - UI

+ (void)alertUsingJSON:(id)JSON orTitle:(NSString *)fallbackTile message:(NSString*)messageOrNil {
    if ([JSON valueForKeyPath:@"title"] && [JSON valueForKeyPath:@"errors"]) {
        [Utils alert:[JSON valueForKeyPath:@"title"] message:[Utils describe:[JSON valueForKeyPath:@"errors"]]];
    } else {
        [Utils alert:fallbackTile message:[Utils describe:messageOrNil]];
    }
}

+ (void)alert:(NSString *)title message:(NSString *)messageOrNil {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:title
                                                      message:messageOrNil
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

+ (LoadingViewController *)loadingViewControllerOn:(UIViewController*)viewController withTitle:(NSString *)title {
    LoadingViewController *loadingViewController = [viewController.storyboard instantiateViewControllerWithIdentifier:@"Loading Screen"];
    loadingViewController.view.autoresizingMask = UIViewAutoresizingNone;
    loadingViewController.view.frame = [[UIScreen mainScreen] bounds];
    [viewController.navigationController.view addSubview:loadingViewController.view];
    return loadingViewController;
}

+ (void)addSubviews:(NSArray *)views toView:(UIView *)view {
    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIView class]]) {
            UIView *enumeratedView = obj;
            [view addSubview:enumeratedView];
        }
    }];
}

+ (void)layoutViews:(NSArray *)views inRect:(CGRect)area withSpacing:(CGSize)spacing {
    __block CGPoint needle = CGPointMake(0.0f, 0.0f); // unnessiary make but you get the point. boom, boom.
    __block float maxHeight = 0.0f;
    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        CGRect modifiedRect = view.frame;
        if (needle.x > 0.0f && needle.x + modifiedRect.size.width > area.size.width) {
            needle.x = 0.0f;
            needle.y += maxHeight + spacing.height;
            maxHeight = 0.0f;
        }
        modifiedRect.origin.x += area.origin.x + needle.x;
        modifiedRect.origin.y += area.origin.y + needle.y;
        view.frame = modifiedRect;
        needle.x += spacing.width + modifiedRect.size.width;
        maxHeight = (maxHeight < modifiedRect.size.height) ? modifiedRect.size.height : maxHeight;
        if (needle.x > area.size.width) {
            needle.x = 0.0f;
            needle.y += maxHeight + spacing.height;
            maxHeight = 0.0f;
        }
    }];
}

+ (UIColor *)randomColor {
    return [UIColor colorWithRed:[Utils randomFloatFrom:0.0f to:1.0f] green:[Utils randomFloatFrom:0.0f to:1.0f] blue:[Utils randomFloatFrom:0.0f to:1.0f] alpha:1.0f];
}

#pragma mark - Tags

+ (NSMutableArray *)createTagViews:(NSArray *)tags {
    
    NSMutableArray *tagViews = [[NSMutableArray alloc] initWithCapacity:[tags count]];
    
    // load the background image
    static UIImage *smallTagBackground = nil;
    if (!smallTagBackground) {
        smallTagBackground = [UIImage imageNamed:@"TagBackgroundSmall"];
        smallTagBackground = [smallTagBackground resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 3.0f, 7.0f, 9.0f)];
    }
    
    // load the font
    static UIFont *smallTagFont = nil;
    if (!smallTagFont) {
        smallTagFont = [UIFont fontWithName:@"Helvetica" size:kTAG_SMALL_TEXT_SIZE];
    }
    
    [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *tag = obj;
        CGSize textSize = [tag sizeWithFont:smallTagFont
                                   forWidth:kTAG_SMALL_MAX_LENGTH - kTAG_SMALL_PADDING_LEFT - kTAG_SMALL_PADDING_RIGHT
                              lineBreakMode:NSLineBreakByTruncatingTail];
        
        // frame for all views in the stack
        CGRect frame = CGRectMake(0.0f, 0.0f, textSize.width + kTAG_SMALL_PADDING_LEFT + kTAG_SMALL_PADDING_RIGHT, kTAG_SMALL_TEXT_SIZE + kTAG_SMALL_PADDING_TOP_OR_BOTTOM + kTAG_SMALL_PADDING_TOP_OR_BOTTOM);
        // the background view
        UIImageView * background = [[UIImageView alloc] initWithFrame:frame];
        background.image = smallTagBackground;
        background.opaque = NO;
        // the text view
        CGRect labelFrame = frame;
        labelFrame.origin.x = kTAG_SMALL_PADDING_LEFT;
        labelFrame.size.width -= kTAG_SMALL_PADDING_LEFT + kTAG_SMALL_PADDING_RIGHT;
        UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
        label.autoresizingMask = UIViewAutoresizingNone;
        label.font = smallTagFont;
        label.text = tag;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.opaque = NO;
        // the container view
        UIView *container = [[UIView  alloc] initWithFrame:frame];
        container.opaque = NO;
        container.backgroundColor = [UIColor clearColor];
        [container addSubview:background];
        [container addSubview:label];
        
        [tagViews addObject:container];
    }];
    
    return tagViews;
}

#pragma mark - String

+ (NSString*)describe:(id)obj {
    if (obj == NULL) {
        return @"";
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        return [Utils describeArray:obj];
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        return [Utils describeDictionary:obj];
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        return [Utils replaceDates:obj];
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    }
    else {
        NSLog(@"Utils `describe:` does not know what to do with %@ class %@", obj, [obj class]);
        return obj;
    }
}

+ (NSString*)describeArray:(NSArray *)arr {
    NSMutableString *str = [NSMutableString stringWithString:@""];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx>0) {
            [str appendString:[NSString stringWithFormat:@", %@", [Utils describe:obj]]];
        } else {
            [str appendString:[Utils describe:obj]];
        }
    }];
    return str;
}

+ (NSString*)describeDictionary:(NSDictionary *)dict {
    NSMutableString *str = [NSMutableString stringWithString:@""];
    __block NSUInteger count = 0;
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (count>0) {
            [str appendString:[NSString stringWithFormat:@", %@: %@", [Utils describe:key], [Utils describe:obj]]];
        } else {
            [str appendString:[NSString stringWithFormat:@"%@: %@", [Utils describe:key], [Utils describe:obj]]];
        }
        ++count;
    }];
    return str;
}

+ (NSString *)replaceDates:(NSString*)str {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]*?)-([0-9]*?)-([0-9]*?)T([0-9]*?):([0-9]*?):([0-9]*?).([0-9]*?)Z"
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionAnchorsMatchLines | NSRegularExpressionAllowCommentsAndWhitespace
                                                                             error:&error];
    if (error) {
        NSLog(@"error regexing string: %@", error);
        return str;
    }
   return [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"$4:$5 $1/$2/$3"];
}

#pragma mark – Date

+ (ISO8601DateFormatter *)dateFormmater {
    static ISO8601DateFormatter *iSO8601DateFormmater = nil;
    if (!iSO8601DateFormmater) {
        iSO8601DateFormmater = [[ISO8601DateFormatter alloc] init];
    }
    return iSO8601DateFormmater;
}

#pragma mark - Math

+ (float)mapFloat:(float)value inputMin:(float)inputMin inputMax:(float)inputMax outputMin:(float)outputMin outputMax:(float)outputMax {
    return [Utils mapFloat:value inputMin:inputMin inputMax:inputMax outputMin:outputMin outputMax:outputMax clamp:NO];
}

+ (float)mapFloat:(float)value inputMin:(float)inputMin inputMax:(float)inputMax outputMin:(float)outputMin outputMax:(float)outputMax clamp:(BOOL)clamp {
    float output = ((value-inputMin)/(inputMax-inputMin)*(outputMax-outputMin)+outputMin);
    if (outputMax < outputMin) {
        if (output < outputMax) {
            output = outputMax;
        }
        else if (output > outputMin) {
            output = outputMin;
        }
    } else {
        if (output > outputMax) {
            output = outputMax;
        }
        else if (output < outputMin) {
            output = outputMin;
        }
    }
    return (clamp && output > outputMax) ? outputMax : output;
}

+ (float)randomFloatFrom:(float)min to:(float)max {
    return ((float)arc4random() / 0x100000000) * (max-min) + min;
}

@end
