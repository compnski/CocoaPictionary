/*----------------------------------------------------------------------------

FILE NAME

DeviceTracker.m - Implamentation file for the DeviceTracker and Transducer
                  classes.
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
#import "DeviceTracker.h"


@implementation Transducer
///////////////////////////////////////////////////////////////////////////
-(Transducer *) init
{
   if(self = [super init]);
   {
      mColor = [NSColor blackColor];
   }
   
   return self;
}



///////////////////////////////////////////////////////////////////////////
-(void) dealloc
{
   [mColor release];
   [super dealloc];
}



///////////////////////////////////////////////////////////////////////////
-(Transducer *) initWithIdent:(UInt64)newIdent color:(NSColor *) newColor
{
   if(self = [super init]);
   {
      ident = newIdent;
      mColor = [newColor copy];
   }
   
   return self;
}



///////////////////////////////////////////////////////////////////////////
-(UInt64) ident
{
   return ident;
}



///////////////////////////////////////////////////////////////////////////
-(NSColor *) color
{
   return mColor;
}



///////////////////////////////////////////////////////////////////////////
-(void) setColor:(NSColor *)newColor
{
   [mColor release];
   mColor = [newColor copy];
}

@end




@implementation DeviceTracker
///////////////////////////////////////////////////////////////////////////
-(DeviceTracker *) init
{
   if(self = [super init])
   {
      currentDevice = NULL;
      deviceList = [[NSMutableArray alloc] init];
   }
   return self;
}



///////////////////////////////////////////////////////////////////////////
-(void) dealloc
{
   [deviceList release];
   [super dealloc];
}



///////////////////////////////////////////////////////////////////////////
-(BOOL) setCurrentDeviceByID:(UInt64) deviceIdent
{
   NSEnumerator *enumerator = [deviceList objectEnumerator];
   id anObject;
	
   while ((anObject = [enumerator nextObject]))
   {
      if ([anObject ident] == deviceIdent)
      {
         currentDevice = anObject;
         return YES;
      }
   }
   
   return NO;
}



///////////////////////////////////////////////////////////////////////////
-(Transducer *) currentDevice
{
   return currentDevice;
}



///////////////////////////////////////////////////////////////////////////
-(UInt16) currentDeviceEventID
{
	return currentDeviceEventID;
}



///////////////////////////////////////////////////////////////////////////
-(void) setCurrentDeviceEventID:(UInt16) newEventID
{
	currentDeviceEventID = newEventID;
}



///////////////////////////////////////////////////////////////////////////
-(void) addDevice:(Transducer *) newDevice
{
   if (newDevice != nil)
   {
      [deviceList addObject: newDevice];
   }
}

@end

