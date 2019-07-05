//
//  TryKingfisherTests.swift
//  TryKingfisherTests
//
//  Created by Paul Wood on 7/4/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import XCTest
@testable import TryKingfisher
import Combine

class MockImageHandler: ImageHandlerType {
  var spiedDeleteURLs = [URL]()
  var stubDeleteImage: (_ url: URL) -> AnyPublisher<Void, Never>
  func deleteImage(_ url: URL) -> AnyPublisher<Void, Never> {
    spiedDeleteURLs.append(url)
    return stubDeleteImage(url)
  }
  var spiedImageURLs = [URL]()
  var stubImage: (_ url: URL) -> AnyPublisher<UIImage, ImageHandlerError>
  func image(_ url: URL) -> AnyPublisher<UIImage, ImageHandlerError> {
    spiedImageURLs.append(url)
    return stubImage(url)
  }
  
  init(stubDeleteImage: @escaping (_ url: URL) -> AnyPublisher<Void, Never>,
       stubImage: @escaping (_ url: URL) -> AnyPublisher<UIImage, ImageHandlerError>) {
    self.stubDeleteImage = stubDeleteImage
    self.stubImage = stubImage
  }
  
}

class TryKingfisherTests: XCTestCase {
  
  var sut: BeardDataSource?
  let testImage = Assets.Images.beardPlaceHolder.uiImage
  
  override func setUp() {
    sut = BeardDataSource()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    sut = nil
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExample() {
    //Given
    let imageHandler = MockImageHandler(stubDeleteImage: { (url: URL) -> AnyPublisher<Void, Never> in
      return Just<Void>(()).eraseToAnyPublisher()
    }) { (url: URL) -> AnyPublisher<UIImage, ImageHandlerError> in
      return Just(self.testImage).setFailureType(to: ImageHandlerError.self).eraseToAnyPublisher()
    }
    sut?.imageHandler = imageHandler
    var spiedDidChangeCount = 0
    _ = sut?.didChange.sink { _ in
      spiedDidChangeCount += 1
    }
    let expect = self.expectation(description: "Finished Test")
    
    //When
    _ = Just<Void>(())
      .delay(for: 1, scheduler: RunLoop.current)
      .map{ [weak sut] _ in sut?.onAppear() }
      .delay(for: 1, scheduler: RunLoop.current)
      .map { [weak sut] _ in sut?.buttonPressed() }
      .sink { _ in
      expect.fulfill()
    }
    
    
    //Then
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(imageHandler.spiedImageURLs.count, 2)
    XCTAssertEqual(imageHandler.spiedDeleteURLs.count, 1)
    XCTAssertEqual(spiedDidChangeCount, 2)
  }
  
}
