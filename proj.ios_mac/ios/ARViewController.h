//
//  ARViewController.h
//  arkit-sample-mobile
//
//  Created by Luo Jinghua on 2018/8/25.
//

#import <UIKit/UIKit.h>

@protocol ARSCNViewDelegate;
@interface ARViewController : UIViewController<ARSCNViewDelegate>
-(void) hitTestWithGlNormalizedPoint:(CGPoint)glNormalizedPoint;
@end
