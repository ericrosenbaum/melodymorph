    //
//  topButtons.mm
//  iPhoneAdvancedEventsExample
//
//  Created by England on 11/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TopButtons.h"


@implementation TopButtons

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
	octave = 1;
	myApp->setOctave(octave);
}
-(IBAction)setInstrument {
    int inst = self.instrumentPicker.selectedSegmentIndex;
    printf("instrument picked: %d\n", inst);
	myApp->setInstrument(inst);
}
-(IBAction)downAnOctave {
	octave -= 1;
	if (octave == 0) {
		[self.leftButton setHidden:YES];
	}
	[self.rightButton setHidden:NO];
	myApp->setOctave(octave);
}
-(IBAction)upAnOctave {
	octave += 1;
	if (octave == 2) {
		[self.rightButton setHidden:YES];
	}
	[self.leftButton setHidden:NO];
	myApp->setOctave(octave);
}
- (void)resetOctave {
	octave = 1;
	[self.leftButton setHidden:NO];
	[self.rightButton setHidden:NO];
}	

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    //return(interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
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

-(void) hide {
}


@end
