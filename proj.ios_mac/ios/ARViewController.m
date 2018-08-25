//
//  ARViewController2.m
//  arkit-sample-mobile
//
//  Created by Luo Jinghua on 2018/8/25.
//

#import "ARViewController.h"
#import "ARKitHelper.h"

#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

@interface ARViewController ()
{
    ARSCNView* arView;
    ARAnchor* currentAnchor;
}

@end

@implementation ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    arView = [[ARSCNView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    arView.delegate = self;
    arView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    self.view = arView;
}

-(void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];

    ARWorldTrackingConfiguration* config = [[ARWorldTrackingConfiguration alloc] init];
    config.planeDetection = ARPlaneDetectionHorizontal;

    // start ARSession
    [arView.session runWithConfiguration:config];
}

-(void) viewDidDisappear:(BOOL) animated {
    [super viewDidDisappear:animated];
    
    [arView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) hitTestWithGlNormalizedPoint:(CGPoint)glNormalizedPoint {
    ARFrame* currentFrame = arView.session.currentFrame;
    if (!currentFrame)
        return;

    // convert GL point to UIKit point.
    CGPoint tapPointNormalized = CGPointMake(glNormalizedPoint.x, 1.0 - glNormalizedPoint.y);

    // transform point from device orientation.
    CGSize videoSize = self.view.bounds.size;
    CGAffineTransform tapPointTransform = [currentFrame displayTransformForOrientation:[UIApplication sharedApplication].statusBarOrientation viewportSize: videoSize];
    CGPoint testPoint = CGPointApplyAffineTransform(tapPointNormalized, tapPointTransform);
    
    // try hitTest
    NSArray<ARHitTestResult *>* results = [currentFrame hitTest:testPoint types:ARHitTestResultTypeExistingPlane];
    ARHitTestResult* result = results.firstObject;
    if (!result)
        return;

    // keep result transform
    currentAnchor = [[ARAnchor alloc] initWithTransform:result.worldTransform];
}

-(SCNMatrix4) anchorToCameraTransform:(ARAnchor*)anchor {
    if (!arView.pointOfView || !anchor)
        return SCNMatrix4Identity;
    SCNMatrix4 originToCameraTransform = arView.pointOfView.worldTransform;
    SCNMatrix4 originToAnchorTransform = SCNMatrix4FromMat4(anchor.transform);
    SCNMatrix4 anchorToCameraTransform = SCNMatrix4Mult(originToCameraTransform, SCNMatrix4Invert(originToAnchorTransform));

    return anchorToCameraTransform;
}

#pragma mark - ARSCNViewDelegate

-(void) renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (currentAnchor == nil)
        currentAnchor = anchor;
}

-(void) renderer:(id<SCNSceneRenderer>)renderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    ARAnchor* anchor = currentAnchor;
    if (!anchor)
        return;
    ARFrame* currentFrame = arView.session.currentFrame;
    if (!currentFrame)
        return;

    SCNMatrix4 transform = [self anchorToCameraTransform:anchor];
    SCNMatrix4 projection = SCNMatrix4FromMat4(currentFrame.camera.projectionMatrix);

    [ARKitHelper cameraMatrixUpdated:transform projection: projection];
}

@end
