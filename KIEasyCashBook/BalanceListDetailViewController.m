//
//  BalaneListDetailViewController.m
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/09.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import "BalanceListDetailViewController.h"
#import "AddBalanceListDetailViewController.h"
#import "MoneyTable.h"
#import "MoneyTableDataManager.h"

@interface BalanceListDetailViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;

@end

@implementation BalanceListDetailViewController
@synthesize tableName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.topItem.title = tableName;
    NSArray *moneyTableObjects;
    moneyTableObjects = [self fetchRequest];
    
    MoneyTable *moneyTable = [moneyTableObjects objectAtIndex:0];
    NSLog(@"%@", moneyTable.name);
    self.label1.text = moneyTable.name;
    self.label2.text = moneyTable.reason;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)unwindToBalanceListDetail:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"insert"]) {
        AddBalanceListDetailViewController *addBalanceListDetailViewController = (AddBalanceListDetailViewController *)segue.sourceViewController;
        
        MoneyTableDataManager *moneyTableDataManager = [MoneyTableDataManager sharedMoneyTableManager];
        
        NSManagedObjectContext *managedObjectContext = [moneyTableDataManager managedObjectContext];
        
        // NSEntityDescriptionのinsertNewObjectForEntityForName:を利用して、
        // NSManagedObjetのインスタンスを取得
        NSManagedObject *newMoneyTable;
        newMoneyTable = [NSEntityDescription insertNewObjectForEntityForName:@"MoneyTable" inManagedObjectContext:managedObjectContext];
        
        int temp = 0;
        
        if (addBalanceListDetailViewController.isIncomeOrOutgoSegmentedControl.selectedSegmentIndex == 0)
        {
            temp = 0 - addBalanceListDetailViewController.amountOfMoneyTextField.text.intValue;
        } else {
            temp = addBalanceListDetailViewController.amountOfMoneyTextField.text.intValue;
        }
        NSNumber *amountOfMoney = [[NSNumber alloc] initWithInteger:temp];
        
        // NSManagedObjectに各属性値を設定
        [newMoneyTable setValue:tableName forKey:@"name"];
        [newMoneyTable setValue:addBalanceListDetailViewController.datePicker.date forKey:@"date"];
        [newMoneyTable setValue:addBalanceListDetailViewController.howToUseTextField.text forKey:@"reason"];
        [newMoneyTable setValue:amountOfMoney forKey:@"amountOfMoney"];
        
        // managedObjectContextオブジェクトのsaveメソッドでデータを保存
        [moneyTableDataManager saveContext];
    }
}

// CoreDataからデータを検索・取得するインスタンスメソッド
-(NSArray*)fetchRequest
{
    MoneyTableDataManager *moneyTableDataManager = [MoneyTableDataManager sharedMoneyTableManager];
    
    NSManagedObjectContext *managedObjectContext = [moneyTableDataManager managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // 検索対象のエンティティを指定
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MoneyTable" inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDesc];
    
    // 検索条件を指定
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", tableName];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    return objects;
}

// CoreDataに新規残高リストを登録するインスタンスメソッド
-(void)insertNewListToMoneyTable
{
    
}

@end
