//
//  BalaneListDetailViewController.h
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/09.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BalanceListDetailViewController : UIViewController<UIScrollViewDelegate>
{
    NSString *tableName;
    int headingHeight;
}

@property NSString *tableName;
@property int headingHeight;
@end
