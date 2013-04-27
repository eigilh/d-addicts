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

#define FIVE_MINUTES 300.0
#define FIFTEEN_MINUTES 900.0

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

- (BOOL)useCache
{
    BOOL valid = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *cacheDate = [defaults objectForKey:@"cacheDate"];
    if (cacheDate) {
        NSTimeInterval cacheAge = [[NSDate date] timeIntervalSinceDate:cacheDate];
        NSLog(@"cacheAge : %.3f seconds", cacheAge);
        if (cacheAge < FIFTEEN_MINUTES) {
            valid = YES;
        }
    }
    return valid;
}

- (void)addRssItemsToEpisodes:(NSArray *)items
{
    [self.episodes removeAllObjects];
    for (NSDictionary *dict in items) {
        [self.episodes addObject:[[Episode alloc] initWithTitle:[dict valueForKey:RSS_TITLE]
                                                           link:[dict valueForKey:RSS_LINK]
                                                    description:[dict valueForKey:RSS_DESCRIPTION]
                                                           date:[dict valueForKey:RSS_PUBDATE]]];
    }
}

- (void)refreshEpisodes:(BOOL)force
{
    NSDate *start = [NSDate date];
    if ([self useCache] && !force) {
        [self readRssFromCache];
    } else {
        [self.rssDC setRssUrl:@"http://www.d-addicts.com/rss.xml"];
        NSArray *items = [self.rssDC rssItems];
        [self addRssItemsToEpisodes:items];
        [self writeRssToCache:items];
    }
    NSDate *stop = [NSDate date];
    NSTimeInterval refreshTime = [stop timeIntervalSinceDate:start];
    NSLog(@"Refresh RSS time : %.3f seconds", refreshTime);
}

- (void)writeRssToCache:(NSArray *)items
{
    NSLog(@"Write Cache");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:items forKey:@"feeds"];
    [defaults setObject:[NSDate date] forKey:@"cacheDate"];
    [defaults synchronize];
}

- (void)readRssFromCache
{
    NSLog(@"Read Cache");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:@"feeds"];
    [self addRssItemsToEpisodes:array];
}


@end
