//
//  DramaViewController.h
//  d-addicts
//
//  Created by Eigil Hansen on 20/05/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RssParser.h"

@interface DramaViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, RssDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusBarItem;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
- (IBAction)goToSearch:(id)sender;
- (IBAction)refreshPressed:(UIBarButtonItem *)sender;

@end
