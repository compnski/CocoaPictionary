//
//  WTPoint.h
//  CocoaPictionary
//
//  Created by Jason on 10/17/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WTPoint : NSObject {
	float opacity;
	BOOL mIsErasing;
	float brushSize;
	NSPoint mLastLoc;
	NSPoint currentLoc;	
}
-(id)initWithArgs:(float)opacity mIsErasing:(BOOL)mIsErasing brushSize:(float)brushSize currentLoc:(NSPoint)currentLoc;
-(float)opacity;
-(float)brushSize;
-(BOOL)mIsErasing;
-(NSPoint)mLastLoc;
-(NSPoint)currentLoc;	
- (float)x;
- (float)y;

@end

