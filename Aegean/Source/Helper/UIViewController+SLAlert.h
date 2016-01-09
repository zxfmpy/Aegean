//
//  UIViewController+SLAlert.h
//  UIViewControllerAlert
//
//  Created by 李凌峰 on 11/15/15.
//  Copyright © 2015 SoulBeats. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AlertActionHandler)();

@interface UIViewController (SLAlert)
@property (nonatomic, assign) BOOL alertShowing;

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle;

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
       cancelActionHandler:(AlertActionHandler)cancelActionHandler;

- (void)showAlertWithTitle:(NSString *)title 
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
       cancelActionHandler:(AlertActionHandler)cancelActionHandler
    destructiveButtonTitle:(NSString *)destructiveButtonTitle
  destructiveActionHandler:(AlertActionHandler)destructiveActionHandler;

- (void)showAlertWithTitle:(NSString *)title 
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
       cancelActionHandler:(AlertActionHandler)cancelActionHandler
        anotherButtonTitle:(NSString *)anotherButtonTitle
      anotherActionHandler:(AlertActionHandler)anotherActionHandler;

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
       cancelActionHandler:(AlertActionHandler)cancelActionHandler
    destructiveButtonTitle:(NSString *)destructiveButtonTitle
  destructiveActionHandler:(AlertActionHandler)destructiveActionHandler
         otherButtonTitles:(NSArray *)otherButtonTitles
       otherActionHandlers:(NSArray *)otherActionHandlers;

@end
