/*----------------------------------------------------------------------------

FILE NAME

WTView.m - Implementation file for WTView class.
		   WTView handles all of the drawing by the user.

COPYRIGHT

	Author Project Builder
	Copyright WACOM Technology, Inc. 2004-2005.
	All rights reserved.

----------------------------------------------------------------------------*/


#import <Carbon/Carbon.h>
#import "WTView.h"
#import "TabletApplication.h"
#import "WTPoint.h"

NSString *WTViewUpdatedNotification = @"WTViewStatsUpdatedNotification";

#define maxBrushSize 50.0;

@implementation WTView
///////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code here.
        mAdjustOpacity = NO;
        mAdjustSize = YES;
        mCaptureMouseMoves = NO;
		allowDrawing = YES;
        mUpdateStatsDuringDrag = YES;
        knownDevices = [[DeviceTracker alloc] init];
		[[NSColor whiteColor] set];
		NSRectFill([self bounds]);
		myMutaryOfBrushStrokes = [[NSMutableArray alloc]init];
    }
    return self;
}



///////////////////////////////////////////////////////////////////////////
- (void) dealloc
{
   [knownDevices release];
   [super dealloc];
}



///////////////////////////////////////////////////////////////////////////
- (void)awakeFromNib
{
   // Must inform the window if we want mouse moves after all object
   // are created and linked.
   // Let our internal routine make the API call so that everything
   // stays in sych. Change the value in the init routine to change
   // the default behavior
	
   [self setCaptureMouseMoves:[self mCaptureMouseMoves]];
   
   //Must register to be notified when device come in and out of Prox
   [[NSNotificationCenter defaultCenter] addObserver:self
               selector:@selector(handleProximity:)
               name:kProximityNotification
               object:nil];
}



///////////////////////////////////////////////////////////////////////////
- (void)tabletPoint:(NSEvent *)theEvent
{
	// The Wacom driver waits for the user to move the cursor
	// at least one pixel (or more depending on double-click assist)
	// before sending drag events.
	
	// This means that you don't get all of the changes in tablet data until
	// the user actually starts dragging.
	
	 // All is not lost, however, as the changes in tablet data between the
	 // mouse down and the first mouse drag, are posted as pure tablet points.
	 // There is no mouse location associated with this data, so you must assume
	 // that the last known mouse location is where it takes place.
	 
	  // WARNING: If the user has more than one device on the tablet at a time,
	  //          (and the tablet supports it) all events from the second
	  //		  concurrent device will come through as pure tablet points.
	  //		  this is where the deviceID field becomes very important!
	  //		  a real application would check for this!
	
	[self handleMouseEvent:theEvent];
	[self drawCurrentDataFromEvent:theEvent];
	[[self window] flushWindow];
}



///////////////////////////////////////////////////////////////////////////
- (void)mouseDown:(NSEvent *)theEvent
{
	// Save the loc the mouse down occurred at. This will be used by the
	// Drawing code during a Drag event to follow.
	mLastLoc = [self convertPoint:[theEvent locationInWindow]
				  fromView:nil];
	myMutaryOfPoints = [[NSMutableArray alloc]init];
	[myMutaryOfBrushStrokes addObject:myMutaryOfPoints];

				  
	// Updating the text display of the stats can take up a lot of time.
	// This can lead to less smooth curves being drawn. Toggle the
	// Update Stats During Drag menu option to see the difference.  
	if(!mUpdateStatsDuringDrag)
	{
		BOOL keepOn = YES;

		// Mouse events are normally coalesced. That is, only one or two mouse
		// events will be in your event que at one time. (Button transtions are
		// never coalseced). This is normally a good thing for non tablet aware
		// applications that can not handle 100+ mouse events per second.
		// To get a smoother representation of what the user did on the tablet,
		// we want to get ALL of the mouse events. Thus we turn mouse event
		// coalescing off during drawing. We need to be sure to turn back on
		// when the user is no loger drawing (Left button up) or else window
		// drags, menu selections and so forth may stat to lag behind the cursor.
		// Note: I demonstrate 1 technique here for dealing 100+ mouse events per
		// second and remaining in synch with the cursor. This may still be too
		// slow for your app. If you need more ideas, please email me at
		// <rledet@wacom.com>.
		[NSApp setMouseCoalescingEnabled:NO];
		fprintf(stderr,"setMouseCoalescingEnabled:NO\n"); 
		
		// Update the stats for just the mouse down. However, we only want to
		// take the time to update the stats AFTER we turn mouse coalescing off!
		// otherwise, we will lose some drag events due to coalescing because
		// updating the stats can take a while.
		[self handleMouseEvent:theEvent];

		while (keepOn)
		{
			// Wait for either a Mouse Up, Mouse Drag or Tablet Point event.
			// Timers will still fire while waiting here.
			fprintf(stderr,"Waiting for Mouse Event\n");
			theEvent = [[self window] nextEventMatchingMask:NSLeftMouseUpMask |
			NSLeftMouseDraggedMask | NSTabletPointMask];

			switch ([theEvent type])
			{
				case NSTabletPoint:
					if([theEvent pressure] == 0.0f)
					{
						// This should NEVER happen. Wacom takes special care
						// to make sure to never do this. Other tablet drivers
						// may not follow this. Ink really, really hates this.
						
						// There was a bug in early versions of Tiger, where
						// Cocoa was not deconstructing the carbon tablet point
						// event properly. (ID# 3732653) It was fixed by build
						// 8A268.
						assert(!"Zero pressure during drag!");
						break;
					}
				case NSLeftMouseDragged:
					[self drawCurrentDataFromEvent:theEvent];

					// Sweep the event que of any outstanding drag or
					// tablet events. Notice the untilDate:nil... This
					// forces the method to return nil right away if
					// there is no event in the que that we want.
					while(theEvent = [NSApp nextEventMatchingMask:
						NSLeftMouseDraggedMask | NSTabletPointMask
						untilDate:nil // Don't wait for the event
						inMode:NSEventTrackingRunLoopMode
						dequeue:YES])
					{
						[self drawCurrentDataFromEvent:theEvent];
					}
					
					// This is a poor example of how to draw in Cocoa
					// Then again, this is sample code for tablets, not
					// smaple code for drawing.
					[[self window] flushWindow];
				break;

				case NSLeftMouseUp:
					keepOn = NO;
					
					// Display the Mouse up event stats
					[self handleMouseEvent:theEvent];
				break;

				default:
				 /* Ignore any other kind of event. */
				break;
			}
		}

		// Finished drawing, turn mouse coalescing back on! See the long
		// comment earlier in this method when coalescing is turned off for
		// more info.
		[NSApp setMouseCoalescingEnabled:YES];
		fprintf(stderr,"setMouseCoalescingEnabled:YES\n");
	}
	else
	{
		[self handleMouseEvent:theEvent];
	}
}



///////////////////////////////////////////////////////////////////////////
- (void)mouseDragged:(NSEvent *)theEvent
{
	if ([theEvent subtype] == NSTabletPointEventSubtype)
	{
		if ([theEvent deviceID] != [knownDevices currentDeviceEventID])
		{
			// The deviceID the event came from does not match the deviceID of
			// the device that was thought to be on the Tablet. Must have
			// missed a Proximity Notification! To avoid this situation, you
			// must listen to background proximty events on the Monitor Target!
			assert(!"Unknown device on Tablet! Are you listening to backgroun events?");
			return;
		}
	}
   
  [self drawCurrentDataFromEvent:theEvent];
  [self handleMouseEvent:theEvent];
  [[self window] flushWindow];
  
}



///////////////////////////////////////////////////////////////////////////
- (void)mouseMoved:(NSEvent *)theEvent
{
	if ([theEvent subtype] == NSTabletPointEventSubtype)
	{
		if ([theEvent deviceID] != [knownDevices currentDeviceEventID])
		{
			// The deviceID the event came from does not match the deviceID of
			// the device that was thought to be on the Tablet. Must have
			// missed a Proximity Notification! To avoid this situation, you
			// must listen to background proximty events on the Monitor Target!
			assert(!"Unknown device on Tablet! Are you listening to backgroun events?");
			return;
		}
	}
   
   [self handleMouseEvent:theEvent];
}



///////////////////////////////////////////////////////////////////////////
- (void)mouseUp:(NSEvent *)theEvent
{
    [self handleMouseEvent:theEvent];
}



///////////////////////////////////////////////////////////////////////////

// - (void)handleMouseEvent:(NSEvent *)theEvent
//
// All of the Mouse Events are funneled through this function so that we
// do not have to duplicate this code. If you do something like this,
// you must be careful because certain fields are only valid for particular
// events. For example, [NSEvent pressure] is not valid for Mouse Moves!
//
- (void)handleMouseEvent:(NSEvent *)theEvent
{
   NSPoint	loc;
   NSPoint	tilt;
   
   mEventType	= [theEvent type];
   
   if(!([theEvent type] == NSTabletPoint))
   {
	   loc = [theEvent locationInWindow];
	   mMouseX	= loc.x;
	   mMouseY	= loc.y;
   }
   
   // pressure: is not valid for MouseMove events
   if(mEventType != NSMouseMoved)
   {
      mPressure	= [theEvent pressure];
   }
   else
   {
      mPressure = 0.0;
   }
   
   if(([theEvent type] == NSTabletPoint)
	|| ([theEvent subtype] == NSTabletPointEventSubtype))
   {
		mAbsX = [theEvent absoluteX];
		mAbsY = [theEvent absoluteY];
		
	   
	   tilt = [theEvent tilt];
	   mTiltX = tilt.x;
	   mTiltY = tilt.y;
		
	   mRotDeg = [theEvent rotation];
	   
	   mDeviceID =  [theEvent deviceID];
	}
   
   // Notify objects that care that this object's stats have been updated
   [[NSNotificationCenter defaultCenter]
         postNotificationName:WTViewUpdatedNotification
         object: self];
}



///////////////////////////////////////////////////////////////////////////

// - (void) handleProximity:(NSNotification *)proxNotice

//

// The proximity notification is based on the Proximity Event.
// (see CarbonEvents.h). The proximity notification will give you detailed
// information about the device that was either just placed on, or just
// taken off of the tablet.
// 
// In this sample code, the Proximity notification is used to determine if
// the pen TIP or ERASER is being used. This information is not provided in
// the embedded tablet event.
//
// Also, on the Intous line of tablets, each trasducer has a unique ID,
// even when different transducers are of the same type. We get that
// information here so we can keep track of the Color assigned to each
// transducer.
//
- (void) handleProximity:(NSNotification *)proxNotice
{
	NSEvent	*proxEvent = (NSEvent*)[[proxNotice userInfo]
									valueForKey:kProximityEventKey];
	BOOL	enteringProximity = NO;
	UInt8	pointerType = 0;
	UInt16	pointerID = 0;
	UInt16	deviceID = 0;
	UInt64	uniqueID = 0;

	if(proxEvent)
	{
		enteringProximity = [proxEvent isEnteringProximity];
		pointerType = [proxEvent pointingDeviceType];
		pointerID = [proxEvent pointingDeviceID];
		deviceID = [proxEvent deviceID];
		uniqueID = [proxEvent uniqueID];
	}
	else
	{
		// This is Carbon stuff I hope to avoid in the future
		// Look at TabletApplication.m for more info
		NSData *proxData = (NSData*)[[proxNotice userInfo]
									valueForKey:kProximityEventCarbonKey];
		TabletProximityRec proxRec = {0};
		
		assert(proxData);
		[proxData getBytes:&proxRec length:sizeof(proxRec)];
		enteringProximity = proxRec.enterProximity ? YES : NO;
		pointerType = proxRec.pointerType;
		pointerID = proxRec.pointerID;
		deviceID = proxRec.deviceID;
		uniqueID = proxRec.uniqueID;
	}
	
	// Only interested in Enter Proximity for 1st concurrent device
	if(enteringProximity && (pointerID == 0))
	{
		mIsErasing = (pointerType == NSEraserPointingDevice);
		NSLog([NSString stringWithFormat:@"isErasing? %d",mIsErasing]);

		if ([knownDevices setCurrentDeviceByID: uniqueID] == NO)
		{
			// must be a new device
			
			// Note: I'm keeping track of all the transducer's that I have seen.
			//       This way, the last used color for each transducer is
			//	     remembered. For example, with Wacom's Intous line of
			//		 tablets, you can set one pen to blue, bring another pen
			//		 into proximity and set it to red, then when you bring the
			//		 first pen back into proxmity, the forecolor will
			//		 automatically be set to blue for the user. (Wacom's
			//		 Graphire line of tablets do not support this.)
			//		 Note: See DeviceTracker.h for more ideas on how to use
			//		       uniqueID!
			
			Transducer *newDevice = [[Transducer alloc]
									initWithIdent: uniqueID
									color: [NSColor blackColor]];

			[knownDevices addDevice:newDevice];
			[newDevice release];
			[knownDevices setCurrentDeviceByID: uniqueID];
		}
		
		// Note: Unique ID is guaranteed across reboots, tablets, and computers.
		//       The deviceID of a transducer *can* change once it has exited
		//		 proximity. The deviceID should ONLY be used to correlate
		//		 [embedded] tablet point events and with tablet proximity events.
		//
		//		 Usually, using the same transducer, on the same
		//		 tablet, on the same computer will recycle the deviceID. That
		//		 is, you will often see the same deviceID used over and over
		//		 again for the same transducer. You may be tempted to use the
		//		 deviceID to uniquely distinquish between transducers. Resist
		//		 this temptation! The deviceID *WILL* change if the transducer
		//		 is used on a second tablet attached to the system, or another
		//		 system.
		//
		//		 The following line of code tells the device tracker
		//		 which deviceID is being used for the current transducer in
		//		 proximity.
		[knownDevices setCurrentDeviceEventID:deviceID];


		// Update the stats. If the transducer has changed, this will also
		// update the current forecolor to the last known color for this
		// transducer.
		[[NSNotificationCenter defaultCenter]
			postNotificationName:WTViewUpdatedNotification
			object: self];
	}
}



///////////////////////////////////////////////////////////////////////////
// - (void) drawCurrentDataFromEvent:(NSEvent *)theEvent
//
// This is where the pretty colors are drawn to the screen!
// A 'Real' app would probably keep track of this information so that the
// - (void) drawRect; function can properly re-draw it.
//
- (void) drawCurrentDataFromEvent:(NSEvent *)theEvent
{
	NSPoint currentLoc;
	float pressure;
	float opacity;
	float brushSize;

		
	if([theEvent type] == NSTabletPoint)
	{
		currentLoc = mLastLoc;
	}
	else
	{
		currentLoc = [self convertPoint:[theEvent locationInWindow]
				  fromView:nil];
	}
	
	pressure = [theEvent pressure];

	if(mAdjustSize)
	{
		brushSize = pressure * maxBrushSize;
	}
	else
	{
		brushSize = 0.5 * maxBrushSize;
	}

	if(mAdjustOpacity)
	{
		opacity = pressure;
	}
	else
	{
		opacity = 1.0;
	}

	WTPoint *wtpoint = [[[WTPoint alloc] initWithArgs:opacity mIsErasing:mIsErasing brushSize:brushSize currentLoc:currentLoc] retain];
	[myMutaryOfPoints addObject:wtpoint];

	mLastLoc = currentLoc;
	[self setNeedsDisplay:YES];

}



- (void)new_stroke:(CGContextRef)tvarCGContextRef brushSize:(float)brushSize r:(int)r g:(int)g b:(int)b a:(int)a;
{
	CGContextDrawPath(tvarCGContextRef,kCGPathStroke);
	CGContextBeginPath(tvarCGContextRef);
	CGContextSetLineWidth(tvarCGContextRef, brushSize );
	CGContextSetRGBStrokeColor(tvarCGContextRef,r,g,b,a);
}

///////////////////////////////////////////////////////////////////////////
// - (void)drawRect:(NSRect)rect
//
// A 'Real' app would probably keep track of the drawing information done
// during Mouse Drags so that it can properly be re-drawn here. I just
// clear the drawing region. (Resize the window and all the drawing is
// erased!)
//
- (void)drawRect:(NSRect)rect
{
   // You do not need to call [self lockFocus] here. Callers of this
   // function are responsible for locking and unlocking the focus for
   // this required method. See the Apple docs on NSView.
	[[NSColor whiteColor] set];
	NSRectFill([self bounds]);

	if([myMutaryOfPoints count] == 0)
		return;
	
	NSGraphicsContext * tvarNSGraphicsContext = [NSGraphicsContext currentContext];
	CGContextRef      tvarCGContextRef     = (CGContextRef) [tvarNSGraphicsContext graphicsPort];

	NSUInteger tvarIntNumberOfStrokes = [myMutaryOfBrushStrokes count];
	
	NSUInteger i;
	for (i = 0; i < tvarIntNumberOfStrokes; i++) {
		
		
		myMutaryOfPoints = [myMutaryOfBrushStrokes objectAtIndex:i];
		
		NSUInteger tvarIntNumberOfPoints = [myMutaryOfPoints count];    // always >= 2
		//MyPoint * tvarLastPointObj      = [myMutaryOfPoints objectAtIndex:0];
		NSPoint local_mLastLoc = [[myMutaryOfPoints objectAtIndex:0] currentLoc];
		float brushSize = 3.0;
		float eraserSize = 10.0;
		
		if ( [[myMutaryOfPoints objectAtIndex:0] mIsErasing] ) {
			[self new_stroke:tvarCGContextRef brushSize:brushSize r:255 g:255 b:255 a:255];
		} else {
			[self new_stroke:tvarCGContextRef brushSize:eraserSize r:0 g:0 b:0 a:255];
		}
		
//		[self new_stroke:tvarCGContextRef brushSize:3.0 r:0 g:0 b:0 a:255];
		CGContextMoveToPoint(tvarCGContextRef,local_mLastLoc.x,local_mLastLoc.y);
		NSUInteger j;
		for (j = 1; j < tvarIntNumberOfPoints; j++) {  // note the index starts at 1
			WTPoint * point = [myMutaryOfPoints objectAtIndex:j];
			//float brushSize = [point brushSize];
			//NSPoint mLastLoc = point.mLastLoc;
			NSPoint currentLoc = [point currentLoc];
			CGContextSetLineWidth(tvarCGContextRef, (brushSize) );
			// Don't forget to lockFocus when drawing to a view without
			// being inside - (void) drawRect;
	
			CGContextAddLineToPoint(tvarCGContextRef,currentLoc.x,currentLoc.y);	
		} // end for
		
		CGContextDrawPath(tvarCGContextRef,kCGPathStroke);
		
	} // end for

	/*
		[path setLineWidth:brushSize];
		[path setLineCapStyle:NSRoundLineCapStyle];
		
		[path moveToPoint:local_mLastLoc];
		
		if(NSEqualPoints(local_mLastLoc,currentLoc))
		{
			[path appendBezierPathWithOvalInRect:
			 NSMakeRect(	currentLoc.x - brushSize/2.0f,
						currentLoc.y - brushSize/2.0f,
						brushSize,brushSize)];
			[path fill];
		}
		else
		{
			[path lineToPoint:currentLoc];
			[path stroke];
		}
		local_mLastLoc = currentLoc;
	 */
	
}


- (void) clear
{
	[myMutaryOfBrushStrokes removeAllObjects];
	[myMutaryOfPoints removeAllObjects];
	[self setNeedsDisplay:YES];

}


///////////////////////////////////////////////////////////////////////////
- (BOOL)isOpaque
{
    // Makes sure that this view is not Transparant!
    return YES;
}



///////////////////////////////////////////////////////////////////////////
- (BOOL)acceptsFirstResponder
{
    // The view only gets MouseMoved events when the view is the First
    // Responder in the Responder event chain
    return YES;
}



///////////////////////////////////////////////////////////////////////////
- (BOOL)becomeFirstResponder
{
	// If do not use the notification method to send proximity events to
	// all objects then you will need to ask the Tablet Driver to resend
	// the last proximity event every time your view becomes the first
	// responder. Alas, you can only do that with the Wacom tablet driver.
	// And really, if you use the simple notification technique, you don't have
	// to.
	
   return YES;
}



///////////////////////////////////////////////////////////////////////////
- (int) mEventType
{
    return mEventType;
}



///////////////////////////////////////////////////////////////////////////
- (UInt16) mDeviceID
{
    return mDeviceID;
}



///////////////////////////////////////////////////////////////////////////
- (float) mMouseX
{
    return mMouseX;
}



///////////////////////////////////////////////////////////////////////////
- (float) mMouseY
{
    return mMouseY;
}



///////////////////////////////////////////////////////////////////////////
- (float) mPressure
{
    return mPressure;
}



///////////////////////////////////////////////////////////////////////////
- (SInt32) mAbsX
{
    return mAbsX;
}



///////////////////////////////////////////////////////////////////////////
- (SInt32) mAbsY
{
    return mAbsY;
}



///////////////////////////////////////////////////////////////////////////
- (float) mTiltX
{
    return mTiltX;
}



///////////////////////////////////////////////////////////////////////////
- (float) mTiltY
{
    return mTiltY;
}



///////////////////////////////////////////////////////////////////////////
- (float) mRotDeg
{
    return mRotDeg;
}



///////////////////////////////////////////////////////////////////////////
- (NSColor *) mForeColor
{
   Transducer *currentDevice = [knownDevices currentDevice];
   
   if(currentDevice != NULL)
   {
      return [currentDevice color];
   }
   
   return [NSColor blackColor];
}



///////////////////////////////////////////////////////////////////////////
- (void) setForeColor:(NSColor *)newColor
{
   Transducer *currentDevice = [knownDevices currentDevice];
   if(currentDevice != NULL)
   {
      [currentDevice setColor:newColor];
   }
}



///////////////////////////////////////////////////////////////////////////
- (BOOL) mAdjustOpacity
{
   return mAdjustOpacity;
}



///////////////////////////////////////////////////////////////////////////
- (void) setAdjustOpacity:(BOOL)adjust
{
   mAdjustOpacity = adjust;
}



///////////////////////////////////////////////////////////////////////////
- (BOOL) mAdjustSize
{
   return mAdjustSize;
}



///////////////////////////////////////////////////////////////////////////
- (void) setAdjustSize:(BOOL)adjust
{
   mAdjustSize = adjust;
}



///////////////////////////////////////////////////////////////////////////
- (BOOL) mCaptureMouseMoves
{
   return mCaptureMouseMoves;
}



///////////////////////////////////////////////////////////////////////////
- (void) setCaptureMouseMoves:(BOOL)value
{
   mCaptureMouseMoves = value;
   [[self window] setAcceptsMouseMovedEvents:mCaptureMouseMoves];
}



///////////////////////////////////////////////////////////////////////////
- (BOOL) mUpdateStatsDuringDrag
{
   return mUpdateStatsDuringDrag;
}



///////////////////////////////////////////////////////////////////////////
- (void) setUpdateStatsDuringDrag:(BOOL)value
{
   mUpdateStatsDuringDrag = value;
}

@end
