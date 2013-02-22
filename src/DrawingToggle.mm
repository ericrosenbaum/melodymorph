    //
//  DrawingToggle.mm
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 6/2/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import "DrawingToggle.h"


@implementation DrawingToggle

-(IBAction)setDrawingOn {
	myApp->setDrawingOn();
}
-(IBAction)setDrawingOff {
	myApp->setDrawingOff();
}
-(IBAction)setErasingOn {
	myApp->setErasingOn();
}
-(IBAction)setErasingOff {
	myApp->setErasingOff();
}
- (IBAction)setSlidingOn {
    myApp->setSlidingOn();
}
- (IBAction)setSlidingOff {
    myApp->setSlidingOff();
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
