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
#import "DramaCell.h"

@interface DramaViewController ()

@property (nonatomic, strong) NSMutableArray *episodes;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic) NSUInteger countBeforeRefresh;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateParser;

@end

@implementation DramaViewController


#define ROW_HEIGHT 54.0

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.rowHeight = ROW_HEIGHT;

    self.searchResults = [NSMutableArray arrayWithCapacity:[self.episodes count]];

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
    if (bounds.origin.y == -64.0f) {
        bounds.origin.y = -20.0f;
        [UIView animateWithDuration:0.2f animations:^{
            self.tableView.bounds = bounds;
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

// Parses the date format specific to the d-addicts feed
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

    [self.refreshControl beginRefreshing];
    [self fetchRSS];
}

- (void)endRefresh
{
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
    //    RssParser *parser = [[RssParser alloc] initWithURL:url];
    
    RssParser *parser = [[RssParser alloc] initWithURL:[NSURL URLWithString:@"http://www.d-addicts.com/rss.xml"]];
    if (parser != nil) {
        [self.episodes removeAllObjects];
        [parser setDelegate:self];
        [parser start];
    }
}

- (void)updateRows
{
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] initWithCapacity:self.countBeforeRefresh];
    for (NSInteger index=0; index < self.countBeforeRefresh; index += 1) {
        [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    }

    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] initWithCapacity:25];
    for (NSInteger index=0; index < self.episodes.count; index += 1) {
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    }
    
    UITableView *tv = self.tableView;
    [tv beginUpdates];
    if (self.episodes.count == self.countBeforeRefresh) {
        [tv reloadRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [tv insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
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
    [self updateRows];
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

- (IBAction)refreshPressed:(id)sender {
    [self beginRefresh];
}

#pragma mark - UISearchDisplay

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// Update the filtered array based on the search text and scope.
	// Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    if (self.searchResults.count > 0) {
        [self.searchResults removeAllObjects];
    }
    NSArray* filteredArray = [self.episodes filteredArrayUsingPredicate:predicate];
    [self.searchResults addObjectsFromArray:filteredArray];
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResults count];
    }
    else
    {
        return [self.episodes count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *episodeCell = @"EpisodeCell";

    DramaCell *cell = (DramaCell *)[self.tableView dequeueReusableCellWithIdentifier:episodeCell];

    // Get cell and episode for Table View or Search Results
    Episode *episode;

    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        episode = [self.searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        episode = [self objectInListAtIndex:indexPath.row];
    }
    
    // Configure cell
//    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline1];
//    cell.textLabel.text = episode.title;
//    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//    cell.detailTextLabel.text = episode.type;
//    cell.detailTextLabel.textColor = self.tableView.tintColor;
//    cell.imageView.image = [UIImage imageNamed:episode.iso];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    cell.titleLabel.text = episode.title;
    cell.flagImage.image = [UIImage imageNamed:episode.isoCountryCode];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showEpisodeDetail"]) {

        NSArray *sourceArray;
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:(UITableViewCell *)sender];
        if (indexPath != nil)
        {
            sourceArray = self.searchResults;
        }
        else
        {
            indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
            sourceArray = self.episodes;
        }

        DramaDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.torrents = sourceArray;
        detailViewController.currentRow = indexPath.row;
    }
}

@end
