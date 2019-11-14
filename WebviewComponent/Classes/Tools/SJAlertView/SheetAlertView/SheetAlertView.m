//
//  SheetAlertView.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/11/8.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "SheetAlertView.h"

static const CGFloat kRowHeight = 48.0f;
static const CGFloat kRowLineHeight = 0.5f;
static const CGFloat kSeparatorHeight = 6.0f;
static const CGFloat kTitleFontSize = 13.0f;
static const CGFloat kButtonTitleFontSize = 18.0f;

@implementation SheetAlertView
@synthesize passMsg;

- (UIView *)produceSheetAlertViewWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles {
    UIView *sheetAlert = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 0)];
     sheetAlert.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    sheetAlert.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    CGFloat actionSheetHeight = 0;
    UIImage *normalImage = [self imageWithColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    UIImage *highlightedImage = [self imageWithColor:[UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f]];
    if (title && title.length > 0)
    {
        actionSheetHeight += kRowLineHeight;
        
        CGFloat titleHeight = ceil([title boundingRectWithSize:CGSizeMake(sheetAlert.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kTitleFontSize]} context:nil].size.height) + 15*2;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, actionSheetHeight, sheetAlert.frame.size.width, titleHeight)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        titleLabel.textColor = [UIColor colorWithRed:135.0f/255.0f green:135.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
        titleLabel.numberOfLines = 0;
        [sheetAlert addSubview:titleLabel];
        
        actionSheetHeight += titleHeight;
    }
    if (destructiveButtonTitle && destructiveButtonTitle.length > 0)
    {
        actionSheetHeight += kRowLineHeight;
        
        UIButton *destructiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        destructiveButton.frame = CGRectMake(0, actionSheetHeight, sheetAlert.frame.size.width, kRowHeight);
        destructiveButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        destructiveButton.tag = -1;
        destructiveButton.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
        [destructiveButton setTitle:destructiveButtonTitle forState:UIControlStateNormal];
        [destructiveButton setTitleColor:[UIColor colorWithRed:230.0f/255.0f green:66.0f/255.0f blue:66.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [destructiveButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [destructiveButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        [destructiveButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [sheetAlert addSubview:destructiveButton];
        
        actionSheetHeight += kRowHeight;
    }
    if (otherButtonTitles && [otherButtonTitles count] > 0)
    {
        for (int i = 0; i < otherButtonTitles.count; i++)
        {
            actionSheetHeight += kRowLineHeight;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, actionSheetHeight, sheetAlert.frame.size.width, kRowHeight);
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            button.tag = i+1;
            button.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
            [button setTitle:otherButtonTitles[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [button setBackgroundImage:normalImage forState:UIControlStateNormal];
            [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [sheetAlert addSubview:button];
            
            actionSheetHeight += kRowHeight;
        }
    }
    if (cancelButtonTitle && cancelButtonTitle.length > 0)
    {
        actionSheetHeight += kSeparatorHeight;
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, actionSheetHeight, sheetAlert.frame.size.width, kRowHeight);
        cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cancelButton.tag = 0;
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
        [cancelButton setTitle:cancelButtonTitle ?: @"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [sheetAlert addSubview:cancelButton];
        
        actionSheetHeight += kRowHeight;
    }
    CGFloat safeAreaH = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) == 20 ? 0 : 34;
    sheetAlert.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, actionSheetHeight+safeAreaH);

    return sheetAlert;
}

- (void)buttonClicked:(UIButton *)button {
    if (button.tag == 0) {
        self.passMsg = @(-1);
    }else if (button.tag == -1) {
        self.passMsg = @(0);
    }else {
        self.passMsg = @(button.tag);
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
