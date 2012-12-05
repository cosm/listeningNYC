#import "RadarViewController.h"
#import "GLTool.h"
#import "RadarSweeper.h"

@interface RadarViewController () {
    RadarSweeper *radar;
    ScanlinesIt scanlinesIterator;
}
@property (strong) EAGLContext *glContext;

@end

@implementation RadarViewController

#pragma mark - Timer

@synthesize updateSweeperTimer;

- (void)updaterSweeper {
    if (radar->scanlines.size()==0) {
        return;
    }
    static float offset = 1.0f;
    
    RadarScanline *scanline = *scanlinesIterator;
    
    for (int i=0; i<scanline->getNumParticles(); ++i) {
        float hueDegrees = RadarMapFloat(i, 0, scanline->getNumParticles(), 180.0f + offset, 360.0f+180.0f + offset);
        scanline->setParticleRGBAColor(1.0f, 0.0f, 0.0f, 1.0f, i);
        scanline->hsvTransformColor(hueDegrees, 1.0f, 1.0f, 1.0f, i);
    }
    offset += 10.0f;
    
    if (++scanlinesIterator == radar->scanlines.end()) {
        scanlinesIterator = radar->scanlines.begin();
    }
}

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
    
    radar = new RadarSweeper(200, 12, 150.0f);
    
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
    
    scanlinesIterator = radar->scanlines.begin();
    self.updateSweeperTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updaterSweeper) userInfo:nil repeats:YES];
}

- (void)viewWillUnload {
    [self.updateSweeperTimer invalidate];
    self.updateSweeperTimer = nil;
    delete radar;
    self.paused = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
