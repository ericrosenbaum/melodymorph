//
//  topButtons.h
//  iPhoneAdvancedEventsExample
//
//  Created by England on 11/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "testApp.h"

@interface TopButtons : UIViewController {
	testApp *myApp;		// points to our instance of testApp
	NSInteger octave;
	IBOutlet UIButton *leftButton;
	IBOutlet UIButton *rightButton;
	IBOutlet UISegmentedControl *instrumentPicker;
}

@property(nonatomic, retain) IBOutlet UIButton *leftButton;
@property(nonatomic, retain) IBOutlet UIButton *rightButton;
@property(nonatomic, retain) IBOutlet UISegmentedControl *instrumentPicker;

-(IBAction)setInstrument;
-(IBAction)downAnOctave;
-(IBAction)upAnOctave;
-(void)resetOctave;
-(void)hide;

@end
