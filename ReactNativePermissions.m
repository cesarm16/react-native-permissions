//
//  ReactNativePermissions.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 18/02/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//


#import "ReactNativePermissions.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>

#import "RNPLocation.h"
#import "RNPAudioVideo.h"

@interface ReactNativePermissions()
@property (strong, nonatomic) RNPLocation *locationMgr;
@end

@implementation ReactNativePermissions


RCT_EXPORT_MODULE();
@synthesize bridge = _bridge;

#pragma mark Initialization

- (instancetype)init
{
    if (self = [super init]) {
    }

    return self;
}

/**
 * run on the main queue.
 */
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}


RCT_REMAP_METHOD(canOpenSettings, canOpenSettings:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@(UIApplicationOpenSettingsURLString != nil));
}

RCT_EXPORT_METHOD(openSettings)
{
    if (@(UIApplicationOpenSettingsURLString != nil)) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

RCT_REMAP_METHOD(getPermissionStatus, getPermissionStatus:(RNPType)type json:(id)json resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *status;

    switch (type) {

        case RNPTypeLocation: {
            NSString *locationPermissionType = [RCTConvert NSString:json];
            status = [RNPLocation getStatusForType:locationPermissionType];
            break;
        }
        case RNPTypeCamera:
            status = [RNPAudioVideo getStatus:@"video"];
            break;
        default:
            break;
    }

    resolve(status);
}

RCT_REMAP_METHOD(requestPermission, permissionType:(RNPType)type json:(id)json resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *status;

    switch (type) {
        case RNPTypeLocation:
            return [self requestLocation:json resolve:resolve];
        case RNPTypeCamera:
            return [RNPAudioVideo request:@"video" completionHandler:resolve];
        default:
            break;
    }


}

- (void) requestLocation:(id)json resolve:(RCTPromiseResolveBlock)resolve
{
    if (self.locationMgr == nil) {
        self.locationMgr = [[RNPLocation alloc] init];
    }

    NSString *type = [RCTConvert NSString:json];

    [self.locationMgr request:type completionHandler:resolve];
}

@end
