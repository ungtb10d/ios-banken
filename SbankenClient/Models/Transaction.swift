//
//  Transaction.swift
//  SBankenClient
//
//  Created by Øyvind Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public class Transaction: Codable {
    public let transactionId: String
    public let accountingDate: Date?
    public let interestDate: Date?
    public let otherAccountNumber: String?
    public let amount: Double
    public let text: String?
    public let transactionType: String?
    public let transactionTypeCode: Int?
    public let transactionTypeText: String?
    public let isReservation: Bool
    // public let reservationType: Int? // TODO The API sends back an Int now. Known bug. Fix this when the API is fixed.
    // public let source: String? // TODO The API sends back an Int now. Known bug. Fix this when the API is fixed.
    public let cardDetailsSpecified: Bool
    public let cardDetails: CardDetails?
}

