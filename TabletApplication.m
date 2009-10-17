/*----------------------------------------------------------------------------

NAME

	TabletApplication.m -- Cocoa has added natvie support for tablet events.
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

	Author Raleigh Ledet
	Copyright WACOM Technologies, Inc. 2004-2005
	All rights reserved.

-----------------------------------------------------------------------------*/

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "TabletApplication.h"

NSString *kProximityNotification = @"kProximityNotification";
NSString *kProximityEventKey = @"kProximityEventKey";
NSString *kProximityEventCarbonKey = @"kProximityEventCarbonKey";

OSStatus CarbonTabletProximityCallback(EventHandlerCallRef inCallRef,
                                    EventRef inEvent, void *userData);
									
@implementation TabletApplication
/////////////////////////////////////////////////////////////////////////////
- (id)init
{
	NSLog(@"Init TabletApplication");
	if(self = [super init])
	{
	
		// There is no way to tell Cocoa to register for background events
		// So install a carbaon event handler on the monitor target so that
		// we can get background tablet proximity events.
		// See the notes above the CarbonTabletProximityCallback() function at
		// the bottom of this file.
	
		OSErr			status = noErr;
		EventTypeSpec	tabletProximityEvent = { kEventClassTablet,
												 kEventTabletProximity };
		
		status = InstallEventHandler( GetEventMonitorTarget(),
						NewEventHandlerUPP( CarbonTabletProximityCallback ),
						1, &tabletProximityEvent, NULL, &mProxEventHandlerRef);
		assert(status == noErr);
	}
	return self;
}



/////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
	RemoveEventHandler(mProxEventHandlerRef);
   [super dealloc];
}



/////////////////////////////////////////////////////////////////////////////
- (void)sendEvent:(NSEvent *)theEvent
{
	if([theEvent type] == NSTabletProximity)
	{
		[self tabletProximity:theEvent];
		return;
	}
	
	[super sendEvent:theEvent];
}



//////////////////////////////////////////////////////////////////////////////
//- (void)tabletProximity:(NSEvent *)theEvent;
//
// Tablet Proximity Events are routed through the NSResponder chain like a
// a mouse event (I think). This means that the first responder to respond to
// this event will prevent other responders from seeing it. :(
//
// Usually, every object that cares about proximity events needs to know when
// a new one comes in. I resolve this little problem by only letting the 
// NSApp respond to the tabletProximity message here. The NSApp will then
// package the proximity event into an NSNotification and post that notification
// to the rest of the app.
//
// So any object in this app that cares about proximity events should register
// to recieve this notification instead of implamenting the NSResponder
// -tabletProximity: method directly.
//
- (void)tabletProximity:(NSEvent *)theEvent;
{
	NSDictionary	*userDict = [NSDictionary dictionaryWithObject:theEvent
												forKey:kProximityEventKey];
	// Send the Proximity Notification
	[[NSNotificationCenter defaultCenter]
		   postNotificationName: kProximityNotification
		   object: self
		   userInfo: userDict];
}


//////////////////////////////////////////////////////////////////////////////
-(void)setMouseCoalescingEnabled:(BOOL)isEnabled
{
	// Carbon Trickery I hope we can avoid for Tiger's release
	// In fact, please file a bug about this.
	// For that matter, use a DTS incident about this too.
	SetMouseCoalescingEnabled(isEnabled,NULL);
}



//////////////////////////////////////////////////////////////////////////////
-(BOOL)isMouseCoalescingEnabled
{
	// Carbon Trickery I hope we can avoid for Tiger's release
	// In fact, please file a bug about this.
	// For that matter, use a DTS incident about this too.
	return IsMouseCoalescingEnabled();
}
@end



//////////////////////////////////////////////////////////////////////////////
// CarbonTabletProximityCallback
//
// Carbon Trickery I hope we can avoid for Tiger's release
// In fact, please file a bug about this.
// For that matter, use a DTS incident about this too.
//
// This is the carbon handler that gets called when a proximity event
// occurs while we are not the foreground application. This is very important.
// The user may have flipped the pen over to the eraser, or switched pens
// completely while this application is in the background. With normal Cocoa
// event processing, we would never know the new properties of the transducer
// when our app is re-activated. This could result in drawing when the user
// expects us to erase, wacko drawing because we were expecting tilt or rotation
// data that is no longer there, or vice versa, or worse, not doing anything
// because the deviceIDs do not match what we expect. Thus we have to rely on
// the Carbon Monitor Target event handler that was setup in the -init method
// of this file.
//
// The part that really sucks is that there is no way that I know of to
// take the carbon event and turn it into a true NSEvent. Thus the proximity
// notification sent from here is slightly different than the usual one above.
// So, each object that listens for Proximity Notifications need to know how
// to deal with the different data in the proximity notification. This would
// be so much easier and cleaner if Cocoa could register for background events.
OSStatus CarbonTabletProximityCallback(EventHandlerCallRef inCallRef,
                                    EventRef inEvent, void *userData )
{
	TabletProximityRec		theTabletRecord = {0};

	// Extract the Tablet Proximity record from the event.
	if(noErr == GetEventParameter(inEvent, kEventParamTabletProximityRec,
								  typeTabletProximityRec, NULL,
								  sizeof(TabletProximityRec),
								  NULL, (void *)&theTabletRecord))
	{
		NSData			*proxData = [NSData dataWithBytes:&theTabletRecord
										length:sizeof(TabletProximityRec)];
		NSDictionary	*userDict = [NSDictionary dictionaryWithObject:proxData
													forKey:kProximityEventCarbonKey];
		// Send the Proximity Notification
		[[NSNotificationCenter defaultCenter]
			   postNotificationName: kProximityNotification
			   object: NSApp
			   userInfo: userDict];
	}
	
	return noErr;
}

