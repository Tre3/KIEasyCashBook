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
#import "CustomScrollView.h"

static const int kHeadingHeight = 40;
static const int kGridCellHeight = 50;

@interface BalanceListDetailViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic) CustomScrollView *gridScrollView;
@property (nonatomic) int sumOfBalance;
@property (nonatomic) AddBalanceListDetailViewController *addBalancelistDetailViewController;
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
    
    self.addBalancelistDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddBalanceListDetailViewController"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *moneyTableObjects;
    moneyTableObjects = [self fetchRequest];
    
    [self createDetailGridTableHeadingAndGridScrollview:[moneyTableObjects count]];
    
    self.sumOfBalance = 0;
    
    NSArray *sortedMoneyTableObjects = [self sortMoneyTable:moneyTableObjects];
    
    for (int i = 0; i < [sortedMoneyTableObjects count]; i++) {
        MoneyTable *moneyTable = [sortedMoneyTableObjects objectAtIndex:i];
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
        
        if ([AddBalanceListDetailViewController getViewMode] == 1) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            
            // 検索対象のエンティティを指定
            NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MoneyTable" inManagedObjectContext:managedObjectContext];
            [request setEntity:entityDesc];
            
            // 要素を検索
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@) and (date = %@) and (reason = %@) and (amountOfMoney = %@)", addBalanceListDetailViewController.editMoneyTableObject.name, addBalanceListDetailViewController.editMoneyTableObject.date, addBalanceListDetailViewController.editMoneyTableObject.reason, addBalanceListDetailViewController.editMoneyTableObject.amountOfMoney];
            [request setPredicate:pred];
            
            NSError *error;
            NSArray *moneyTableArray = [managedObjectContext executeFetchRequest:request error:&error];
            
            for (NSManagedObject *object in moneyTableArray) {
                [managedObjectContext deleteObject:object];
            }
            
            NSString *logMessage = [[NSString alloc]init];
            if (![managedObjectContext save:&error]) {
                logMessage = @"faled to delete objects";
            } else {
                logMessage = @"successed to delete objects";
            }
        }
        
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

-(NSArray*)sortMoneyTable:(NSArray*)moneyTableObjectArray
{
    NSSortDescriptor *sortDateDesc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    
    return [moneyTableObjectArray sortedArrayUsingDescriptors:@[sortDateDesc]];
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
    
    self.gridScrollView = [[CustomScrollView alloc] initWithFrame:CGRectMake(0, tableHeading_y_coodinate+kHeadingHeight, mainScreenFrame.size.width, mainScreenFrame.size.height - navigationBarFrame.size.height - statusFrame.size.height - (kHeadingHeight * 2))];
    
    self.gridScrollView.scrollEnabled = YES;
    self.gridScrollView.contentSize = CGSizeMake(mainScreenFrame.size.width, kGridCellHeight*lineNumber);
    
    [self.view addSubview:self.gridScrollView];
    
    UILabel *navigationMessage = [[UILabel alloc] initWithFrame:CGRectMake(0,mainScreenFrame.size.height - kHeadingHeight,mainScreenFrame.size.width,kHeadingHeight)];
    navigationMessage.text = @"リストをタップで編集・削除できます";
    navigationMessage.textAlignment = NSTextAlignmentCenter;
    navigationMessage.layer.borderColor = [UIColor grayColor].CGColor;
    navigationMessage.layer.borderWidth = 1.0;
    navigationMessage.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:navigationMessage];
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
    cellDate.backgroundColor = [UIColor colorWithRed:0.88f green:0.90f blue:0.99f alpha:1];
    
    UILabel *cellReason = [[UILabel alloc] initWithFrame:CGRectMake(mainScreenFrame.size.width/4,kGridCellHeight*lineNumber,mainScreenFrame.size.width/4,kGridCellHeight)];
    cellReason.text = moneyTableObject.reason;
    cellReason.font = [UIFont systemFontOfSize:10];
    cellReason.textAlignment = NSTextAlignmentCenter;
    cellReason.layer.borderColor = [UIColor grayColor].CGColor;
    cellReason.layer.borderWidth = 1.0;
    cellReason.backgroundColor = [UIColor colorWithRed:0.88f green:0.90f blue:0.99f alpha:1];
    
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
    cellAmountOfMoney.backgroundColor = [UIColor colorWithRed:0.88f green:0.90f blue:0.99f alpha:1];
    
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
    cellAmountOfBalance.backgroundColor =[UIColor colorWithRed:0.88f green:0.90f blue:0.99f alpha:1];
    
    [self.gridScrollView addSubview:cellDate];
    [self.gridScrollView addSubview:cellReason];
    [self.gridScrollView addSubview:cellAmountOfMoney];
    [self.gridScrollView addSubview:cellAmountOfBalance];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat x,y;
    NSArray* objects=[touches allObjects];
    
    for (int i=0 ; i<objects.count ; i++) {
        CGPoint location = [[objects objectAtIndex:i] locationInView:self.gridScrollView];
        x = location.x; // X座標
        y = location.y; // Y座標
        NSLog(@"x : %f", x);
        NSLog(@"y : %f", y);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat x,y;
    NSArray* objects=[touches allObjects];
    
    for (int i=0 ; i<objects.count ; i++) {
        CGPoint location = [[objects objectAtIndex:i] locationInView:self.gridScrollView];
        x = location.x; // X座標
        y = location.y; // Y座標
        NSLog(@"x end : %f", x);
        NSLog(@"y end : %f", y);
        
        if (y > 0) {
            
            int lineNumber;
            lineNumber = y / kGridCellHeight;
            NSArray *moneyTableObjects;
            moneyTableObjects = [self fetchRequest];
            moneyTableObjects = [self sortMoneyTable:moneyTableObjects];
            MoneyTable *moneyTable = [moneyTableObjects objectAtIndex:lineNumber];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"この記録の操作を選択してください" message:[NSString stringWithFormat:@"日付 : %@\n使い道 : %@\n金額 : %@", [dateFormatter stringFromDate:moneyTable.date], moneyTable.reason, [moneyTable.amountOfMoney stringValue]] preferredStyle:UIAlertControllerStyleActionSheet];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"編集する" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [AddBalanceListDetailViewController setViewMode:1];
                [self presentViewController:self.addBalancelistDetailViewController animated:YES completion:nil];
                [self.addBalancelistDetailViewController.datePicker setDate:moneyTable.date];
                [self.addBalancelistDetailViewController.howToUseTextField setText:moneyTable.reason];
                NSNumber *amountOfMoney = moneyTable.amountOfMoney;
                if ([amountOfMoney intValue] < 0) {
                    [self.addBalancelistDetailViewController.isIncomeOrOutgoSegmentedControl setSelectedSegmentIndex:0];
                } else {
                    [self.addBalancelistDetailViewController.isIncomeOrOutgoSegmentedControl setSelectedSegmentIndex:1];
                }
                int amountOfMoneyInt = abs([amountOfMoney intValue]);
                NSString *amountOfMoneyString = [NSString stringWithFormat:@"%d", amountOfMoneyInt];
                [self.addBalancelistDetailViewController.amountOfMoneyTextField setText:amountOfMoneyString];
                self.addBalancelistDetailViewController.editMoneyTableObject = moneyTable;
                
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"削除する" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                MoneyTableDataManager *moneyTableDataManager = [MoneyTableDataManager sharedMoneyTableManager];
                NSManagedObjectContext *managedObjectContext = [moneyTableDataManager managedObjectContext];
                
                NSFetchRequest *preRequest = [[NSFetchRequest alloc] init];
                
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                
                // 検索対象のエンティティを指定
                NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MoneyTable" inManagedObjectContext:managedObjectContext];
                
                [preRequest setEntity:entityDesc];
                NSPredicate *prePred = [NSPredicate predicateWithFormat:@"name = %@", moneyTable.name];
                [preRequest setPredicate:prePred];
                NSError *preError;
                NSArray *preMoneyTableArray = [managedObjectContext executeFetchRequest:preRequest error:&preError];
                if ([preMoneyTableArray count] == 1) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"リストが空になるため削除できません" message:@"" preferredStyle:UIAlertControllerStyleAlert];[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    }]];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                } else {
                
                    [request setEntity:entityDesc];
                
                    // 要素を検索
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@) and (date = %@) and (reason = %@) and (amountOfMoney = %@)", moneyTable.name, moneyTable.date, moneyTable.reason, moneyTable.amountOfMoney];
                    [request setPredicate:pred];
                
                    NSError *error;
                    NSArray *moneyTableArray = [managedObjectContext executeFetchRequest:request error:&error];
                
                    for (NSManagedObject *object in moneyTableArray) {
                        [managedObjectContext deleteObject:object];
                    }
                
                    NSString *logMessage = [[NSString alloc]init];
                    if (![managedObjectContext save:&error]) {
                        logMessage = @"faled to delete objects";
                    } else {
                        logMessage = @"successed to delete objects";
                    }
                
                    [self.gridScrollView removeFromSuperview];
                
                    NSArray *moneyTableObjects;
                    moneyTableObjects = [self fetchRequest];
                
                    [self createDetailGridTableHeadingAndGridScrollview:[moneyTableObjects count]];
                
                    self.sumOfBalance = 0;
                
                    NSArray *sortedMoneyTableObjects = [self sortMoneyTable:moneyTableObjects];
                
                    for (int i = 0; i < [sortedMoneyTableObjects count]; i++) {
                        MoneyTable *moneyTable = [sortedMoneyTableObjects objectAtIndex:i];
                        self.sumOfBalance = self.sumOfBalance + [moneyTable.amountOfMoney intValue];
                    
                        [self createDetailGridCell:moneyTable lineNumber:i amountOfBalance:self.sumOfBalance];
                    }
                }
                
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

@end
