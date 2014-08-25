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

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (weak, nonatomic) IBOutlet UIStepper *episodeStepper;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *flagImage;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedByLabel;
@end

@implementation DramaDetailViewController

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return _dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.episodeStepper.minimumValue = 0;
    self.episodeStepper.maximumValue = self.torrents.count - 1;
    self.episodeStepper.value = self.currentRow;

    [self configureView];
}

- (void)configureView
{
    Episode *episode = self.torrents[self.currentRow];

    self.navigationItem.title = [NSString stringWithFormat:@"%ld of %lu", self.currentRow+1, (unsigned long)[self.torrents count]];
    self.titleLabel.text = episode.title;
    self.flagImage.image = [UIImage imageNamed:episode.isoCountryCode];
    self.typeLabel.text = episode.type;
    self.subtitleLabel.text = episode.sub;
    self.sizeLabel.text = episode.size;
    self.addedByLabel.text = episode.addedBy;
}

- (IBAction)step:(UIStepper*)sender {
    self.currentRow = sender.value;
    [self configureView];
}


@end
