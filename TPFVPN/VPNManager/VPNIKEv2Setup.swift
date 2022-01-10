/* 代码参考自：https://gist.github.com/IhorYachmenov/fb63fd19f30541780950b6670e8a2865 */
import Foundation
import NetworkExtension

@objc public class VPNIKEv2Setup: NSObject {
    static let shared = VPNIKEv2Setup()

    let vpnManager = NEVPNManager.shared()
    let keychainService = KeychainService()

    func initVPNTunnelProviderManager() {
        keychainService.save(key: "vpnPwd", value: "myUserPass")

        print("CALL LOAD TO PREFERENCES...")
        vpnManager.loadFromPreferences { [self] (error) -> Void in

            if error != nil {
                print("VPN Preferences error: 1 - \(String(describing: error))")
            } else {
                let IKEv2Protocol = NEVPNProtocolIKEv2()

                IKEv2Protocol.authenticationMethod = .none
                IKEv2Protocol.serverAddress = VPNServerSettings.shared.vpnServerAddress
                IKEv2Protocol.username = VPNServerSettings.shared.userName
                IKEv2Protocol.remoteIdentifier = VPNServerSettings.shared.vpnRemoteIdentifier
                IKEv2Protocol.localIdentifier = VPNServerSettings.shared.vpnLocalIdentifier
                IKEv2Protocol.passwordReference = keychainService.load(key: "vpnPwd")

                IKEv2Protocol.useExtendedAuthentication = true
                IKEv2Protocol.disconnectOnSleep = false
                
                IKEv2Protocol.ikeSecurityAssociationParameters.diffieHellmanGroup = .group14

                self.vpnManager.protocolConfiguration = IKEv2Protocol
                self.vpnManager.localizedDescription = VPNServerSettings.shared.localizedDescription
                self.vpnManager.isEnabled = true
                self.vpnManager.isOnDemandEnabled = false

                print("SAVE TO PREFERENCES...")
                // SAVE TO PREFERENCES...
                self.vpnManager.saveToPreferences(completionHandler: { (error) -> Void in
                    if error != nil {
                        print("VPN Preferences error: 2 - \(String(describing: error))")
                    } else {
                        print("CALL LOAD TO PREFERENCES AGAIN...")
                        // CALL LOAD TO PREFERENCES AGAIN...
                        self.vpnManager.loadFromPreferences(completionHandler: { error in
                            if error != nil {
                                print("VPN Preferences error: 2 - \(String(describing: error))")
                            } else {
                                var startError: NSError?

                                do {
                                    // START THE CONNECTION...
                                    try self.vpnManager.connection.startVPNTunnel()
                                } catch let error as NSError {
                                    startError = error
                                    print(startError.debugDescription)
                                } catch {
                                    print("Fatal Error")
                                    fatalError()
                                }
                                if startError != nil {
                                    print("VPN Preferences error: 3 - \(String(describing: error))")

                                    // Show alert here
                                    print("title: Oops.., message: Something went wrong while connecting to the VPN. Please try again.")

                                    print(startError.debugDescription)
                                } else {
                                    print("Starting VPN...")
                                }
                            }
                        })
                    }
                })
            }
        }
    }

    // MARK: - Connect VPN

    @objc public static func connectVPN() {
        VPNIKEv2Setup().initVPNTunnelProviderManager()
    }

    // MARK: - Disconnect VPN

    @objc public static func disconnectVPN() {
        VPNIKEv2Setup().vpnManager.connection.stopVPNTunnel()
    }

    // MARK: - Disconnect VPN

    @objc public static func testConnect() {
        do {
            try VPNIKEv2Setup().vpnManager.connection.startVPNTunnel()
        } catch let error {
            print(error)
        }
    }

    // MARK: - check connection staatus

    static func checkStatus() {
        let status = VPNIKEv2Setup().vpnManager.connection.status
        print("VPN connection status = \(status.rawValue)")

        switch status {
        case NEVPNStatus.connected:

            print("Connected")

        case NEVPNStatus.invalid, NEVPNStatus.disconnected:

            print("Disconnected")

        case NEVPNStatus.connecting, NEVPNStatus.reasserting:

            print("Connecting")

        case NEVPNStatus.disconnecting:

            print("Disconnecting")

        default:
            print("Unknown VPN connection status")
        }
    }

    func dataFromFile() -> Data? {
//        let rootCertPath = Bundle.main.url(forResource: "phone", withExtension: "p12")
        let rootCertPath = Bundle.main.url(forResource: "ca.cert", withExtension: "cer")
        print(rootCertPath?.absoluteURL as Any)

        return try? Data(contentsOf: rootCertPath!.absoluteURL)
    }
}
