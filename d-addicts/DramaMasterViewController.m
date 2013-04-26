//
//  DramaMasterViewController.m
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "DramaMasterViewController.h"

#import "DramaDetailViewController.h"
#import "EpisodeDataController.h"
#import "Episode.h"

#import "FilterViewController.h"

@interface DramaMasterViewController ()
@property (nonatomic, strong) EpisodeDataController *dataController;
@end

@implementation DramaMasterViewController

- (IBAction)refresh:(UIRefreshControl *)sender {
    [self refreshEpisodesForce:YES];
}

- (EpisodeDataController *)dataController
{
    if (!_dataController) {
        _dataController = [[EpisodeDataController alloc] init];
    }
    return _dataController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    [self refreshEpisodesForce:NO];
}

- (void)refreshEpisodesForce:(BOOL)force
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t q = dispatch_queue_create("rss downloader", NULL);
    dispatch_async(q, ^{
        [self.dataController refreshEpisodes:force];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });    
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return [self.dataController countOfList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpisodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Episode *episodeAtIndex = [self.dataController objectInListAtIndex:indexPath.row];
    [[cell textLabel] setText:episodeAtIndex.title];
    [[cell detailTextLabel] setText:episodeAtIndex.type];
    [[cell imageView] setImage:[UIImage imageNamed:episodeAtIndex.iso]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showEpisodeDetail"]) {
        DramaDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.episode = [self.dataController objectInListAtIndex:[self.tableView indexPathForSelectedRow].row];
    } else if ([[segue identifier] isEqualToString:@"showFilter"]) {
        // FilterViewController *filterVC = [segue destinationViewController];
        // Pass filter to view
    }
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"ReturnInput"]) {
        
        // FilterViewController *filterVC = [segue sourceViewController];
        // Implement filter

        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)cancel:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"CancelInput"]) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}
@end
