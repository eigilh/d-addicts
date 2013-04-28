//
//  EpisodeDataController.m
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "EpisodeDataController.h"
#import "Episode.h"
#import "RssDataController.h"

@interface EpisodeDataController ()
@property (nonatomic, strong) RssDataController *rssDC;
@end

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

- (RssDataController *)rssDC
{
    if (!_rssDC) _rssDC = [[RssDataController alloc] init];
    return _rssDC;
}

- (void)refreshEpisodes
{
    [self.rssDC setRssUrl:@"http://www.d-addicts.com/rss.xml"];
    NSArray *items = [self.rssDC rssItems];
    [self.episodes removeAllObjects];
    for (NSDictionary *dict in items) {
        [self.episodes addObject:[[Episode alloc] initWithTitle:[dict valueForKey:RSS_TITLE]
                                                           link:[dict valueForKey:RSS_LINK]
                                                    description:[dict valueForKey:RSS_DESCRIPTION]
                                                           date:[dict valueForKey:RSS_PUBDATE]]];
    }
}

@end
