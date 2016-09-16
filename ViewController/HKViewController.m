//
//  HKViewController.m
//  Demo_HealthKit
//
//  Created by NinhNguyen on 9/16/16.
//  Copyright © 2016 NinhNguyen. All rights reserved.
//

#import "HKTableViewCell.h"
#import "HKViewController.h"
#import <HealthKit/HealthKit.h>

NSString* const cellIdentifier = @"hkCellIdentifier";
NSString* const nibNameHKTableViewCell = @"HKTableViewCell";

@interface HKViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView* hkTableView;

@property (strong, nonatomic) HKHealthStore* heathKitStore;
@property (strong, nonatomic) HKQuantityType* quantityType;
@property (strong, nonatomic) HKSampleQuery* sampleQuery;
@property (strong, nonatomic) HKQuantitySample* step;
@property (strong, nonatomic) NSSet* dataTypesToWrite;
@property (strong, nonatomic) NSSet* dataTypesToRead;
@property (strong, nonatomic) NSArray<HKQuantitySample*>* arraySteps;

@end

@implementation HKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([HKHealthStore isHealthDataAvailable] == YES) {
        self.heathKitStore = [[HKHealthStore alloc] init];
    }
    [self configurationTableView];

    self.quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    self.dataTypesToWrite = [[NSSet alloc] initWithObjects:self.quantityType, nil];
    self.dataTypesToRead = [[NSSet alloc] initWithObjects:self.quantityType, nil];

    // requeire permission access health kit
    [self.heathKitStore requestAuthorizationToShareTypes:self.dataTypesToWrite
                                               readTypes:self.dataTypesToRead
                                              completion:^(BOOL success, NSError* _Nullable error) {
                                                  if (success) {
                                                      NSLog(@"success");
                                                  }
                                                  else {
                                                      NSLog(@"error = %@", error.description);
                                                  }

                                              }];

    // access healthkit store
    self.sampleQuery = [[HKSampleQuery alloc] initWithSampleType:self.quantityType
                                                       predicate:nil
                                                           limit:100
                                                 sortDescriptors:nil
                                                  resultsHandler:^(HKSampleQuery* _Nonnull query, NSArray<__kindof HKSample*>* _Nullable results, NSError* _Nullable error) {

                                                      self.arraySteps = results;

                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self.hkTableView reloadData];
                                                      });

                                                  }];
    [self.heathKitStore executeQuery:self.sampleQuery];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)configurationTableView
{
    self.hkTableView.dataSource = self;
    self.hkTableView.delegate = self;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arraySteps.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HKTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:nibNameHKTableViewCell bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    self.step = self.arraySteps[indexPath.row];
    double numberOfSteps = [self.step.quantity doubleValueForUnit:[HKUnit countUnit]];

    cell.lblSteps.text = [NSString stringWithFormat:@"%.0f", numberOfSteps];
    cell.lblDate.text = [self stringYYYYMMDDFromDate:self.step.startDate];

    return cell;
}

- (NSString*)stringYYYYMMDDFromDate:(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString* strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
