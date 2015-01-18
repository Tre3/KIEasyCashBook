//
//  MoneyTable.h
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/18.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MoneyTable : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * reason;
@property (nonatomic, retain) NSNumber * amountOfMoney;

@end
