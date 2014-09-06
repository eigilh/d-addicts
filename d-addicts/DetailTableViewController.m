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

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *flagImage;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedByLabel;

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        self.titleLabel.text = self.episode.title;
        self.flagImage.image = [UIImage imageNamed:self.episode.isoCountryCode];
        self.typeLabel.text = self.episode.type;
        self.subtitleLabel.text = self.episode.sub;
        self.sizeLabel.text = self.episode.size;
        self.addedByLabel.text = self.episode.addedBy;
    }
}

@end
