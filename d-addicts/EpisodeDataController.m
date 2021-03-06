//
//  EpisodeDataController.m
//  d-addicts
//
//  Created by Eigil Hansen on 06/09/14.
//  Copyright (c) 2014 Eigil Hansen. All rights reserved.
//

#import "EpisodeDataController.h"
#import "Episode.h"
#import "XMLDictionary.h"

@interface EpisodeDataController ()
@property (nonatomic, strong) NSMutableArray *episodeList;
@property (nonatomic, strong) NSDateFormatter *dateParser;
@property NSURLSession *defaultSession;
@end

@implementation EpisodeDataController

- (NSMutableArray *)episodeList
{
    if (!_episodeList) {
        _episodeList = [[NSMutableArray alloc] init];
    }
    return _episodeList;
}

- (void)connect
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                        delegate:nil
                                                   delegateQueue:[NSOperationQueue mainQueue]];
}

// For offline and error testing
//    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rss" withExtension:@"xml"];
//    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"bad" withExtension:@"xml"];

-(void)start
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[self.defaultSession dataTaskWithURL:[NSURL URLWithString:@"http://www.d-addicts.com/rss.xml"]
                        completionHandler:^(NSData *data, NSURLResponse *response,
                                            NSError *error) {
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                            if (error) {
                                NSLog(@"Got response %@ with error %@.\n", response, error);
                                NSLog(@"DATA:\n%@\nEND DATA\n", [[NSString alloc] initWithData: data
                                                                                      encoding: NSUTF8StringEncoding]);
                                [self.delegate dataDidFailWithError:error.localizedDescription];
                            } else {
                                [self.episodeList removeAllObjects];
                                NSDictionary *episodeDictionary = [NSDictionary dictionaryWithXMLData:data];
                                NSArray *items = [episodeDictionary valueForKeyPath:@"channel.item"];
                                for (NSDictionary *item in items) {
                                    [self addItem:item];
                                }
                                [self.delegate dataDidLoad];
                            }
                        }] resume];
}

- (NSUInteger)episodeCount
{
    return [self.episodeList count];
}

- (Episode *)episodeAtIndex:(NSUInteger)index
{
    if (index < self.episodeCount)
    {
        return [self.episodeList objectAtIndex:index];
    }
    else
    {
        return nil;
    }
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

- (void)addItem:(NSDictionary *)dict
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

@end
