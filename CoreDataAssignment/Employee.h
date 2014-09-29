//
//  Employee.h
//  CoreDataAssignment
//
//  Created by pcs20 on 9/25/14.
//  Copyright (c) 2014 Paradigmcreatives. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Transactions;

@interface Employee : NSManagedObject

@property (nonatomic, retain) NSString * empName;
@property (nonatomic, retain) NSNumber * empID;
@property (nonatomic, retain) NSSet *employeeDetails;
@end

@interface Employee (CoreDataGeneratedAccessors)

- (void)addEmployeeDetailsObject:(Transactions *)value;
- (void)removeEmployeeDetailsObject:(Transactions *)value;
- (void)addEmployeeDetails:(NSSet *)values;
- (void)removeEmployeeDetails:(NSSet *)values;

@end
