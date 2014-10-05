//
//  DramaViewController.h
//  d-addicts
//
//  Created by Eigil Hansen on 20/05/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EpisodeDataController.h"

@interface DramaViewController : UITableViewController <UITableViewDataSource, UIAlertViewDelegate, EpisodeDataDelegate>

@end
