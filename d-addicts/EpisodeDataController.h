//
//  EpisodeDataController.h
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RssDataController.h"

@class Episode;

@interface EpisodeDataController : NSObject <RssDelegate>

@property (nonatomic, strong) NSMutableArray *episodes;

- (void)refreshEpisodes;
- (NSUInteger)countOfList;
- (Episode *)objectInListAtIndex:(NSUInteger)index;

@end
