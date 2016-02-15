# NTAlertView
Drop-in replacement for UIAlertView with high customization capabilities

![alt tag](https://raw.githubusercontent.com/narcistabarasi/NTAlertView/master/screenshots/Simulator%20Screen%20Shot%2015%20Feb%202016%2019.47.10.png)
![alt tag](https://raw.githubusercontent.com/narcistabarasi/NTAlertView/master/screenshots/Simulator%20Screen%20Shot%2015%20Feb%202016%2019.47.43.png)
![alt tag](https://raw.githubusercontent.com/narcistabarasi/NTAlertView/master/screenshots/Simulator%20Screen%20Shot%2015%20Feb%202016%2019.49.22.png)
![alt tag](https://raw.githubusercontent.com/narcistabarasi/NTAlertView/master/screenshots/Simulator%20Screen%20Shot%2015%20Feb%202016%2019.49.29.png)
![alt tag](https://raw.githubusercontent.com/narcistabarasi/NTAlertView/master/screenshots/Simulator%20Screen%20Shot%2015%20Feb%202016%2019.56.28.png)



### Installation:
Drag and drop "NTAlertView.h" and "NTAlertView.m" to your project and you're ready to go.

### How to use:

* First of all, don't forget to import the header
```objective-c
#import "NTAlertView.h"
```
* You can create an alert by calling the exact same methods as you do on UIAlertView
```objective-c
NTAlertView *alert =  [[NTAlertView alloc] initWithTitle:@"Title" message:@"Message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
[alert show];
```
* If you want to take actions based on what button the user taps, implement NTAlertViewDelegate 
```objective-c
- (void)alertView:(NTAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)alertViewWillDismiss:(NTAlertView *)alertView;
- (void)alertViewDidShow:(NTAlertView *)alertView;
```

* Also, you can add your own custom view for the body of the alert:

You shouldn't use initWithFrame: for your custom views (only autolayout supported)

It is mandatory to set a constraint with a fixed height for your custom view
```objective-c
NTAlertView *alert =  [[NTAlertView alloc] initWithTitle:@"Title" message:@"This is a demo of NTAlertView with UIImageView as a custom view" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Button 1",nil];
[alert setBlurType:NTBackGroundBlurTypeDark];
            
UIImageView *imageView = [UIImageView new];
imageView.translatesAutoresizingMaskIntoConstraints = NO;
imageView.image = [UIImage imageNamed:@"landscape.jpeg"];
imageView.contentMode = UIViewContentModeScaleAspectFit;
[alert.customView addSubview:imageView];
[alert.customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(==150)]|" options:0 metrics:nil views:@{@"imageView":imageView}]];
[alert.customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[imageView]-10-|" options:0 metrics:nil views:@{@"imageView":imageView}]];
[alert show];
```
