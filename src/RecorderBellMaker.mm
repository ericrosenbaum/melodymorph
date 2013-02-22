    //
//  RecorderBellMaker.mm
//  iPhoneAdvancedEventsExample
//
//  Created by England on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "RecorderBellMaker.h"


@implementation RecorderBellMaker


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	recording = false;
	[self.toggleButton setImage:[UIImage imageNamed:@"rec_bell_maker.png"] forState:UIControlStateNormal];
}

- (IBAction)toggleRecording {
	if (!recording) {
		recording = true;
		[self.toggleButton setImage:[UIImage imageNamed:@"rec_bell_maker_active.png"] forState:UIControlStateNormal];
		myApp->startRecording();
		notes.clear();
		noteCount = 0;
		recStartTime = 0;
	} else {
		recording = false;
		[self.toggleButton setImage:[UIImage imageNamed:@"rec_bell_maker.png"] forState:UIControlStateNormal];
		myApp->stopRecording();
		[self makeBell];
	}
}
- (void)recordNote:(Bell *)b {
	if (!(b->isRecorderBell())) {
		noteCount++;
		if (noteCount == 1) {
			recStartTime = ofGetElapsedTimef();
		}
		Note *n = new Note();
		n->time = ofGetElapsedTimef() - recStartTime;
		n->note = b->getNoteNum();
		n->octave = b->getOctave();
		n->velocity = b->getVelocity();
		n->instrument = b->getInstrument();
		notes.push_back(n);
	}
}
- (void)recordRecordedNote:(Note *)n {
	if (recording) {
		noteCount++;
		if (noteCount == 1) {
			recStartTime = ofGetElapsedTimef();
		}
		Note *newNote = new Note();
		newNote->time = ofGetElapsedTimef() - recStartTime;
		newNote->note = n->note;
		newNote->octave = n->octave;
		newNote->velocity = n->velocity;
		newNote->instrument = n->instrument;
		notes.push_back(newNote);	
	}
}

- (void) makeBell {
	if (noteCount > 0) {
		myApp->makeRecBell(notes);
		notes.clear();
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
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

