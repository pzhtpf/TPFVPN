//
//  TPFVPNManager.m
//  iOS-Study-Demo
//
//  Created by Roc.Tian on 2022/1/6.
//

#import "TPFVPNManager.h"
#import "TPFVPN-Swift.h"

@implementation TPFVPNManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        //添加VPN状态变化通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVpnStateChange:) name:NEVPNStatusDidChangeNotification object:nil];
        [self initConfig:^(NSError *error) {
        }];
    }
    return self;
}

- (void)initConfig:(void (^)(NSError *))completionHandler {
    NSLog(@"hello VPN");
    //将pwd放入钥匙串，因为我们读取密码的时候需要从钥匙串中读出
    KeychainService *keychainService = [[KeychainService alloc] init];
    [keychainService saveWithKey:@"vpnPwd" value:@"myUserPass"];

    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError *_Nullable error) {
        if (error) {
            NSLog(@"VPN Preferences error:%@", error);
            if (completionHandler) completionHandler(error);
        } else {
            NEVPNProtocolIKEv2 *config = [[NEVPNProtocolIKEv2 alloc] init];
            config.authenticationMethod = NEVPNIKEAuthenticationMethodNone;
            VPNServerSettings *serverSettings = [[VPNServerSettings alloc] init];

            config.serverAddress = [serverSettings getVpnServerAddress];
            config.username =  [serverSettings getUserName];
            config.remoteIdentifier = [serverSettings getVpnRemoteIdentifier];
            config.localIdentifier = [serverSettings getVpnLocalIdentifier];
            config.passwordReference = [keychainService loadWithKey:@"vpnPwd"];

            config.IKESecurityAssociationParameters.diffieHellmanGroup = NEVPNIKEv2DiffieHellmanGroup14;

            config.useExtendedAuthentication = true;
            config.disconnectOnSleep = false;

            self.manager.protocolConfiguration = config;
            self.manager.localizedDescription = [serverSettings getLocalizedDescription];
            self.manager.enabled = true;
            self.manager.onDemandEnabled = false;

            NSLog(@"SAVE TO PREFERENCES...");
            //SAVE TO PREFERENCES...
            if (self.manager.connection.status != NEVPNStatusConnected) {
                [self.manager saveToPreferencesWithCompletionHandler:^(NSError *_Nullable error) {
                    if (error) {
                        NSLog(@"VPN Preferences error: %@", error);
                        if (completionHandler) completionHandler(error);
                    } else {
                        if (completionHandler) completionHandler(nil);
                    }
                }];
            }
        }
    }];
}

- (void)startVPN {
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError *_Nullable error) {
        if (error) {
            NSLog(@"VPN Preferences error:%@", error);
        } else {
            NSError *startError;
            [self.manager.connection startVPNTunnelAndReturnError:&startError];
            if (startError) {
                NSLog(@"start error %@", error.localizedDescription);
            } else {
                NSLog(@"Connection established");
            }
        }
    }];
}

- (void)stopVPN {
    // Add code here to start the process of stopping the tunnel
    [self.manager.connection stopVPNTunnel];
}

- (void)onVpnStateChange:(NSNotification *)Notification {
    NEVPNStatus state = self.manager.connection.status;

    switch (state) {
        case NEVPNStatusInvalid:
            NSLog(@"链接无效");
            break;
        case NEVPNStatusDisconnected:
            NSLog(@"未连接");
            break;
        case NEVPNStatusConnecting:
            NSLog(@"正在连接");
            break;
        case NEVPNStatusConnected:
            NSLog(@"已连接");
            break;
        case NEVPNStatusDisconnecting:
            NSLog(@"断开连接");
            break;

        default:
            break;
    }

    if (self.onVpnStateChange) self.onVpnStateChange(state);
}

#pragma mark getter
- (NEVPNManager *)manager {
    return [NEVPNManager sharedManager];
}

@end
