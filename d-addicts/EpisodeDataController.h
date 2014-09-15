//
//  EpisodeDataController.h
//  d-addicts
//
//  Created by Eigil Hansen on 06/09/14.
//  Copyright (c) 2014 Eigil Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RssParser.h"

@class Episode;

@protocol EpisodeDataDelegate;

/*! 
 *  @class EpisodeDataController
 *  Provide a list of the latest tv-episode posted to d-addicts.com.
 *
 *  Instantiate an EpisodeDataController to initiate loading the data
 *  from d-addicts.com.
 *
 *  Implement the EpisodeDataDelegate protocol to get notified when loading of data completes.
 */
@interface EpisodeDataController : NSObject <RssDelegate>

@property (weak) id <EpisodeDataDelegate> delegate;

- (void)connect;

/*!
 *  start loading data
 */
- (void)start;

/*!
 *  Return the number of items in the episode list.
 *  @return The number of episodes.
 */
- (NSUInteger)episodeCount;

/*!
 *  Return the Episode located at index in the episode list.
 *
 *  @param index An index within the bounds of the episode list.
 *  @return The episode located at index.
 */
- (Episode *)episodeAtIndex:(NSUInteger)index;

@end

@protocol EpisodeDataDelegate <NSObject>

/*!
 *  Tells the delegate that the data finished loading.
 *
 *  The delegate should do whatever is appropriate, like calling reloadData on a Table View.
 */
- (void)dataDidLoad;

/*!
 *  Tells the delegate that loading of data failed.
 *
 *  @param error The localized string describing the error.
 */
- (void)dataDidFailWithError:(NSString *)error;

@end
