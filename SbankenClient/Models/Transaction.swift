//
//  Transaction.swift
//  SbankenClient
//
//  Created by Øyvind Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public class Transaction: Codable {
    public let accountingDate: Date?
    public let interestDate: Date?
    public let otherAccountNumber: String?
    public let amount: Double
    public let text: String?
    public let transactionType: String?
    public let transactionTypeCode: Int?
    public let transactionTypeText: String?
    public let isReservation: Bool
    public let reservationType: String?
    public let source: String?
    public let cardDetailsSpecified: Bool
    public let cardDetails: CardDetails?
}
