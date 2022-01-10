//
//  TPFVPNManager.h
//  iOS-Study-Demo
//
//  Created by Roc.Tian on 2022/1/6.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnVpnStateChange)(NEVPNStatus state);

@interface TPFVPNManager : NSObject

@property (nonatomic, strong) NEVPNManager *manager;
@property (nonatomic) OnVpnStateChange onVpnStateChange;

- (void)startVPN;
- (void)stopVPN;

@end

NS_ASSUME_NONNULL_END
