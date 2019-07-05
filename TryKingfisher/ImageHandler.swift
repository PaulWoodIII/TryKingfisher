//
//  ImageHandler.swift
//  TryKingfisher
//
//  Created by Paul Wood on 7/4/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import Combine
import UIKit
import Kingfisher

/// App specific errors mapped from the Kingfisher Errors
public enum ImageHandlerError: Error {
  
  /// An erroor that should be displayed to the user in some way
  public enum DisplaceableErrorReason: Error {
    case unknown
    
    var displayText: String {
      switch self {
      case .unknown:
        return "Unknown Error Occured"
      }
    }
  }
  
  case displayableError(reason: DisplaceableErrorReason)
  
}

/// Public interface of an Image Handler so objects that need this functionality don't know we have this dependency
/// this allows the dependency to be changed at a future date without changing the code that needs images
protocol ImageHandlerType {
  func deleteImage(_ url: URL) -> AnyPublisher<Void, Never>
  func image(_ url: URL) -> AnyPublisher<UIImage, ImageHandlerError>
}

/// Currently a wrapper over the few things we need Kingfisher for
class ImageHandler: ImageHandlerType {

  /// Delete an image for the URL given
  func deleteImage(_ url: URL) -> AnyPublisher<Void, Never> {
    return Future <Void, Never>(){ promise in
      KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString){
        promise(.success(()))
      }
    }
    .assertNoFailure()
    .eraseToAnyPublisher()
  }

  /// fetches and image or returns an error
  func image(_ url: URL) -> AnyPublisher<UIImage, ImageHandlerError> {
    let resource = ImageResource(downloadURL: url)

    return Future<UIImage, ImageHandlerError>{
      promise in
      let opts = KingfisherOptionsInfo([.forceRefresh, .waitForCache])
      KingfisherManager.shared.retrieveImage(with: resource, options:opts) { result in
        switch result {
        case .success(let result):
          promise( .success(result.image))
        case .failure(_):
          let err = ImageHandlerError.displayableError(reason: .unknown)
          promise(.failure(err))
        }
      }
    }.eraseToAnyPublisher()
  }
}
