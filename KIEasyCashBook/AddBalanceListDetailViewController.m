//
//  AddBalanceListDetailViewController.m
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/09.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import "AddBalanceListDetailViewController.h"

@interface AddBalanceListDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *amountOfMoneyTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *wholeScrollView;

@end

@implementation AddBalanceListDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSoftKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.amountOfMoneyTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    [self registerForKeyboardNotifications];
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

@end
