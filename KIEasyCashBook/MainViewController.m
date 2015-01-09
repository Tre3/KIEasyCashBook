//
//  ViewController.m
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/08.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tableEditButton;
@property (weak, nonatomic) IBOutlet UITableView *balanceListSummary;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.balanceListSummary.delegate = self;
    self.balanceListSummary.dataSource = self;
    
    self.dataSource = @[@"a",@"b",@"c"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.detailTextLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath{
    
    [self performSegueWithIdentifier:@"toBalanceListDetailSegue" sender:self];
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

-(IBAction)unwindToMaster:(UIStoryboardSegue *)segue
{
    
}

@end
