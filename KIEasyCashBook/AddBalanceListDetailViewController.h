//
//  AddBalanceListDetailViewController.h
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/09.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBalanceListDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *amountOfMoneyTextField;
@property (weak, nonatomic) IBOutlet UITextField *howToUseTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *wholeScrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isIncomeOrOutgoSegmentedControl;

@end