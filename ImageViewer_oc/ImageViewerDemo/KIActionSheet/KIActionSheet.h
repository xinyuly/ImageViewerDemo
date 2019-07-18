//
//  KIActionSheet.h
//  KIActionSheet
//
//  Created by apple on 16/8/15.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KIActionSheet;
typedef void(^KIActionSheetClickedButtonAtIndexBlock)       (KIActionSheet *actionSheet, NSInteger buttonIndex);
typedef void(^KIActionSheetCancelBlock)                     (KIActionSheet *actionSheet);
typedef void(^KIActionSheetWillPresentBlock)                (KIActionSheet *actionSheet);
typedef void(^KIActionSheetDidPresentBlock)                 (KIActionSheet *actionSheet);
typedef void(^KIActionSheetWillDismissWithButtonIndexBlock) (KIActionSheet *actionSheet, NSInteger buttonIndex);
typedef void(^KIActionSheetDidDismissWithButtonIndexBlock)  (KIActionSheet *actionSheet, NSInteger buttonIndex);


@interface KIActionSheet : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, readonly) NSInteger numberOfButtons;
@property (nonatomic, readonly) NSInteger cancelButtonIndex;
@property (nonatomic, readonly) NSInteger destructiveButtonIndex;

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

// 添加一个 Button， 如果 Title 已经存在，或者添加失败，则会返回  -1;
- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

- (void)setCancelButtonTitle:(NSString *)title;
- (void)setDestructiveButtonTitle:(NSString *)title;

- (void)show;

- (void)dismiss;

- (void)setClickedButtonAtIndexBlock:(KIActionSheetClickedButtonAtIndexBlock)block;
- (void)setCancelBlock:(KIActionSheetCancelBlock)block;
- (void)setWillPresentBlock:(KIActionSheetWillPresentBlock)block;
- (void)setDidPresentBlock:(KIActionSheetDidPresentBlock)block;
- (void)setWillDismissWithButtonIndexBlock:(KIActionSheetWillDismissWithButtonIndexBlock)block;
- (void)setDidDismissWithButtonIndexBlock:(KIActionSheetDidDismissWithButtonIndexBlock)block;

@end
