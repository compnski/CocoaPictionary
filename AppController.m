//
//  AppController.m
//  CocoaPictionary
//
//  Created by Jason on 10/17/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//

#import "AppController.h"


@implementation AppController

-(id)awakeFromNib
{
	NSLog(@"initializing...");  

	pictionary = [[PictionaryModel alloc] init];
	current_state = STATE_STOP;
	[timerLabel setStringValue:@"00"];
	[statusMessage setStringValue:[self generate_status_message]];
	[self update_ui_from_state];
	return self;
}


-(void)update_ui_from_state
{
	switch(current_state) {
		case STATE_STOP:
			[startButton setHidden:false];
			[gotIt setHidden:true];
			[buttonView setHidden:true];
			[answerView setHidden:true];
			[timeUp setHidden:true];
			break;
		case STATE_DRAWING:
			[gotIt setHidden:false];
			[startButton setHidden:true];
			[buttonView setHidden:true];
			[answerView setHidden:true];
			[timeUp setHidden:true];
			break;
		case STATE_GOT_ANSWER:
			[gotIt setHidden:true];
			[startButton setHidden:true];
			[buttonView setHidden:false];
			[answerView setHidden:false];
			[timeUp setHidden:true];
			break;
		case STATE_TIME_UP:
			[gotIt setHidden:true];
			[startButton setHidden:true];
			[buttonView setHidden:true];
			[answerView setHidden:false];
			[timeUp setHidden:false];
			break;
	}
	[scoreLabel setStringValue:[self generate_score_message]];
}

- (NSString *)generate_score_message
{
	NSMutableString *ret = [[NSMutableString alloc] initWithString:@""];
	for(int i=0; i < [[pictionary get_players] count]; i++) {
		NSLog([NSString stringWithFormat:@"score %d  %@", i, [[pictionary get_players] objectAtIndex:i]] );
		[ret appendFormat:@"%@: %d\t\t", [[pictionary get_players] objectAtIndex:i],[pictionary get_scores][i]];
		NSLog(ret);
	}
	return ret;
}

- (NSString *)generate_status_message
{
	return [NSString stringWithFormat:@"%@ drawing %@", [pictionary get_current_player], [pictionary get_current_category]];
}

- (void)j_clicked:(id)sender
{
	if(![pictionary next_round:@"Jason"]) 
		return;
	current_state = STATE_STOP;
	[self update_ui_from_state];
	[self save_image];
}

- (void)a_clicked:(id)sender
{
	if(![pictionary next_round:@"Alex"])
		return;
	current_state = STATE_STOP;
	[self update_ui_from_state];
	[self save_image];
}

- (void)m_clicked:(id)sender
{
	if(![pictionary next_round:@"Matt"])
		return;
	current_state = STATE_STOP;
	[self update_ui_from_state];
	[self save_image];
}

- (void)times_up_clicked:(id)sender
{
	[self save_image];
	[pictionary next_round:nil];
	current_state = STATE_STOP;
	NSLog(@"times up");
	[self update_ui_from_state];
}

- (void)got_it_clicked:(id)sender
{
	current_state = STATE_GOT_ANSWER;
	[self update_ui_from_state];
	[self stop_timer];
}

-(void)start_clicked:(id)sender
{
	current_state = STATE_DRAWING;
	[self update_ui_from_state];
	[statusMessage setStringValue:[self generate_status_message]];
	[self reset_timer];
	[drawArea clear];
}

-(void)stop_timer{
	[timer invalidate];
}

-(void)update_timer
{
	time_left--;
	if(time_left <= 0) {
		time_left = 0;
		[timer invalidate];
		current_state = STATE_TIME_UP;
		[self update_ui_from_state];
	}
	[timerLabel setStringValue:[NSString stringWithFormat:@"%d", time_left]];
	NSLog(@"timer");
}

-(void)reset_timer
{
	time_left = GAME_LENGTH;
	timer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update_timer) userInfo:nil repeats:YES] retain];
}

-(void)save_image
{
	NSData *data = [drawArea dataWithPDFInsideRect:[drawArea bounds]];
	NSBitmapImageRep *imageRep = [NSBitmapImageRep
								  imageRepWithData:[[[NSImage alloc] initWithData:data] TIFFRepresentation]];
	NSNumber *ditherTransparency = [NSNumber numberWithBool:YES];
	NSDictionary *propertyDict = [NSDictionary
								  dictionaryWithObject:ditherTransparency forKey:NSImageInterlaced];
	data = [imageRep representationUsingType:NSPNGFileType
								  properties:propertyDict];

	[data writeToFile:[NSString stringWithFormat:@"/Users/jason/Documents/pictionary/%@-%@.png",[answerField stringValue],[pictionary get_current_player]] atomically:YES];
	[drawArea clear];
}

@end
