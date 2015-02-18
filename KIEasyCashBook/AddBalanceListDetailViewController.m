//
//  AddBalanceListDetailViewController.m
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/09.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import "AddBalanceListDetailViewController.h"
#import "MoneyTableDataManager.h"

@interface AddBalanceListDetailViewController ()

@end

@implementation AddBalanceListDetailViewController

static int viewMode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (viewMode == 1) {
        self.addBalanceNavigationItem.title = @"入出金の編集";
    }
    
    self.wholeScrollView.backgroundColor = [UIColor colorWithRed:0.88f green:0.90f blue:0.99f alpha:1];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.70f green:1.00f blue:0.40f alpha:1]];
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 22)];
    statusBarView.backgroundColor  =  [UIColor colorWithRed:0.70f green:1.00f blue:0.40f alpha:1];
    [self.view addSubview:statusBarView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSoftKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.amountOfMoneyTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    viewMode = 0;
}

- (void)closeSoftKeyboard {
    [self.view endEditing: YES];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    CGPoint scrollPoint = CGPointMake(0.0,150.0);
    [self.wholeScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.wholeScrollView setContentOffset:CGPointZero animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (int)getViewMode{
    return viewMode;
}

+ (void)setViewMode:(int)useViewMode
{
    viewMode = useViewMode;
}

@end
