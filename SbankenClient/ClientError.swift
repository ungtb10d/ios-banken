//
//  ClientError.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 01/11/2018.
//  Copyright © 2018 Sbanken. All rights reserved.
//

import Foundation

public enum ClientError: Error {
    case invalidToken
    case invalidRequest
    case responseDecodingFailed
    case errorResponse
    case baseUrlNotSet
}
