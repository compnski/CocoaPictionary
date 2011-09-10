//
//  PictionaryModel.m
//  CocoaPictionary
//
//  Created by Jason on 10/17/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//

#import "PictionaryModel.h"


@implementation PictionaryModel

-(id)init
{
	self = [super init];
	categories = [[NSArray arrayWithObjects: @"AP - All Play", @"D - Difficult", @"A - Action", @"P - Person/Place/Animal", @"O - Object", @"? - Pick",nil] retain];
	players = [[NSArray arrayWithObjects: @"Jason", @"Alex", @"Matt",@"Alli",@"Ganz",@"Harry"] retain];
//	NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], nil];
//	scores= [[NSMutableDictionary dictionaryWithObjects:objects forKeys:players] retain];
	scores = calloc(sizeof(int), [players count]);
	current_player_idx = arc4random() % [players count];
	current_category_idx = arc4random() % [categories count];

	return self;
}

-(NSString *)get_current_player
{
	return [players objectAtIndex:current_player_idx];
}

-(NSString *)get_current_category
{
	return [categories objectAtIndex:current_category_idx];
}

-(BOOL)next_round:(NSString *)winner
{
	
	if(winner != nil) {
		if([players indexOfObject:winner] == current_player_idx) {
			NSLog(@"Player can't win!");
			return false;
		}
		scores[[players indexOfObject:winner]] += 2;
		scores[current_player_idx] += 1;
	} else {
		scores[current_player_idx]--;
		}
	current_player_idx = (current_player_idx + 1) % [players count];
	current_category_idx = arc4random() % [categories count];
	return true;
}

-(int*)get_scores
{
	return scores;
}

-(NSArray*)get_players
{
	return players;
}


@end
