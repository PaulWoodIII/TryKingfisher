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
  @Published var viewModel: BeardViewModel
  
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
        //Set current View Model attributes
        self.viewModel.image = result
        self.viewModel.name = self.names.randomElement()!
      }
  }
  
  private func deleteImageFromCache() -> AnyPublisher<Void, Never> {
    return imageHandler.deleteImage(beardUrl)
  }
  
  /// Getter for the didChange Publisher to conform to `BindableObject`
  lazy var didChange: AnyPublisher<Void, Never> = {
    return self.$viewModel
      .publisher(for: \.image, \.name)
      .throttle(for: 1, scheduler: RunLoop.main, latest: true)
      .map{ _ in return }
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }()
  
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
