//
//  DramaDetailViewController.h
//  d-addicts
//
//  Created by Eigil Hansen on 11/04/13.
//  Copyright (c) 2013 Eigil Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;

@interface DramaDetailViewController : UIViewController

@property (strong, nonatomic) NSArray *torrents;
@property (nonatomic) NSInteger currentRow;
@property (strong, nonatomic) Episode *episode;

@property (weak, nonatomic) IBOutlet UIImageView *flagImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedByLabel;
//@property (weak, nonatomic) IBOutlet UILabel *infoHashLabel;

- (IBAction)upDownPressed:(UISegmentedControl *)sender;
@end
