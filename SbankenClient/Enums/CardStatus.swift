//
//  CardStatus.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 04/10/2019.
//  Copyright © 2019 SBanken. All rights reserved.
//

import Foundation

public enum CardStatus: String, Codable {
    case unknown = "Unknown"
    case active = "Active"
    case inactive = "Inactive"
    case renewal = "Renewal"
    case deleted = "Deleted"
    case blocked = "Blocked"
}
