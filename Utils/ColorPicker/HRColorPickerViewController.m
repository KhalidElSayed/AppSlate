/*-
 * Copyright (c) 2011 Ryota Hayashi
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD$
 */

#import "HRColorPickerViewController.h"
#import "HRColorPickerView.h"

@implementation HRColorPickerViewController

@synthesize delegate;


+ (HRColorPickerViewController *)colorPickerViewControllerWithColor:(UIColor *)color
{
    return [[HRColorPickerViewController alloc] initWithColor:color fullColor:NO saveStyle:HCPCSaveStyleSaveAlways];
}

+ (HRColorPickerViewController *)cancelableColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[HRColorPickerViewController alloc] initWithColor:color fullColor:NO saveStyle:HCPCSaveStyleSaveAndCancel];
}

+ (HRColorPickerViewController *)fullColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[HRColorPickerViewController alloc] initWithColor:color fullColor:YES saveStyle:HCPCSaveStyleSaveAlways];
}

+ (HRColorPickerViewController *)cancelableFullColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[HRColorPickerViewController alloc] initWithColor:color fullColor:YES saveStyle:HCPCSaveStyleSaveAndCancel];
}



- (id)initWithDefaultColor:(UIColor *)defaultColor
{
    return [self initWithColor:defaultColor fullColor:NO saveStyle:HCPCSaveStyleSaveAlways];
}

- (id)initWithColor:(UIColor*)defaultColor fullColor:(BOOL)fullColor saveStyle:(HCPCSaveStyle)saveStyle

{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _color = defaultColor;
        _fullColor = fullColor;
        _saveStyle = saveStyle;
    }

    // blade
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"setSound" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &myID);

    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    if( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() )
    {
        CGSize size = CGSizeMake(320, 530); // size of view in popover
        self.preferredContentSize = size;

        saveBtn = [[BButton alloc] initWithFrame:CGRectMake(C_GAP, colorPickerView.frame.size.height+4, C_WIDTH, 40)];
        clearBtn = [[BButton alloc] initWithFrame:CGRectMake(C_GAP, colorPickerView.frame.size.height+48, C_WIDTH, 36)];
    }
    else
    {
        saveBtn = [[BButton alloc] initWithFrame:CGRectMake(C_GAP+(C_WIDTH/2), colorPickerView.frame.size.height, C_WIDTH/2-C_GAP, 36)];
        clearBtn = [[BButton alloc] initWithFrame:CGRectMake(C_GAP, colorPickerView.frame.size.height, C_WIDTH/2-C_GAP, 36)];
    }
    [saveBtn setTitle:NSLocalizedString(@"APPLY",@"btn")];
    [saveBtn addTarget:self action:@selector(save:)];
    [self.view addSubview:saveBtn];

    if( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() )
        [clearBtn setTitle:NSLocalizedString(@"TRANSPARENT APPLY",@"btn")];
    else
        [clearBtn setTitle:NSLocalizedString(@"TRANSPARENT",@"TRANSPARENT")];
    [clearBtn addTarget:self action:@selector(clearSave:)];
    [clearBtn setBackgroundColor:[UIColor grayColor]];
    [clearBtn setTitleColor:[UIColor blackColor]];
    [self.view addSubview:clearBtn];
}

// UIPopover Controller 의 크기를 조정해주기 위해서 사용하는 팁 같은 코드.
-(void) viewDidAppear:(BOOL)animated
{
    if( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() )
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_CHANGE_POPOVER object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    HRRGBColor rgbColor;

    if( [_color isEqual:CSCLEAR] )
        RGBColorFromUIColor([UIColor whiteColor], &rgbColor);
    else
        RGBColorFromUIColor(_color, &rgbColor);
    
    HRColorPickerStyle style;
    if (_fullColor) {
        style = [HRColorPickerView fullColorStyle];
    }else{
        style = [HRColorPickerView defaultStyle];
    }
    
    colorPickerView = [[HRColorPickerView alloc] initWithStyle:style defaultColor:rgbColor];

    [self.view addSubview:colorPickerView];
    
//    if (_saveStyle == HCPCSaveStyleSaveAndCancel) {
//        UIBarButtonItem *buttonItem;
//        
//        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
//        self.navigationItem.leftBarButtonItem = buttonItem;
//        
//        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
//        self.navigationItem.rightBarButtonItem = buttonItem;
//    }
    self.title = NSLocalizedString(@"Color Setting", @"Color Setting");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_saveStyle == HCPCSaveStyleSaveAlways) {
        [self save:self];
    }
}

- (void)saveColor:(id)sender{
    [self save];
}

- (void)save
{
//    HRRGBColor rgbColor = [colorPickerView RGBColor];
//    if (self.delegate) { blade is not need this code...
//        [self.delegate setSelectedColor:[UIColor colorWithRed:rgbColor.r green:rgbColor.g blue:rgbColor.b alpha:1.0f]];
//    }

//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
    HRRGBColor rgbColor = [colorPickerView RGBColor];
    // blade
    [self saveValue:[UIColor colorWithRed:rgbColor.r green:rgbColor.g blue:rgbColor.b alpha:1.0f]];

    if( UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM() )
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)clearSave:(id)sender
{
    [self saveValue:CSCLEAR];
}

- (void)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return( (interfaceOrientation == UIInterfaceOrientationPortrait) ||
           (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) );
}

- (void)dealloc{
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // deallocでループを止めることができないので、BeforeDeallocを呼び出して下さい
    //
    /////////////////////////////////////////////////////////////////////////////
    
    [colorPickerView BeforeDealloc];
}

@end
