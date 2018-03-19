//
//  CardDetails.swift
//  SbankenClient
//
//  Created by Øyvind Tjervaag on 19/03/2018.
//  Copyright © 2018 SBanken. All rights reserved.
//

import Foundation

public class CardDetails: Codable {
    public let cardNumber: String?
    public let currencyAmount: Double?
    public let currencyRate: Double?
    public let merchantCategoryCode: String?
    public let merchantCategoryDescription: String?
    public let merchantCity: String?
    public let merchantName: String?
    public let originalCurrencyCode: String?
    public let purchaseDate: Date?
    public let transactionId: String?
}
