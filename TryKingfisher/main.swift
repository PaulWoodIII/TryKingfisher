//
//  main.swift
//  TryKingfisher
//
//  Created by Paul Wood on 7/5/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation

import UIKit

let appDelegateClass: AnyClass = NSClassFromString("TestingAppDelegate") ?? AppDelegate.self
print(CommandLine.arguments)
UIApplicationMain(
  CommandLine.argc,
  CommandLine.unsafeArgv,
  nil,
  NSStringFromClass(appDelegateClass)
)
