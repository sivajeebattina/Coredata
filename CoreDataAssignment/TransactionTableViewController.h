//
//  TransactionTableViewController.h
//  CoreDataAssignment
//
//  Created by pcs20 on 9/25/14.
//  Copyright (c) 2014 Paradigmcreatives. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Employee.h"

@interface TransactionTableViewController : UITableViewController<NSFetchedResultsControllerDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,strong)NSManagedObjectContext *managedObjectContext;

@property(nonatomic,strong)Employee *selectedEmployee;

- (IBAction)addTransactionClicked:(id)sender;

@end
