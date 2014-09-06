//
//  DetailTableViewController.h
//  d-addicts
//
//  Created by Eigil Hansen on 06/09/14.
//  Copyright (c) 2014 Eigil Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;

@interface DetailTableViewController : UITableViewController

@property (nonatomic, strong) Episode *episode;

@end
