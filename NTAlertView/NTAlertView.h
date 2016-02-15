/*
 Copyright 2016 Narcis Tabarasi
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


#import <UIKit/UIKit.h>

#ifndef RGB
#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#endif

//Background blur types
typedef NS_ENUM(NSInteger, NTBackGroundBlurType) {
    NTBackGroundBlurTypeDark = 0,
    NTBackGroundBlurTypeLight,
    NTBackGroundBlurTypeExtraLight,
    NTBackGroundBlurTypeNone
};


@class NTAlertView;
@protocol NTAlertViewDelegate <NSObject>
@optional
- (void)alertView:(NTAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)alertViewWillDismiss:(NTAlertView *)alertView;
- (void)alertViewDidShow:(NTAlertView *)alertView;
- (BOOL)canDismissAlert;
@end


@interface NTAlertView : UIView

/**
 Space left/right between the alert and the edge of the screen
 */
@property (nonatomic, retain) NSNumber *horizontalPadding;

/**
 Corner radius will be apply on the alert itself and on the buttons
 */
@property (nonatomic, retain) NSNumber *cornerRadius;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, retain) NSNumber *borderWidth;

/**
 Font used for "title" and buttons
 */
@property (nonatomic, retain) UIFont *boldFont; // font used for title and buttons
/**
 Font used for "message"
 */
@property (nonatomic, retain) UIFont *normalFont; // font used for message
/**
 View that can contain custom elements for the alert. All the views will be placed between the "message" and the buttons.
 Each subview must specify an autolayout constraint for height.
 Don't use "initWithFrame:" for your subviews
 */
@property (nonatomic, readonly) UIView *customView;
/**
 Type of blur to be applied for the background that surrounds the alert. (for iOS 7, no blur will be applied)
 */
@property (nonatomic) NTBackGroundBlurType blurType;
/**
 Initialize the alert
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id <NTAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
/**
 Show the alert
 */
- (void)show;
/**
 Dismiss the alert
 */
- (void)dismiss;

@end
