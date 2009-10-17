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
}
- (id) initWithNSPoint:(NSPoint)pNSPoint;
- (NSPoint) myNSPoint;
- (float)x;
- (float)y;

@end
