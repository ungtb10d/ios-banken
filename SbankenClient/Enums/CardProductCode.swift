//
//  CardProductCode.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 04/10/2019.
//  Copyright © 2019 SBanken. All rights reserved.
//

import Foundation

public enum CardProductCode: String, Codable {
    case debitCard = "DebitCard"
    case debitCardCl = "DebitCardCL"
    case creditCard = "CreditCard"
    case creditCardCl = "CreditCardCL"
    case debitCardYouth = "DebitCardYouth"
    case debitCardYouthCl = "DebitCardYouthCL"
    case x2xCard = "X2XCard"
    case x2xCardChild = "X2XCardChild"
    case x2xCardChildNet = "X2XCardChildNet"
    case electronCard = "ElectronCard"
    case unknown = "Unknown"
}
