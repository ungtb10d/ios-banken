//
//  CardsResponse.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 04/10/2019.
//  Copyright © 2019 SBanken. All rights reserved.
//

import Foundation

public struct CardsResponse: Codable {
    public var availableItems: Int
    public var items: [Card]
    public var errorType: String?
    public var isError: Bool
    public var errorMessage: String?
}
