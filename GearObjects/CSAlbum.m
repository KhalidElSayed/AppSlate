//
//  CSAlbum.m
//  AppSlate
//
//  Created by Taehan Kim 태한 김 on 12. 2. 21..
//  Copyright (c) 2012년 ChocolateSoft. All rights reserved.
//

#import "CSAlbum.h"
#import "CSAppDelegate.h"
#import "CSMainViewController.h"

@implementation CSAlbum

-(id) object
{
    return (csView);
}

-(void) setShow:(NSNumber*)BoolValue
{
    // YES 값인 경우만 반응하자.
    if( ![BoolValue boolValue] )
        return;
    
    if( USERCONTEXT.imRunning )
    {
        if( nil == imgPicker ){
            imgPicker = [[UIImagePickerController alloc] init];
            [imgPicker setDelegate:self];
            [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }

        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            if( nil == albumPop )
                albumPop = [[UIPopoverController alloc] initWithContentViewController:imgPicker];

            [albumPop presentPopoverFromRect:csView.frame inView:((CSAppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            imgPicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [[(CSAppDelegate*)([UIApplication sharedApplication].delegate) mainViewController] presentViewController:imgPicker animated:YES completion:NULL];
        }
    }
}

-(NSNumber*) getShow
{
    return @NO;
}

//===========================================================================

#pragma mark -

-(id) initGear
{
    if( ![super init] ) return nil;
    
    csView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [(UIImageView*)csView setImage:[UIImage imageNamed:@"gi_album.png"]];
    [csView setUserInteractionEnabled:YES];

    csCode = CS_ALBUM;
    
    csResizable = NO;
    csShow = NO;

    albumPop = nil;
    imgPicker = nil;

    NSDictionary *d1 = MAKE_PROPERTY_D(@">Show Action", P_BOOL, @selector(setShow:),@selector(getShow));
    pListArray = @[d1];

    NSMutableDictionary MAKE_ACTION_D(@"Selected Image", A_IMG, a1);
    actionArray = @[a1];

    return self;
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if( (self=[super initWithCoder:decoder]) ) {
        [(UIImageView*)csView setImage:[UIImage imageNamed:@"gi_album.png"]];
        albumPop = nil;
        imgPicker = nil;
    }
    return self;
}

#pragma mark - Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[(CSAppDelegate*)([UIApplication sharedApplication].delegate) mainViewController] dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [albumPop dismissPopoverAnimated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)Info
{
    SEL act;
    NSNumber *nsMagicNum;

    act = ((NSValue*)((NSDictionary*)actionArray[0])[@"selector"]).pointerValue;
    if( nil != act ){
        nsMagicNum = ((NSDictionary*)actionArray[0])[@"mNum"];
        CSGearObject *gObj = [USERCONTEXT getGearWithMagicNum:nsMagicNum.integerValue];
        
        if( nil != gObj ){
            if( [gObj respondsToSelector:act] )
                [gObj performSelector:act withObject:image];
            else
                EXCLAMATION;
        }
    }
	
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[(CSAppDelegate*)([UIApplication sharedApplication].delegate) mainViewController] dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [albumPop dismissPopoverAnimated:YES];
    }
}

@end
