//
//  EpisodeDataController.h
//  d-addicts
//
//  Created by Eigil Hansen on 06/09/14.
//  Copyright (c) 2014 Eigil Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RssParser.h"

#define kEndParseNotification @"kEndParseNotification"
#define kFailParseNotification @"kFailParseNotification"

@class Episode;

@interface EpisodeDataController : NSObject <RssDelegate>

- (NSUInteger)episodeCount;

- (Episode *)episodeAtIndex:(NSUInteger)index;

@end
