//
//  DramaViewController.h
//  d-addicts
//
//  Created by Eigil Hansen on 20/05/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RssParser.h"

@interface DramaViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, RssDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusBarItem;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
- (IBAction)goToSearch:(id)sender;
- (IBAction)refreshPressed:(UIBarButtonItem *)sender;

@end
