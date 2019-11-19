//
//  VPTextField.h
//  VPInterfaceControllerDemo
//
//  Created by peter on 2018/6/6.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VPTextFieldSelectedDelegate <NSObject>

- (void)dataArraySelectedIndex:(NSInteger)index target:(id)target;

@end

@interface VPTextField : UITextField

@property (nonatomic, assign) NSInteger showCellCount;
@property (nonatomic, strong) NSArray<NSString *> *dataArray;

@property (nonatomic) UIView *holdView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<VPTextFieldSelectedDelegate> selectedDelegate;

@property (nonatomic, assign) BOOL isDevApp;

@end
