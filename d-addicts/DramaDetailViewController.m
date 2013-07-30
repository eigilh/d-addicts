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

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *flagImage;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedByLabel;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionView;
@end

@implementation DramaDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
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
    }
}

- (void)configureView
{
    if (self.episode) {
        self.navigationItem.title = [NSString stringWithFormat:@"%d of %d", self.currentRow+1, [self.torrents count]];
        self.titleLabel.text = self.episode.title;
        self.flagImage.image = [UIImage imageNamed:self.episode.iso];
        self.typeLabel.text = self.episode.type;
        self.subtitleLabel.text = self.episode.sub;
        self.addedByLabel.text = self.episode.addedBy;
        [self.descriptionView loadHTMLString:self.episode.description baseURL:nil];
    }
    [self enableUpDownButtons];
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
