//
//  ViewController.m
//  TPFVPN
//
//  Created by Roc.Tian on 2022/1/10.
//

#import "ViewController.h"
#import "TPFVPNManager.h"
#import "TPFVPN-Swift.h"

@interface ViewController ()

@property (strong, nonatomic) TPFVPNManager *VPNManager;
@property (nonatomic)  int VPNStatus;
@property (weak, nonatomic) IBOutlet UILabel *VPNStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *VPNButton;
- (IBAction)VPNButtonAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    self.VPNManager.onVpnStateChange = ^(NEVPNStatus state) {
        [weakSelf onVpnStateChange:state];
    };
        
//    [VPNIKEv2Setup connectVPN]; /* Swift版本 */

}


- (IBAction)VPNButtonAction:(id)sender {
//    [VPNIKEv2Setup testConnect]; /* Swift版本 */
    if (self.VPNStatus == 0) {
        [self.VPNManager startVPN];
    } else {
        [self.VPNManager stopVPN];
    }
}

- (void)onVpnStateChange:(NEVPNStatus)state {
    self.VPNButton.enabled = state != NEVPNStatusConnecting;
    self.VPNStatus = state == NEVPNStatusConnected ? 1 : 0;
    switch (state) {
        case NEVPNStatusInvalid:
            self.VPNStatusLabel.text = @"链接无效";
            [self.VPNButton setTitle:@"打开VPN" forState:UIControlStateNormal];
            break;
        case NEVPNStatusDisconnected:
            self.VPNStatusLabel.text = @"未连接";
            [self.VPNButton setTitle:@"打开VPN" forState:UIControlStateNormal];
            break;
        case NEVPNStatusConnecting:
            self.VPNStatusLabel.text = @"正在连接";
            [self.VPNButton setTitle:@"打开VPN" forState:UIControlStateNormal];
            break;
        case NEVPNStatusConnected:
            self.VPNStatusLabel.text = @"已连接";
            [self.VPNButton setTitle:@"关闭VPN" forState:UIControlStateNormal];
            break;
        case NEVPNStatusDisconnecting:
            self.VPNStatusLabel.text = @"断开连接";
            [self.VPNButton setTitle:@"打开VPN" forState:UIControlStateNormal];
            break;

        default:
            break;
    }
}

#pragma mark getter
- (TPFVPNManager *)VPNManager {
    if (!_VPNManager) {
        _VPNManager = [[TPFVPNManager alloc] init];
    }
    return _VPNManager;
}

@end
