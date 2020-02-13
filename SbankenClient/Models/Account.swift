//
//  Account.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

open class Account: Codable {
    public let accountId: String
    public let accountNumber: String
    public let ownerCustomerId: String
    public let name: String
    public let accountType: String
    public let available: Double
    public let balance: Double
    public let creditLimit: Double
}
