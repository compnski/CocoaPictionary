//
//  MyPoint.m
//  CocoaPictionary
//
//  Created by Jason on 10/16/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//
#import "MyPoint.h"

@implementation MyPoint

- (id) initWithNSPoint:(NSPoint)pNSPoint;
{
    if ((self = [super init]) == nil) {
        return self;
    } // end if
	
    myNSPoint.x = pNSPoint.x;
    myNSPoint.y = pNSPoint.y;
    
    return self;
	
} // end initWithNSPoint

- (NSPoint) myNSPoint;
{
    return myNSPoint;
} // end myNSPoint

- (float)x;
{
    return myNSPoint.x;
} // end x

- (float)y;
{
    return myNSPoint.y;
} // end y


@end
