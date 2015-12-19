//
//  ViewController.m
//  HealthKitDemo
//
//  Created by Yongwei.Chen on 12/7/15.
//  Copyright © 2015 PandaPlan. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>
#import <HealthKit/HKObjectType.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lbHealthAvailable;
@property (weak, nonatomic) IBOutlet UIButton *btnRequestStepAccess;
@property (weak, nonatomic) IBOutlet UIButton *btnRequestSleepAccess;
@property (weak, nonatomic) IBOutlet UILabel *lbTotalSteps;
@property (weak, nonatomic) IBOutlet UILabel *lbTotalHours;

@property (strong, nonatomic) HKHealthStore *healthStore;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    BOOL isHealthAvailable = HKHealthStore.isHealthDataAvailable;
    self.lbHealthAvailable.text = isHealthAvailable ? @"YES" : @"NO";
    
    
    
    if(self.healthStore == nil){
        self.healthStore = [[HKHealthStore alloc]init];
    }
    
    
    // check sleep permission
    HKObjectType *typeSleep = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    HKAuthorizationStatus statusSleep = [self.healthStore authorizationStatusForType:typeSleep];
    if (statusSleep == HKAuthorizationStatusSharingAuthorized) {
        [self.btnRequestSleepAccess setTitle:@"authorized already" forState:UIControlStateNormal];
        self.btnRequestSleepAccess.enabled = NO;
        
        NSDate *endDate = [[NSDate alloc] init];
        NSDate *startDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-60 toDate:endDate options:NSCalendarMatchStrictly];
        [self getSleepCountWithStartDate:startDate EndDate:endDate];
        
    }

    
    // check step permission
    HKObjectType *typeStep = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKAuthorizationStatus statusStep = [self.healthStore authorizationStatusForType:typeStep];
    if (statusStep == HKAuthorizationStatusSharingAuthorized) {
        [self.btnRequestStepAccess setTitle:@"authorized already" forState:UIControlStateNormal];
        self.btnRequestStepAccess.enabled = NO;
        
        NSDate *endDate = [[NSDate alloc] init];
        NSDate *startDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:endDate options:NSCalendarMatchStrictly];
        [self getStepCountWithStartDate:startDate EndDate:endDate];

    }

}

- (IBAction)requestSleepPermission:(id)sender {
    
    HKObjectType *type = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    NSSet *readTypes = [NSSet setWithObject:type];
    
    [self.btnRequestSleepAccess setTitle:@"requesting...." forState:UIControlStateNormal];
    self.btnRequestSleepAccess.enabled = NO;
    [self.healthStore requestAuthorizationToShareTypes:readTypes readTypes:readTypes completion:^(BOOL success, NSError * __nullable error) {
        if(error){
            NSLog(@"HealthKit permission error: %@", error.localizedDescription);
            [self.btnRequestSleepAccess setTitle:@"failed, request again" forState:UIControlStateNormal];
            self.btnRequestSleepAccess.enabled = YES;
        }
        else {
            [self.btnRequestSleepAccess setTitle:@"authorized done" forState:UIControlStateNormal];
            self.btnRequestSleepAccess.enabled = NO;
            
            [self querySleepSource];
            NSDate *endDate = [[NSDate alloc] init];
            NSDate *startDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-60 toDate:endDate options:NSCalendarMatchStrictly];
            [self getSleepCountWithStartDate:startDate EndDate:endDate];
        }
    }];

}

- (IBAction)requestStepPermission:(id)sender {

    
    HKObjectType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *readTypes = [NSSet setWithObject:type];
    
    [self.btnRequestStepAccess setTitle:@"requesting...." forState:UIControlStateNormal];
    self.btnRequestStepAccess.enabled = NO;
    [self.healthStore requestAuthorizationToShareTypes:readTypes readTypes:readTypes completion:^(BOOL success, NSError * __nullable error) {
        if(error){
            NSLog(@"HealthKit permission error: %@", error.localizedDescription);
            [self.btnRequestStepAccess setTitle:@"failed, request again" forState:UIControlStateNormal];
            self.btnRequestStepAccess.enabled = YES;
        }
        else {
            [self.btnRequestStepAccess setTitle:@"authorized done" forState:UIControlStateNormal];
            self.btnRequestStepAccess.enabled = NO;
            
            [self queryStepSource];
            NSDate *endDate = [[NSDate alloc] init];
            NSDate *startDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:endDate options:NSCalendarMatchStrictly];
            [self getStepCountWithStartDate:startDate EndDate:endDate];
        }
    }];

}

// 列出所有数据源的名字
-(void)queryStepSource {
    HKSampleType *sampleType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKSourceQuery *query =
    [[HKSourceQuery alloc]
     initWithSampleType:sampleType
     samplePredicate:nil
     completionHandler:^(HKSourceQuery *query, NSSet *sources, NSError *error) {
        
         if (error) {
             NSLog(@"*** An error occured while gathering the sources for step date.%@ ***", error.localizedDescription);
             abort();
         }
         
         NSLog(@"Query suceeded");
         for (HKSource *source in sources) {
             NSLog(@"name = %@", source.name);
         }
         
     }];
    [self.healthStore executeQuery:query];
}

// 列出所有数据源的名字
-(void)querySleepSource {
    HKSampleType *sampleType =
    [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    HKSourceQuery *query =
    [[HKSourceQuery alloc]
     initWithSampleType:sampleType
     samplePredicate:nil
     completionHandler:^(HKSourceQuery *query, NSSet *sources, NSError *error) {
         
         
         if (error) {
             NSLog(@"*** An error occured while gathering the sources for step date.%@ ***", error.localizedDescription);
             abort();
         }
         
         NSLog(@"Query suceeded");
         for (HKSource *source in sources) {
             NSLog(@"name = %@", source.name);
         }
         
     }];
    [self.healthStore executeQuery:query];
    
}

// 获取某个时间段内的步数
- (void)getStepCountWithStartDate:(NSDate*)startDate EndDate:(NSDate*)endDate {
    NSString *stepCountID = HKQuantityTypeIdentifierStepCount;
    HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:stepCountID];
    HKStatisticsOptions sumoptions = HKStatisticsOptionCumulativeSum;
    
    //获得某一时间段的数
    NSDateComponents *stepDC = [[NSDateComponents alloc]init];
    stepDC.day = 1;
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    HKStatisticsCollectionQuery *collectionQuery ;
    collectionQuery = [[HKStatisticsCollectionQuery alloc]initWithQuantityType:stepCountType quantitySamplePredicate:predicate options:sumoptions anchorDate:startDate intervalComponents:stepDC];
    
    collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error){
        //        NSLog(@"result = %@， count = %i ",result,(int)result.statistics.count);
        if (error) {
            NSLog(@"*** An error occured while gathering the sources for step date.%@ ***", error.localizedDescription);
            return ;
        }

        __block int totalStepCount = 0;
        [result enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics * __nonnull result, BOOL * __nonnull stop) {
            
            HKQuantity *sum = [result sumQuantity];
            int stepCount = [sum doubleValueForUnit:[HKUnit countUnit]];
            totalStepCount += stepCount;
            
            NSLog(@"steps : %lf, date = %@",[sum doubleValueForUnit:[HKUnit countUnit]],result.startDate);
            
            NSLog(@"开始时间：= %@ ，最后时间：= %@",startDate,endDate);
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lbTotalSteps.text = [NSString stringWithFormat:@"%d", totalStepCount];
        });
        
    };
    
    
    [self.healthStore executeQuery:collectionQuery];
}

// 获取某个时间段内的睡眠
- (void)getSleepCountWithStartDate:(NSDate*)startDate EndDate:(NSDate*)endDate {
    // setup sleep-data based query in Health Kit data
    HKSampleType *sampleType = [HKSampleType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:YES];
    
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc]
initWithSampleType:sampleType
         predicate:predicate
             limit:HKObjectQueryNoLimit
   sortDescriptors:@[sortDescriptor]
    resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if(!error && results)
        {
            __block int totalSleepMinutes = 0;
            for(HKCategorySample *samples in results)
            {
                // save seconds asleep with wake-up moment as time-value
                NSTimeInterval timeAsleep = [[samples endDate] timeIntervalSinceDate:[samples startDate]];
                NSLog(@"睡了: %f分钟", timeAsleep/60);
                totalSleepMinutes += timeAsleep/60;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                    self.lbTotalHours.text = [NSString stringWithFormat:@"%d", totalSleepMinutes/60];
                });
            };
    }];
    
    // execute query
    [self.healthStore executeQuery:sampleQuery];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
