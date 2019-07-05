//
//  BeardDataSource.swift
//  TryKingfisher
//
//  Created by Paul Wood on 7/5/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

protocol BeardDataSourceType {
  var viewModel: BeardViewModel { get }
  func onAppear()
}

class BeardDataSource: BindableObject {
  
  
  private static let beardUrlString = "https://placebeard.it/120"
  private let beardUrl = URL(string: beardUrlString)!
  
  /// Could add @Published here
  var viewModel: BeardViewModel
  
  /// Injectable 
  var imageHandler: ImageHandlerType = ImageHandler()
  
  init() {
    viewModel = BeardViewModel(image: nil,
                               name: names.randomElement()!)
  }

  func onAppear() {
    getNewImage()
  }
  
  func buttonPressed() {
    _ = deleteImageFromCache()
      .sink { _ in
      self.getNewImage()
    }
  }
  
  private var imageDownloadTask: Cancellable?
  private func getNewImage() {
    imageDownloadTask?.cancel()
    imageDownloadTask = imageHandler.image(beardUrl)
      .receive(on: RunLoop.main)
      .sink { (result: UIImage) in
        print("Will Update")

        //Set current View Model attributes
//        self.viewModel.image = result
//        self.viewModel.name = self.names.randomElement()!
        
        // Set view model with a new view model
        self.viewModel = BeardViewModel(image: result,
                                        name: self.newName())
        
        self._didChange.send()
    }
  }
  
  private func deleteImageFromCache() -> AnyPublisher<Void, Never> {
    return imageHandler.deleteImage(beardUrl)
  }
  
  /// Hide the PassthroughSubject so nefarious objects don't call `.send()` on it
  /// really only this object should know to do that
  private var _didChange = PassthroughSubject<Void, Never>()
  
  /// Getter for the didChange Publisher to conform to `BindableObject`
  var didChange: AnyPublisher<Void, Never> {

    // Niave implementation was to use a subject as the publisher
    return _didChange
      .subscribe(on: RunLoop.main)
//      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
    
    // I'd Prefer to use Combine and merged streams to trigger DidChange but
    // that isn't working so I started to add test to find out why
    
    // use the viewModel itself
//    return self.$viewModel
//      .receive(on: RunLoop.main)
//      .map{ _ in return ()}
//      .assertNoFailure().eraseToAnyPublisher()
    
    // use the view model's attributes
//    return $viewModel.publisher(for: \.name, \.image)
//      .map { _ -> () in
//        print("Did Change")
//    }
//      .receive(on: RunLoop.main)
//      .eraseToAnyPublisher()

  }
  
  /// Some Names to use
  private let names: [String] = [
  "Adam", "Bob", "Charlie", "Dick", "Edgar", "Frank", "George", "Harry", "Tom",
  ]
  
  /// Helper method to get a new Name
  private func newName() -> String {
    return names.randomElement()!
  }
}

struct BeardViewModel {
  // Tried adding @Published here but that doesn't seem right since
  // the struct would contain a variable to a publisher that wouldn't mutate
  var image: UIImage?
  var name: String = ""
}
