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
#import "DramaCell.h"

@interface DramaViewController ()
@property (nonatomic, strong) EpisodeDataController *episodeDataController;
@end

@implementation DramaViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataControllerDidFinish:) name:kEndParseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataControllerDidFinish:) name:kFailParseNotification object:nil];
    self.episodeDataController = [[EpisodeDataController alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dataControllerDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqualToString:kEndParseNotification]) {
        [self.tableView reloadData];
    }
    if ([notification.name isEqualToString:kFailParseNotification]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error while fetching feed"
                                                        message:notification.userInfo[@"error"]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.episodeDataController episodeCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DramaCell *cell = (DramaCell *)[self.tableView dequeueReusableCellWithIdentifier:@"EpisodeCell"];
    Episode *episode = [self.episodeDataController episodeAtIndex:indexPath.row];

    // Configure cell
    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    cell.titleLabel.text = episode.title;
    cell.flagImage.image = [UIImage imageNamed:episode.isoCountryCode];

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
