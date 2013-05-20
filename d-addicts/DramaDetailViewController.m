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

@property (weak, nonatomic) IBOutlet UIImageView *flagImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedByLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *upDownButtons;

- (void)configureView;
@end

@implementation DramaDetailViewController

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
    // Update the user interface for the detail item.
    Episode *theEpisode = self.episode;
    
    if (theEpisode) {
        self.navigationItem.title = [NSString stringWithFormat:@"%d of %d", self.currentRow+1, [self.torrents count]];
        self.flagImage.image = [UIImage imageNamed:theEpisode.iso];
        self.titleLabel.text = theEpisode.title;
        
        /*
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEEEE, dd MMMMM yyyy HH:mm:ss zzz"];
        NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
        [df setLocale:enLocale];
        [df setFormatterBehavior:NSDateFormatterBehaviorDefault];
        NSDate *date = [df dateFromString:theEpisode.pubDate];
        NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
        [df2 setDateStyle:NSDateFormatterMediumStyle];
        self.pubDateLabel.text = [theEpisode.pubDate substringToIndex:16];
         */
        self.pubDateLabel.text = theEpisode.pubDate;
        self.typeLabel.text = theEpisode.type;
        self.subLabel.text = theEpisode.sub;
        self.sizeLabel.text = theEpisode.size;
        self.addedByLabel.text = theEpisode.addedBy;
    }
    [self enableUpDownButtons];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView setContentSize:self.contentView.bounds.size];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureView];
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
