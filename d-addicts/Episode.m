//
//  Episode.m
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "Episode.h"

@interface Episode ()
@end

@implementation Episode

+ (NSString *)isoNameFromType:(NSString *)t
{
    NSString *isoName = nil;
    
    if ([t isEqualToString:@"jdrama"]) isoName = @"jp";
    else if ([t isEqualToString:@"kdrama"]) isoName = @"kr";
    else if ([t isEqualToString:@"hkdrama"]) isoName = @"hk";
    else if ([t isEqualToString:@"twdrama"]) isoName = @"tw";
    else if ([t isEqualToString:@"cdrama"]) isoName = @"cn";
    else if ([t isEqualToString:@"sgdrama"]) isoName = @"sg";
    else if ([t isEqualToString:@"j-tv"]) isoName = @"jp";
    else if ([t isEqualToString:@"k-tv"]) isoName = @"kr";
    else if ([t isEqualToString:@"hk-tv"]) isoName = @"hk";
    
    return isoName;
}

- (NSString *)iso
{
    return [Episode isoNameFromType:self.type];
}

- (NSDictionary *)descriptionItemList:(NSString *)description
{
    NSArray *descriptionItems = [description componentsSeparatedByString:@"<br/>"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (NSString *item in descriptionItems) {
        NSArray *keyValue = [item componentsSeparatedByString:@": "];
        [dictionary setObject:keyValue[1] forKey:keyValue[0]];
    }
    return dictionary;
}

- (id)initWithTitle:(NSString *)title link:(NSString *)link description:(NSString *)description date:(NSString *)date
{
    self = [super init];
    if (self) {
        _title = title;
        _link = link;
        _pubDate = date;
        NSDictionary *itemList = [self descriptionItemList:description];
        _infoHash = [itemList valueForKey:@"Info_hash"];
        _size = [itemList valueForKey:@"Size"];
        _addedBy = [itemList valueForKey:@"Added by"];
        _type = [itemList valueForKey:@"Type"];
        _sub = [itemList valueForKey:@"Sub"];
    }
    return self;
}

@end
