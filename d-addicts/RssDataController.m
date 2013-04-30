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
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *description;
    NSMutableString *pubDate;
    NSString *element;
}
@property (nonatomic, strong) NSString *rssUrl;

@end

@implementation RssDataController

- (RssDataController *)initWithURL:(NSString *)url
{
    self = [super init];
    if (self) {
        self.rssUrl = url;
    }
    return self;
}

- (void)parseRSS
{
    UIApplication *myApp = [UIApplication sharedApplication];
    myApp.networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:self.rssUrl];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    myApp.networkActivityIndicatorVisible = NO;
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
        [self.delegate didFindItem:item];
        
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    // End 
}


@end
