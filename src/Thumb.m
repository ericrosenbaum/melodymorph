//
//  Thumb.m
//  singingfingers
//
//  Created by England on 6/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Thumb.h"


@implementation Thumb

-(UIImage *) thumb {
	return thumb;
}
-(NSString *) idStr {
	return idStr;
}

-(void) setThumb:(UIImage *)image {
	[image retain];
	[thumb release];
	thumb = image;
}
-(void) setIdStr:(NSString *)str {
	[str retain];
	[idStr release];
	idStr = str;
}

- (NSComparisonResult)compareThumbs:(Thumb *)otherThumb {
	NSInteger id1 = [[self idStr] integerValue]; 
	NSInteger id2 = [[otherThumb idStr] integerValue]; 
		
	if (id1 < id2) {
		return NSOrderedAscending;
	}
	else if (id1 > id2) {
		return NSOrderedDescending;
	}
	else 
	{
		return NSOrderedSame;
	}
}



@end
