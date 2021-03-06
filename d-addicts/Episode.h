//
//  Episode.h
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Episode : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, strong) NSString *infoHash;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *addedBy;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *sub;
@property (nonatomic, strong) NSString *links;
@property (nonatomic, strong) NSString *itemDescription;

@property (readonly) NSString *isoCountryCode;

/**
 *  The designated initializer
 */
- (id)initWithTitle:(NSString *)title
               link:(NSString *)link
    itemDescription:(NSString *)itemDescription
               date:(NSDate *)date;

@end
