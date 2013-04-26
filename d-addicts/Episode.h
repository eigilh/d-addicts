//
//  Episode.h
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Episode : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, copy) NSString *infoHash;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *addedBy;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *sub;

@property (readonly) NSString *iso;

- (id)initWithTitle:(NSString *)title link:(NSString *)link description:(NSString *)description date:(NSString *)date;

@end
