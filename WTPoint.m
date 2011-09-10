//
//  WTPoint.m
//  CocoaPictionary
//
//  Created by Jason on 10/17/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//

#import "WTPoint.h"


@implementation WTPoint
-(id)initWithArgs:(float)_opacity mIsErasing:(BOOL)_mIsErasing brushSize:(float)_brushSize currentLoc:(NSPoint)_currentLoc;
{
	if ((self = [super init]) == nil) {
        return self;
    } // end if
		
	opacity = _opacity;
	mIsErasing = _mIsErasing;
	brushSize = _brushSize;
	currentLoc = _currentLoc;
	return self;
}

-(float)opacity;
{
	return opacity;
}
-(float)brushSize;
{
	return brushSize;
}
-(BOOL)mIsErasing;
{
	return mIsErasing;
}
-(NSPoint)mLastLoc;
{
	return mLastLoc;
}
-(NSPoint)currentLoc;	
{
	return currentLoc;
}
- (float)x;
{
    return currentLoc.x;
} // end x

- (float)y;
{
    return currentLoc.y;
} // end y

@end
