//
//  AccessToken.swift
//  SbankenClient
//
//  Created by Øyvind Tjervaag on 27/11/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public class AccessToken: Codable {
    public var accessToken: String
    public var expiresIn: Int
    public var tokenType: String
    public var expiresAt: Date?
    
    lazy var expiryDate: Date = {
        expiresAt ?? Calendar.current.date(byAdding: .second, value: expiresIn, to: Date())!
    }()
    
    public init(_ accessToken: String, expiresIn: Int, tokenType: String, expiresAt: Date?) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
        self.expiresAt = expiresAt
    }
    
    public func hasExpired() -> Bool {
        guard let expiresAt = self.expiresAt else {
            return false
        }
        return Date() < expiresAt ? true : false
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}
