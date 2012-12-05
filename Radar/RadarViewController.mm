#import "RadarViewController.h"
#import "GLTool.h"
#import "RadarSweeper.h"

@interface RadarViewController () {
    RadarSweeper *radar;
}
@property (strong) EAGLContext *glContext;

@end

@implementation RadarViewController

#pragma mark - GL

@synthesize projectionMatrixEffect;

#pragma mark - UI

@synthesize glContext;

- (void)update {
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.projectionMatrixEffect prepareToDraw];
    
    radar->draw(); 
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    radar = new RadarSweeper(100, 12, 100.0f);
    
    // configure the view
    self.preferredFramesPerSecond = 30;
    ((GLKView *)self.view).drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    ((GLKView *)self.view).drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    ((GLKView *)self.view).delegate = self;
    NSLog(@"class is %@", [self.view class]);
    
    // set the context
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.glContext) {
        NSLog(@"Unable to create OpenGL context");
        exit(1);
    }
    [EAGLContext setCurrentContext:self.glContext];
    ((GLKView *)self.view).context = self.glContext;
    
    // create the projection matrix
    self.projectionMatrixEffect = [[GLKBaseEffect alloc] init];
    GLToolProjectionMatrixEffectWithFrame(self.projectionMatrixEffect, self.view.frame);
    
    self.paused = NO;
}

- (void)viewWillUnload {
    delete radar;
    self.paused = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
