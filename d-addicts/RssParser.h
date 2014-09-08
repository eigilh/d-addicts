//
//  RssDataController.h
//  d-addicts
//
//  Created by Eigil Hansen on 21/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RSS_ITEM    @"item"
#define RSS_TITLE   @"title"
#define RSS_LINK    @"link"
#define RSS_DESCRIPTION @"description"
#define RSS_PUBDATE @"pubDate"

@protocol RssDelegate;

@interface RssParser : NSObject <NSXMLParserDelegate>

- (RssParser *)initWithURL:(NSURL *)url;
- (void)loadRss;

@property (weak) id <RssDelegate> delegate;

@end

@protocol RssDelegate <NSObject>
- (void)didParseItem:(NSDictionary *)dictionary;
- (void)didEndParse;
- (void)didFailParseWithError:(NSError *)error;
@end