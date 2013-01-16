#import "Utils.h"
#import "ISO8601DateFormatter.h"
#import "LoadingViewController.h"

struct TagLayoutSettings {
    float maxLength;
    float textSize;
    float paddingBottomOrTop;
    float paddingLeft;
    float paddingRight;
};

typedef struct TagLayoutSettings TagLayoutSettings;

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

+ (void)layoutViewsVerticalCenterStyle:(NSArray *)views inRect:(CGRect)rect spacingMin:(float)spacingMin spacingMax:(float)spacingMax {
    
    __block float totalHeightForViews = 0;
    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        totalHeightForViews += view.frame.size.height;
    }];
    
    float spacingAvailable = rect.size.height - totalHeightForViews;
    __block float padding = [Utils clampFloat:spacingAvailable/[views count] min:spacingMin max:spacingMax] / 2.0f;
    float heightRequired = totalHeightForViews + (padding * 2.0f * [views count]);
    
    __block CGPoint needle = CGPointMake(0.0, (rect.size.height / 2.0f) - (heightRequired / 2.0f));
    
    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *tagView = obj;
        CGRect frame = tagView.frame;
        needle.y += padding;
        frame.origin = needle;
        tagView.frame = frame;
        needle.y += frame.size.height + padding;
//        if (idx > 1) {
//            [tagView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                if ([obj isKindOfClass:[UIImageView class]]) {
//                    UIImageView *imageView = obj;
//                    imageView.transform = CGAffineTransformMakeScale(1, -1);
//                }
//            }];
//        }
    }];
}

+ (void)flipChildUIImageViewsIn:(NSArray *)views whichExceed:(CGPoint)point {
    [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (view.frame.origin.y > point.y) {
            [view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = obj;
                    imageView.transform = CGAffineTransformScale(imageView.transform, 1, -1);
                }
            }];
        }
        if (view.frame.origin.x > point.x) {
            [view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = obj;
                    imageView.transform = CGAffineTransformScale(imageView.transform, -1, 1);
                }
            }];
        }
    }];
}

+ (void)layoutViewsHTMLStyle:(NSArray *)views inRect:(CGRect)area withSpacing:(CGSize)spacing {
    __block CGPoint needle = CGPointMake(0.0f, 0.0f); // unnecessary but you get the point. boom, boom.
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


+ (void)setY:(float)y to:(UIView *)view {
    CGRect frame = view.frame;
    frame.origin.y = y;
    view.frame = frame;
}

#pragma mark - Tags

+ (NSMutableArray *)createTagViews:(NSArray *)tags {
    
    TagLayoutSettings settings;
    settings.maxLength = 100.0f;
    settings.textSize = 12.0f;
    settings.paddingBottomOrTop = 6.0f;
    settings.paddingLeft = 6.0f;
    settings.paddingRight = 18.0f;
    
    // load the background image
    static UIImage *tagBackground = nil;
    if (!tagBackground) {
        tagBackground = [UIImage imageNamed:@"TagBackground"];
        tagBackground = [tagBackground resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 3.0f, 14.0f, 14.0f)];
    }
    
    // load the font
    static UIFont *tagFont = nil;
    if (!tagFont) {
        tagFont = [UIFont fontWithName:@"Helvetica-Light" size:settings.textSize];
    }
    
    return [Utils createTagViews:tags withSettings:settings Background:tagBackground font:tagFont];
}

+ (NSMutableArray *)createSmallTagViews:(NSArray *)tags {
    
    TagLayoutSettings settings;
    settings.maxLength = 100.0f;
    settings.textSize = 10.0f;
    settings.paddingBottomOrTop = 4.0f;
    settings.paddingLeft = 4.0f;
    settings.paddingRight = 12.0f;

    // load the background image
    static UIImage *smallTagBackground = nil;
    if (!smallTagBackground) {
        smallTagBackground = [UIImage imageNamed:@"TagBackgroundSmall"];
        smallTagBackground = [smallTagBackground resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 3.0f, 7.0f, 9.0f)];
    }
    
    // load the font
    static UIFont *smallTagFont = nil;
    if (!smallTagFont) {
        smallTagFont = [UIFont fontWithName:@"Helvetica" size:settings.textSize];
    }
    
    return [Utils createTagViews:tags withSettings:settings Background:smallTagBackground font:smallTagFont];
}


+ (NSMutableArray *)createBiggerTagViews:(NSArray *)tags {
    TagLayoutSettings settings;
    settings.maxLength = 100.0f;
    settings.textSize = 14.0f;
    settings.paddingBottomOrTop = 6.0f;
    settings.paddingLeft = 6.0f;
    settings.paddingRight = 18.0f;
    
    // load the background image
    static UIImage *tagBackground = nil;
    if (!tagBackground) {
        tagBackground = [UIImage imageNamed:@"TagBackground"];
        tagBackground = [tagBackground resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 3.0f, 14.0f, 14.0f)];
    }
    
    // load the font
    static UIFont *tagFont = nil;
    if (!tagFont) {
        tagFont = [UIFont fontWithName:@"Helvetica-Light" size:settings.textSize];
    }
    
    return [Utils createTagViews:tags withSettings:settings Background:tagBackground font:tagFont];
}

+ (NSMutableArray *)createTagViews:(NSArray *)tags withSettings:(TagLayoutSettings)settings Background:(UIImage *)backgroundImage font:(UIFont *)font {
    
    NSMutableArray *tagViews = [[NSMutableArray alloc] initWithCapacity:[tags count]];
    
    [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *tag = obj;
        CGSize textSize = [tag sizeWithFont:font
                                   forWidth:settings.maxLength - settings.paddingLeft - settings.paddingRight
                              lineBreakMode:NSLineBreakByTruncatingTail];
        
        // frame for all views in the stack
        CGRect frame = CGRectMake(0.0f, 0.0f, textSize.width + settings.paddingLeft + settings.paddingRight, settings.textSize + settings.paddingBottomOrTop + settings.paddingBottomOrTop);
        // the background view
        UIImageView * background = [[UIImageView alloc] initWithFrame:frame];
        background.image = backgroundImage;
        background.opaque = NO;
        // the text view
        CGRect labelFrame = frame;
        labelFrame.origin.x = settings.paddingLeft;
        labelFrame.size.width -= settings.paddingLeft + settings.paddingRight;
        UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
        label.autoresizingMask = UIViewAutoresizingNone;
        label.font = font;
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

+ (NSMutableArray *)tags {
    static NSMutableArray *tags = nil;
    if (!tags) {
        tags = [[NSMutableArray alloc] initWithArray:@[@"animals",@"architecture",@"art",@"asia",@"australia",@"autumn",@"baby",@"band",@"barcelona",@"beach",@"berlin",@"bike",@"bird",@"birds",@"birthday",@"black",@"blackandwhite",@"blue",@"bw",@"california",@"canada",@"canon",@"car",@"cat",@"chicago",@"china",@"christmas",@"church",@"city",@"clouds",@"color",@"concert",@"dance",@"day",@"de",@"dog",@"england",@"europe",@"fall",@"family",@"fashion",@"festival",@"film",@"florida",@"flower",@"flowers",@"food",@"football",@"france",@"friends",@"fun",@"garden",@"geotagged",@"germany",@"girl",@"graffiti",@"green",@"halloween",@"hawaii",@"holiday",@"house",@"india",@"instagramapp",@"iphone",@"iphoneography",@"island",@"italia",@"italy",@"japan",@"kids",@"la",@"lake",@"landscape",@"light",@"live",@"london",@"love",@"macro",@"me",@"mexico",@"model",@"museum",@"music",@"nature",@"new",@"newyork",@"newyorkcity",@"night",@"nikon",@"nyc",@"ocean",@"old",@"paris",@"park",@"party",@"people",@"photo",@"photography",@"photos",@"portrait",@"raw",@"red",@"river",@"rock",@"san",@"sanfrancisco",@"scotland",@"sea",@"seattle",@"show",@"sky",@"snow",@"spain",@"spring",@"square",@"squareformat",@"street",@"summer",@"sun",@"sunset",@"taiwan",@"texas",@"thailand",@"tokyo",@"travel",@"tree",@"trees",@"trip",@"uk",@"unitedstates",@"urban",@"usa",@"vacation",@"vintage",@"washington",@"water",@"wedding",@"white",@"winter",@"woman",@"yellow",@"zoo" @""]];
    }
    return tags;
}

+ (void)saveTags {
    
}

+ (NSMutableArray *)findTagsIn:(NSString *)string {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^\\s,][^,]*[^\\s,]|[^\\s,])\\s*?" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionAnchorsMatchLines error:&error];
    NSArray *rangeMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray *matches = [[NSMutableArray alloc] initWithCapacity:[rangeMatches count]];
    [rangeMatches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSTextCheckingResult *result = obj;
        [matches addObject:[string substringWithRange:result.range]];
    }];
    return matches;
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

#pragma mark - Array

+ (void)addObjectsWhenNotADuplicate:(NSArray *)objects to:(NSMutableArray *)arr {
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [Utils addObjectWhenNotADuplicate:obj to:arr];
    }];
}

+ (BOOL)addObjectWhenNotADuplicate:(id)obj to:(NSMutableArray *)arr {
    __block BOOL found = false;
    [arr enumerateObjectsUsingBlock:^(id arrayItem, NSUInteger idx, BOOL *stop) {
        if ([arrayItem isEqual:obj]) {
            found = YES;
            *stop = YES;
        }
    }];
    if (!found) {
        [arr addObject:obj];
    }
    return (found) ? NO : YES;
}

#pragma mark – Date

+ (ISO8601DateFormatter *)dateFormmater {
    static ISO8601DateFormatter *iSO8601DateFormmater = nil;
    if (!iSO8601DateFormmater) {
        iSO8601DateFormmater = [[ISO8601DateFormatter alloc] init];
    }
    return iSO8601DateFormmater;
}

#pragma mark - Color

+ (UIColor *)randomColor {
    return [UIColor colorWithRed:[Utils randomFloatFrom:0.0f to:1.0f] green:[Utils randomFloatFrom:0.0f to:1.0f] blue:[Utils randomFloatFrom:0.0f to:1.0f] alpha:1.0f];
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
    return (clamp) ? [Utils clampFloat:output min:outputMin max:outputMax] : output;
}

+ (float)randomFloatFrom:(float)min to:(float)max {
    return ((float)arc4random() / 0x100000000) * (max-min) + min;
}

+ (float)clampFloat:(float)value min:(float)min max:(float)max {
    if (value > max) { return max; }
    if (value < min) { return min; }
    return value;
}

#pragma  mark - Device

// this is used locally only if one is not set
// in the system preferences.
NSString * createUUID() {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

+ (NSString *)deviceGUID {
    NSString *guid = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceGUID"];
    if (guid == nil) {
        guid = createUUID();
        [[NSUserDefaults standardUserDefaults] setObject:guid forKey:@"DeviceGUID"];
        if (![[NSUserDefaults standardUserDefaults] synchronize]) {
            [Utils alert:@"error" message:@"Failed to save the guid"];
        }
    }
    return guid;
}

@end
