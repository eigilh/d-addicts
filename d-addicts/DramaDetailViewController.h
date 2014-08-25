//
//  DramaDetailViewController.h
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;

@interface DramaDetailViewController : UIViewController

@property (strong, nonatomic) NSArray *torrents;
@property (nonatomic) NSInteger currentRow;

@end
