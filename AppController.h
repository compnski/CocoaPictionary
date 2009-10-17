//
//  AppController.h
//  CocoaPictionary
//
//  Created by Jason on 10/17/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PictionaryModel.h"
#import "MyViewController.h"
#import "WTView.h"

#define GAME_LENGTH 5
typedef enum appState
	{
		STATE_STOP, STATE_DRAWING, STATE_GOT_ANSWER, STATE_TIME_UP
	} app_state;


@interface AppController : NSObject {
	IBOutlet WTView *drawArea;
	IBOutlet NSTextField *timerLabel;
	IBOutlet NSTextField *statusMessage;
	IBOutlet NSTextField *answerField;
	IBOutlet NSTextField *scoreLabel;
	IBOutlet NSView *buttonView;
	IBOutlet NSView *answerView;
	IBOutlet NSButton *timeUp;
	IBOutlet NSButton *gotIt;
	IBOutlet NSButton *startButton;
	app_state current_state;
	PictionaryModel *pictionary;
	NSTimer *timer;
	int time_left;
	
}

- (IBAction)got_it_clicked:(id)sender;
- (IBAction)j_clicked:(id)sender;
- (IBAction)a_clicked:(id)sender;
- (IBAction)m_clicked:(id)sender;
- (IBAction)times_up_clicked:(id)sender;
- (IBAction)start_clicked:(id)sender;


-(void)update_ui_from_state;
-(void)update_timer;
-(void)reset_timer;
-(void)stop_timer;
-(void)save_image;
-(NSString *)generate_status_message;
-(NSString *)generate_score_message;

@end
