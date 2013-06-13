//
//  DramaDetailViewController.m
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "DramaDetailViewController.h"
#import "Episode.h"

@interface DramaDetailViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *upDownButtons;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation DramaDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return _dateFormatter;
}

#pragma mark - Managing the detail item

- (void)setEpisode:(Episode *)newEpisode
{
    if (_episode != newEpisode) {
        _episode = newEpisode;
        
        // Update the view.
        [self configureView];
    }
}

- (void)setCurrentRow:(NSInteger)newRow
{
    _currentRow = newRow;
    if (self.torrents) {
        self.episode = self.torrents[newRow];
        [self.tableView reloadData];
    }
}

- (void)configureView
{
    if (self.episode) {
        self.navigationItem.title = [NSString stringWithFormat:@"%d of %d", self.currentRow+1, [self.torrents count]];
    }
    [self enableUpDownButtons];
}

#define TYPE 0
#define SUBTITLE 1
#define SIZE 2
#define ADDED_BY 3

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TYPE:
            cell.imageView.image = [UIImage imageNamed:self.episode.iso];
            cell.textLabel.text = self.episode.type;
            cell.detailTextLabel.text = @"Type";
            break;
            
        case SUBTITLE:
            cell.textLabel.text = self.episode.sub;
            cell.detailTextLabel.text = @"Subtitle";
            break;
            
        case SIZE:
            cell.textLabel.text = self.episode.size;
            cell.detailTextLabel.text = @"Size";
            break;
            
        case ADDED_BY:
            cell.textLabel.text = self.episode.addedBy;
            cell.detailTextLabel.text = @"Added by";
            break;
            
        default:
            break;
    }
}

#pragma mark - Table View Date Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.episode.title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [self.dateFormatter stringFromDate:self.episode.pubDate];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *detailID = @"detail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailID forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#define UP 0
#define DOWN 1

- (void)enableUpDownButtons
{
    if (self.currentRow == 0) {
        [self.upDownButtons setEnabled:NO forSegmentAtIndex:UP];
    } else {
        [self.upDownButtons setEnabled:YES forSegmentAtIndex:UP];
    }
    if (self.currentRow == [self.torrents count]-1) {
        [self.upDownButtons setEnabled:NO forSegmentAtIndex:DOWN];
    } else {
        [self.upDownButtons setEnabled:YES forSegmentAtIndex:DOWN];
    }
}

- (IBAction)upDownPressed:(UISegmentedControl *)sender {
    NSInteger button = sender.selectedSegmentIndex;
    switch (button) {
        case UP:
            if (self.currentRow > 0) self.currentRow -= 1;
            break;
        case DOWN:
            if (self.currentRow < [self.torrents count] - 1) self.currentRow += 1;
            break;
    }
}

@end
