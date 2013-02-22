#pragma once
//
//  RecorderBellMaker.h
//  iPhoneAdvancedEventsExample
//
//  Created by England on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "testApp.h"
#include "Note.cpp"
#include "Bell.mm"

@interface RecorderBellMaker : UIViewController {
	testApp *myApp;		// points to our instance of testApp
	IBOutlet UIButton *toggleButton;
	BOOL recording;
	float recStartTime;
	int noteCount;
	vector<Note*> notes;
}

@property(nonatomic, retain) IBOutlet UIButton *toggleButton;

- (IBAction)toggleRecording;
- (void)recordNote:(Bell *)b;
- (void)recordRecordedNote:(Note *)n;
- (void)makeBell;


@end
