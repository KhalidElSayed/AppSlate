//
//  CSStrComp.m
//  AppSlate
//
//  Created by Taehan Kim on 12. 2. 23..
//  Copyright (c) 2012년 ChocolateSoft. All rights reserved.
//

#import "CSStrComp.h"

@implementation CSStrComp

-(id) object
{
    return (csView);
}

//===========================================================================

-(void) setBaseString:(NSString*) value
{
    if( [value isKindOfClass:[NSString class]] )
        base = value;
    else  if( [value isKindOfClass:[NSNumber class]] )
        base = [(NSNumber*)value stringValue];
    else
        return;

    if( USERCONTEXT.imRunning ){
        SEL act;
        NSNumber *nsMagicNum;
        
        act = ((NSValue*)((NSDictionary*)actionArray[0])[@"selector"]).pointerValue;
        if( nil != act ){
            nsMagicNum = ((NSDictionary*)actionArray[0])[@"mNum"];
            CSGearObject *gObj = [USERCONTEXT getGearWithMagicNum:nsMagicNum.integerValue];

            if( nil != gObj ){
                NSComparisonResult result;
                result = [base compare:var];

                if( [gObj respondsToSelector:act] )
                    [gObj performSelector:act withObject:@(result)];
                else
                    EXCLAMATION;
            }
        }        
    }
}

-(NSString*) getBaseString
{
    return base;
}

-(void) setVariableString:(NSString*) value
{
    if( [value isKindOfClass:[NSString class]] )
        var = value;
    else  if( [value isKindOfClass:[NSNumber class]] )
        var = [(NSNumber*)value stringValue];
    else
        return;

    if( USERCONTEXT.imRunning ){
        SEL act;
        NSNumber *nsMagicNum;
        
        act = ((NSValue*)((NSDictionary*)actionArray[0])[@"selector"]).pointerValue;
        if( nil != act ){
            nsMagicNum = ((NSDictionary*)actionArray[0])[@"mNum"];
            CSGearObject *gObj = [USERCONTEXT getGearWithMagicNum:nsMagicNum.integerValue];
            
            if( nil != gObj ){
                NSComparisonResult result;
                result = [base compare:var];
                
                if( [gObj respondsToSelector:act] )
                    [gObj performSelector:act withObject:@(result)];
                else
                    EXCLAMATION;
            }
        }        
    }
}

-(NSString*) getVariableString
{
    return var;
}

//===========================================================================

#pragma mark -

-(id) initGear
{
    if( ![super init] ) return nil;
    
    csView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [(UIImageView*)csView setImage:[UIImage imageNamed:@"gi_strcomp.png"]];
    [csView setUserInteractionEnabled:YES];

    csCode = CS_STRCOMP;

    csResizable = NO;
    csShow = NO;

    base = @"";
    var = @"";
    
    NSDictionary *d1 = MAKE_PROPERTY_D(@"Base String", P_TXT, @selector(setBaseString:),@selector(getBaseString));
    NSDictionary *d2 = MAKE_PROPERTY_D(@">Input String", P_TXT, @selector(setVariableString:),@selector(getVariableString));
    pListArray = @[d1,d2];

    NSMutableDictionary MAKE_ACTION_D(@"Result", A_NUM, a1);
    actionArray = @[a1];

    return self;
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if( (self=[super initWithCoder:decoder]) ) {
        [(UIImageView*)csView setImage:[UIImage imageNamed:@"gi_strcomp.png"]];
        base = [decoder decodeObjectForKey:@"base"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:base forKey:@"base"];
}

@end
