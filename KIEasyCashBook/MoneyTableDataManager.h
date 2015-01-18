//
//  MoneyTableDataManager.h
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/01/19.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MoneyTableDataManager : NSObject
{
    NSManagedObjectContext* _managedObjectContext;
    NSManagedObjectModel* _managedObjectModel;
    NSPersistentStoreCoordinator* _persistentStoreCoordinator;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (MoneyTableDataManager*)sharedMoneyTableManager;

@end
