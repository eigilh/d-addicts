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

@interface DramaMasterViewController ()
@property (nonatomic, strong) EpisodeDataController *dataController;
@property (strong,nonatomic) NSArray *filteredEpisodes;
@end

@implementation DramaMasterViewController

#define TEXT_SIZE 14.0f
#define DETAIL_TEXT_SIZE 12.0f
#define ROW_HEIGHT (TEXT_SIZE+DETAIL_TEXT_SIZE)*2

- (IBAction)refresh:(UIRefreshControl *)sender {
    [self refreshEpisodes];
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
    self.tableView.rowHeight = ROW_HEIGHT;
    [self refreshEpisodes];
}

- (void)hideSearchBar
{
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.episodeSearchBar.bounds.size.height;
    [UIView animateWithDuration:0.5f animations:^{
        self.tableView.bounds = newBounds;
    }];
}

- (void)refreshEpisodes
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t q = dispatch_queue_create("rss downloader", NULL);
    dispatch_async(q, ^{
        [self.dataController refreshEpisodes];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            [self hideSearchBar];
        });
    });    
}

#pragma mark - Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// Update the filtered array based on the search text and scope.
	// Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    self.filteredEpisodes = [[self.dataController episodes] filteredArrayUsingPredicate:predicate];
}

#pragma mark - UISearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Hide the Search Bar behind the Navigation Bar
    [self hideSearchBar];
}

#pragma mark - UISearchDisplay Delegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = ROW_HEIGHT;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Table View delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredEpisodes count];
    } else {
        return [self.dataController countOfList];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpisodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Get episode from Table View or Search Results
    Episode *episode;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        episode = [self.filteredEpisodes objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        episode = [self.dataController objectInListAtIndex:indexPath.row];
    }

    // Configure cell
    cell.textLabel.font = [UIFont boldSystemFontOfSize:TEXT_SIZE];
    cell.textLabel.text = episode.title;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:DETAIL_TEXT_SIZE];
    cell.detailTextLabel.text = episode.type;
    cell.imageView.image = [UIImage imageNamed:episode.iso];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to episode detail
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"showEpisodeDetail" sender:tableView];        
    }
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showEpisodeDetail"]) {
        DramaDetailViewController *detailViewController = [segue destinationViewController];
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            detailViewController.torrents = self.filteredEpisodes;
            detailViewController.currentRow = indexPath.row;
        } else {
            detailViewController.torrents = self.dataController.episodes;
            detailViewController.currentRow = [self.tableView indexPathForSelectedRow].row;
        }

    }
}

-(IBAction)goToSearch:(id)sender {
    // If you're worried that your users might not catch on to the fact that a search bar is available if they scroll to reveal it, a search icon will help them
    // If you don't hide your search bar in your app, don’t include this, as it would be redundant
    [self.episodeSearchBar becomeFirstResponder];
}

@end
