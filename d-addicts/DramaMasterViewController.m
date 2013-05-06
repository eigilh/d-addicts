//
//  DramaMasterViewController.m
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "DramaMasterViewController.h"
#import "DramaDetailViewController.h"
#import "Episode.h"

@interface DramaMasterViewController ()
@property (nonatomic, strong) NSMutableArray *episodes;
@property (nonatomic, strong) NSArray *filteredEpisodes;
@property (nonatomic) NSUInteger countBeforeRefresh;
@end

@implementation DramaMasterViewController

#define TEXT_SIZE 14.0f
#define DETAIL_TEXT_SIZE 12.0f
#define ROW_HEIGHT (TEXT_SIZE+DETAIL_TEXT_SIZE)*2.0f

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
    if (self.tableView.bounds.origin.y <= 0.0) {
        CGRect newBounds = self.tableView.bounds;
        newBounds.origin.y = newBounds.origin.y + self.episodeSearchBar.bounds.size.height;
        [UIView animateWithDuration:0.5f animations:^{
            self.tableView.bounds = newBounds;
        }];
    }
}

- (void)refreshEpisodes
{
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // save the number of items in the table
    self.countBeforeRefresh = self.episodes.count;
    [self fetchRSS];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.refreshControl endRefreshing];
    [self hideSearchBar];
}

- (NSMutableArray *)episodes
{
    if (!_episodes) _episodes = [[NSMutableArray alloc] init];
    return _episodes;
}

- (Episode *)objectInListAtIndex:(NSUInteger)theIndex
{
    if (theIndex < self.episodes.count)
        return [self.episodes objectAtIndex:theIndex];
    else
        return nil;
}

- (void)fetchRSS
{
// For offline and error testing
//    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rss" withExtension:@"xml"];
//    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"bad" withExtension:@"xml"];
//    NSString *urlString = [url absoluteString];
//    RssParser *parser = [[RssParser alloc] initWithURL:urlString];
    
    RssParser *parser = [[RssParser alloc] initWithURL:@"http://www.d-addicts.com/rss.xml"];
    if (parser != nil) {
        [self.episodes removeAllObjects];
        [parser setDelegate:self];
        [parser fetch];
    }
}

- (void)insertAndDeleteRows
{
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] initWithCapacity:self.countBeforeRefresh];
    if (self.countBeforeRefresh > 0) {
        for (NSInteger index=0; index < self.countBeforeRefresh; index += 1) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }
    }

    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] initWithCapacity:25];
    for (NSInteger index=0; index < self.episodes.count; index += 1) {
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    }
    
    UITableView *tv = self.tableView;
    [tv beginUpdates];
    [tv insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    [tv deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [tv endUpdates];
}

#pragma mark - RssDelegate

- (void)didParseItem:(NSDictionary *)dict
{
    Episode *episode = [[Episode alloc] initWithTitle:[dict valueForKey:RSS_TITLE]
                                                 link:[dict valueForKey:RSS_LINK]
                                          description:[dict valueForKey:RSS_DESCRIPTION]
                                                 date:[dict valueForKey:RSS_PUBDATE]];
    if (episode) {
        [self.episodes addObject:episode];
    }
}

- (void)didEndParse
{
    [self insertAndDeleteRows];
//    [self.tableView reloadData];
}

- (void)didFailParseWithError:(NSError *)error
{
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error while fetching feed"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

#pragma mark - UISearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Hide the Search Bar behind the Navigation Bar
    [self hideSearchBar];
}

#pragma mark - UISearchDisplay

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// Update the filtered array based on the search text and scope.
	// Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    self.filteredEpisodes = [self.episodes filteredArrayUsingPredicate:predicate];
}

#pragma mark - UISearchDisplay Delegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = ROW_HEIGHT;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredEpisodes.count;
    } else {
        return self.episodes.count;
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
    } else {
        episode = [self objectInListAtIndex:indexPath.row];
    }

    // Configure cell
    cell.textLabel.font = [UIFont boldSystemFontOfSize:TEXT_SIZE];
    cell.textLabel.text = episode.title;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:DETAIL_TEXT_SIZE];
    cell.detailTextLabel.text = episode.type;
    cell.imageView.image = [UIImage imageNamed:episode.iso];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to episode detail
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"showEpisodeDetail" sender:tableView];        
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showEpisodeDetail"]) {
        DramaDetailViewController *detailViewController = [segue destinationViewController];
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            detailViewController.torrents = self.filteredEpisodes;
            detailViewController.currentRow = indexPath.row;
        } else {
            detailViewController.torrents = self.episodes;
            detailViewController.currentRow = [self.tableView indexPathForSelectedRow].row;
        }
    }
}

#pragma mark - Target Action

- (IBAction)refresh:(UIRefreshControl *)sender {
    [self refreshEpisodes];
}

- (IBAction)goToSearch:(id)sender {
    // If you're worried that your users might not catch on to the fact that a search bar is available if they scroll to reveal it, a search icon will help them
    // If you don't hide your search bar in your app, don’t include this, as it would be redundant
    [self.episodeSearchBar becomeFirstResponder];
}

- (IBAction)refreshPressed:(UIBarButtonItem *)sender {
    [self refreshEpisodes];
}

@end
