    //
//  ControlPanel.m
//  MelodyMorph
//
//  Created by England on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ControlPanel.h"
#include "config.h"


@implementation ControlPanel

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 myApp = (testApp*)ofGetAppPtr();
 }
 
 -(IBAction)saveCanvas {
	 [self.view setHidden:YES];
     myApp->enterUIMode(PRE_SAVE_MODE);
 }
 -(IBAction)loadCanvas {
	 [self.view setHidden:YES];
	 myApp->enterUIMode(LOAD_MENU_MODE);
 }
 -(IBAction)clearCanvas {
	 myApp->clearCanvas();
 }
-(IBAction)toggleAllNotes {
	myApp->toggleAllNotes();
}
-(IBAction)toggleNoteNames {
	myApp->toggleNoteNames();
}
 
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Overriden to allow any orientation.
    // return(interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
     return YES;
}
 


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
