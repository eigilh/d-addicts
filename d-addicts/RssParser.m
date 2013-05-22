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
@property (nonatomic, strong) NSMutableString *description;
@property (nonatomic, strong) NSMutableString *pubDate;
@property (nonatomic, strong) NSString *element;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *buffer;
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

- (NSMutableData *)buffer
{
    if (!_buffer) {
        _buffer = [NSMutableData data];
    }
    return _buffer;
}

- (void)start
{
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0];
    // Create url connection and fire request
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received
    // Furthermore, this method is called each time there is a redirect so set length to 0
    [self.buffer setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the buffer
    [self.buffer appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // We don't need the connection any more
    self.connection = nil;
    
    // You can parse the stuff in your buffer now
    self.parser = [[NSXMLParser alloc] initWithData:self.buffer];
    if (self.parser != nil) {
        [self.parser setDelegate:self];
        [self.parser setShouldResolveExternalEntities:NO];
        [self.parser parse];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    // Check the error var
    [self.delegate didFailParseWithError:error];
}

#pragma mark - XML Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    self.element = elementName;
    
    if ([self.element isEqualToString:RSS_ITEM]) {
        self.item       = [[NSMutableDictionary alloc] init];
        self.title      = [[NSMutableString alloc] init];
        self.link       = [[NSMutableString alloc] init];
        self.description = [[NSMutableString alloc] init];
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
        [self.description appendString:string];
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
        [self.item setObject:[self.description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                      forKey:RSS_DESCRIPTION];
        [self.item setObject:[self.pubDate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                      forKey:RSS_PUBDATE];
        [self.delegate didParseItem:self.item];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.delegate didEndParse];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self.delegate didFailParseWithError:parseError];
}

@end
