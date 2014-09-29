//
//  EmployeeTableViewController.m
//  CoreDataAssignment
//
//  Created by pcs20 on 9/25/14.
//  Copyright (c) 2014 Paradigmcreatives. All rights reserved.
//

#import "EmployeeTableViewController.h"
#import "Employee.h"
#import "TransactionTableViewController.h"
#import "UpdateViewController.h"

@interface EmployeeTableViewController (){

    AppDelegate *appDel;
    NSString *updateEmpName;
    NSString *updateEmpId;
    NSIndexPath *selectedIndexpath;
}

@end

@implementation EmployeeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    appDel=[[UIApplication sharedApplication] delegate];
    
    _managedObjectContext=appDel.managedObjectContext;
    _fetchedResultsController=[self returnFetchedResultsController];
    
    NSError *error;
    
    [_fetchedResultsController performFetch:&error];
    
    
    
    UILongPressGestureRecognizer *longpress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(updateMethodcalled:)];
    
    longpress.minimumPressDuration=1.0;
    longpress.delegate = self;
    [self.tableView addGestureRecognizer:longpress];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([[_fetchedResultsController sections]count]>0) {
        return [[_fetchedResultsController sections] count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo=[[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Employee" forIndexPath:indexPath];
    
    Employee *employee=[_fetchedResultsController objectAtIndexPath:indexPath];
    
   
    
    cell.textLabel.text=employee.empName;
    cell.detailTextLabel.text=[employee.empID stringValue];
    
    return cell;
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]isEqualToString:@"gotoTransactions"]) {
    
        
        UINavigationController *navController=[segue destinationViewController];
        
        TransactionTableViewController *transactns=[navController.viewControllers objectAtIndex:0];
        
        transactns.managedObjectContext=_managedObjectContext;
        
        NSIndexPath *selectedIndexpath=[self.tableView indexPathForSelectedRow];
        
        transactns.selectedEmployee=[_fetchedResultsController objectAtIndexPath:selectedIndexpath];
    }
    
    
}



-(NSFetchedResultsController *)returnFetchedResultsController{
    
    if (_fetchedResultsController!=nil) {
        return _fetchedResultsController;
    }
   
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Employee" inManagedObjectContext:_managedObjectContext];
    
                                 [fetchRequest setEntity:entity];
                                 
    NSSortDescriptor *sortDescript=[[NSSortDescriptor alloc]initWithKey:@"empName" ascending:YES];
    NSArray *descriptArray=[[NSArray alloc] initWithObjects:sortDescript, nil];
    [fetchRequest setSortDescriptors:descriptArray];
    
    
    NSFetchedResultsController *fetchedResultsContrl=[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    
    
    fetchedResultsContrl.delegate=self;
    return fetchedResultsContrl;

}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        case NSFetchedResultsChangeUpdate:
            if (newIndexPath==nil) {
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
            
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];

                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
       
    }

}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{

    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
    [self.tableView endUpdates];
   
}

-(IBAction)employeeAddClicked:(id)sender{

    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Add Employee" message:@"Enter Employee details" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    
    alert.alertViewStyle=UIAlertViewStyleLoginAndPasswordInput;
    
    UITextField *amountField=[alert textFieldAtIndex:1];
    
    amountField.secureTextEntry=NO;
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==2) {
        if (buttonIndex==1) {
 
            
            Employee *emp=[[self returnFetchedResultsController] objectAtIndexPath:selectedIndexpath];
            
            emp.empID=[NSNumber numberWithInt:[[alertView textFieldAtIndex:1].text intValue]];
            emp.empName=[alertView textFieldAtIndex:0].text;
            NSError *error=nil;
            
            [_managedObjectContext save:&error];
        
           
        }
        
    }
    
    else{

    if (buttonIndex==1) {
        Employee *employee=[NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:_managedObjectContext];
        
        employee.empName=[alertView textFieldAtIndex:0].text;
        employee.empID=[NSNumber numberWithInt:[[alertView textFieldAtIndex:1].text intValue]];
        
        NSError *error;
        
        [_managedObjectContext save:&error];
    }

    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        Employee *tempObject=[_fetchedResultsController objectAtIndexPath:indexPath];
        
        [_managedObjectContext deleteObject:tempObject];
        NSError *error=nil;
        [_managedObjectContext save:&error];
    }
    
}

-(void)updateMethodcalled:(UILongPressGestureRecognizer *)longPressGuesture{
    
    if (longPressGuesture.state==UIGestureRecognizerStateEnded) {
        CGPoint p=[longPressGuesture locationInView:self.tableView];
        
        
        selectedIndexpath=[self.tableView indexPathForRowAtPoint:p];
        
        Employee *tempObject=[_fetchedResultsController objectAtIndexPath:selectedIndexpath];
        updateEmpName=tempObject.empName;
        updateEmpId=[tempObject.empID stringValue];
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Update Employee" message:@"Update Employee Details" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        alert.tag=2;
        
        alert.alertViewStyle=UIAlertViewStyleLoginAndPasswordInput;
        [alert textFieldAtIndex:1].secureTextEntry=NO;
        
        
        [[alert textFieldAtIndex:0] setText:updateEmpName];
        [[alert textFieldAtIndex:1] setText:updateEmpId];
        
        [alert show];

    }
    
    
}


@end
