//
//  TransactionTableViewController.m
//  CoreDataAssignment
//
//  Created by pcs20 on 9/25/14.
//  Copyright (c) 2014 Paradigmcreatives. All rights reserved.
//

#import "TransactionTableViewController.h"
#import "Transactions.h"

@interface TransactionTableViewController (){

    NSString *updateDesc;
    NSString *updateAmount;
    NSIndexPath *selectedIndexpath;
}

@end

@implementation TransactionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _fetchedResultsController=[self returnFetchedResultsController];
    
    NSError *error;
    
    [_fetchedResultsController performFetch:&error];
    
    UILongPressGestureRecognizer *longpress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(updateMethodcalled:)];

    longpress.minimumPressDuration=1.0;
    longpress.delegate=self;
    [self.tableView addGestureRecognizer:longpress];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Transaction" forIndexPath:indexPath];
    
    Transactions *transactions=[_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text=transactions.desc;
    cell.detailTextLabel.text=[transactions.amount stringValue];
    
    return cell;
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}



-(NSFetchedResultsController *)returnFetchedResultsController{
    
    if (_fetchedResultsController!=nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Transactions" inManagedObjectContext:_managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescript=[[NSSortDescriptor alloc]initWithKey:@"amount" ascending:YES];
    NSArray *descriptArray=[[NSArray alloc] initWithObjects:sortDescript, nil];
    [fetchRequest setSortDescriptors:descriptArray];
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"transactionDetails==%@",_selectedEmployee];
    [fetchRequest setPredicate:predicate];
    
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



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==2) {
        if (buttonIndex==1) {
            Transactions *transact=[_fetchedResultsController objectAtIndexPath:selectedIndexpath];
            
            transact.desc=[alertView textFieldAtIndex:0].text;
            transact.amount=[NSNumber numberWithInt:[[alertView textFieldAtIndex:1].text intValue] ];
            
            NSError *error=nil;
            
            [_managedObjectContext save:&error];
        }
    }
    
    else{
    if (buttonIndex==1) {
        Transactions *transact=[NSEntityDescription insertNewObjectForEntityForName:@"Transactions" inManagedObjectContext:_managedObjectContext];
        
        transact.desc=[alertView textFieldAtIndex:0].text;
        transact.amount=[NSNumber numberWithInt:[[alertView textFieldAtIndex:1].text intValue]];
        transact.transactionDetails=_selectedEmployee;
        
        NSError *error;
        
        [_managedObjectContext save:&error];
    }
    
    }
}


- (IBAction)addTransactionClicked:(id)sender {
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Add Transaction" message:@"Enter Transaction details" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    
    alert.alertViewStyle=UIAlertViewStyleLoginAndPasswordInput;
    
    UITextField *amountField=[alert textFieldAtIndex:1];
    
    amountField.secureTextEntry=NO;
    
    [alert show];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    if (editingStyle==UITableViewCellEditingStyleDelete) {
        Transactions *tempObject=[_fetchedResultsController objectAtIndexPath:indexPath];
        
        [_managedObjectContext deleteObject:tempObject];
        NSError *error=nil;
        [_managedObjectContext save:&error];
    }

}


-(void)updateMethodcalled:(UILongPressGestureRecognizer *)longPressGuesture{
    
    if (longPressGuesture.state==UIGestureRecognizerStateEnded) {
        CGPoint p=[longPressGuesture locationInView:self.tableView];
        
        
        selectedIndexpath=[self.tableView indexPathForRowAtPoint:p];
        
        Transactions *tempObject=[_fetchedResultsController objectAtIndexPath:selectedIndexpath];
        updateDesc=tempObject.desc;
        updateAmount=[tempObject.amount stringValue];
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Update Transaction" message:@"Update Transaction Details" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        alert.tag=2;
        
        alert.alertViewStyle=UIAlertViewStyleLoginAndPasswordInput;
        [alert textFieldAtIndex:1].secureTextEntry=NO;
        
        [[alert textFieldAtIndex:0] setText:updateDesc];
        [[alert textFieldAtIndex:1] setText:updateAmount];
        
        [alert show];
    }
    
 
    
}

@end
