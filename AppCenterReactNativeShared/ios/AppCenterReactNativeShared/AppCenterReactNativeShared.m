// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "AppCenterReactNativeShared.h"
#import <AppCenter/MSACAppCenter.h>
#import <AppCenter/MSACWrapperSdk.h>
#import <AppCenter/MSACLogger.h>

@implementation AppCenterReactNativeShared

static NSString *const logTag = @"AppCenterReactNativeShared";
static NSString *const kAppCenterSecretKey = @"AppSecret";
static NSString *const kAppCenterStartAutomaticallyKey = @"StartAutomatically";
static NSString *const kAppCenterNetworkRequestsAllowedByDefaultKey = @"AppCenterNetworkRequestsAllowedByDefault";
static NSString *const kAppCenterConfigResource = @"AppCenter-Config";

static NSString *appSecret;
static BOOL startAutomatically;
static MSACWrapperSdk *wrapperSdk;
static NSDictionary *configuration;

+ (void)setAppSecret:(NSString *)secret {
  appSecret = secret;
}

+ (NSString *)getAppSecret {
  if (appSecret == nil) {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kAppCenterConfigResource ofType:@"plist"];
    configuration = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    appSecret = [configuration objectForKey:kAppCenterSecretKey];

    // Read start automatically flag, by default it's true if not set.
    id rawStartAutomatically = [configuration objectForKey:kAppCenterStartAutomaticallyKey];
    if ([rawStartAutomatically isKindOfClass:[NSNumber class]]) {
      startAutomatically = [rawStartAutomatically boolValue];
    } else {
      startAutomatically = YES;
    }
  }
  return appSecret;
}

+ (BOOL)isNetworkAllowed {
    NSNumber *storedAllowedValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"MSAppCenterNetworkRequestsAllowed"];
    if (storedAllowedValue != nil) {
      MSACLogDebug(logTag, @"Stored network requests value: %@.", [storedAllowedValue boolValue] ? @"allowed" : @"forbidden");
      return [storedAllowedValue boolValue];
    }
    NSNumber *sdkNetworkRequestsAllowedByDefault = [configuration objectForKey:kAppCenterNetworkRequestsAllowedByDefaultKey];
    if (sdkNetworkRequestsAllowedByDefault != nil) {
      MSACLogDebug(logTag, @"Configuration network requests value: %@.", [storedAllowedValue boolValue] ? @"allowed" : @"forbidden");
      return [sdkNetworkRequestsAllowedByDefault boolValue];
    }
    MSACLogDebug(logTag, @"Network requests default value applied.");
    return YES;
}

+ (void)configureAppCenter {
  if (!wrapperSdk) {
    MSACWrapperSdk *wrapperSdk = [[MSACWrapperSdk alloc] initWithWrapperSdkVersion:@"4.1.0"
                                                                wrapperSdkName:@"appcenter.react-native"
                                                         wrapperRuntimeVersion:nil
                                                        liveUpdateReleaseLabel:nil
                                                       liveUpdateDeploymentKey:nil
                                                         liveUpdatePackageHash:nil];
    [self setWrapperSdk:wrapperSdk];
    [AppCenterReactNativeShared getAppSecret];
    BOOL isNetworkAllowed = [AppCenterReactNativeShared isNetworkAllowed];
    [MSACAppCenter setNetworkRequestsAllowed:isNetworkAllowed];
    if (startAutomatically) {
      if ([appSecret length] == 0) {
        [MSACAppCenter configure];
      } else {
        [MSACAppCenter configureWithAppSecret:appSecret];
      }
    }
  }
}

+ (MSACWrapperSdk *)getWrapperSdk {
  return wrapperSdk;
}

+ (void)setWrapperSdk:(MSACWrapperSdk *)sdk {
  wrapperSdk = sdk;
  [MSACAppCenter setWrapperSdk:sdk];
}

+ (void)setStartAutomatically:(BOOL)shouldStartAutomatically {
  startAutomatically = shouldStartAutomatically;
}

+ (NSDictionary *)getConfiguration {
  return configuration;
}

@end
