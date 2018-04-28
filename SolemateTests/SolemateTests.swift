//
//  SolemateTests.swift
//  SolemateTests
//
//  Created by Bill Moriarty on 4/25/18.
//  Copyright © 2018 Uppalled. All rights reserved.
//

import XCTest
@testable import Solemate

class SolemateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testSendToAWSforRecognition() {
        let imageToTestWith: UIImage = #imageLiteral(resourceName: "Powerphases")
        //image file to send
        let testVC = ViewController()
        testVC.identificationAPICall(imageToSend: imageToTestWith)
        XCTAssert((testVC.identificationTask != nil))
    }
    
    func testidentificationAPICall() {
        let imageToTestWith: UIImage = #imageLiteral(resourceName: "Powerphases")
        //image file to send
        let testVC = ViewController()
        testVC.identificationAPICall(imageToSend: imageToTestWith)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssert(testVC.identifiedShoe.price > 0)
        }
    }
    
    func testGetSimilarShoes() {
        let imageToTestWith: UIImage = #imageLiteral(resourceName: "Powerphases")
        //image file to send
        let testVC = shoeDetailsViewController()
        testVC.recommendationAPICall(imageToSend: imageToTestWith)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssert(testVC.returnedSimilarShoeList.endIndex>0)
        }
    }

    //displayDetails
    func testDisplayDetails()  {
        let imageToTestWith = #imageLiteral(resourceName: "Powerphases")
        let testShoe = shoe(image: imageToTestWith, name: "Test Shoe", desc: "This is a test shoe", price: 399.99, url: "www.google.com")
        let testVC = shoeDetailsViewController()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            testVC.loadShoeDetailsHandler(shoe: testShoe)
            XCTAssertTrue(testVC.shoeDescription.text == "This is a test shoe")
                }
    }
    
    //loadSavedList
    //saveList
    
}// end class SolemateTests: XCTestCase
