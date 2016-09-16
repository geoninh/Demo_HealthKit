//
//  HKTableViewCell.h
//  Demo_HealthKit
//
//  Created by NinhNguyen on 9/16/16.
//  Copyright © 2016 NinhNguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblSteps;

@end
