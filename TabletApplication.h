/*----------------------------------------------------------------------------
 
 NAME
 
 TabletApplication.h -- Header file
 Cocoa has added natvie support for tablet events.
 While this makes some things greatly easier, there
 are still some things we need to override
 NSApplication to help us with.
 1) Added some proxy methods to turn mouse coalesing
 On & Off
 2) Capture tablet proximity events and post them
 as NSNotifications so that each object that
 needs to know about proximity changes gets that
 info, regardless of where they are in the event
 chain.
 3) Install a Carbon Event Handler to capture tablet
 proximty events that occur when our app is in the
 background. Cocoa does not nativley support
 Moniter Event Targets. :(
 
 
 COPYRIGHT
 
 Author Project Builder
 Copyright WACOM Technology, Inc. 2004-2005.
 All rights reserved.
 
 -----------------------------------------------------------------------------*/

#import <AppKit/NSApplication.h>

extern NSString *kProximityNotification;
extern NSString *kProximityEventKey;
extern NSString *kProximityEventCarbonKey;

@interface TabletApplication : NSApplication {
	EventHandlerRef	mProxEventHandlerRef;
}

// Carbon Trickery I hope we can avoid for Tiger's release
-(BOOL)isMouseCoalescingEnabled;
-(void)setMouseCoalescingEnabled:(BOOL)isEnabled;
@end
