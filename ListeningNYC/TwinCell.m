#import "TwinCell.h"
#import "Utils.h"

@interface TwinCell() {}

@property BOOL hasLaidOutTags;

@end


@implementation TwinCell

#pragma mark - Data

@synthesize tagStrings_left, tagStrings_right;

#pragma mark - IB

@synthesize tagContainer_left;
@synthesize tagContainer_right;
@synthesize dateLabel_left;
@synthesize dateLabel_right;
@synthesize timeLabel_left;
@synthesize timeLabel_right;
@synthesize deleteButton_left;
@synthesize deleteButton_right;

- (IBAction)delete_left:(id)sender {
    NSLog(@"Delete Left");
}

- (IBAction)delete_right:(id)sender {
    NSLog(@"Delete Right");
}

#pragma mark - UI

@synthesize  tagViews_left, tagViews_right, hasLaidOutTags;

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.hasLaidOutTags) {
        self.tagViews_left = [Utils createSmallTagViews:self.tagStrings_left];
        self.tagViews_right = [Utils createSmallTagViews:self.tagStrings_right];
        
        [Utils layoutViewsHTMLStyle:self.tagViews_left
                             inRect:CGRectMake(0.0f, 0.0f, self.tagContainer_left.frame.size.width, self.tagContainer_left.frame.size.height)
                        withSpacing:CGSizeMake(5.0f, 3.0f)];
        [Utils addSubviews:self.tagViews_left toView:self.tagContainer_left];
        
        [Utils layoutViewsHTMLStyle:self.tagViews_right
                             inRect:CGRectMake(0.0f, 0.0f, self.tagContainer_right.frame.size.width, self.tagContainer_right.frame.size.height)
                        withSpacing:CGSizeMake(5.0f, 3.0f)];
        [Utils addSubviews:self.tagViews_right toView:self.tagContainer_right];
    }
    
    self.hasLaidOutTags = YES; 
}

- (void)drawRect:(CGRect)rect {
    
}

#pragma mark - Life cycle

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.hasLaidOutTags = NO;
        NSLog(@"setting selection stykle using encoder");
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.hasLaidOutTags = NO;
        NSLog(@"setting selection stykle");
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
