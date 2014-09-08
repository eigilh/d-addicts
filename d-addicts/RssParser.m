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

@property (nonatomic, strong) NSURL *url;
@property NSURLSession *defaultSession;

@end

@implementation RssParser

- (RssParser *)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)loadRss
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    [[self.defaultSession dataTaskWithURL:self.url
                        completionHandler:^(NSData *data, NSURLResponse *response,
                                            NSError *error) {
//                            NSLog(@"Got response %@ with error %@.\n", response, error);
//                            NSLog(@"DATA:\n%@\nEND DATA\n",
//                                  [[NSString alloc] initWithData: data
//                                                        encoding: NSUTF8StringEncoding]);
                            [self processData:data withError:error];
                        }] resume];
}

- (void)processData:(NSData *)data withError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (error)
    {
        if ([self.delegate respondsToSelector:@selector(didFailParseWithError:)]) {
            [self.delegate didFailParseWithError:error];
        }
    }
    else
    {
        self.parser = [[NSXMLParser alloc] initWithData:data];
        if (self.parser != nil) {
            [self.parser setDelegate:self];
            [self.parser setShouldResolveExternalEntities:NO];
            [self.parser parse];
        }
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
    if ([self.delegate respondsToSelector:@selector(didEndParse)]) {
        [self.delegate didEndParse];
    }

}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"NSXMLParser error at line: %ld, colomn: %ld", (long)parser.lineNumber , (long)parser.columnNumber);

    if ([self.delegate respondsToSelector:@selector(didFailParseWithError:)]) {
        [self.delegate didFailParseWithError:parseError];
    }
}

@end
