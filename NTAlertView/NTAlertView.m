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


#import "NTAlertView.h"


#define HORIZONTAL_PADDING @40
#define TITLE_HEIGHT @40
#define CORNER_RADIUS @3
#define DEFAULT_BOLD_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:16]
#define DEFAULT_NORMAL_FONT [UIFont fontWithName:@"HelveticaNeue" size:15]
#define BLUR_TYPE 0



@interface NTAlertView ()
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *cancelButtonTitle;
@property (nonatomic, retain) NSMutableArray *otherButtonTitles;
@property (nonatomic) id <NTAlertViewDelegate> delegate;
@property (nonatomic, retain) UIScreen *screen;

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIView *contentViewClone;

@property (nonatomic, retain) UIView *backgroundView;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) NSMutableArray *buttons;

@end

@implementation NTAlertView
@synthesize customView;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id <NTAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    self = [super init];
    if (self) {
        
        self.title = title;
        self.message = message;
        self.delegate = delegate;
        self.cancelButtonTitle = cancelButtonTitle;
        
        NSMutableArray *arguments=[NSMutableArray new];
        id eachObject;
        va_list argumentList;
        if (otherButtonTitles)
        {
            [arguments addObject: otherButtonTitles];
            va_start(argumentList, otherButtonTitles);
            while ((eachObject = va_arg(argumentList, id)))
            {
                [arguments addObject: eachObject];
            }
            va_end(argumentList);
        }
        self.otherButtonTitles = arguments;
        
        [self setupFrame];
        self.backgroundColor = [UIColor clearColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (UIFont *)boldFont {
    if (!_boldFont) {
        _boldFont = DEFAULT_BOLD_FONT;
    }
    return _boldFont;
}

- (UIFont *)normalFont{
    if (!_normalFont) {
        _normalFont = DEFAULT_NORMAL_FONT;
    }
    return _normalFont;
}

- (NSNumber *)cornerRadius {
    if (!_cornerRadius) {
        _cornerRadius = CORNER_RADIUS;
    }
    return _cornerRadius;
}

- (NSNumber *)horizontalPadding {
    if (!_horizontalPadding) {
        _horizontalPadding = HORIZONTAL_PADDING;
    }
    return _horizontalPadding;
}

- (UIColor *)borderColor {
    if (!_borderColor) {
        _borderColor = [UIColor whiteColor];//RGB(0x34495e);
    }
    return _borderColor;
}

- (UIView *)customView {
    if (!customView) {
        customView = ({
            UIView *vv = [UIView new];
            vv.translatesAutoresizingMaskIntoConstraints = NO;
            vv;
        });
    }
    return customView;
}

- (void)setupFrame {
     self.screen =  [UIScreen mainScreen];
    [self setFrame:self.screen.bounds];
}

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];
    
    [self setupContentFrame];
    [self blurBackgroundWithType:self.blurType];
    
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardIfVisible)];
    self.backgroundView.userInteractionEnabled = YES;
    [self.backgroundView addGestureRecognizer:tapG];

    [self animateShow];
}

- (void)dismiss {
    [self dismissKeyboardIfVisible];
    [self animateHide];
}

- (void)dismissKeyboardIfVisible {
    [[self findFirstResponderBeneathView:self] resignFirstResponder];
}

- (void)animateShow {
    [UIView animateWithDuration:0.2 animations:^{
        [self.contentView setAlpha:1.0];
        [self.contentViewClone setAlpha:1.0];
        if ([UIBlurEffect class]) {
            [self.backgroundView setAlpha:1.0];
        }
        else {
            [self.backgroundView setAlpha:0.75];
        }

    }];
    [self configureIncomingAnimation];
}

- (void)animateHide {
    [self configureOutgoingAnimation];
    [UIView animateWithDuration:0.2 animations:^{
        [self.contentView setAlpha:0.0];
        [self.contentViewClone setAlpha:0.0];
        [self.backgroundView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setupContentFrame {
    
    [self setupWrapper];
    
    NSMutableDictionary *metrics = [NSMutableDictionary new];
    metrics[@"horPadding"] = self.horizontalPadding;
    
    NSMutableDictionary *views = [NSMutableDictionary new];
    
    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = self.title;
        label.font = self.boldFont;
        label;
    });
    UIView *titleWrapper = ({
        UIView *v = [UIView new];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        v.backgroundColor = RGB(0xebebeb);
        v.clipsToBounds = YES;
        v;
    });
    [self.contentView addSubview:titleWrapper];
    [titleWrapper addSubview:self.titleLabel];
    [titleWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[title]-10-|" options:0 metrics:nil views:@{@"title":self.titleLabel}]];
    [titleWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]|" options:0 metrics:nil views:@{@"title":self.titleLabel}]];
    
    
    views[@"titleWrapper"] = titleWrapper;
    
    if (self.title.length == 0) {
        metrics[@"titleHeight"] = @0;
    }
    else {
        metrics[@"titleHeight"] = TITLE_HEIGHT;
    }
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleWrapper]|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleWrapper(==titleHeight)]" options:0 metrics:metrics views:views]];
    
    self.messageLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.text = self.message;
        label.font = self.normalFont;
        label;
    });
    UIView *messageWrapper = ({
        UIView *v = [UIView new];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        v.backgroundColor = [UIColor whiteColor];
        v;
    });
    [self.contentView addSubview:messageWrapper];
    [messageWrapper addSubview:self.messageLabel];
    [messageWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[message]-10-|" options:0 metrics:nil views:@{@"message":self.messageLabel}]];
    [messageWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[message]|" options:0 metrics:nil views:@{@"message":self.messageLabel}]];
    
    [self.contentView addSubview:messageWrapper];
    views[@"messageWrapper"] = messageWrapper;
    
    if (self.message.length > 0) {
        metrics[@"messagePadding"] = @5;
    }
    else {
        metrics[@"messagePadding"] = @0;
    }
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[messageWrapper]|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleWrapper]-messagePadding-[messageWrapper]" options:0 metrics:metrics views:views]];
    
    
    [self.contentView addSubview:self.customView];
    views[@"customView"] = self.customView;
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[messageWrapper]-messagePadding-[customView]" options:0 metrics:metrics views:views]];
    
    
    UIButton *cancelButton = ({
        UIButton *btn = [UIButton new];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setBackgroundColor:RGB(0xee593b)];
        [btn setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:self.boldFont];
        btn.layer.cornerRadius = [self.cornerRadius floatValue];
        btn.tag = 100;
        [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.contentView addSubview:cancelButton];
    views[@"cancelButton"] = cancelButton;
    
    
    
    if (self.otherButtonTitles.count == 0) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[cancelButton]-10-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[customView]-5-[cancelButton(==40)]-10-|" options:0 metrics:metrics views:views]];
    }
    else if (self.otherButtonTitles.count == 1) {
        UIButton *button = ({
            UIButton *btn = [UIButton new];
            btn.translatesAutoresizingMaskIntoConstraints = NO;
            [btn setBackgroundColor:RGB(0x0977aa)];
            [btn setTitle:self.otherButtonTitles[0] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn.titleLabel setFont:self.boldFont];
            btn.layer.cornerRadius = [self.cornerRadius floatValue];
            btn.tag = 101;
            [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [self.contentView addSubview:button];
        views[@"button"] = button;
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[cancelButton]-5-[button(==cancelButton)]-10-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[customView]-5-[cancelButton(==40)]-10-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[customView]-5-[button(==40)]-10-|" options:0 metrics:metrics views:views]];
    }
    else {
        
        UIButton *previousButton = nil;
        for (int i=0; i<self.otherButtonTitles.count; i++) {
            
            NSString *string = self.otherButtonTitles[i];
            UIButton *button = ({
                UIButton *btn = [UIButton new];
                btn.translatesAutoresizingMaskIntoConstraints = NO;
                [btn setBackgroundColor:RGB(0x0977aa)];
                [btn setTitle:string forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn.titleLabel setFont:self.boldFont];
                btn.layer.cornerRadius = [self.cornerRadius floatValue];
                btn.tag = 100 + i + 1;
                [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                btn;
            });
            [self.contentView addSubview:button];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[button]-10-|" options:0 metrics:nil views:@{@"button":button}]];
            if (!previousButton) {
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[customView]-5-[button(==40)]" options:0 metrics:nil views:@{@"button":button, @"customView":self.customView}]];
            }
            else {
                [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-5-[button(==prev)]" options:0 metrics:nil views:@{@"button":button, @"prev":previousButton}]];
            }
            previousButton = button;
        }
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[cancelButton]-10-|" options:0 metrics:metrics views:@{@"cancelButton":cancelButton}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-5-[cancelButton(==prev)]-10-|" options:0 metrics:metrics views:@{@"cancelButton":cancelButton, @"prev":previousButton}]];
    }
}

- (void)setupWrapper {
    
    
    self.contentViewClone = [UIView new];
    self.contentViewClone.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentViewClone.backgroundColor = [UIColor whiteColor];
    self.contentViewClone.alpha = 0.0f;
    self.contentViewClone.layer.masksToBounds = NO;
    self.contentViewClone.layer.shadowOffset = CGSizeMake(0, 0);
    self.contentViewClone.layer.shadowRadius = 15;
    self.contentViewClone.layer.shadowOpacity = 0.5;
    
    self.contentViewClone.layer.cornerRadius = [self.cornerRadius floatValue];
    self.contentViewClone.layer.borderWidth = [self.borderWidth floatValue];
    self.contentViewClone.layer.borderColor = self.borderColor.CGColor;
    [self addSubview:self.contentViewClone];
    
    self.contentView = [UIView new];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.alpha = 0.0f;
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = [self.cornerRadius floatValue];
    self.contentView.layer.borderWidth = [self.borderWidth floatValue];
    self.contentView.layer.borderColor = self.borderColor.CGColor;
    [self addSubview:self.contentView];
    
    UIView *separator1 = ({
        UIView *v = [UIView new];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        v;
    });
    
    UIView *separator2 = ({
        UIView *v = [UIView new];
        v.translatesAutoresizingMaskIntoConstraints = NO;
        v;
    });
    [self addSubview:separator1];
    [self addSubview:separator2];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horPadding-[content]-horPadding-|" options:0 metrics:@{@"horPadding":self.horizontalPadding} views:@{@"content":self.contentView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sep1][content][sep2(==sep1)]|" options:0 metrics:nil views:@{@"content":self.contentView, @"sep1":separator1, @"sep2":separator2}]];
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horPadding-[content]-horPadding-|" options:0 metrics:@{@"horPadding":self.horizontalPadding} views:@{@"content":self.contentViewClone}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sep1][content][sep2(==sep1)]|" options:0 metrics:nil views:@{@"content":self.contentViewClone, @"sep1":separator1, @"sep2":separator2}]];
}

- (void)blurBackgroundWithType:(NTBackGroundBlurType)blurType {
    
    UIVisualEffect *blurEffect;
    
    switch (blurType) {
        case NTBackGroundBlurTypeDark:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            break;
        case NTBackGroundBlurTypeLight:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            break;
        case NTBackGroundBlurTypeExtraLight:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            break;
        case NTBackGroundBlurTypeNone:
            return;
            break;
        default:
            break;
    }
    self.backgroundView = [[UIView alloc] initWithFrame:self.screen.bounds];
    if (blurEffect) {
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [visualEffectView setFrame:self.backgroundView.bounds];
        [self.backgroundView addSubview:visualEffectView];
    }
    else {
        self.backgroundView.backgroundColor = [UIColor blackColor];
    }
    [self.backgroundView setAlpha:0.0];
    [self insertSubview:self.backgroundView belowSubview:self.contentViewClone];
}


- (void)configureIncomingAnimation {
    
    self.contentView.transform = CGAffineTransformMakeScale(0.4, 0.4);
    self.contentViewClone.transform = CGAffineTransformMakeScale(0.4, 0.4);
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentViewClone.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(alertViewDidShow:)]) {
            [self.delegate alertViewDidShow:self];
        }
    }];
}



- (void)configureOutgoingAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        self.contentViewClone.transform = CGAffineTransformMakeScale(0.75, 0.75);
    } completion:nil];
}

- (void)buttonTapped:(id)sender {
    UIButton *button = sender;
    int buttonIndex = (int)button.tag - 100;
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:buttonIndex];
    }
    if ([self.delegate respondsToSelector:@selector(alertViewWillDismiss:)]) {
        [self.delegate alertViewWillDismiss:self];
    }
    if (buttonIndex == 0) {
        [self dismiss];
    }
    
    if ([self.delegate respondsToSelector:@selector(canDismissAlert)]) {
        if ([self.delegate canDismissAlert]) {
            [self dismiss];
        }
    }
    else {
        [self dismiss];
    }
}

- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary* keyboardInfo = [note userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];

    float keyBoardHeight = keyboardFrameBeginRect.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.center = CGPointMake(self.contentView.center.x, self.contentView.center.y-keyBoardHeight/2);
        self.contentViewClone.center = self.contentView.center;
    }];
}

- (void)keyboardWillHide:(NSNotification *)note {
    [[self findFirstResponderBeneathView:self] resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.center = self.center;
        self.contentViewClone.center = self.contentView.center;
    }];
}

- (UIView*)findFirstResponderBeneathView:(UIView*)view {
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder]) {
            return childView;
        }
        UIView *result = [self findFirstResponderBeneathView:childView];
        if (result) return result;
    }
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
