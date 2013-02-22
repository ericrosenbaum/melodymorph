//
//  LoadFileViewController.h
//  singingfingers
//
//  Created by England on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "testApp.h"

@interface LoadFileViewController : UIViewController <UIAlertViewDelegate> {
	IBOutlet UIScrollView *scrollView;
	testApp *myApp;		// points to our instance of testApp
	NSMutableArray *thumbList;
	UIImage *xIcon;
	UIAlertView *alertConfirmDelete;
	NSInteger idToDelete;
}

-(void)addThumbToList:(UIImage *)thumb withIdString:(NSString *)idStr;
-(void)createButtonForImage:(NSInteger)num atPosition:(NSInteger)pos;
-(NSInteger)getNextCanvasId;
-(void)resizeScrollView;
-(IBAction)dismissView;
-(IBAction)updateThumbs;
-(void)deleteImage;
-(NSInteger)getIndexForId:(NSInteger)idIWant;

//- (void)emailScreenImg:(id)sender;


@end
