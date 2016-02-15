//
//  ViewController.m
//  NTAlertViewExample
//
//  Created by Narcis Tabarasi on 15/02/16.
//  Copyright © 2016 Narcis Tabarasi. All rights reserved.
//

#import "ViewController.h"
#import "NTAlertView.h"

@interface ViewController () <NTAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NTAlertView";
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ident = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Example %ld",indexPath.row+1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            NTAlertView *alert =  [[NTAlertView alloc] initWithTitle:@"Title" message:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin non commodo leo. Duis tellus dui, posuere et nibh ut, varius tristique tellus." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert setBlurType:NTBackGroundBlurTypeDark];
            [alert show];
            break;
        }
        case 1: {
            NTAlertView *alert =  [[NTAlertView alloc] initWithTitle:@"Title" message:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin non commodo leo. Duis tellus dui, posuere et nibh ut, varius tristique tellus." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Button 1",nil];
            [alert setBlurType:NTBackGroundBlurTypeDark];
            [alert show];
            break;
        }
        case 2: {
            NTAlertView *alert =  [[NTAlertView alloc] initWithTitle:@"Title" message:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin non commodo leo. Duis tellus dui, posuere et nibh ut, varius tristique tellus." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Button 1",@"Button 2",@"Button 3",nil];
            [alert setBlurType:NTBackGroundBlurTypeDark];
            [alert show];
            break;
        }
        case 3: {
            NTAlertView *alert =  [[NTAlertView alloc] initWithTitle:@"Title" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Button 1",nil];
            [alert setBlurType:NTBackGroundBlurTypeDark];
            //    alert.borderWidth = @1;
            
            UITextField *field = [UITextField new];
            field.translatesAutoresizingMaskIntoConstraints = NO;
            field.placeholder = @"Example Textfield";
            [alert.customView addSubview:field];
            [alert.customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[field(==40)]|" options:0 metrics:nil views:@{@"field":field}]];
            [alert.customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[field]-10-|" options:0 metrics:nil views:@{@"field":field}]];
            
            [alert show];
            break;
        }
        case 4: {
            NTAlertView *alert =  [[NTAlertView alloc] initWithTitle:@"Title" message:@"This is a demo of NTAlertView with UIImageView as a custom view" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Button 1",nil];
            [alert setBlurType:NTBackGroundBlurTypeDark];
            //    alert.borderWidth = @1;
            
            UIImageView *imageView = [UIImageView new];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.image = [UIImage imageNamed:@"landscape.jpeg"];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [alert.customView addSubview:imageView];
            [alert.customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(==150)]|" options:0 metrics:nil views:@{@"imageView":imageView}]];
            [alert.customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[imageView]-10-|" options:0 metrics:nil views:@{@"imageView":imageView}]];
            
            [alert show];

            break;
        }
        default:
            break;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
