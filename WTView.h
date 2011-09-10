/*----------------------------------------------------------------------------

FILE NAME

WTView.h - Header file for WTView class.
		   WTView handles all of the drawing by the user.

COPYRIGHT

	Author Project Builder
	Copyright WACOM Technology, Inc. 2004-2005.
	All rights reserved.

----------------------------------------------------------------------------*/

#import <AppKit/AppKit.h>
#import "DeviceTracker.h"

@interface WTView : NSView {
    int		mEventType;
    UInt16	mDeviceID;
    float	mMouseX;
    float	mMouseY;
    float	mPressure;
    SInt32	mAbsX;
    SInt32	mAbsY;
    float	mTiltX;
    float	mTiltY;
    float	mRotDeg;
    
    DeviceTracker* knownDevices;
    BOOL		mAdjustOpacity;
    BOOL		mAdjustSize;
    BOOL		mCaptureMouseMoves;
    BOOL		mUpdateStatsDuringDrag;
    
    NSMutableArray  * myMutaryOfPoints;
	NSMutableArray  * myMutaryOfBrushStrokes;

	
    //Private
	BOOL		allowDrawing;
    BOOL		mIsErasing;
    NSPoint		mLastLoc;
}

- (int) mEventType;
- (UInt16) mDeviceID;
- (float) mMouseX;
- (float) mMouseY;
- (float) mPressure;
- (SInt32) mAbsX;
- (SInt32) mAbsY;
- (float) mTiltX;
- (float) mTiltY;
- (float) mRotDeg;
    
- (NSColor *) mForeColor;
- (void) setForeColor:(NSColor *)newColor;

- (BOOL) mAdjustOpacity;
- (void) setAdjustOpacity:(BOOL)adjust;
- (BOOL) mAdjustSize;
- (void) setAdjustSize:(BOOL)adjust;

- (BOOL) mCaptureMouseMoves;
- (void) setCaptureMouseMoves:(BOOL)value;
- (BOOL) mUpdateStatsDuringDrag;
- (void) setUpdateStatsDuringDrag:(BOOL)value;

- (void) handleMouseEvent:(NSEvent *)theEvent;
- (void) handleProximity:(NSNotification *)proxNotice;
- (void) drawCurrentDataFromEvent:(NSEvent *)theEvent;

- (void) clear;
//- (void) allowDrawing:(BOOL)allow:
@end

extern NSString *WTViewUpdatedNotification;
