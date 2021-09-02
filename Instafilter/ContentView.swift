//
//  ContentView.swift
//  Instafilter
//
//  Created by Milo Wyner on 9/2/21.
//

import SwiftUI

struct ContentView: View {
    @State private var blurAmount: CGFloat = 0

    var body: some View {
        let blur = Binding<CGFloat> {
            blurAmount
        } set: {
            blurAmount = $0
            print("New value is \(blurAmount)")
        }
        
        return VStack {
            Text("Hello, World!")
                .blur(radius: blurAmount)

            Slider(value: blur, in: 0...20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
