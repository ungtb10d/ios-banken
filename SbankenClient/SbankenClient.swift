//
//  SbankenClient.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

open class SbankenClient: NSObject {
    var clientId: String?
    var secret: String?
    public var baseUrl: String? = Constants.baseUrl
    public var tokenManager: AccessTokenManager = AccessTokenManager()
    public var urlSession: SURLSessionProtocol = URLSession.shared
    public var decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        return jsonDecoder
    }()
    public var encoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        return jsonEncoder
    }()
    
    public init(clientId: String?, secret: String?) {
        self.clientId = clientId
        self.secret = secret
    }
    
    public func accounts(userId: String,
                         success: @escaping ([Account]) -> Void,
                         failure: @escaping (Error?, String?) -> Void) {
        accessToken(clientId: clientId, secret: secret) { (token) in
            guard token != nil else {
                failure(ClientError.invalidToken, "Invalid or expired token")
                return
            }
            
            guard let baseUrl = self.baseUrl else {
                failure(ClientError.baseUrlNotSet, "BaseURL not set")
                return
            }
            
            let urlString = "\(baseUrl)/core.Bank/api/v1/Accounts"
            guard var request = self.urlRequest(urlString, token: token!) else { return }
            request.setValue(userId, forHTTPHeaderField: "CustomerID")
            
            self.urlSession.dataTask(with: request, completionHandler: { (data, _, error) in
                guard data != nil, error == nil else {
                    failure(error, "Requst failed or empty response")
                    return
                }
                
                if let accountsResponse = try? self.decoder.decode(AccountsResponse.self, from: data!) {
                    success(accountsResponse.items)
                } else {
                    failure(ClientError.responseDecodingFailed, "Could not decode AccountsResponse")
                }
            }).resume()
        }
    }
    
    public func transactions(userId: String,
                             accountId: String,
                             startDate: Date,
                             endDate: Date = Date(),
                             index: Int = 0,
                             length: Int = 10,
                             success: @escaping (TransactionResponse) -> Void,
                             failure: @escaping (Error?) -> Void) {
        accessToken(clientId: clientId, secret: secret) { (token) in
            guard token != nil else {
                failure(nil)
                return
            }
            
            let formatter = ISO8601DateFormatter()
            let parameters = [
                "index": "\(index)",
                "length": "\(length)",
                "startDate": formatter.string(from: startDate),
                "endDate": formatter.string(from: endDate)
                ] as [String: Any]

            guard let baseUrl = self.baseUrl else {
                failure(ClientError.baseUrlNotSet)
                return
            }
            
            let urlString = "\(baseUrl)/core.Bank/api/v1/Transactions/\(accountId)"
            guard var request = self.urlRequest(urlString, token: token!, parameters: parameters) else { return }
            request.setValue(userId, forHTTPHeaderField: "CustomerID")
            
            self.urlSession.dataTask(with: request, completionHandler: { (data, _, error) in
                guard data != nil, error == nil else {
                    failure(error)
                    return
                }
                
                if let transactionResponse = try? self.decoder.decode(TransactionResponse.self, from: data!) {
                    success(transactionResponse)
                } else {
                    failure(nil)
                }
            }).resume()
        }
    }
    
    public func transfer(userId: String,
                         fromAccount: String,
                         toAccount: String,
                         message: String,
                         amount: Float,
                         success: @escaping (TransferResponse) -> Void,
                         failure: @escaping (Error?) -> Void) {
        accessToken(clientId: clientId, secret: secret) { (token) in
            guard token != nil else {
                failure(nil)
                return
            }
            
            guard let baseUrl = self.baseUrl else {
                failure(ClientError.baseUrlNotSet)
                return
            }
            
            let urlString = "\(baseUrl)/core.Bank/api/v1/Transfers"
            guard var request = self.urlRequest(urlString, token: token!) else { return }
            
            let transferRequest = TransferRequest(fromAccount: fromAccount,
                                                  toAccount: toAccount,
                                                  message: message,
                                                  amount: amount)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(userId, forHTTPHeaderField: "CustomerID")
            
            if let body = try? self.encoder.encode(transferRequest) {
                request.httpBody = body
            } else {
                failure(nil)
            }
            
            self.urlSession.dataTask(with: request, completionHandler: { (data, _, error) in
                guard data != nil, error == nil else {
                    failure(error)
                    return
                }
                
                if let transferResponse = try? self.decoder.decode(TransferResponse.self, from: data!) {
                    if transferResponse.isError {
                        failure(nil)
                    } else {
                        success(transferResponse)
                    }
                } else {
                    failure(nil)
                }
            }).resume()
        }
    }
    
    public func urlRequest(_ urlString: String, token: AccessToken, parameters: [String: Any]) -> URLRequest? {
        guard var request = urlRequest(urlString, token: token) else { return nil }
        guard let originalUrl = request.url?.absoluteString else { return nil }
        
        request.url = URL(string: "\(originalUrl)?\(parameters.stringFromHttpParameters())")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return request
    }
    
    public func urlRequest(_ urlString: String, token: AccessToken) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    open func accessToken(clientId: String?, secret: String?, completion: @escaping (AccessToken?) -> Void) {
        if tokenManager.token != nil {
            completion(tokenManager.token!)
            return
        }
        
        guard let clientId = clientId, let secret = secret else { return }
        
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-_.!~*'()")
        
        let encodedClientId = clientId.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
        let encodedsecret = secret.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
        
        let credentialData = "\(encodedClientId!):\(encodedsecret!)".data(using: .utf8)!
        let encodedCredentials = credentialData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
        let url = URL(string: "\(Constants.baseAuthUrl)/identityserver/connect/token")
        var request = URLRequest(url: url!)
        
        [
            "Authorization": "Basic \(encodedCredentials)",
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
            "Accept": "application/json"
        ].forEach { (key, value) in request.setValue(value, forHTTPHeaderField: key) }
        
        request.httpMethod = "POST"
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        self.urlSession.dataTask(with: request,
                                 completionHandler: { (data, _, error) in
            guard data != nil, error == nil else {
                completion(nil)
                return
            }
            
            if let token = try? self.decoder.decode(AccessToken.self, from: data!) {
                self.tokenManager.token = token
            }
            
            completion(self.tokenManager.token)
        }).resume()
    }
}
