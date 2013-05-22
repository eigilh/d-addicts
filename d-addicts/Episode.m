//
//  Episode.m
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "Episode.h"

@interface Episode ()
@property (strong, nonatomic) NSDateFormatter *dateParser;
@end

@implementation Episode

+ (NSString *)isoFromType:(NSString *)t
{
    NSString *isoCode = nil;
    
    if ([t isEqualToString:@"jdrama"]) isoCode = @"jp";
    else if ([t isEqualToString:@"kdrama"]) isoCode = @"kr";
    else if ([t isEqualToString:@"hkdrama"]) isoCode = @"hk";
    else if ([t isEqualToString:@"twdrama"]) isoCode = @"tw";
    else if ([t isEqualToString:@"cdrama"]) isoCode = @"cn";
    else if ([t isEqualToString:@"sgdrama"]) isoCode = @"sg";
    else if ([t isEqualToString:@"j-tv"]) isoCode = @"jp";
    else if ([t isEqualToString:@"k-tv"]) isoCode = @"kr";
    else if ([t isEqualToString:@"hk-tv"]) isoCode = @"hk";
    
    return isoCode;
}

- (NSString *)iso
{
    return [Episode isoFromType:self.type];
}

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

- (NSDictionary *)descriptionItemList:(NSString *)description
{
    NSArray *descriptionItems = [description componentsSeparatedByString:@"<br/>"];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *item in descriptionItems) {
        NSArray *keyValue = [item componentsSeparatedByString:@": "];
        if (keyValue.count != 2) {
            NSLog(@"Bad item data: %@", keyValue);
            continue;
        }
        [dictionary setObject:keyValue[1] forKey:keyValue[0]];
    }
    return dictionary;
}

- (id)initWithTitle:(NSString *)title
               link:(NSString *)link
        description:(NSString *)description
               date:(NSString *)date
{
    self = [super init];
    if (self) {
        self.title = title;
        self.link = link;
        self.pubDate = [self.dateParser dateFromString:date];
        NSDictionary *itemList = [self descriptionItemList:description];
        self.infoHash = [itemList valueForKey:@"Info_hash"];
        self.size = [itemList valueForKey:@"Size"];
        self.addedBy = [itemList valueForKey:@"Added by"];
        self.type = [itemList valueForKey:@"Type"];
        self.sub = [itemList valueForKey:@"Sub"];
    }
    return self;
}

@end
