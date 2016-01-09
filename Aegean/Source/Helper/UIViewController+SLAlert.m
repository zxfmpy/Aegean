//
//  UIViewController+SLAlert.m
//  UIViewControllerAlert
//
//  Created by 李凌峰 on 11/15/15.
//  Copyright © 2015 SoulBeats. All rights reserved.
//

#import "UIViewController+SLAlert.h"
#import <objc/runtime.h>
#import "UIAlertView+Blocks.h"

@implementation UIViewController (SLAlert)

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle {
    [self showAlertWithTitle:title message:message
           cancelButtonTitle:cancelButtonTitle
         cancelActionHandler:nil
      destructiveButtonTitle:nil
    destructiveActionHandler:nil
           otherButtonTitles:nil
         otherActionHandlers:nil];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
       cancelActionHandler:(AlertActionHandler)cancelActionHandler {
    [self showAlertWithTitle:title
                     message:message
           cancelButtonTitle:cancelButtonTitle
         cancelActionHandler:cancelActionHandler
      destructiveButtonTitle:nil
    destructiveActionHandler:nil
           otherButtonTitles:nil
         otherActionHandlers:nil];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
       cancelActionHandler:(AlertActionHandler)cancelActionHandler
    destructiveButtonTitle:(NSString *)destructiveButtonTitle
  destructiveActionHandler:(AlertActionHandler)destructiveActionHandler {
    [self showAlertWithTitle:title
                     message:message
           cancelButtonTitle:cancelButtonTitle
         cancelActionHandler:cancelActionHandler
      destructiveButtonTitle:destructiveButtonTitle
    destructiveActionHandler:destructiveActionHandler
           otherButtonTitles:nil
         otherActionHandlers:nil];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
       cancelActionHandler:(AlertActionHandler)cancelActionHandler
        anotherButtonTitle:(NSString *)anotherButtonTitle
      anotherActionHandler:(AlertActionHandler)anotherActionHandler {
    NSArray *otherButtonTitles = nil;
    if (anotherButtonTitle) {
        otherButtonTitles = @[anotherButtonTitle];
    }
    NSArray *otherActionHandlers = nil;
    if (anotherActionHandler) {
        otherActionHandlers = @[anotherActionHandler];
    } else {
        otherActionHandlers = @[[NSNull null]];
    }
    [self showAlertWithTitle:title
                     message:message
           cancelButtonTitle:cancelButtonTitle
         cancelActionHandler:cancelActionHandler
      destructiveButtonTitle:nil
    destructiveActionHandler:nil
           otherButtonTitles:otherButtonTitles
         otherActionHandlers:otherActionHandlers];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
       cancelActionHandler:(AlertActionHandler)cancelActionHandler
    destructiveButtonTitle:(NSString *)destructiveButtonTitle
  destructiveActionHandler:(AlertActionHandler)destructiveActionHandler
         otherButtonTitles:(NSArray *)otherButtonTitles
       otherActionHandlers:(NSArray *)otherActionHandlers {
    // 检查该视图控制器是否正在显示中
    if (self.isViewLoaded && self.view.window && !self.alertShowing) {
        if (NSClassFromString(@"UIAlertController")) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            if (destructiveButtonTitle.length) {
                UIAlertAction *destructiveAlertAction = [UIAlertAction actionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    if (destructiveActionHandler) {
                        destructiveActionHandler();
                    }
                    self.alertShowing = NO;
                }];
                [alertController addAction:destructiveAlertAction];
            }
            if (cancelButtonTitle.length) {
                UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    if (cancelActionHandler) {
                        cancelActionHandler();
                    }
                    self.alertShowing = NO;
                }];
                [alertController addAction:cancelAlertAction];
            }
            for (int i = 0; i < otherButtonTitles.count; i++) {
                NSString *otherButtonTitle = [otherButtonTitles objectAtIndex:i];
                if (otherButtonTitle.length) {
                    AlertActionHandler handler = nil;
                    if (i < otherActionHandlers.count && [otherActionHandlers objectAtIndex:i] != [NSNull null]) {
                        handler = (AlertActionHandler)[otherActionHandlers objectAtIndex:i];
                    }
                    UIAlertAction *defaultAlertAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        if (handler) {
                            handler();
                        }
                        self.alertShowing = NO;
                    }];
                    [alertController addAction:defaultAlertAction];
                }
            }
            [self presentViewController:alertController animated:YES completion:NULL];
        } else {
            if (destructiveButtonTitle.length) {
                NSMutableArray *temp = [NSMutableArray arrayWithArray:otherButtonTitles];
                [temp addObject:destructiveButtonTitle];
                otherButtonTitles = [temp copy];
                
                temp = [NSMutableArray arrayWithArray:otherActionHandlers];
                if (destructiveActionHandler) {
                    [temp addObject:destructiveActionHandler];
                } else {
                    [temp addObject:[NSNull null]];
                }
                otherActionHandlers = [temp copy];
            }
            
            UIAlertView *alertView = [UIAlertView showWithTitle:title
                                                        message:message
                                                          style:UIAlertViewStyleDefault
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:otherButtonTitles
                                                       tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                           if (buttonIndex == alertView.cancelButtonIndex) {
                                                               if (cancelActionHandler) {
                                                                   cancelActionHandler();
                                                               }
                                                           } else {
                                                               NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
                                                               NSInteger i = [otherButtonTitles indexOfObject:buttonTitle];
                                                               if (i < otherActionHandlers.count && [otherActionHandlers objectAtIndex:i] != [NSNull null]) {
                                                                   ((AlertActionHandler)[otherActionHandlers objectAtIndex:i])();
                                                               }
                                                           }
                                                           self.alertShowing = NO;
                                                       }];
            [alertView show];
        }
        self.alertShowing = YES;
    }
}

- (BOOL)alertShowing {
    NSNumber *number = objc_getAssociatedObject(self, @selector(alertShowing));
    return [number boolValue];
}

- (void)setAlertShowing:(BOOL)alertShowing {
    NSNumber *number = @(alertShowing);
    objc_setAssociatedObject(self, @selector(alertShowing), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
