/*----------------------------------------------------------------------------

FILE NAME

DeviceTracker.h - Header file for the DeviceTracker and Transducer classes.
                  Note: Basically, these classes provide a way for the user
						to assign a specific color to each pen (if the pen
						supports unique serial numbers). Then, to change colors,
						the user literally just uses a different pen on the
						tablet. The program will automatically change the
						forground color to the last color used by that pen.
						This concept could be extended to any other kind of
						preference such as brush type, tool type, privlages etc.
						One wacky idea is that when a manger uses his/her
						personal pen, additional options are unlocked.
						It is not done in this sample code, but the data stored
						by the DeviceTracker could be saved to NSUserPreferences
						and reloaded at app start. Then the app would remember
						brush color across launches!
                  Transducer - This class stores the color preferences for
				               a specific transducer.
				  DeviceTracker - This class manages a collection of Transducer
				                  objects. It makes sure that it each transducer
								  in it's collection has a unique ID.
								  It also has a cocpet of the "current"
								  transducer object being used.

COPYRIGHT

	Author Project Builder
	Copyright WACOM Technology, Inc. 2004-2005.
	All rights reserved.

----------------------------------------------------------------------------*/
#import <Cocoa/Cocoa.h>

@interface Transducer : NSObject {
   UInt64 ident;
   NSColor	*mColor;
}

-(Transducer *) initWithIdent:(UInt64)newIdent color:(NSColor *) newColor;
-(UInt64) ident;
-(NSColor *) color;
-(void) setColor:(NSColor *) newColor;

@end

@interface DeviceTracker : NSObject {
   Transducer		*currentDevice;
   NSMutableArray	*deviceList;
   UInt16			currentDeviceEventID;
}

-(BOOL) setCurrentDeviceByID:(UInt64) deviceIdent;
-(Transducer *) currentDevice;
-(UInt16) currentDeviceEventID;
-(void) setCurrentDeviceEventID:(UInt16) newEventID;
-(void) addDevice:(Transducer *) newDevice;
@end
