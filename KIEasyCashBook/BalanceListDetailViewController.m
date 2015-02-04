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

static const int kHeadingHeight = 40;
static const int kGridCellHeight = 50;

@interface BalanceListDetailViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic) UIScrollView *gridScrollView;
@property (nonatomic) int sumOfBalance;

@end

@implementation BalanceListDetailViewController
@synthesize tableName;
@synthesize headingHeight;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.70f green:1.00f blue:0.40f alpha:1]];
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 22)];
    statusBarView.backgroundColor  =  [UIColor colorWithRed:0.70f green:1.00f blue:0.40f alpha:1];
    [self.view addSubview:statusBarView];
    
    self.navigationBar.topItem.title = tableName;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *moneyTableObjects;
    moneyTableObjects = [self fetchRequest];
    
    [self createDetailGridTableHeadingAndGridScrollview:[moneyTableObjects count]];
    
    self.sumOfBalance = 0;
    
    for (int i = 0; i < [moneyTableObjects count]; i++) {
        MoneyTable *moneyTable = [moneyTableObjects objectAtIndex:i];
        self.sumOfBalance = self.sumOfBalance + [moneyTable.amountOfMoney intValue];
        
        [self createDetailGridCell:moneyTable lineNumber:i amountOfBalance:self.sumOfBalance];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.gridScrollView removeFromSuperview];
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

-(void)createDetailGridTableHeadingAndGridScrollview:(NSUInteger)lineNumber
{
    CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
    CGRect navigationBarFrame = self.navigationBar.frame;
    CGRect statusFrame = [UIApplication sharedApplication].statusBarFrame;
    
    int tableHeading_y_coodinate = navigationBarFrame.size.height + statusFrame.size.height;
    
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(0,tableHeading_y_coodinate,mainScreenFrame.size.width/4,kHeadingHeight)];
    labelDate.text = @"日時";
    labelDate.textAlignment = NSTextAlignmentCenter;
    labelDate.layer.borderColor = [UIColor grayColor].CGColor;
    labelDate.layer.borderWidth = 1.0;
    labelDate.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *labelReason = [[UILabel alloc] initWithFrame:CGRectMake(mainScreenFrame.size.width/4,tableHeading_y_coodinate,mainScreenFrame.size.width/4,kHeadingHeight)];
    labelReason.text = @"使い道";
    labelReason.textAlignment = NSTextAlignmentCenter;
    labelReason.layer.borderColor = [UIColor grayColor].CGColor;
    labelReason.layer.borderWidth = 1.0;
    labelReason.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *labelAmountOfMoney = [[UILabel alloc] initWithFrame:CGRectMake(mainScreenFrame.size.width/2,tableHeading_y_coodinate,mainScreenFrame.size.width/4,kHeadingHeight)];
    labelAmountOfMoney.text = @"金額";
    labelAmountOfMoney.textAlignment = NSTextAlignmentCenter;
    labelAmountOfMoney.layer.borderColor = [UIColor grayColor].CGColor;
    labelAmountOfMoney.layer.borderWidth = 1.0;
    labelAmountOfMoney.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *labelAmountOfBalance = [[UILabel alloc] initWithFrame:CGRectMake(mainScreenFrame.size.width*3/4,tableHeading_y_coodinate,mainScreenFrame.size.width/4,kHeadingHeight)];
    labelAmountOfBalance.text = @"残額";
    labelAmountOfBalance.textAlignment = NSTextAlignmentCenter;
    labelAmountOfBalance.layer.borderColor = [UIColor grayColor].CGColor;
    labelAmountOfBalance.layer.borderWidth = 1.0;
    labelAmountOfBalance.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:labelDate];
    [self.view addSubview:labelReason];
    [self.view addSubview:labelAmountOfMoney];
    [self.view addSubview:labelAmountOfBalance];
    
    self.gridScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, tableHeading_y_coodinate+kHeadingHeight, mainScreenFrame.size.width, mainScreenFrame.size.height - navigationBarFrame.size.height - statusFrame.size.height - kHeadingHeight)];
    
    self.gridScrollView.scrollEnabled = YES;
    self.gridScrollView.contentSize = CGSizeMake(mainScreenFrame.size.width, kGridCellHeight*lineNumber);
    
    [self.view addSubview:self.gridScrollView];
}

-(void)createDetailGridCell:(MoneyTable*)moneyTableObject lineNumber:(int)lineNumber amountOfBalance:(int)amountOfBalance
{
    CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
    
    UILabel *cellDate = [[UILabel alloc] initWithFrame:CGRectMake(0,kGridCellHeight*lineNumber,mainScreenFrame.size.width/4,kGridCellHeight)];
    NSDate* usedDate = moneyTableObject.date;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    cellDate.text = [dateFormatter stringFromDate:usedDate];
    cellDate.font = [UIFont systemFontOfSize:10];
    cellDate.textAlignment = NSTextAlignmentCenter;
    cellDate.layer.borderColor = [UIColor grayColor].CGColor;
    cellDate.layer.borderWidth = 1.0;
    
    UILabel *cellReason = [[UILabel alloc] initWithFrame:CGRectMake(mainScreenFrame.size.width/4,kGridCellHeight*lineNumber,mainScreenFrame.size.width/4,kGridCellHeight)];
    cellReason.text = moneyTableObject.reason;
    cellReason.font = [UIFont systemFontOfSize:10];
    cellReason.textAlignment = NSTextAlignmentCenter;
    cellReason.layer.borderColor = [UIColor grayColor].CGColor;
    cellReason.layer.borderWidth = 1.0;
    
    UILabel *cellAmountOfMoney = [[UILabel alloc] initWithFrame:CGRectMake(mainScreenFrame.size.width/2,kGridCellHeight*lineNumber,mainScreenFrame.size.width/4,kGridCellHeight)];
    cellAmountOfMoney.text = moneyTableObject.amountOfMoney.stringValue;
    
    if (moneyTableObject.amountOfMoney.intValue > 0) {
        cellAmountOfMoney.textColor = [UIColor blueColor];
    } else if (moneyTableObject.amountOfMoney.intValue < 0) {
        cellAmountOfMoney.textColor = [UIColor redColor];
    }
    
    cellAmountOfMoney.textAlignment = NSTextAlignmentCenter;
    cellAmountOfMoney.layer.borderColor = [UIColor grayColor].CGColor;
    cellAmountOfMoney.layer.borderWidth = 1.0;
    
    UILabel *cellAmountOfBalance = [[UILabel alloc] initWithFrame:CGRectMake(mainScreenFrame.size.width*3/4,kGridCellHeight*lineNumber,mainScreenFrame.size.width/4,kGridCellHeight)];
    cellAmountOfBalance.text = [NSString stringWithFormat:@"%d", amountOfBalance];
    
    if (amountOfBalance > 0) {
        cellAmountOfBalance.textColor = [UIColor blueColor];
    } else if (amountOfBalance < 0) {
        cellAmountOfBalance.textColor = [UIColor redColor];
    }
    
    cellAmountOfBalance.textAlignment = NSTextAlignmentCenter;
    cellAmountOfBalance.layer.borderColor = [UIColor grayColor].CGColor;
    cellAmountOfBalance.layer.borderWidth = 1.0;
    
    [self.gridScrollView addSubview:cellDate];
    [self.gridScrollView addSubview:cellReason];
    [self.gridScrollView addSubview:cellAmountOfMoney];
    [self.gridScrollView addSubview:cellAmountOfBalance];
}

@end
