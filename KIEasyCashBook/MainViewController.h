//
//  ViewController.h
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/08.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSString *tableName;
    int entireFortune;
    bool isListZeroMode;
    bool isAddFailed;
}
@property NSString *tableName;
@property int entireFortune;
@property bool isListZeroMode;
@property bool isAddFailed;
@end

