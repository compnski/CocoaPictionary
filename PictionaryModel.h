//
//  PictionaryModel.h
//  CocoaPictionary
//
//  Created by Jason on 10/17/09.
//  Copyright 2009 TokBox Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PictionaryModel : NSObject {
	NSArray *players;
	NSArray *categories;
	int current_player_idx;
	int current_category_idx;
	//NSMutableDictionary *scores;
	int *scores;
}


-(NSString *)get_current_player;
-(NSString *)get_current_category;
-(BOOL)next_round:(NSString *)winner;
-(int *)get_scores;
-(NSArray *)get_players;


@end
