//
//  ImageHandlerTests.swift
//  TryKingfisherTests
//
//  Created by Paul Wood on 7/5/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import XCTest
import Combine
@testable import TryKingfisher
import Kingfisher

class MockKingfisherImageCache: ImageCacheType {
  var spiedKeys = [String]()
  func removeImage(forKey key: String, completionHandler: (() -> Void)?) {
    spiedKeys.append(key)
    completionHandler?()
  }
}

class MockKingfisherManager: KingfisherManagerType {
  var imageCache: ImageCacheType = MockKingfisherImageCache()
  var spiedResources = [Resource]()
  var spiedOptions = [KingfisherOptionsInfo?]()
  
  func retrieveImage(with resource: Resource,
                     options: KingfisherOptionsInfo?,
                     completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask? {
    spiedResources.append(resource)
    spiedOptions.append(options)
    let resul = success(s)
    completionHandler(resul)
    return nil
  }
}

class ImageHandlerTests: XCTestCase {
  
  var sut: ImageHandler?
  
  override func setUp() {
    sut = ImageHandler()
  }
  
  override func tearDown() {
    sut = nil
  }
  
  func testDelete() {
    //Given
    let mockManager = MockKingfisherManager()
    let cache = MockKingfisherImageCache()
    mockManager.imageCache = cache
    sut?.kingfisherManager = mockManager
    let urlToRequest = URL(string: "http://test.com")!
    
    //When
    sut?.deleteImage(urlToRequest)
    
    //Then
    XCTAssertEqual(cache.spiedKeys.count, 1)
  }
  
  func testRetrieve() {
    //Given
    let mockManager = MockKingfisherManager()
    let cache = MockKingfisherImageCache()
    mockManager.imageCache = cache
    sut?.kingfisherManager = mockManager
    let urlToRequest = URL(string: "http://test.com")!
    
    //When
    sut?.image(urlToRequest)
    
    //Then
    XCTAssertEqual(mockManager.spiedResources.count, 1)
    XCTAssertEqual(mockManager.spiedOptions.count, 1)
  }
  
}
