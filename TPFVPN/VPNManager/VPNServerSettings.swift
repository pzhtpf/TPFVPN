//
//  VPNServerSettings.swift
//  iOS-Study-Demo
//
//  Created by Roc.Tian on 2022/1/7.
//

import Foundation

class VPNServerSettings: NSObject {
    static let shared = VPNServerSettings()
    
    let userName = "myUserName" // password from file certificate "****.p12"
    let vpnServerAddress = "45.62.100.176"
    let vpnRemoteIdentifier = "45.62.100.176" // In my case same like vpn server address
    let vpnLocalIdentifier = "phone@caf1e9*******.algo"
    let vpnServerCertificateIssuerCommonName = "45.62.100.176" // In my case same like vpn server address
    let localizedDescription = "Roc.Tian VPN"
    
    @objc public func getUserName() -> String {
        return userName;
    }
    @objc public func getVpnServerAddress() -> String {
        return vpnServerAddress;
    }
    @objc public func getVpnRemoteIdentifier() -> String {
        return vpnRemoteIdentifier;
    }
    @objc public func getVpnLocalIdentifier() -> String {
        return vpnLocalIdentifier;
    }
    @objc public func getLocalizedDescription() -> String {
        return localizedDescription;
    }
}
