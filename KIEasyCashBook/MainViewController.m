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
#import "MoneyTable.h"
#import "MoneyTableDataManager.h"

@interface MainViewController () {
    NSMutableArray *balanceLists;
    NSManagedObjectContext *context;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tableEditButton;
@property (weak, nonatomic) IBOutlet UITableView *balanceListSummary;
@property (weak, nonatomic) IBOutlet UILabel *entireFortuneLabel;

@end

@implementation MainViewController
@synthesize tableName;
@synthesize entireFortune;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.balanceListSummary.delegate = self;
    self.balanceListSummary.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    balanceLists = [self createMoneyTableArrray];
    self.entireFortuneLabel.text = [NSString stringWithFormat:@"残高合計:%@ 円",[[NSString alloc] initWithFormat:@"%d", entireFortune]];
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
    if (self.balanceListSummary.isEditing) {
        [self.balanceListSummary setEditing:NO animated:YES];
        self.tableEditButton.title = @"編集";
    }
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteMoneyTableEntitiy:balanceLists[indexPath.row]];
        [balanceLists removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

//// TableViewに新規残高リストを追加して表示するインスタンスメソッド
//-(void) insertNewList:(id)sender
//{
//    if (!balanceLists) {
//        balanceLists = [[NSMutableArray alloc] init];
//    }
//    [balanceLists insertObject:sender atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.balanceListSummary insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

// ModalViewからメイン画面に戻ってくるときのセグエを判定し、必要な処理を行う
-(IBAction)unwindToMaster:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"save"]) {
        AddBalanceListModalViewController *addBalanceListModalViewController = (AddBalanceListModalViewController *)segue.sourceViewController;
        if ([addBalanceListModalViewController.addBalanceListTextField.text length] > 0) {
            [self insertNewListToMoneyTable:addBalanceListModalViewController.addBalanceListTextField.text];
        } else {
            // Todo
            // アラートの表示（ここで可能か？）
        }
    }
}

// CoreDataに新規残高リストを登録するインスタンスメソッド
-(void)insertNewListToMoneyTable:(NSString*)name
{
    MoneyTableDataManager *moneyTableDataManager = [MoneyTableDataManager sharedMoneyTableManager];

    NSManagedObjectContext *managedObjectContext = [moneyTableDataManager managedObjectContext];
    
    // NSEntityDescriptionのinsertNewObjectForEntityForName:を利用して、
    // NSManagedObjetのインスタンスを取得
    NSManagedObject *newMoneyTable;
    newMoneyTable = [NSEntityDescription insertNewObjectForEntityForName:@"MoneyTable" inManagedObjectContext:managedObjectContext];
    
    NSDate *now = [NSDate date];
    NSNumber *amountOfMoney = 0;
    
    // NSManagedObjectに各属性値を設定
    [newMoneyTable setValue:name forKey:@"name"];
    [newMoneyTable setValue:now forKey:@"date"];
    [newMoneyTable setValue:@"デフォルト" forKey:@"reason"];
    [newMoneyTable setValue:amountOfMoney forKey:@"amountOfMoney"];
    
    // managedObjectContextオブジェクトのsaveメソッドでデータを保存
    [moneyTableDataManager saveContext];
}

-(NSMutableArray*)createMoneyTableArrray
{
    MoneyTableDataManager *moneyTableDataManager = [MoneyTableDataManager sharedMoneyTableManager];
    
    NSManagedObjectContext *managedObjectContext = [moneyTableDataManager managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // 検索対象のエンティティを指定
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MoneyTable" inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDesc];
    
    // 全要素を取得
    NSPredicate *pred = [NSPredicate predicateWithValue:YES];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *moneyTableArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableArray *moneyTableMutableArray = [[NSMutableArray alloc] init];
    
    int entireFortuneTemp = 0;
    
    BOOL hasListName;
    for (MoneyTable *moneyTable in moneyTableArray) {
        
        hasListName = false;
        for (NSString *listName in moneyTableMutableArray) {
            if ([listName isEqualToString:moneyTable.name]) {
                hasListName = true;
            }
        }
        if (!hasListName) {
            [moneyTableMutableArray addObject:moneyTable.name];
        }
        
        NSLog(@"%d", [moneyTable.amountOfMoney intValue]);
        entireFortuneTemp = entireFortuneTemp + [moneyTable.amountOfMoney intValue];
    }
    
    entireFortune = entireFortuneTemp;
    
    return moneyTableMutableArray;
}

- (BOOL)deleteMoneyTableEntitiy:(NSString *)name {
    
    MoneyTableDataManager *moneyTableDataManager = [MoneyTableDataManager sharedMoneyTableManager];
    
    NSManagedObjectContext *managedObjectContext = [moneyTableDataManager managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // 検索対象のエンティティを指定
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MoneyTable" inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDesc];
    
    // 要素を検索
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", name];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *moneyTableArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *object in moneyTableArray) {
        [managedObjectContext deleteObject:object];
    }
    
    NSString *logMessage = [[NSString alloc]init];
    if (![managedObjectContext save:&error]) {
        logMessage = @"faled to delete objects";
        return false;
    } else {
        logMessage = @"successed to delete objects";
        return true;
    }
    
    return false;
}

@end
