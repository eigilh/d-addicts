//
//  RssDataController.m
//  d-addicts
//
//  Created by Eigil Hansen on 21/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "RssDataController.h"

@interface RssDataController ()
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSMutableDictionary *item;
@property (nonatomic, strong) NSMutableString *title;
@property (nonatomic, strong) NSMutableString *link;
@property (nonatomic, strong) NSMutableString *description;
@property (nonatomic, strong) NSMutableString *pubDate;
@property (nonatomic, strong) NSString *element;

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

- (BOOL)parseRSS
{
    BOOL succes = NO;
    UIApplication *myApp = [UIApplication sharedApplication];
    myApp.networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:self.rssUrl];
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    if (self.parser != nil) {
        [self.parser setDelegate:self];
        [self.parser setShouldResolveExternalEntities:NO];
        succes = [self.parser parse];
        if (!succes) {
            NSLog(@"Fejl i parseRSS");
        }
    }
    
    myApp.networkActivityIndicatorVisible = NO;
    return succes;
}

#pragma mark - XML Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    self.element = elementName;
    
    if ([self.element isEqualToString:RSS_ITEM]) {
        
        self.item    = [[NSMutableDictionary alloc] init];
        self.title   = [[NSMutableString alloc] init];
        self.link    = [[NSMutableString alloc] init];
        self.description = [[NSMutableString alloc] init];
        self.pubDate = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([self.element isEqualToString:RSS_TITLE]) {
        [self.title appendString:string];
    } else if ([self.element isEqualToString:RSS_LINK]) {
        [self.link appendString:string];
    } else if ([self.element isEqualToString:RSS_DESCRIPTION]) {
        [self.description appendString:string];
    } else if ([self.element isEqualToString:RSS_PUBDATE]) {
        [self.pubDate appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:RSS_ITEM]) {
        
        [self.item setObject:self.title forKey:RSS_TITLE];
        [self.item setObject:[self.link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:RSS_LINK];
        [self.item setObject:self.description forKey:RSS_DESCRIPTION];
        [self.item setObject:self.pubDate forKey:RSS_PUBDATE];
        [self.delegate didFindItem:self.item];
        
    }
}
/*
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    // End
}
*/
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Error: %@", [parseError localizedDescription] );
}

@end
