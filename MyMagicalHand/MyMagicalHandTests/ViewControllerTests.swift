//
//  ViewControllerTests.swift
//  MyMagicalHandTests
//
//  Created by 김호준 on 2021/04/28.
//

import XCTest
@testable import MyMagicalHand

class ViewControllerTests: XCTestCase {
    var sut: ViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = bringRootViewController()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testController_whenStartApp_labelsAreHidden() {
        //then
        XCTAssertEqual(sut.looksLikeLabel.isHidden, true)
        XCTAssertEqual(sut.percentLabel.isHidden, true)
    }
    
    func testController_whenTappedShowResultButton_labelsAreNotHidden() {
        //when
        sut.showResultButton.sendActions(for: .touchUpInside)
        //then
        XCTAssertFalse(sut.looksLikeLabel.isHidden)
        XCTAssertFalse(sut.percentLabel.isHidden)
    }
    
    func testController_whenTappedClearButton_canvasViewIsClear() {
        //given
        sut.canvasView.touchesBegan(Set<UITouch>(), with: .none)
        //when
        sut.clearButton.sendActions(for: .touchUpInside)
        //then
        XCTAssertEqual(sut.canvasView.paths.count, 0)
    }
    
    func testController_whenTappedClearButton_labelsAreHidden() {
        //when
        sut.clearButton.sendActions(for: .touchUpInside)
        //then
        XCTAssertTrue(sut.looksLikeLabel.isHidden)
        XCTAssertTrue(sut.percentLabel.isHidden)
    }
}
