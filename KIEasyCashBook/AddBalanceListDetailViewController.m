//
//  AddBalanceListDetailViewController.m
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/09.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import "AddBalanceListDetailViewController.h"

@interface AddBalanceListDetailViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *plusOrMinusPickerView;

@end

@implementation AddBalanceListDetailViewController
{
    NSArray* plusOrMinusArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.plusOrMinusPickerView.delegate = self;
    
    plusOrMinusArray = [NSArray arrayWithObjects:@"+", @"-", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ピッカービューのコンポーネント（行）の数を返す *必須
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)plusOrMinusPickerView {
    return 1;
}

// 行数を返す例　*必須
- (NSInteger) pickerView: (UIPickerView*)pView numberOfRowsInComponent:(NSInteger) component {
    int cnt = [plusOrMinusArray count];
    return cnt;
}

// ピッカービューの行のタイトルを返す
- (NSString*)pickerView: (UIPickerView*) pView titleForRow:(NSInteger) row forComponent:(NSInteger)componet
{
    //n行目に配列のn番目の要素を設定
    return [plusOrMinusArray objectAtIndex:row];
}

//選択されたピッカービューを取得
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //0列目の選択している行番号を取得
    NSInteger selectedRow = [pickerView selectedRowInComponent:0];
    NSLog(@"%d", selectedRow);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
