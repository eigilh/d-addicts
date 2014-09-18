//
//  DetailTableViewController.m
//  d-addicts
//
//  Created by Eigil Hansen on 06/09/14.
//  Copyright (c) 2014 Eigil Hansen. All rights reserved.
//

#import "DetailTableViewController.h"
#import "Episode.h"

@interface DetailTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *flagImage;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubDateLabel;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)setEpisode:(Episode *)newEpisode
{
    if (newEpisode != _episode) {
        _episode = newEpisode;
        [self configureView];
    }
}

- (void)configureView
{
    if (self.episode)
    {
//        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        self.titleLabel.text = self.episode.title;
        self.flagImage.image = [UIImage imageNamed:self.episode.isoCountryCode];
        self.typeLabel.text = self.episode.type;
        self.subtitleLabel.text = self.episode.sub;
        self.sizeLabel.text = self.episode.size;
        self.addedByLabel.text = self.episode.addedBy;
        self.pubDateLabel.text = [self.dateFormatter stringFromDate:self.episode.pubDate];
    }
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
    }
    return _dateFormatter;
}

@end
