//
//  DramaMasterViewController.h
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RssParser.h"

@interface DramaMasterViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, RssDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
-(IBAction)goToSearch:(id)sender;
- (IBAction)refreshPressed:(UIBarButtonItem *)sender;
@end
