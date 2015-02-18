//
//  AddBalanceListModalViewController.m
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/09.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import "AddBalanceListModalViewController.h"

@interface AddBalanceListModalViewController ()

@end

@implementation AddBalanceListModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.88f green:0.90f blue:0.99f alpha:1];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.70f green:1.00f blue:0.40f alpha:1]];
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 22)];
    statusBarView.backgroundColor  =  [UIColor colorWithRed:0.70f green:1.00f blue:0.40f alpha:1];
    [self.view addSubview:statusBarView];
    
    self.addBalanceListAmountOfMoneyTextField.keyboardType = UIKeyboardTypeNumberPad;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
