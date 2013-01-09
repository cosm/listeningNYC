#import "TagDeleteView.h"

@interface TagDeleteView ()

// UI
@property (nonatomic, weak) UIButton *button;
- (void)touched:(id)sender;

@end

@implementation TagDeleteView

#pragma mark - Data

@synthesize tagname, delegate;

#pragma mark - UI

@synthesize button;

- (void)touched:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagDeleteView:requestsDeletionOf:)]) {
        [self.delegate tagDeleteView:self requestsDeletionOf:self.tagname];
    }
}


#pragma mark - Life Cycle

- (id)initWithOrigin:(CGPoint)origin tag:(NSString *)name upImage:(UIImage *)upImage selectedImage:(UIImage *)selectedImage {
    self = [super initWithFrame:CGRectMake(origin.x - (upImage.size.width/2.0f), origin.y - (upImage.size.height/2.0f), upImage.size.width, upImage.size.height)];
    if (self) {
        self.tagname = name;
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(0.0f, 0.0f, upImage.size.width, upImage.size.height);
        [self.button setImage:upImage forState:UIControlStateNormal];
        [self.button setImage:selectedImage forState:UIControlStateSelected];
        self.button.showsTouchWhenHighlighted = YES;
        [self.button addTarget:self action:@selector(touched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    return self;
}

@end
