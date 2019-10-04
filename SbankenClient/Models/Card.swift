//
//  Card.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 04/10/2019.
//  Copyright © 2019 SBanken. All rights reserved.
//

import Foundation

public class Card: Codable {
    public let cardId: String
    public let cardNumber: String
    public let cardVersionNumber: Int
    public let accountNumber: String
    public let customerId: String
    public let expiryDate: Date
    public let accountOwner: String
    public let status: CardStatus
    public let cardType: String
    public let productCode: CardProductCode
}
