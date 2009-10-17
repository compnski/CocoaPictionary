//
//  MyViewController.m
//  CocoaPictionary
//
//  Created by Jason on 10/16/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//

#import "MyViewController.h"
#import "MyViewController.h"

@implementation MyViewController

- (id)initWithFrame:(NSRect)pNsrectFrameRect {
	
	if ((self = [super initWithFrame:pNsrectFrameRect]) == nil) {
		return self;
	} // end if
	
	myMutaryOfBrushStrokes = [[NSMutableArray alloc]init];
	
	// initialise random numebr generator used in drawRect for creating colours etc.
	srand(time(NULL));
	
	return self;
} // end initWithFrame


- (void)clear {
	[myMutaryOfBrushStrokes removeAllObjects];
	[myMutaryOfPoints removeAllObjects];
	[self setNeedsDisplay:YES];

}

-(void)mouseDown:(NSEvent *)pTheEvent {
	
	myMutaryOfPoints = [[NSMutableArray alloc]init];
	[myMutaryOfBrushStrokes addObject:myMutaryOfPoints];
	
	NSPoint tvarMousePointInWindow = [pTheEvent locationInWindow];
	NSPoint tvarMousePointInView   = [self convertPoint:tvarMousePointInWindow fromView:nil];
	MyPoint * tvarMyPointObj      = [[MyPoint alloc]initWithNSPoint:tvarMousePointInView];
	
	[myMutaryOfPoints addObject:tvarMyPointObj];      
	
} // end mouseDown



-(void)mouseDragged:(NSEvent *)pTheEvent {
	
	NSPoint tvarMousePointInWindow = [pTheEvent locationInWindow];
	NSPoint tvarMousePointInView   = [self convertPoint:tvarMousePointInWindow fromView:nil];
	MyPoint * tvarMyPointObj      = [[MyPoint alloc]initWithNSPoint:tvarMousePointInView];
	
	[myMutaryOfPoints addObject:tvarMyPointObj];   
	
	[self setNeedsDisplay:YES]; 
	
} // end mouseDragged



-(void)mouseUp:(NSEvent *)pTheEvent {
	
	NSPoint tvarMousePointInWindow = [pTheEvent locationInWindow];
	NSPoint tvarMousePointInView   = [self convertPoint:tvarMousePointInWindow fromView:nil];
	MyPoint * tvarMyPointObj      = [[MyPoint alloc]initWithNSPoint:tvarMousePointInView];
	
	[myMutaryOfPoints addObject:tvarMyPointObj];	
	
	[self setNeedsDisplay:YES];
	
} // end mouseUp


- (float)randVar;
{
	return ( (float)(rand() % 10000 ) / 10000.0);
} // end randVar



- (void)drawRect:(NSRect)pNSRect {
	// colour the background white
	[[NSColor whiteColor] set];		// this is Cocoa
	NSRectFill( pNSRect );
	
	if ([myMutaryOfBrushStrokes count] == 0) {
		return;
	} // end if
	
	// This is Quartz 
	NSGraphicsContext * tvarNSGraphicsContext = [NSGraphicsContext currentContext];
	CGContextRef      tvarCGContextRef     = (CGContextRef) [tvarNSGraphicsContext graphicsPort];
	
	NSUInteger tvarIntNumberOfStrokes = [myMutaryOfBrushStrokes count];
	
	NSUInteger i;
	for (i = 0; i < tvarIntNumberOfStrokes; i++) {
		
		CGContextSetRGBStrokeColor(tvarCGContextRef,0,0,0,255);
		CGContextSetLineWidth(tvarCGContextRef, (3.0) );
		
		myMutaryOfPoints = [myMutaryOfBrushStrokes objectAtIndex:i];
		
		NSUInteger tvarIntNumberOfPoints = [myMutaryOfPoints count];    // always >= 2
		MyPoint * tvarLastPointObj      = [myMutaryOfPoints objectAtIndex:0];
		CGContextBeginPath(tvarCGContextRef);
		CGContextMoveToPoint(tvarCGContextRef,[tvarLastPointObj x],[tvarLastPointObj y]);
		
		NSUInteger j;
		for (j = 1; j < tvarIntNumberOfPoints; j++) {  // note the index starts at 1
			MyPoint * tvarCurPointObj = [myMutaryOfPoints objectAtIndex:j];
			CGContextAddLineToPoint(tvarCGContextRef,[tvarCurPointObj x],[tvarCurPointObj y]);	
		} // end for
		
		CGContextDrawPath(tvarCGContextRef,kCGPathStroke);
		
	} // end for
	
} // end drawRect


@end
