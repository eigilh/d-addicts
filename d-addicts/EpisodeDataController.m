//
//  EpisodeDataController.m
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "EpisodeDataController.h"
#import "Episode.h"

@implementation EpisodeDataController

- (NSMutableArray *)episodes
{
    if (!_episodes) _episodes = [[NSMutableArray alloc] init];
    return _episodes;
}

- (NSUInteger)countOfList
{
    return [self.episodes count];
}

- (Episode *)objectInListAtIndex:(NSUInteger)theIndex
{
    return [self.episodes objectAtIndex:theIndex];
}

- (void)refreshEpisodes
{
    RssDataController *rssDC = [[RssDataController alloc] initWithURL:@"http://www.d-addicts.com/rss.xml"];
    if (rssDC != nil) {
        [self.episodes removeAllObjects];
        [rssDC setDelegate:self];
        [rssDC parseRSS];
    }
}

#pragma mark - RssDelegate

- (void)didFindItem:(NSDictionary *)dict
{
    [self.episodes addObject:[[Episode alloc] initWithTitle:[dict valueForKey:RSS_TITLE]
                                                       link:[dict valueForKey:RSS_LINK]
                                                description:[dict valueForKey:RSS_DESCRIPTION]
                                                       date:[dict valueForKey:RSS_PUBDATE]]];
}

@end
