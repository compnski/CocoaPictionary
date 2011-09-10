//
//  MyViewController.h
//  CocoaPictionary
//
//  Created by Jason on 10/16/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyPoint.h"
#import <AppKit/AppKit.h>
#import "DeviceTracker.h"

@interface MyViewController : NSView {
    NSMutableArray  * myMutaryOfBrushStrokes;
    NSMutableArray  * myMutaryOfPoints;
	float m_pressure;
	BOOL is_eraser;
}

- (float)randVar;
- (void)clear;
@end
