//
//  DramaDetailViewController.h
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;

@interface DramaDetailViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) NSArray *torrents;
@property (nonatomic) NSInteger currentRow;
@property (strong, nonatomic) Episode *episode;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)upDownPressed:(UISegmentedControl *)sender;
@end
