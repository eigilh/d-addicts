//
//  DramaViewController.m
//  d-addicts
//
//  Created by Eigil Hansen on 20/05/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "DramaViewController.h"
#import "DramaDetailViewController.h"
#import "Episode.h"

@interface DramaViewController ()

@property (nonatomic, strong) NSMutableArray *episodes;
@property (nonatomic, strong) NSArray *filteredEpisodes;
@property (nonatomic) NSUInteger countBeforeRefresh;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateParser;

@end

@implementation DramaViewController


#define TEXT_SIZE 14.0f
#define DETAIL_TEXT_SIZE 13.0f
#define ROW_HEIGHT (TEXT_SIZE+DETAIL_TEXT_SIZE)*2.0f

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.refreshControl addTarget:self
                            action:@selector(beginRefresh)
                  forControlEvents:UIControlEventValueChanged];
    self.tableView.rowHeight = ROW_HEIGHT;
    [self.refreshControl beginRefreshing];
    [self beginRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.dateFormatter = nil;
    self.dateParser = nil;
}

- (void)hideSearchBar
{
    CGRect bounds = self.tableView.bounds;
    if (bounds.origin.y <= 0.0f) {
        CGRect newBounds = bounds;
        newBounds.origin.y = self.searchBar.bounds.size.height;
        [UIView animateWithDuration:0.4f animations:^{
            self.tableView.bounds = newBounds;
        }];
    }
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
    }
    return _dateFormatter;
}

- (NSDateFormatter *)dateParser
{
    if (_dateParser == nil) {
        _dateParser = [[NSDateFormatter alloc] init];
        [_dateParser setDateFormat:@"EEEEE, dd MMMMM yyyy HH:mm:ss zzz"];
        NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
        [_dateParser setLocale:enLocale];
        [_dateParser setFormatterBehavior:NSDateFormatterBehaviorDefault];
    }
    return _dateParser;
}

- (void)beginRefresh
{
    // save the number of items in the table
    self.countBeforeRefresh = self.episodes.count;
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Fetching RSS feed..."];
    [self fetchRSS];
}

- (void)endRefresh
{
    NSString *status = NSLocalizedString(@"Updated", @"Status text suffixed with date");
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", status, [self.dateFormatter stringFromDate:[NSDate date]]]];
    [self hideSearchBar];
    [self.refreshControl endRefreshing];
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
    //    RssParser *parser = [[RssParser alloc] initWithURL:url];
    
    RssParser *parser = [[RssParser alloc] initWithURL:[NSURL URLWithString:@"http://www.d-addicts.com/rss.xml"]];
    if (parser != nil) {
        [self.episodes removeAllObjects];
        [parser setDelegate:self];
        [parser start];
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
    if (self.episodes.count == self.countBeforeRefresh) {
        [tv reloadRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [tv insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [tv deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    }
    [tv endUpdates];
}

#pragma mark - RssDelegate

- (void)didParseItem:(NSDictionary *)dict
{
    NSDate *date = [self.dateParser dateFromString:[dict valueForKey:RSS_PUBDATE]];
    Episode *episode = [[Episode alloc] initWithTitle:[dict valueForKey:RSS_TITLE]
                                                 link:[dict valueForKey:RSS_LINK]
                                          description:[dict valueForKey:RSS_DESCRIPTION]
                                                 date:date];
    if (episode) {
        [self.episodes addObject:episode];
    }
}

- (void)didEndParse
{
    [self insertAndDeleteRows];
    [self endRefresh];
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
    // Clear out any old data in the table view
    [self.tableView reloadData];
    [self endRefresh];
}

#pragma mark - UIAlertView Delegate

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
    static NSString *episodeCell = @"EpisodeCell";
    UITableViewCell *cell;
    Episode *episode;
    
    cell = [tableView dequeueReusableCellWithIdentifier:episodeCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:episodeCell];
    }
    // Get cell and episode for Table View or Search Results
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
        if (sender == self.searchDisplayController.searchResultsTableView) {
            detailViewController.torrents = self.filteredEpisodes;
            NSIndexPath *indexPath = [sender indexPathForSelectedRow];
            detailViewController.currentRow = indexPath.row;
            [sender deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            detailViewController.torrents = self.episodes;
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            detailViewController.currentRow = indexPath.row;
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

@end
