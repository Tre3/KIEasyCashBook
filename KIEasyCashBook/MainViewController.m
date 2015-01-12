//
//  ViewController.m
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/08.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import "MainViewController.h"
#import "BalanceListDetailViewController.h"
#import "AddBalanceListModalViewController.h"

@interface MainViewController () {
    NSMutableArray *balanceLists;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tableEditButton;
@property (weak, nonatomic) IBOutlet UITableView *balanceListSummary;

@end

@implementation MainViewController
@synthesize tableName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.balanceListSummary.delegate = self;
    self.balanceListSummary.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return balanceLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = balanceLists[indexPath.row];
    cell.detailTextLabel.text = balanceLists[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath{
    tableName = balanceLists[indexPath.row];
    
    [self performSegueWithIdentifier:@"toBalanceListDetailSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"toBalanceListDetailSegue"]) {
        //ここでパラメータを渡す
        BalanceListDetailViewController *balanceListDetailViewController = segue.destinationViewController;
        balanceListDetailViewController.tableName = tableName;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (IBAction)onClickTableEditButton:(UIBarButtonItem *)sender {
    if (self.balanceListSummary.isEditing) {
        [self.balanceListSummary setEditing:NO animated:YES];
        self.tableEditButton.title = @"編集";
    } else {
        [self.balanceListSummary setEditing:YES animated:YES];
        self.tableEditButton.title = @"編集完了";
    }
}

-(void) insertNewList:(id)sender
{
    if (!balanceLists) {
        balanceLists = [[NSMutableArray alloc] init];
    }
    [balanceLists insertObject:sender atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.balanceListSummary insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(IBAction)unwindToMaster:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"save"]) {
        AddBalanceListModalViewController *addBalanceListModalViewController = (AddBalanceListModalViewController *)segue.sourceViewController;
        [self insertNewList:addBalanceListModalViewController.addBalanceListTextField.text];
    }
}
@end
