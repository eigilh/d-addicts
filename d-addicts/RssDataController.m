//
//  RssDataController.m
//  d-addicts
//
//  Created by Eigil Hansen on 21/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "RssDataController.h"

@interface RssDataController ()
{
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *description;
    NSMutableString *pubDate;
    NSString *element;
}
@end

@implementation RssDataController

- (RssDataController *)init
{
    self = [super init];
    if (self) {
        feeds = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)setRssUrl:(NSString *)newUrl
{
    _rssUrl = newUrl;
    
    UIApplication *myApp = [UIApplication sharedApplication];
    myApp.networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:newUrl];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];

    if (feeds.count > 0) {
        [feeds removeAllObjects];
    }
    [parser parse];
    myApp.networkActivityIndicatorVisible = NO;
}

- (NSArray *)rssItems
{
    return [NSArray arrayWithArray:feeds];
}

#pragma mark - XML Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:RSS_ITEM]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        description = [[NSMutableString alloc] init];
        pubDate = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:RSS_TITLE]) {
        [title appendString:string];
    } else if ([element isEqualToString:RSS_LINK]) {
        [link appendString:string];
    } else if ([element isEqualToString:RSS_DESCRIPTION]) {
        [description appendString:string];
    } else if ([element isEqualToString:RSS_PUBDATE]) {
        [pubDate appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:RSS_ITEM]) {
        
        [item setObject:title forKey:RSS_TITLE];
        [item setObject:[link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:RSS_LINK];
        [item setObject:description forKey:RSS_DESCRIPTION];
        [item setObject:pubDate forKey:RSS_PUBDATE];
        [feeds addObject:[item copy]];        
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    // End 
}


@end
