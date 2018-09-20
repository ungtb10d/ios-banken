//
//  SbankenClient.swift
//  SbankenClient
//
//  Created by Terje Tjervaag on 07/10/2017.
//  Copyright © 2017 SBanken. All rights reserved.
//

import Foundation

public class SbankenClient: NSObject {
    var clientId: String
    var secret: String
    
    var tokenManager: AccessTokenManager = AccessTokenManager()
    var urlSession: SURLSessionProtocol = URLSession.shared
    var decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        return jsonDecoder
    }()
    var encoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        return jsonEncoder
    }()

    public init(clientId: String, secret: String) {
        self.clientId = clientId
        self.secret = secret
    }
    
    public func accounts(userId: String, success: @escaping ([Account]) -> Void, failure: @escaping (Error?) -> Void) {
        accessToken(clientId: clientId, secret: secret) { (token) in
            guard token != nil else {
                failure(nil)
                return
            }
            
            let urlString = "\(Constants.baseUrl)/Bank/api/v1/Accounts"
            guard var request = RequestHelper.urlRequest(urlString, token: token!) else { return }
            request.setValue(userId, forHTTPHeaderField: "CustomerID")

            self.urlSession.dataTask(with: request, completionHandler: { (data, _, error) in
                guard data != nil, error == nil else {
                    failure(error)
                    return
                }
                
                if let accountsResponse = try? self.decoder.decode(AccountsResponse.self, from: data!) {
                    success(accountsResponse.items)
                } else {
                    failure(nil)
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

            let urlString = "\(Constants.baseUrl)/Bank/api/v1/Transactions/\(accountId)"
            guard var request = RequestHelper.urlRequest(urlString,
                                                         token: token!,
                                                         parameters: parameters) else { return }
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
                         fromAccountId: String,
                         toAccountId: String,
                         message: String,
                         amount: Float,
                         success: @escaping (TransferResponse) -> Void,
                         failure: @escaping (Error?) -> Void) {
        accessToken(clientId: clientId, secret: secret) { (token) in
            guard token != nil else {
                failure(nil)
                return
            }
            
            let urlString = "\(Constants.baseUrl)/Bank/api/v1/Transfers"
            guard var request = RequestHelper.urlRequest(urlString, token: token!) else { return }
            
            let transferRequest = TransferRequest(fromAccountId: fromAccountId,
                                                  toAccountId: toAccountId,
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

    public func eFakturas(userId: String,
                          status: String,
                          startDate: Date,
                          endDate: Date = Date(),
                          length: Int = 100,
                          index: Int = 0,
                          success: @escaping (EFakturasResponse) -> Void,
                          failure: @escaping (Error?) -> Void) {
        accessToken(clientId: clientId, secret: secret) { (token) in
            guard token != nil else {
                failure(nil)
                return
            }

            let urlString = "\(Constants.baseUrl)/Bank/api/v1/EFakturas"
            let formatter = ISO8601DateFormatter()
            let parameters = [
                "index": "\(index)",
                "length": "\(length)",
                "startDate": formatter.string(from: startDate),
                "endDate": formatter.string(from: endDate)
                ] as [String: Any]

            guard var request = RequestHelper.urlRequest(urlString,
                                                         token: token!,
                                                         parameters: parameters) else { return }
            request.setValue(userId, forHTTPHeaderField: "CustomerID")

            self.urlSession.dataTask(with: request, completionHandler: { (data, _, error) in
                guard data != nil, error == nil else {
                    failure(error)
                    return
                }

                let stringData = String(data: (data as Data?)!, encoding: .utf8)
                let fixedString = stringData?.replacingOccurrences(of: "00:00:00", with: "00:00:00Z").data(using: .utf8)

                if let eFakturasResponse = try? self.decoder.decode(EFakturasResponse.self, from: fixedString!) {
                    if eFakturasResponse.isError {
                        failure(nil)
                    } else {
                        success(eFakturasResponse)
                    }
                } else {
                    failure(nil)
                }
            }).resume()
        }
    }
    
    public func payEFaktura(userId: String,
                            eFakturaId: String,
                            fromAccountId: String,
                            payMinimumAmount: Bool,
                            success: @escaping (EFakturaPaymentResponse) -> Void,
                            failure: @escaping (Error?) -> Void) {
        accessToken(clientId: clientId, secret: secret) { (token) in
            guard token != nil else {
                failure(nil)
                return
            }
            
            let urlString = "\(Constants.baseUrl)/Bank/api/v1/EFakturas"
            guard var request = RequestHelper.urlRequest(urlString,
                                                         token: token!) else { return }
            
            let paymentRequest = EFakturaPaymentRequest(eFakturaId: eFakturaId,
                                                        accountId: fromAccountId,
                                                        payOnlyMinimumAmount: payMinimumAmount)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(userId, forHTTPHeaderField: "CustomerID")
            
            if let body = try? self.encoder.encode(paymentRequest) {
                request.httpBody = body
            } else {
                failure(nil)
            }
            
            self.urlSession.dataTask(with: request, completionHandler: { (data, _, error) in
                guard data != nil, error == nil else {
                    failure(error)
                    return
                }
                
                if let paymentResponse = try? self.decoder.decode(EFakturaPaymentResponse.self, from: data!) {
                    if paymentResponse.isError {
                        failure(nil)
                    } else {
                        success(paymentResponse)
                    }
                } else {
                    failure(nil)
                }
            }).resume()
        }
    }
    
    private func accessToken(clientId: String, secret: String, completion: @escaping (AccessToken?) -> Void) {
        if tokenManager.token != nil {
            completion(tokenManager.token!)
            return
        }
        
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
        
        self.urlSession.dataTask(with: request, completionHandler: { (data, _, error) in
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
