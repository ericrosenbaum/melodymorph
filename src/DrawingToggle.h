//
//  DrawingToggle.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 6/2/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "testApp.h"

@interface DrawingToggle : UIViewController {
	IBOutlet UIButton *drawingToggleButton;
	testApp *myApp;
}

- (IBAction)setDrawingOn;
- (IBAction)setDrawingOff;
- (IBAction)setErasingOn;
- (IBAction)setErasingOff;
- (IBAction)setSlidingOn;
- (IBAction)setSlidingOff;

@end
