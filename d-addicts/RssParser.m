//
//  RssDataController.m
//  d-addicts
//
//  Created by Eigil Hansen on 21/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "RssParser.h"

@interface RssParser ()
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSMutableDictionary *item;
@property (nonatomic, strong) NSMutableString *title;
@property (nonatomic, strong) NSMutableString *link;
@property (nonatomic, strong) NSMutableString *itemDescription;
@property (nonatomic, strong) NSMutableString *pubDate;
@property (nonatomic, strong) NSString *element;

@end

@implementation RssParser


- (void)parseData:(NSData *)data
{
    self.parser = [[NSXMLParser alloc] initWithData:data];
    if (self.parser != nil) {
        [self.parser setDelegate:self];
        [self.parser parse];
    }
}

#pragma mark - XML Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    self.element = elementName;
    
    if ([self.element isEqualToString:RSS_ITEM]) {
        self.item       = [[NSMutableDictionary alloc] init];
        self.title      = [[NSMutableString alloc] init];
        self.link       = [[NSMutableString alloc] init];
        self.itemDescription = [[NSMutableString alloc] init];
        self.pubDate    = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([self.element isEqualToString:RSS_TITLE]) {
        [self.title appendString:string];
    } else if ([self.element isEqualToString:RSS_LINK]) {
        [self.link appendString:string];
    } else if ([self.element isEqualToString:RSS_DESCRIPTION]) {
        [self.itemDescription appendString:string];
    } else if ([self.element isEqualToString:RSS_PUBDATE]) {
        [self.pubDate appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:RSS_ITEM]) {
        [self.item setObject:[self.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                      forKey:RSS_TITLE];
        [self.item setObject:[self.link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                      forKey:RSS_LINK];
        [self.item setObject:[self.itemDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                      forKey:RSS_DESCRIPTION];
        [self.item setObject:[self.pubDate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                      forKey:RSS_PUBDATE];
        if ([self.delegate respondsToSelector:@selector(didParseItem:)]) {
            [self.delegate didParseItem:self.item];
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.delegate didEndParse];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"NSXMLParser error at line: %ld, colomn: %ld", (long)parser.lineNumber , (long)parser.columnNumber);

    [self.delegate didFailParseWithError:parseError];
}

@end
