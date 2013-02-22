//
//  LoadFileViewController.mm
//  singingfingers
//
//  Created by England on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoadFileViewController.h"
#import "Thumb.h"
#include "ofxDirList.h"

@implementation LoadFileViewController

// this should not be a constant- should be able to count at runtime

#define numExamples 8 

-(void)viewDidLoad {
	
	myApp = (testApp*)ofGetAppPtr();

	// scrollview
	//CGRect frame = CGRectMake(0,0, 768, 900);
    CGRect frame = CGRectMake(0,0, 1024, 600);
	scrollView =[[UIScrollView alloc]initWithFrame:frame];
	[self.view addSubview:scrollView];
		
	thumbList = [NSMutableArray arrayWithCapacity:200]; // hard coded limit, not good
	[thumbList retain];
	
	// pre-load examples thumbnails 
	for (int i=0; i<numExamples; i++) {
		NSString *fileName = [NSString stringWithFormat:@"thumbImage%d", i];
		NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png" inDirectory:@"examples"];  
		UIImage *thumb = [UIImage imageWithContentsOfFile:filePath];
		NSString *thumbNumStr = [NSString stringWithFormat:@"%d", i];
		[self addThumbToList:thumb withIdString:thumbNumStr];
	}	
	
	// count current total number of saved files
	ofxDirList DIR;
	int nFiles = DIR.listDir(ofxiPhoneGetDocumentsDirectory());
	
	//printf("%d\n", nFiles);
		
	// pre-load thumbnail images for saved drawings 
	for (int i=0; i<nFiles; i++) {
		string path = DIR.getPath(i);
		NSString *pathName = [[NSString alloc] initWithUTF8String:path.c_str()];
		NSString *thumbName = [[pathName lastPathComponent] stringByDeletingPathExtension];
		NSRange r = [thumbName rangeOfString:@"thumbImage"];
		if (r.location != NSNotFound) {
			NSString *thumbNumStr = [thumbName stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
			UIImage *thumb = [UIImage imageWithContentsOfFile:pathName];
			[self addThumbToList:thumb withIdString:thumbNumStr];
		}
	}
	
	// x icon image
	xIcon = [UIImage imageNamed:@"icon_x20.png"];
			 
	// create buttons
	NSInteger nImages = [thumbList count];
	if (nImages > 0) {
		for (int i=0; i<nImages; i++) {
			[self createButtonForImage:[[[thumbList objectAtIndex:i] idStr] integerValue] atPosition:i];
		}
	}
	[self resizeScrollView];
}

-(void)addThumbToList:(UIImage *)thumb withIdString:(NSString *)idStr {
	Thumb *t = [[Thumb alloc] init];
	[t setIdStr:idStr];
	[t setThumb:thumb];
	[thumbList addObject:t]; 
	//[t release];
	[thumbList sortUsingSelector:@selector(compareThumbs:)];
}
	 
-(void)createButtonForImage:(NSInteger)num atPosition:(NSInteger)pos {
	//CGRect r = CGRectMake(20+(pos%6)*120, 20+(int)(pos/6.0)*163, 110, 143);
	CGRect r = CGRectMake(20+(pos%6)*163, 20+(int)(pos/6.0)*120, 143, 110);
	
    //UIButton *button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] initWithFrame:r];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:r];
	
	button.tag = num;
	if (pos < numExamples) {
		[button addTarget:self action:@selector(loadExample:) forControlEvents:UIControlEventTouchUpInside];
	} else {
		[button addTarget:self action:@selector(loadImage:) forControlEvents:UIControlEventTouchUpInside];
	}
	UIImage *thumb = [[thumbList objectAtIndex:pos] thumb];
	[button setImage:thumb forState:UIControlStateNormal];
	[scrollView addSubview:button];
	
	// add a little button for deleting
	if (pos >= numExamples) { // special case for examples, so you can't delete them
		CGRect r2 = CGRectMake(CGRectGetMaxX(r) - 25, CGRectGetMaxY(r) - 25, 20, 20);
		//UIButton *deleteButton = [[UIButton buttonWithType:UIButtonTypeCustom] initWithFrame:r2];
		UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[deleteButton setFrame:r2];
		deleteButton.tag = num;
		[deleteButton addTarget:self action:@selector(confirmDelete:) forControlEvents:UIControlEventTouchUpInside];
		[deleteButton setImage:xIcon forState:UIControlStateNormal];
		[scrollView addSubview:deleteButton];
	}
	
}
-(void)updateThumbs {		
	NSInteger thumbNum = [self getNextCanvasId]; 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *thumbName = [NSString stringWithFormat:@"thumbImage%d.png", thumbNum];
	NSString *uniquePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:thumbName];
	UIImage *thumb = [UIImage imageWithContentsOfFile:uniquePath];
	if (thumb) {
		[self addThumbToList:thumb withIdString:[NSString stringWithFormat:@"%d", thumbNum]];
		[self createButtonForImage:thumbNum atPosition:[thumbList count] - 1];
	}
	[self resizeScrollView];
}
-(void)rebuildButtons {
	for (UIView *view in [scrollView subviews]) {
		[view removeFromSuperview];
	}
	NSInteger count = 0;
	for (Thumb *t in thumbList) {
		[self createButtonForImage:[[t idStr] integerValue] atPosition:count];
		count++;
	}	
}
-(NSInteger)getNextCanvasId {
	NSInteger c = [thumbList count] - 1;
	if (c > 0) {
		Thumb *t = [thumbList objectAtIndex:c];
		NSString *tStr = [t idStr];
		NSInteger lastId = [tStr integerValue];
		return lastId + 1;
	} else {
		return 0;
	}
}
-(void)resizeScrollView {
	NSInteger nImages = [thumbList count];
	//[scrollView setContentSize:CGSizeMake(768, 163+(int)(nImages/6.0)*163)];	
    [scrollView setContentSize:CGSizeMake(1024, 163+(int)(nImages/6.0)*163)];	
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

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

-(void)loadImage:(id)sender {
	//myApp->loadCanvas([sender tag], false);
	[self dismissView];
}
-(void)loadExample:(id)sender {
	//myApp->loadCanvas([sender tag], true);
	[self dismissView];
}

- (void)confirmDelete:(id)sender {
	idToDelete = (int)[sender tag];
	alertConfirmDelete = [[UIAlertView alloc] initWithTitle:@"Delete" 
													message:@"Are you sure you want to delete?" 
												   delegate:self 
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles:@"Okay", nil];
	[alertConfirmDelete show];
	[alertConfirmDelete release];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == [alertView firstOtherButtonIndex]) { //user pressed okay
		[self deleteImage];
	}
}

-(void)deleteImage {
		
	NSInteger index = [self getIndexForId: idToDelete];
	[thumbList removeObjectAtIndex:index];
	[self rebuildButtons];
	
	// delete the actual files
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 

	NSString *fileName = [NSString stringWithFormat:@"thumbImage%d.png", idToDelete];
	NSString *fullPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
	[fileManager removeItemAtPath:fullPath error:NULL];
	
	fileName = [NSString stringWithFormat:@"bells%d.xml", idToDelete];
	fullPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
	[fileManager removeItemAtPath:fullPath error:NULL];
		
}
- (NSInteger)getIndexForId:(NSInteger)idIWant {
    NSInteger index = 0;
    for (Thumb *t in thumbList) {
        if ([[t idStr] integerValue] == idIWant)
            return index;
        index++;
    }
    return NSNotFound;
}
-(IBAction)dismissView{
    
    printf("dismissView:\n");
    
    // start an animation block
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    
    // configure your animation
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView: [[self view]superview] cache: YES];
    
    //[[self view] removeFromSuperview];
	[[self view] setHidden:YES];
    
    // do it!
    [UIView commitAnimations];
    
}

- (void)dealloc {
    [super dealloc];
}

//- (void)emailScreenImg:(id)sender {
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
//	NSString *fileName = [NSString stringWithFormat:@"screenImage%d.png", (int)[sender tag]];
//	NSString *fullPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
//	char *to = (char *)[@"me" UTF8String];
//	char *subject = (char *)[@"yay" UTF8String];
//	char *body = (char *)[@"empty" UTF8String];
//	char *p = (char *)[fullPath UTF8String];
//	myApp->sendEmail(to, subject, body, p, [self parentViewController]);
//}


@end
