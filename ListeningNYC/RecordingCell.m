#import "RecordingCell.h"
#import "Utils.h"
#import "COSMFeedModel.h"

@interface RecordingCell() {}

@property BOOL hasLaidOutTags;

@end

@implementation RecordingCell

#pragma mark - Data

@synthesize feed, delegate;

#pragma mark - IB

@synthesize tagContainer;
@synthesize dateLabel;
@synthesize deleteButton;

- (IBAction)deleteRecording:(id)sender {
    UIAlertView* message = [[UIAlertView alloc] initWithTitle: @"Delete" message:@"Are you sure you wish to delete this recoriding?" delegate:self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Delete", nil];
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cellWantsDeletion:)]) {
            [self.delegate cellWantsDeletion:self];
        }
    }
}

#pragma mark - UI

@synthesize tagViews, hasLaidOutTags;

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.hasLaidOutTags) {
        self.tagViews = [Utils createSmallTagViews:[Utils tagArrayWithoutMachineTags:[self.feed.info valueForKeyPath:@"tags"]]];
        
        [Utils layoutViewsHTMLStyle:self.tagViews
                             inRect:CGRectMake(0.0f, 0.0f, self.tagContainer.frame.size.width, self.tagContainer.frame.size.height)
                        withSpacing:CGSizeMake(5.0f, 3.0f)];
        [Utils addSubviews:self.tagViews toView:self.tagContainer];
    }
    self.hasLaidOutTags = YES;
    self.deleteButton.hidden = YES;
}

- (void)drawRect:(CGRect)rect {
    
}

- (void)swipedLeft:(id)sender {
    self.deleteButton.hidden = NO;
}


- (void)swipedRight:(id)sender {
    self.deleteButton.hidden = YES;
}

#pragma mark - Life cycle

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.hasLaidOutTags = NO;   
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwipeGestureRecognizer* swipeGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
        [swipeGestureRecognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:swipeGestureRecognizerLeft];
        
        UISwipeGestureRecognizer* swipeGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
        [swipeGestureRecognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:swipeGestureRecognizerRight];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.hasLaidOutTags = NO;
        NSLog(@"setting selection style");
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwipeGestureRecognizer* swipeGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
        [swipeGestureRecognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:swipeGestureRecognizerLeft];
        
        UISwipeGestureRecognizer* swipeGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
        [swipeGestureRecognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:swipeGestureRecognizerRight];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
