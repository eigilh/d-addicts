//
//  EpisodeDataController.m
//  d-addicts
//
//  Created by Eigil Hansen on 06/09/14.
//  Copyright (c) 2014 Eigil Hansen. All rights reserved.
//

#import "EpisodeDataController.h"
#import "Episode.h"

@interface EpisodeDataController ()
@property (nonatomic, strong) NSMutableArray *episodeList;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateParser;
@end

@implementation EpisodeDataController

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        self.episodeList = [[NSMutableArray alloc] init];
        self.delegate = delegate;
    }
    return self;
}

- (void)load
{
    // For offline and error testing
    //    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rss" withExtension:@"xml"];
    //    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"bad" withExtension:@"xml"];
    //    RssParser *parser = [[RssParser alloc] initWithURL:url];

    RssParser *parser = [[RssParser alloc] initWithURL:[NSURL URLWithString:@"http://www.d-addicts.com/rss.xml"]];
    if (parser != nil) {
        [parser setDelegate:self];
        [parser start];
    }

}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
    }
    return _dateFormatter;
}

// Parses the date format specific to the d-addicts feed
- (NSDateFormatter *)dateParser
{
    if (_dateParser == nil) {
        _dateParser = [[NSDateFormatter alloc] init];
        [_dateParser setDateFormat:@"EEEEE, dd MMMMM yyyy HH:mm:ss zzz"];
        NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
        [_dateParser setLocale:enLocale];
        [_dateParser setFormatterBehavior:NSDateFormatterBehaviorDefault];
    }
    return _dateParser;
}

#pragma mark - RssDelegate

- (void)didParseItem:(NSDictionary *)dict
{
    NSDate *date = [self.dateParser dateFromString:[dict valueForKey:RSS_PUBDATE]];
    Episode *episode = [[Episode alloc] initWithTitle:[dict valueForKey:RSS_TITLE]
                                                 link:[dict valueForKey:RSS_LINK]
                                      itemDescription:[dict valueForKey:RSS_DESCRIPTION]
                                                 date:date];
    if (episode) {
        [self.episodeList addObject:episode];
    }
}

- (void)didEndParse
{
    [self.delegate dataDidLoad];
}

- (void)didFailParseWithError:(NSError *)error
{
    if (error) {
        [self.delegate dataDidFailWithError:error.localizedDescription];
    }
}

- (NSUInteger)episodeCount
{
    return [self.episodeList count];
}

- (Episode *)episodeAtIndex:(NSUInteger)index
{
    return [self.episodeList objectAtIndex:index];
}

@end
