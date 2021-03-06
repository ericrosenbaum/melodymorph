#ifndef _CONTROLPANEL_ER
#define _CONTROLPANEL_ER

//
//  ControlPanel.h
//  MelodyMorph
//
//  Created by England on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "testApp.h"

@interface ControlPanel : UIViewController {
	testApp *myApp;
    
    IBOutlet UISwitch *allNotesSwitch;
    IBOutlet UISwitch *noteNamesSwitch;

}

@property (nonatomic, retain) UISwitch *allNotesSwitch;
@property (nonatomic, retain) UISwitch *noteNamesSwitch;

-(IBAction)saveCanvas;
-(IBAction)loadCanvas;
-(IBAction)clearCanvas;
-(IBAction)toggleAllNotes;
-(IBAction)toggleNoteNames;
-(IBAction)saveToServer;
-(IBAction)browseServer;

@end

#endif