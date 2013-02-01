#import "RadarViewController.h"
#import "GLTool.h"
#import "RadarSweeper.h"

@interface RadarViewController () {
    RadarSweeper *radar;
    ScanlinesIt scanlinesIterator;
}
@property (strong) EAGLContext *glContext;
@property BOOL hasStarted;
@end

@implementation RadarViewController

@synthesize datasource;

#pragma mark - Control

// control
- (void)start {
    if (self.hasStarted) { return; }
    scanlinesIterator = radar->scanlines.begin();
    [self.updateSweeperTimer invalidate];

    double recordTime = kRECORD_FOR;
    unsigned int numberOfRadar = radar->scanlines.size();
    NSTimeInterval updatesPerSecond = recordTime / double(numberOfRadar);

    self.updateSweeperTimer = [NSTimer scheduledTimerWithTimeInterval:updatesPerSecond target:self selector:@selector(updaterSweeper) userInfo:nil repeats:YES];

    self.hasStarted = YES;
}

- (void)stop {
    if (!self.hasStarted) { return; }
    scanlinesIterator = radar->scanlines.begin();
    [self.updateSweeperTimer invalidate];
    
    self.hasStarted = NO;
}

- (void)requestAllFromDatasource {
    if (self.datasource && [self.datasource respondsToSelector:@selector(valueForAllSweeperParticle:inTotal:for:)]) {
        // use the first scanline as a reference of size
        RadarScanline *firstScanline = *(radar->scanlines.begin());
        unsigned int numberOfParticles = firstScanline->getNumParticles();
        
        for (unsigned int i=0; i<numberOfParticles; ++i) {
            float alpha = [self.datasource valueForAllSweeperParticle:i inTotal:numberOfParticles for:self];
            // run through each scanline
            for (ScanlinesIt it=radar->scanlines.begin(); it != radar->scanlines.end(); ++it) {
                RadarScanline *scanline = *it;
                scanline->setAlpha(alpha, i);
            }
        }

    }
//    if (self.datasource && [self.datasource respondsToSelector:@selector(valueForAllSweeperParticle:inTotal:for:)]) {
//        for (ScanlinesIt it=radar->scanlines.begin(); it != radar->scanlines.end(); ++it) {
//            RadarScanline *scanline = *it;
//            unsigned int numberOfParticles = scanline->getNumParticles();
//            for (ScanlinesIt it=radar->scanlines.begin(); it != radar->scanlines.end(); ++it) {
//                RadarScanline *scanline = *it;
//                for (unsigned int i=0; i<numberOfParticles; ++i) {
//                    float alpha = [self.datasource valueForSweeperParticle:i inTotal:numberOfParticles for:self];
//                    scanline->setAlpha(alpha, i);
//                }
//            }
//        }
//    }
}

- (void)reset {
    for (ScanlinesIt it=radar->scanlines.begin(); it != radar->scanlines.end(); ++it) {
        RadarScanline *scanline = *it;
        unsigned int numberOfParticles = scanline->getNumParticles();
        for (unsigned int i=0; i<numberOfParticles; ++i) {
            scanline->setAlpha(0.0f, i);
        }
    }
    scanlinesIterator = radar->scanlines.begin();
}


#pragma mark - Timer

@synthesize updateSweeperTimer, hasStarted;

- (void)updaterSweeper {
    if (radar->scanlines.size()==0) {
        return;
    }
    
    RadarScanline *scanline = *scanlinesIterator;
    
    if (self.datasource && [self.datasource respondsToSelector:@selector(valueForSweeperParticle:inTotal:for:)]) {
        unsigned int numberOfParticles = scanline->getNumParticles();
        for (unsigned int i=0; i<numberOfParticles; ++i) {
            float alpha = [self.datasource valueForSweeperParticle:i inTotal:numberOfParticles for:self];
            scanline->setAlpha(alpha, i);
        }
    }
    
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

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"RadarViewController viewWillAppear");
    self.paused = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"RadarViewController viewWillDisappear");
    self.paused = YES;
    [self stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasStarted = NO;
    
    radar = new RadarSweeper(400, 80, 150.0f);
    radar->setHues(0.0f, 180.0f);
//    for (int i=0; i<scanline->getNumParticles(); ++i) {
//        float hueDegrees = RadarMapFloat(i, 0, scanline->getNumParticles(), 180.0f + offset, 360.0f+180.0f + offset);
//        scanline->setParticleRGBAColor(1.0f, 0.0f, 0.0f, 1.0f, i);
//        scanline->hsvTransformColor(hueDegrees, 1.0f, 1.0f, 1.0f, i);
//    }
    
    // configure the view
    self.preferredFramesPerSecond = 30;
    ((GLKView *)self.view).drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    ((GLKView *)self.view).drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    ((GLKView *)self.view).delegate = self;
    
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
    
    self.view.backgroundColor = [UIColor clearColor];
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
