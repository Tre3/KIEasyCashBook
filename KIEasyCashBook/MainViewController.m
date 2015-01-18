//
//  ViewController.m
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/08.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
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

// 画面遷移前に次画面にパラメータを渡す
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"toBalanceListDetailSegue"]) {
        //ここでパラメータを渡す
        BalanceListDetailViewController *balanceListDetailViewController = segue.destinationViewController;
        balanceListDetailViewController.tableName = tableName;
    }
}

// TableViewをエディットモード切り替え可能にする
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// TableViewのエディットモード切り替えを行う
- (IBAction)onClickTableEditButton:(UIBarButtonItem *)sender {
    if (self.balanceListSummary.isEditing) {
        [self.balanceListSummary setEditing:NO animated:YES];
        self.tableEditButton.title = @"編集";
    } else {
        [self.balanceListSummary setEditing:YES animated:YES];
        self.tableEditButton.title = @"編集完了";
    }
}

// TableViewに新規残高リストを追加して表示するインスタンスメソッド
-(void) insertNewList:(id)sender
{
    if (!balanceLists) {
        balanceLists = [[NSMutableArray alloc] init];
    }
    [balanceLists insertObject:sender atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.balanceListSummary insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// ModalViewからメイン画面に戻ってくるときのセグエを判定し、必要な処理を行う
-(IBAction)unwindToMaster:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"save"]) {
        AddBalanceListModalViewController *addBalanceListModalViewController = (AddBalanceListModalViewController *)segue.sourceViewController;
        [self insertNewList:addBalanceListModalViewController.addBalanceListTextField.text];
        [self insertNewListToMoneyTable:addBalanceListModalViewController.addBalanceListTextField.text];
    }
}

// CoreDataに新規残高リストを登録するインスタンスメソッド
-(void)insertNewListToMoneyTable:(NSString*)name
{
    AppDelegate* appDelegate = [[AppDelegate alloc] init];
    // contextはNSManagedObjectContextのインスタンス
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // NSEntityDescriptionのinsertNewObjectForEntityForName:を利用して、
    // NSManagedObjetのインスタンスを取得
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"MoneyTable" inManagedObjectContext:context];
    
    NSDate *now = [NSDate date];
    NSNumber *amountOfMoney = 0;
    
    // NSManagedObjectに各属性値を設定
    [newContact setValue:name forKey:@"name"];
    [newContact setValue:now forKey:@"date"];
    [newContact setValue:@"デフォルト" forKey:@"reason"];
    [newContact setValue:amountOfMoney forKey:@"amountOfMoney"];
    
    // managedObjectContextオブジェクトのsaveメソッドでデータを保存
    [appDelegate saveContext];

}

@end
