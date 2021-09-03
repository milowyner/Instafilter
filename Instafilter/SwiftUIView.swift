//
//  SwiftUIView.swift
//  Instafilter
//
//  Created by Milo Wyner on 9/3/21.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack {
            Button("Log in") { }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .clipShape(Capsule())

            Button("Reset Password") { }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .clipShape(Capsule())
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
