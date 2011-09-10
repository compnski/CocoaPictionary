//
//  MyPoint.h
//  CocoaPictionary
//
//  Created by Jason on 10/16/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//
// wrapper for NSPoint
#import <Cocoa/Cocoa.h>

@interface MyPoint : NSObject {
    NSPoint myNSPoint;
	BOOL is_erase;
	float pressure;
}
- (id) initWithNSPoint:(NSPoint)pNSPoint is_eraser:(BOOL)is_erase;
- (NSPoint) myNSPoint;
- (float)x;
- (float)y;
- (BOOL)is_erase;
- (float)pressure;

@end
