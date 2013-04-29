//
//  DramaDetailViewController.m
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import "DramaDetailViewController.h"
#import "Episode.h"
/*
@interface DramaDetailViewController ()
- (void)configureView;
@end
*/
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
        self.pubDateLabel.text = theEpisode.pubDate;
        self.typeLabel.text = theEpisode.type;
        self.subLabel.text = theEpisode.sub;
        self.sizeLabel.text = theEpisode.size;
        self.addedByLabel.text = theEpisode.addedBy;
        //self.infoHashLabel.text = theEpisode.infoHash;
    }
    [self enableUpDownButtons];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    if (button == UP) {
        if (self.currentRow > 0) {
            self.currentRow -= 1;
        }
    } else if (button == DOWN) {
        if (self.currentRow < [self.torrents count] - 1) {
            self.currentRow += 1;
        }
    }
    [self enableUpDownButtons];
}
@end
