//
//  SbankenClientCardsTests.swift
//  SbankenClientTests
//
//  Created by Terje Tjervaag on 17/06/2019.
//  Copyright © 2019 SBanken. All rights reserved.
//

import XCTest
@testable import SbankenClient

class SbankenClientCardsTests: XCTestCase {
    var mockUrlSession = MockURLSession()
    var mockTokenManager = AccessTokenManager()
    var defaultUserId = "12345"
    var defaultAccessToken = "TOKEN"
    var client: SbankenClient?
    
    var goodCardData = """
        {
           \"availableItems\":8,
           \"items\":[
              {
                 \"cardId\":\"-122_1\",
                 \"cardNumber\":\"121212\",
                 \"cardVersionNumber\":9,
                 \"accountNumber\":\"97101111111\",
                 \"customerId\":\"11111111111\",
                 \"expiryDate\":\"2017-11-01T00:00:00\",
                 \"accountOwner\":\"11111111111\",
                 \"status\":\"Deleted\",
                 \"cardType\":\"VISA\",
                 \"productCode\":\"DebitCard\"
              },
              {
                 \"cardId\":\"-121_1\",
                 \"cardNumber\":\"97101111111\",
                 \"cardVersionNumber\":1,
                 \"accountNumber\":\"97101111111\",
                 \"customerId\":\"11111111111\",
                 \"expiryDate\":\"2019-03-01T00:00:00\",
                 \"accountOwner\":\"11111111111\",
                 \"status\":\"Active\",
                 \"cardType\":\"VISA\",
                 \"productCode\":\"DebitCard\"
              }
            ],
            \"isError\": false
          }
    """.data(using: .utf8)
    
    var badCardData = """
        [tralala
    """.data(using: .utf8)
    
    override func setUp() {
        super.setUp()
        mockTokenManager.token = AccessToken("TOKEN", expiresIn: 1000, tokenType: "TYPE")
        client = SbankenClient(clientId: "CLIENT",
                               secret: "SECRET")
        client?.urlSession = mockUrlSession as SURLSessionProtocol
        client?.tokenManager = mockTokenManager
        mockUrlSession.lastRequest = nil
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClientQueriesForCards() {
        let request = cardRequest(userId: defaultUserId)
        
        XCTAssertEqual(request?.url?.path, "/exec.bank/api/v1/Cards")
    }
    
    func testAccountRequestHasRequiredHeaders() {
        let request = cardRequest(userId: defaultUserId)
        
        XCTAssertEqual(request?.allHTTPHeaderFields!["Authorization"], "Bearer \(defaultAccessToken)")
        XCTAssertEqual(request?.allHTTPHeaderFields!["Accept"], "application/json")
        XCTAssertEqual(request?.allHTTPHeaderFields!["CustomerID"], defaultUserId)
    }
    
    func testAccountRequestReturnsErrorForBadData() {
        mockUrlSession.responseData = badCardData
        let errorExpectation = expectation(description: "Error occurred")
        _ = cardRequest(userId: defaultUserId, success: { _ in }, failure: { (_, _) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testAccountRequestReturnsSuccessForGoodData() {
        mockUrlSession.responseData = goodCardData
        let returnExpectation = expectation(description: "Error or success was called")
        _ = cardRequest(userId: defaultUserId, success: { (accounts) in
            XCTAssertNotNil(accounts)
            returnExpectation.fulfill()
        }, failure: { (_, _) in
            XCTFail("Error should not occur")
            returnExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testAccountRequestDoesNotFail() {
        let errorExpectation = expectation(description: "Error occurred")
        _ = cardRequest(userId: defaultUserId, success: { _ in }, failure: { (_, _) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func testAccountRequestReturnsErrorForHttpError() {
        mockUrlSession.responseError = NSError(domain: "error", code: 0, userInfo: nil)
        let errorExpectation = expectation(description: "Error occurred")
        _ = cardRequest(userId: defaultUserId, success: { _ in }, failure: { (_, _) in
            XCTAssert(true, "Error occurred")
            errorExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10)
    }
    
    func cardRequest(userId: String,
                     success: @escaping ([Card]) -> Void = { _ in },
                     failure: @escaping (Error?, String?) -> Void = { _, _  in }) -> URLRequest? {
        client?.cards(userId: userId, success: success, failure: failure)
        
        return mockUrlSession.lastRequest
    }
}
