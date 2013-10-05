//
//  CSAccelero.m
//  AppSlate
//
//  Created by Taehan Kim on 12. 3. 3..
//  Copyright (c) 2012년 ChocolateSoft. All rights reserved.
//

#import "CSAccelero.h"

@implementation CSAccelero

-(id) object
{
    return (csView);
}

//===========================================================================

-(void) setActivate:(NSNumber*) BoolValue
{
    if( [BoolValue isKindOfClass:[NSString class]] )
        isRun = [(NSString*)BoolValue boolValue];
    else  if( [BoolValue isKindOfClass:[NSNumber class]] )
        isRun = [BoolValue boolValue];
    else
        return;
}

-(NSNumber*) getActivate
{
    return @(isRun);
}

//===========================================================================

#pragma mark -

-(id) initGear
{
    if( ![super init] ) return nil;
    
    csView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [(UIImageView*)csView setImage:[UIImage imageNamed:@"gi_aclo.png"]];
    [csView setUserInteractionEnabled:YES];

    csCode = CS_NOR;
    
    csResizable = NO;
    csShow = NO;
    
    ac = [[CMMotionManager alloc] init];
    ac.accelerometerUpdateInterval = 0.1;

    isRun = NO;


    NSDictionary *d1 = MAKE_PROPERTY_D(@"Activate", P_BOOL, @selector(setActivate:),@selector(getActivate));
    pListArray = @[d1];
    
    NSMutableDictionary MAKE_ACTION_D(@"Output X", A_NUM, a1);
    NSMutableDictionary MAKE_ACTION_D(@"Output Y", A_NUM, a2);
    NSMutableDictionary MAKE_ACTION_D(@"Output Z", A_NUM, a3);
    actionArray = @[a1,a2,a3];

    [ac startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
    {
        [self accelerometerX:accelerometerData.acceleration.x Y:accelerometerData.acceleration.y Z:accelerometerData.acceleration.z];
    } ];

    return self;
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if( (self=[super initWithCoder:decoder]) ) {
        [(UIImageView*)csView setImage:[UIImage imageNamed:@"gi_aclo.png"]];
        ac = [[CMMotionManager alloc] init];
        ac.accelerometerUpdateInterval = 0.1;
        isRun = [decoder decodeBoolForKey:@"isRun"];

        [ac startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
             [self accelerometerX:accelerometerData.acceleration.x Y:accelerometerData.acceleration.y Z:accelerometerData.acceleration.z];
         } ];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeBool:isRun forKey:@"isRun"];
}

#pragma mark -

- (void)accelerometerX:(CGFloat) _x Y:(CGFloat) _y Z:(CGFloat) _z
{
    if( USERCONTEXT.imRunning && isRun )
    {
//        double alpha = (1.0/60.0) / ((1.0/60.0) + (1.0/5.0));
//        x = acceleration.x * alpha + x * (1.0 - alpha);
//        y = acceleration.y * alpha + y * (1.0 - alpha);
//        z = acceleration.z * alpha + z * (1.0 - alpha);

        SEL act;
        NSNumber *nsMagicNum;

        act = ((NSValue*)((NSDictionary*)actionArray[0])[@"selector"]).pointerValue;
        if( nil != act ){
            nsMagicNum = ((NSDictionary*)actionArray[0])[@"mNum"];
            CSGearObject *gObj = [USERCONTEXT getGearWithMagicNum:nsMagicNum.integerValue];
            
            if( nil != gObj ){
                if( [gObj respondsToSelector:act] )
                    [gObj performSelector:act withObject:@(_x)];
            }
        }
        act = ((NSValue*)((NSDictionary*)actionArray[1])[@"selector"]).pointerValue;
        if( nil != act ){
            nsMagicNum = ((NSDictionary*)actionArray[1])[@"mNum"];
            CSGearObject *gObj = [USERCONTEXT getGearWithMagicNum:nsMagicNum.integerValue];
            
            if( nil != gObj ){
                if( [gObj respondsToSelector:act] )
                    [gObj performSelector:act withObject:@(_y)];
            }
        }
        act = ((NSValue*)((NSDictionary*)actionArray[2])[@"selector"]).pointerValue;
        if( nil != act ){
            nsMagicNum = ((NSDictionary*)actionArray[2])[@"mNum"];
            CSGearObject *gObj = [USERCONTEXT getGearWithMagicNum:nsMagicNum.integerValue];
            
            if( nil != gObj ){
                if( [gObj respondsToSelector:act] )
                    [gObj performSelector:act withObject:@(_z)];
            }
        }

    }
}

@end
