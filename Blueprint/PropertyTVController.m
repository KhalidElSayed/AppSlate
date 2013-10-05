//
//  PropertyTVController.m
//  AppSlate
//
//  Created by Taehan Kim on 11. 12. 11..
//  Copyright (c) 2011년 ChocolateSoft. All rights reserved.
//
#import <objc/message.h>
#import "CSAppDelegate.h"
#import "PropertyTVController.h"
#import "StringSettingViewController.h"
#import "NumberSettingViewController.h"
#import "HRColorPickerViewController.h"
#import "FontSettingController.h"
#import "AlignSettingController.h"
#import "BoolSettingController.h"
#import "CellSettingController.h"
#import "UIBAlertView.h"

@implementation PropertyTVController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Property", @"Property");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tock" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &tockSoundID);
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    AudioServicesDisposeSystemSoundID(tockSoundID);
}

- (void)viewWillAppear:(BOOL)animated
{
    CGFloat hs = ([[theGear getPropertiesList] count]*46) + ([[theGear getActionList] count]*60) + 40.0;

    if( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() )
    {
        if( hs > 500 ) hs = 500;

        CGSize size = CGSizeMake(320, hs); // size of view in popover
        self.preferredContentSize = size;
    }

    [self.tableView reloadData];

    [super viewWillAppear:animated];
}

// UIPopover Controller 의 크기를 조정해주기 위해서 사용하는 팁 같은 코드.
-(void) viewDidAppear:(BOOL)animated
{
    if( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() )
    {
        CGSize currentSetSizeForPopover = self.preferredContentSize;
        CGSize fakeMomentarySize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
        self.preferredContentSize = fakeMomentarySize;
        self.tableView.backgroundColor = [UIColor clearColor];
    } else {
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma -
// 현재 목록에서 표시할 속성을 가진 객체를 세팅받는다.
-(void) setSelectedGear:(CSGearObject*) obj
{
    theGear = obj;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if( 1 <= [[theGear getActionList] count] )
        return 2;

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch( section ){
        case 0:
            return [[theGear getPropertiesList] count];
        case 1:
            return [[theGear getActionList] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;

    // 1. property list
    if( 0 == indexPath.section ){
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
        }
        NSArray *plist = [theGear getPropertiesList];

        // Configure the cell...
        if( [(plist[indexPath.row])[@"name"] hasPrefix:@">"] ) // This is Action Property
        {
            [cell.textLabel setTextColor:[UIColor grayColor]];
            cell.textLabel.text = [(plist[indexPath.row])[@"name"] substringFromIndex:1];
            cell.imageView.image = [UIImage imageNamed:@"action_icon.png"];
        } else {
            [cell.textLabel setTextColor:[UIColor blackColor]];
            cell.textLabel.text = (plist[indexPath.row])[@"name"];
            cell.imageView.image = nil;
        }
    }
    // 2. action list
    if( 1 == indexPath.section ){
        cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"actionCell"];
            // 연결하거나, 연결 상태를 알려줄 버튼.
            BButton *btn = [[BButton alloc] initWithFrame:CGRectMake(270,15,30,30)];
            [btn.layer setCornerRadius:9.0];
            [cell.contentView setBackgroundColor:[UIColor clearColor]];//CS_RGB(255, 245, 240)];
            [btn.btn addTarget:self action:@selector(unlinkAction:) forControlEvents:UIControlEventTouchUpInside];
            [btn.btn addTarget:self action:@selector(lineAction:) forControlEvents:UIControlEventTouchDown];
            [btn.btn addTarget:self action:@selector(removeLineAction:) forControlEvents:UIControlEventTouchUpOutside];
            [cell.contentView addSubview:btn];
        }
        NSArray *alist = [theGear getActionList];
        NSMutableDictionary *acDic = alist[indexPath.row];

        cell.textLabel.text = acDic[@"name"];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        BButton *aBtn = (cell.contentView.subviews)[0];

        // 연결 정보
        if( nil != ((NSValue*)acDic[@"selector"]).pointerValue )
        {
            NSString *className, *propertyName;
            NSNumber *nsMagicNum = acDic[@"mNum"];
            for( CSGearObject *g in USERCONTEXT.gearsArray )
            {
                if( g.csMagicNum == nsMagicNum.integerValue ){
                    className = [NSStringFromClass([g class]) substringFromIndex:2];
                    break;
                }
            }

            // selector 이름 앞의 3글자 - 즉 'set' 은 빼고 이름을 정보로 표시해줌.
            propertyName = [NSStringFromSelector(((NSValue*)acDic[@"selector"]).pointerValue) substringFromIndex:3];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ :: %@",className, propertyName];
            [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];

            [aBtn.layer setBackgroundColor:[UIColor redColor].CGColor];
            [aBtn setTitle:@"✕"];

            [aBtn.btn setTag:indexPath.row];  // tag 에 액션 목록의 인덱스를 기입한다.
            [aBtn setUserInteractionEnabled:YES];
        }
        else {
            cell.detailTextLabel.text = nil;
            [aBtn.layer setBackgroundColor:[UIColor grayColor].CGColor];
            [aBtn setTitle:@""];

            [aBtn setTag:NSIntegerMax]; // NSIntegerMax 를 없는 숫자로 사용하자.
            [aBtn setUserInteractionEnabled:NO];
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"Property",@"Property");
        case 1:
            return NSLocalizedString(@"Action",@"Action");
        default:
            break;
    }
    return nil;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( 0 == indexPath.section )
        return 46.0;

    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *VC = nil;

    // 선택 표시는 다시 풀자.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if( 0 == indexPath.section ) // ----------------------------------------------------------------
    {
        NSDictionary *info = [theGear getPropertiesList][indexPath.row];

        if( [info[@"name"] hasPrefix:@">"] ) // This is Action Property
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You can access to Action properties only on running state. " delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
            [alert show];
            return;
        }

        // Navigation logic may go here. Create and push another view controller.
        if( [info[@"type"] isEqualToString:P_TXT] )
        {
            VC = [[StringSettingViewController alloc] initWithGear:theGear propertyInfo:info];
        }
        else if( [info[@"type"] isEqualToString:P_COLOR] )
        {
            UIColor *myColor = objc_msgSend(theGear, [info[@"getSelector"] pointerValue]);
            VC = [HRColorPickerViewController cancelableColorPickerViewControllerWithColor:myColor];
            [(SettingViewCommon*)VC setGearValue:theGear propertyInfo:info];
        }
        else if( [info[@"type"] isEqualToString:P_FONT] )
        {
            VC = [[FontSettingController alloc] initWithGear:theGear propertyInfo:info];
        }
        else if( [info[@"type"] isEqualToString:P_ALIGN] )
        {
            VC = [[AlignSettingController alloc] initWithGear:theGear propertyInfo:info];
        }
        else if( [info[@"type"] isEqualToString:P_BOOL] )
        {
            VC = [[BoolSettingController alloc] initWithGear:theGear propertyInfo:info];
        }
        else if( [info[@"type"] isEqualToString:P_NUM] )
        {
            VC = [[NumberSettingViewController alloc] initWithGear:theGear propertyInfo:info];
        }
        else if( [info[@"type"] isEqualToString:P_CELL] )
        {
            VC = [[CellSettingController alloc] initWithGear:theGear propertyInfo:info];
        }
        else if( [info[@"type"] isEqualToString:P_IMG] )
        {
            VC = [[UIImagePickerController alloc] init];
            [(UIImagePickerController*)VC setDelegate:self];
            [(UIImagePickerController*)VC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            tempInfo = info;

            if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
            {
                if( nil == libpop )
                    libpop = [[UIPopoverController alloc] initWithContentViewController:VC];
                UITableViewCell *tc = [tableView cellForRowAtIndexPath:indexPath];
                UIView *theView = ((CSAppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController.view;
                [libpop presentPopoverFromRect:[tc convertRect:tc.bounds toView:theView]
                                        inView:theView
                      permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                UIViewController *mainVC = ((CSAppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController;
                [self dismissViewControllerAnimated:YES completion:^{
                    [mainVC presentViewController:VC animated:YES completion:NULL];
                }];
            }
            return;
        }
        else if( [info[@"type"] isEqualToString:P_NO] )
        {
            SEL selector = [info[@"selector"] pointerValue];
            objc_msgSend(theGear, selector, @YES);
        }
        if( nil == VC ) return;

        NSLog(@"p name:%@", info[@"name"] );

        [self.navigationController pushViewController:VC animated:YES];
    }
    else if( 1 == indexPath.section ) // ------------------------------------------------------------
    {
        // Blueprint 로 링크 시작에 필요한 정보를 주고, 연결 동작을 시작시키자.
        NSMutableDictionary *gearInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
        gearInfo[@"theGear"] = theGear;
        gearInfo[@"theActionIndex"] = @(indexPath.row);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_ACTION_LINK
                                                            object:self
                                                          userInfo:gearInfo];
    }

    if( [[NSUserDefaults standardUserDefaults] boolForKey:@"SND_SET"] )
        AudioServicesPlaySystemSound(tockSoundID);
}

#pragma mark - unlink button Action

-(void) unlinkAction:(id)sender
{
    // 연결되지 않은 액션 항목이다. 버튼은 동작하지 않는다.
    if( NSIntegerMax == ((UIButton*)sender).tag ) return;


    UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"" message:@"Unlink the Action" cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm",nil];
    [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel)
    {
        // unlink the action
        NSArray *alist = [theGear getActionList];
        NSMutableDictionary *acDic = alist[((UIButton*)sender).tag];

        NSNumber *nsMagicNum = acDic[@"mNum"];
        CSGearObject *gObj = [USERCONTEXT getGearWithMagicNum:nsMagicNum.integerValue];
        
        if( nil != gObj ){
            [[gObj.csView.subviews lastObject] removeFromSuperview];
        }
        
        if (didCancel) return; // ---------------------------------
        
        acDic[@"selector"] = [NSValue valueWithPointer:nil];
        acDic[@"mNum"] = @(0);
        
        [self.tableView reloadData];
        
        // 액션 연결선 표시를 갱신해주기 위해서 멈춤 메시지를 보낸다. 그러면 갱신되는 효과가 있다.
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_STOP
                                                            object:nil];
    }];
}

-(void) lineAction:(id)sender
{
    // 연결되지 않은 액션 항목이다. 버튼은 동작하지 않는다.
    if( NSIntegerMax == ((UIButton*)sender).tag ) return;

    NSArray *alist = [theGear getActionList];
    NSMutableDictionary *acDic = alist[((UIButton*)sender).tag];

    NSNumber *nsMagicNum = acDic[@"mNum"];
    CSGearObject *gObj = [USERCONTEXT getGearWithMagicNum:nsMagicNum.integerValue];

    if( nil != gObj ){
        UIView *chV = [[UIView alloc] initWithFrame:gObj.csView.bounds];
        [chV setBackgroundColor:[UIColor redColor]];
        [chV setAlpha:0.3];
        [gObj.csView addSubview:chV];
        [gObj.csView setNeedsDisplay];
    }
}

-(void) removeLineAction:(id)sender
{
    // 연결되지 않은 액션 항목이다. 버튼은 동작하지 않는다.
    if( NSIntegerMax == ((UIButton*)sender).tag ) return;

    NSArray *alist = [theGear getActionList];
    NSMutableDictionary *acDic = alist[((UIButton*)sender).tag];
    
    NSNumber *nsMagicNum = acDic[@"mNum"];
    CSGearObject *gObj = [USERCONTEXT getGearWithMagicNum:nsMagicNum.integerValue];
    
    if( nil != gObj ){
        [[gObj.csView.subviews lastObject] removeFromSuperview];
    }
}

#pragma mark - ImagePicker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        [libpop dismissPopoverAnimated:YES];
    else
        [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)Info
{
    SEL act = [tempInfo[@"selector"] pointerValue];
    [theGear performSelector:act withObject:image];

    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        [libpop dismissPopoverAnimated:YES];
    else
        [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
