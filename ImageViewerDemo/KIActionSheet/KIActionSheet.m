//
//  KIActionSheet.m
//  KIActionSheet
//
//  Created by apple on 16/8/15.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "KIActionSheet.h"
#import "UITableView+KIActionSheet.h"

#define kActionSheetTitleKey       @"kActionSheetTitleKey"
#define kActionSheetTitleListKey   @"kActionSheetTitleListKey"
#define kActionSheetDestructiveKey @"kActionSheetDestructiveKey"
#define kActionSheetCancelKey      @"kActionSheetCancelKey"

#define kTitleSection       0
#define kTitleListSection   1
#define kDestructiveSection 2
#define kCancelSection      3

////////////////////////////////////////////////////////////////////////////////
@interface UIApplication (KIActionSheet)
@end

@implementation UIApplication (KIActionSheet)
- (UIWindow*)mainApplicationWindowIgnoringWindow:(UIWindow *)ignoringWindow {
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (!window.hidden && window != ignoringWindow) {
            return window;
        }
    }
    return nil;
}
@end

////////////////////////////////////////////////////////////////////////////////
@interface KI_ActionSheetController : UIViewController
@end

@implementation KI_ActionSheetController
- (void)dealloc {
}

- (UIViewController *)mainController {
    UIWindow *mainAppWindow = [[UIApplication sharedApplication] mainApplicationWindowIgnoringWindow:self.view.window];
    UIViewController *topController = mainAppWindow.rootViewController;
    
    while(topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [[self mainController] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate {
    return [[self mainController] shouldAutorotate];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations {
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#endif
    return [[self mainController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self mainController] preferredInterfaceOrientationForPresentation];
}
    
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateSubviewsFrame:self.view.frame];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    CGRect newFrame = self.view.bounds;
    newFrame.size = size;
    [self updateSubviewsFrame:newFrame];
}
    
- (void)updateSubviewsFrame:(CGRect)frame {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[KIActionSheet class]]) {
            [view setFrame:frame];
        }
    }
}

@end

////////////////////////////////////////////////////////////////////////////////
@interface KIActionSheet () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *dataSource;
    
@property(nonatomic) NSInteger cancelButtonIndex;
@property(nonatomic) NSInteger destructiveButtonIndex;

@property (nonatomic, copy) KIActionSheetClickedButtonAtIndexBlock        actionSheetClickedButtonAtIndexBlock;
@property (nonatomic, copy) KIActionSheetCancelBlock                      actionSheetCancelBlock;
@property (nonatomic, copy) KIActionSheetWillPresentBlock                 actionSheetWillPresentBlock;
@property (nonatomic, copy) KIActionSheetDidPresentBlock                  actionSheetDidPresentBlock;
@property (nonatomic, copy) KIActionSheetWillDismissWithButtonIndexBlock  actionSheetWillDismissWithButtonIndexBlock;
@property (nonatomic, copy) KIActionSheetDidDismissWithButtonIndexBlock   actionSheetDidDismissWithButtonIndexBlock;

@end

@implementation KIActionSheet

#pragma mark - Lifecycle
- (void)dealloc {
}

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    if (self = [super init]) {
        NSMutableArray *otherList = [[NSMutableArray alloc] init];
        if (otherButtonTitles) {
            [otherList addObject:otherButtonTitles];
            
            va_list list;
            va_start(list, otherButtonTitles);
            
            NSString *title;
            while(YES) {
                title = va_arg(list, NSString *);
                if (title == nil) {
                    break;
                }
                [otherList addObject:title];
            }
            va_end(list);
        }
        
        NSMutableArray *titleList = [[NSMutableArray alloc] init];
        NSMutableArray *desList = [[NSMutableArray alloc] init];
        NSMutableArray *cancelList = [[NSMutableArray alloc] init];

        if (title != nil && ![[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            [titleList addObject:title];
        }
        if (cancelButtonTitle != nil && ![[cancelButtonTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            [cancelList addObject:cancelButtonTitle];
        }
        if (destructiveButtonTitle != nil && ![[destructiveButtonTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            [desList addObject:destructiveButtonTitle];
        }
        
        [self.dataSource setObject:titleList forKey:kActionSheetTitleKey];
        [self.dataSource setObject:otherList forKey:kActionSheetTitleListKey];
        [self.dataSource setObject:desList forKey:kActionSheetDestructiveKey];
        [self.dataSource setObject:cancelList forKey:kActionSheetCancelKey];
        
        [self ki__initFinished];
    }
    return self;
}

- (void)ki__initFinished {
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kTitleSection) {
        return [[self.dataSource objectForKey:kActionSheetTitleKey] count];
    } else if (section == kTitleListSection) {
        return [[self.dataSource objectForKey:kActionSheetTitleListKey] count];
    } else if (section == kDestructiveSection) {
        return [[self.dataSource objectForKey:kActionSheetDestructiveKey] count];
    } else if (section == kCancelSection) {
        return [[self.dataSource objectForKey:kActionSheetCancelKey] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.dataSource.count > 1 && section == self.dataSource.count-1 && [[self.dataSource objectForKey:kActionSheetCancelKey] count] > 0) {
        if ([[self.dataSource objectForKey:kActionSheetDestructiveKey] count] > 0 || [[self.dataSource objectForKey:kActionSheetTitleListKey] count] > 0) {
            return 8.0f;
        }
    }
    return 0;
}
    
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] init];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kTitleSection || [[self.dataSource objectForKey:kActionSheetTitleKey] count] > 0) {
        return 60.0f;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CELL_IDENTIFIER = @"CELL_IDENTIFIER";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UIView *selectedView = [[UIView alloc] init];
        [selectedView setBackgroundColor:[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0]];
        [cell setSelectedBackgroundView:selectedView];
        
        UIView *view = [[UIView alloc] init];
        [view setBackgroundColor:[UIColor whiteColor]];
        [cell setBackgroundView:view];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    [cell.textLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [cell.textLabel setTextColor:[UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.00]];
    
    NSString *title;
    if (indexPath.section == kTitleSection) {
        title = [[self.dataSource objectForKey:kActionSheetTitleKey] firstObject];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1.00]];
        [cell.textLabel setNumberOfLines:2];
    } else if (indexPath.section == kTitleListSection) {
        NSArray *list = [self.dataSource objectForKey:kActionSheetTitleListKey];
        title = [list objectAtIndex:indexPath.row];
    } else if (indexPath.section == kDestructiveSection) {
        title = [[self.dataSource objectForKey:kActionSheetDestructiveKey] firstObject];
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.92 green:0.25 blue:0.27 alpha:1.00]];
    } else if (indexPath.section == kCancelSection) {
        title = [[self.dataSource objectForKey:kActionSheetCancelKey] firstObject];
    }
    [cell.textLabel setText:title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kTitleSection) {
        return ;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger index = indexPath.row;
    
    if (indexPath.section > kTitleListSection) {
        index += [self tableView:tableView numberOfRowsInSection:kTitleListSection];
    }
    
    if (indexPath.section > kDestructiveSection) {
        index += [self tableView:tableView numberOfRowsInSection:kDestructiveSection];
    }
    
    if (indexPath.section == kCancelSection && self.actionSheetCancelBlock != nil) {
        self.actionSheetCancelBlock(self);
    } else {
        if (self.actionSheetClickedButtonAtIndexBlock != nil) {
            self.actionSheetClickedButtonAtIndexBlock(self, index);
        }
    }

    if (self.actionSheetWillDismissWithButtonIndexBlock != nil) {
        self.actionSheetWillDismissWithButtonIndexBlock(self, index);
    }
    
    __weak KIActionSheet *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self dissmissWithBlock:^{
            if (weakSelf.actionSheetDidDismissWithButtonIndexBlock != nil) {
                weakSelf.actionSheetDidDismissWithButtonIndexBlock(weakSelf, index);
            }
        }];
    });
}

#pragma mark - Methods
- (void)updateBackgroundColorWithAlpha:(CGFloat)alpha {
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:alpha]];
}

- (void)showBackgroundColor {
    [self updateBackgroundColorWithAlpha:0.5f];
}

- (void)hideBackgroundColor {
    [self updateBackgroundColorWithAlpha:0.0f];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (_tableView != nil) {
        CGFloat height = self.tableView.height;
        CGRect tFrame = CGRectMake(0, CGRectGetHeight(self.frame)-height, CGRectGetWidth(self.frame), height);
        [self.tableView setFrame:tFrame];
    }
}
    
- (NSInteger)addButtonWithTitle:(NSString *)title {
    if (title == nil || [title isEqualToString:@""]) {
        return -1;
    }
    NSMutableArray *titleList = [self.dataSource objectForKey:kActionSheetTitleListKey];
    for (NSString *t in titleList) {
        if ([t isEqualToString:title]) {
            return -1;
        }
    }
    
    [titleList addObject:title];
    return titleList.count-1;
}
    
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex {
    NSMutableArray *titleList = [self.dataSource objectForKey:kActionSheetTitleListKey];
    NSArray *desList = [self.dataSource objectForKey:kActionSheetDestructiveKey];
    NSArray *cancelList = [self.dataSource objectForKey:kActionSheetCancelKey];
    
    NSString *title = nil;
    
    if (buttonIndex < titleList.count) {
        title = [titleList objectAtIndex:buttonIndex];
        return title;
    }
    
    NSInteger dx = buttonIndex - (titleList.count - 1);
    if (dx == 1) {
        if (desList.count > 0) {
            title = [desList firstObject];
        } else if (cancelList.count > 0) {
            title = [cancelList firstObject];
        }
        return title;
    }
    
    if (dx == 2) {
        if (desList.count > 0 && cancelList.count > 0) {
            title = [cancelList firstObject];
            return title;
        }
    }
    return title;
}
    
- (void)setCancelButtonTitle:(NSString *)title {
    if (title == nil) {
        [self.dataSource setObject:[@[] mutableCopy] forKey:kActionSheetCancelKey];
    } else {
        [self.dataSource setObject:[@[[title copy]] mutableCopy] forKey:kActionSheetCancelKey];
    }
}
    
- (void)setDestructiveButtonTitle:(NSString *)title {
    if (title == nil) {
        [self.dataSource setObject:[@[] mutableCopy] forKey:kActionSheetDestructiveKey];
    } else {
        [self.dataSource setObject:[@[[title copy]] mutableCopy] forKey:kActionSheetDestructiveKey];
    }
}

- (void)show {
    [self.window setFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    [self.window setHidden:NO];
    [self showInView:self.window.rootViewController.view];
}

- (void)showInView:(UIView *)view {
    if (self.actionSheetWillPresentBlock != nil) {
        self.actionSheetWillPresentBlock(self);
    }
    
    [self setFrame:view.bounds];
    [view addSubview:self];
    
    [self initTableView];
    [self hideBackgroundColor];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self showBackgroundColor];
                         [self showTableView];
                     } completion:^(BOOL finished) {
                         if (self.actionSheetDidPresentBlock != nil) {
                             self.actionSheetDidPresentBlock(self);
                         }
                     }];
}

- (void)initTableView {
    [self addSubview:self.tableView];
    
    CGFloat height = self.tableView.height;
    CGRect tFrame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), height);
    [self.tableView setFrame:tFrame];
}

- (void)showTableView {
    CGFloat height = self.tableView.height;
    CGRect tFrame = CGRectMake(0, CGRectGetHeight(self.frame)-height, CGRectGetWidth(self.frame), height);
    [self.tableView setFrame:tFrame];
}

- (void)dismiss {
    [self dissmissWithBlock:^{
    }];
}

- (void)dissmissWithBlock:(void(^)(void))block {
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self hideBackgroundColor];
                         [self hideTableView];
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         
                         KI_ActionSheetController *controller = (KI_ActionSheetController *)self.window.rootViewController;
                         
                         NSArray *subViews = [controller.view subviews];
                         
                         if (subViews.count == 0) {
                             [self.window removeFromSuperview];
                             [self.window resignKeyWindow];
                             [self.window setHidden:YES];
                         }
                         block();
                     }];
}

- (void)hideTableView {
    CGFloat height = self.tableView.height;
    CGRect tFrame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), height);
    [self.tableView setFrame:tFrame];
}

#pragma mark - Getters & Setters
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:0.0f]];
        [_tableView setBounces:NO];
        [_tableView setShowsVerticalScrollIndicator:NO];
        [_tableView setShowsHorizontalScrollIndicator:NO];
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

- (NSMutableDictionary *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableDictionary alloc] init];
    }
    return _dataSource;
}

- (UIWindow *)window {
    static UIWindow *window = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[UIWindow alloc] init];
        [window setWindowLevel:UIWindowLevelAlert];
        [window setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [window setRootViewController:[[KI_ActionSheetController alloc] init]];
        [window.rootViewController.view setBackgroundColor:[UIColor clearColor]];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
        window.rootViewController.wantsFullScreenLayout = YES;
#endif
    });
    [window setBackgroundColor:[UIColor clearColor]];
    return window;
}
    
- (NSString *)title {
    return [[self.dataSource objectForKey:kActionSheetTitleKey] firstObject];
}

- (void)setTitle:(NSString *)title {
    [self.dataSource setObject:@[[title copy]] forKey:kActionSheetTitleKey];
}

- (void)setClickedButtonAtIndexBlock:(KIActionSheetClickedButtonAtIndexBlock)block {
    [self setActionSheetClickedButtonAtIndexBlock:block];
}

- (void)setCancelBlock:(KIActionSheetCancelBlock)block {
    [self setActionSheetCancelBlock:block];
}

- (void)setWillPresentBlock:(KIActionSheetWillPresentBlock)block {
    [self setActionSheetWillPresentBlock:block];
}

- (void)setDidPresentBlock:(KIActionSheetDidPresentBlock)block {
    [self setActionSheetDidPresentBlock:block];
}

- (void)setWillDismissWithButtonIndexBlock:(KIActionSheetWillDismissWithButtonIndexBlock)block {
    [self setActionSheetWillDismissWithButtonIndexBlock:block];
}

- (void)setDidDismissWithButtonIndexBlock:(KIActionSheetDidDismissWithButtonIndexBlock)block {
    [self setActionSheetDidDismissWithButtonIndexBlock:block];
}
    
- (NSInteger)numberOfButtons {
    NSInteger count = 0;
    for (NSArray *list in self.dataSource.allValues) {
        count += list.count;
    }
    return count;
}

- (NSInteger)cancelButtonIndex {
    NSInteger index = -1;
    if ([[self.dataSource objectForKey:kActionSheetCancelKey] count] > 0) {
        index += [[self.dataSource objectForKey:kActionSheetTitleListKey] count];
        index += [[self.dataSource objectForKey:kActionSheetDestructiveKey] count];
        index += [[self.dataSource objectForKey:kActionSheetCancelKey] count];
    }
    return index;
}

- (NSInteger)destructiveButtonIndex {
    NSInteger index = -1;
    if ([[self.dataSource objectForKey:kActionSheetDestructiveKey] count] > 0) {
        index += [[self.dataSource objectForKey:kActionSheetTitleListKey] count];
        index += [[self.dataSource objectForKey:kActionSheetDestructiveKey] count];
    }
    return index;
}

@end
