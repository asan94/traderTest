//
//  TraderTestTests.swift
//  TraderTestTests
//
//  Created by Asan Ametov on 27.02.2026.
//

import XCTest
@testable import TraderTest

final class TraderTestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

final class QuoteDMTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_encodingAndDecoding() throws {
        let expected = QuoteDM(
            ticker: "AAPL",
            lastTradePrice: 150.0,
            prevClosePrice: 140.0,
            lastTradeReferance: "US",
            name: "Apple",
            change: 10.0,
            minStep: 0.01,
            hasChanges: nil,
            ltt: "ltt1"
        )

        // 1. encode
        let data = try JSONEncoder().encode(expected)

        // 2. decode
        let actual = try JSONDecoder().decode(QuoteDM.self, from: data)

        // 3. проверка
        XCTAssertEqual(expected.ticker, actual.ticker)
        XCTAssertEqual(expected.lastTradePrice, actual.lastTradePrice)
        XCTAssertEqual(expected.prevClosePrice, actual.prevClosePrice)
        XCTAssertEqual(expected.lastTradeReferance, actual.lastTradeReferance)
        XCTAssertEqual(expected.name, actual.name)
        XCTAssertEqual(expected.change, actual.change)
        XCTAssertEqual(expected.minStep, actual.minStep)
        XCTAssertEqual(expected.ltt, actual.ltt)
    }

    func test_decodingWithPartialJSON() throws {
        let rawJSON = """
        {
            "c": "AAPL",
            "name": "Apple",
            "ltt": "01-02-2026 00:00"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(QuoteDM.self, from: rawJSON)

        XCTAssertEqual(decoded.ticker, "AAPL")
        XCTAssertEqual(decoded.name, "Apple")
        XCTAssertNil(decoded.lastTradePrice)
        XCTAssertNil(decoded.change)
    }
    
    func test_diff_whenOld_isNilOrPartiallyNil() {
        let base = QuoteDM(
            ticker: "AAPL",
            lastTradePrice: 140.0,
            prevClosePrice: 130.0,
            lastTradeReferance: nil,
            name: "Apple",
            change: nil,
            minStep: 0.01,
            ltt: "ltt1"
        )

        let update = QuoteDM(
            ticker: "AAPL",
            lastTradePrice: 150.0,
            prevClosePrice: nil,   // остается старое значение
            lastTradeReferance: "new",
            name: "Apple Inc.",
            change: 10.0,
            minStep: nil,
            ltt: "ltt2"
        )

        let diffed = update.diff(from: base)

        XCTAssertEqual(diffed.lastTradePrice, 150.0)
        XCTAssertEqual(diffed.prevClosePrice, 130.0)   // из base
        XCTAssertEqual(diffed.lastTradeReferance, "new")
        XCTAssertEqual(diffed.change, 10.0)
        XCTAssertTrue(diffed.hasChanges == true)
        XCTAssertEqual(diffed.minStep, 0.01)           // из base (minStep nil → используется base)
        XCTAssertEqual(diffed.ltt, "ltt2")
    }

}

final class QuoteCellViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_init_buildsTextsAndFlagsCorrectly() {
        let quote = QuoteDM(
            ticker: "GAZP.ME",
            lastTradePrice: 150.123456,
            prevClosePrice: 140.0,
            lastTradeReferance: "ME",
            name: "Gazprom",
            change: 10.0,
            minStep: 0.01,
            hasChanges: true,
            ltt: "12:34:56"
        )

        let vm = QuoteCellViewModel(quote: quote, highlight: .up)

        XCTAssertEqual(vm.ticker, "GAZP.ME")
        XCTAssertEqual(vm.tickerText, "GAZP")                           // без .ME
        XCTAssertEqual(vm.name, "ME | Gazprom")                         // join ref + name
        XCTAssertEqual(vm.exchange, "ME")
        XCTAssertEqual(vm.last, 150.123456, accuracy: 0.000001)
        XCTAssertEqual(vm.prevClose, Decimal(140.0))
        XCTAssertEqual(vm.minStep, Decimal(0.01))

        // priceText: "last (change)" или "last - "
        XCTAssertTrue(vm.priceText.contains("150.12"))                  // с округлением minStep
        XCTAssertTrue(vm.priceText.contains("(+10"))                    // знак и changePoints

        // changePercentText: prevClose as percent string (по твоей логике)
        XCTAssertTrue(vm.changePercentText.hasSuffix("%"))

        XCTAssertTrue(vm.isPositive)
        XCTAssertFalse(vm.isNegative)
        XCTAssertEqual(vm.highlight, .up)

        XCTAssertEqual(vm.lastTradeTime, "12:34:56")
        XCTAssertEqual(
            vm.iconURL,
            "https://tradernet.com/logos/get-logo-by-ticker?ticker=gazp.me"
        )
    }
    

    func test_hashable_andEquality_useTickerAndTime() {
        let quoteA = QuoteDM(
            ticker: "GAZP.ME",
            lastTradePrice: 150.0,
            prevClosePrice: 140.0,
            lastTradeReferance: "ME",
            name: "Gazprom",
            change: 10.0,
            minStep: 0.01,
            hasChanges: true,
            ltt: "12:00:00"
        )

        let quoteB = QuoteDM(
            ticker: "GAZP.ME",
            lastTradePrice: 151.0,
            prevClosePrice: 140.0,
            lastTradeReferance: "ME",
            name: "Gazprom",
            change: 11.0,
            minStep: 0.01,
            hasChanges: true,
            ltt: "12:00:00"
        )

        let quoteC = QuoteDM(
            ticker: "GAZP.ME",
            lastTradePrice: 152.0,
            prevClosePrice: 140.0,
            lastTradeReferance: "ME",
            name: "Gazprom",
            change: 12.0,
            minStep: 0.01,
            hasChanges: true,
            ltt: "12:01:00"
        )

        let a = QuoteCellViewModel(quote: quoteA, highlight: .none)
        let b = QuoteCellViewModel(quote: quoteB, highlight: .up)
        let c = QuoteCellViewModel(quote: quoteC, highlight: .down)

        XCTAssertEqual(a, b)                // одинаковые ticker + time
        XCTAssertNotEqual(a, c)            // отличается time

        var set = Set<QuoteCellViewModel>()
        set.insert(a)
        set.insert(b)                      // не должен добавиться как новый
        XCTAssertEqual(set.count, 1)

        set.insert(c)
        XCTAssertEqual(set.count, 2)
    }
    
    func test_negativeAndZeroChangeFlagsAndPriceText() {
         // отрицательное изменение
         let negativeQuote = QuoteDM(
             ticker: "AAPL",
             lastTradePrice: 90.0,
             prevClosePrice: 100.0,
             lastTradeReferance: nil,
             name: "Apple",
             change: -10.0,
             minStep: 0.01,
             hasChanges: true,
             ltt: "10:00:00"
         )

         let negativeVM = QuoteCellViewModel(quote: negativeQuote, highlight: .down)
         XCTAssertFalse(negativeVM.isPositive)
         XCTAssertTrue(negativeVM.isNegative)
         XCTAssertEqual(negativeVM.highlight, .down)

         // нулевое изменение → "last - "
         let zeroQuote = QuoteDM(
             ticker: "AAPL",
             lastTradePrice: 100.0,
             prevClosePrice: 100.0,
             lastTradeReferance: nil,
             name: "Apple",
             change: 0.0,
             minStep: 0.01,
             hasChanges: false,
             ltt: "11:00:00"
         )

         let zeroVM = QuoteCellViewModel(quote: zeroQuote, highlight: .none)
         XCTAssertTrue(zeroVM.priceText.contains(" - "))
         XCTAssertFalse(zeroVM.isPositive)
         XCTAssertFalse(zeroVM.isNegative)
     }
}

