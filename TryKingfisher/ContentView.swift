//
//  ContentView.swift
//  TryKingfisher
//
//  Created by Paul Wood on 7/4/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView : View {
  
  @EnvironmentObject var ds: BeardDataSource
  
    var body: some View {
      VStack {
        Text(ds.viewModel.name)
        Image(uiImage: ds.viewModel.image ?? UIImage())
        Button("Click Me") {
          print("Clicked")
          self.ds.buttonPressed()
        }
      }
      .onAppear{
        self.ds.onAppear()
      }
    }
  
  
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BeardDataSource())
    }
}
#endif
