//
//  Thumb.h
//  singingfingers
//
//  Created by England on 6/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Thumb : NSObject {
	UIImage *thumb;
	NSString *idStr;
}

//getters
-(UIImage *) thumb;
-(NSString *) idStr;

//setters
-(void) setThumb:(UIImage *)image;
-(void) setIdStr:(NSString *)str;

-(NSComparisonResult) compareThumbs:(Thumb *)otherThumb;

@end
