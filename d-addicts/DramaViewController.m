//
//  DramaViewController.m
//  d-addicts
//
//  Created by Eigil Hansen on 20/05/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "DramaViewController.h"
#import "DetailTableViewController.h"
#import "EpisodeDataController.h"
#import "Episode.h"

@interface DramaViewController ()
@property (nonatomic, strong) EpisodeDataController *episodeDataController;
@end

@implementation DramaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.episodeDataController = [[EpisodeDataController alloc] init];
    self.episodeDataController.delegate = self;
    [self.episodeDataController connect];
    [self.episodeDataController start];

    // Required for self-sizing cells in iOS 8
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Episode Data Delegate

- (void)dataDidLoad
{
    [self.tableView reloadData];
}

- (void)dataDidFailWithError:(NSString *)error
{
    [self.tableView reloadData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error while fetching feed"
                                                    message:error
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.episodeDataController episodeCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EpisodeCell"];
    Episode *episode = [self.episodeDataController episodeAtIndex:indexPath.row];

    // Configure cell
//    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    cell.textLabel.text = episode.title;
    cell.imageView.image = [UIImage imageNamed:episode.isoCountryCode];

    return cell;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowEpisodeDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        DetailTableViewController *detailViewController = segue.destinationViewController;
        detailViewController.episode = [self.episodeDataController episodeAtIndex:indexPath.row];
    }
}

@end
