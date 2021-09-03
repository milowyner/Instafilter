//
//  ContentView.swift
//  Instafilter
//
//  Created by Milo Wyner on 9/2/21.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var intensity: Float = 1.0
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var currentFilter: CIFilter?
    @State private var setIntensity: ((Float) -> ())?
    
    var body: some View {
        let intensityBinding = Binding<Float> {
            intensity
        } set: {
            intensity = $0
            loadImage(with: intensity)
        }
        
        return NavigationView {
            VStack {
                Text("Tap to select a picture")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray)
                    .aspectRatio(1.5, contentMode: .fit)
                    .overlay(
                        image?
                            .resizable()
                            .scaledToFill()
                    )
                    .clipped()
                    .onTapGesture {
                        showingImagePicker = true
                    }
                
                HStack {
                    Text("Intensity:")
                    Text("0%")
                    Slider(value: intensityBinding, in: 0...1.0)
                    Text("100%")
                }
                .padding()
                
                Button("Select Filter") {
                    showingActionSheet = true
                }
            }
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: { loadImage(with: intensity) }, content: {
                ImagePicker(image: $inputImage)
            })
            .actionSheet(isPresented: $showingActionSheet, content: {
                ActionSheet(title: Text("Choose a filter"), buttons: [
                    .default(Text("Sepia")) {
                        currentFilter = CIFilter.sepiaTone()
                        setIntensity = setSepiaIntensity
                        loadImage(with: intensity)
                    },
                    .default(Text("Crystallize")) {
                        currentFilter = CIFilter.crystallize()
                        setIntensity = setCrystallizeIntensity
                        loadImage(with: intensity)
                    },
                    .default(Text("Twirl")) {
                        currentFilter = CIFilter.twirlDistortion()
                        setIntensity = setTwirlIntensity
                        loadImage(with: intensity)
                    },
                    .cancel()
                ])
            })
        }
    }
    
    func setSepiaIntensity(_ intensity: Float) {
        guard let currentFilter = currentFilter as? CISepiaTone else { return }
        currentFilter.intensity = intensity
    }
    
    func setCrystallizeIntensity(_ intensity: Float) {
        guard let currentFilter = currentFilter as? CICrystallize else { return }
        currentFilter.radius = intensity * 100
    }
    
    func setTwirlIntensity(_ intensity: Float) {
        guard let currentFilter = currentFilter as? CITwirlDistortion,
              let inputImage = inputImage else { return }
        print("twirl")
        currentFilter.radius = 400
        currentFilter.angle = intensity * 2 * .pi
        currentFilter.center = CGPoint(x: inputImage.size.width / 2, y: inputImage.size.height / 2)
    }
    
    func loadImage(with intensity: Float) {
        guard let inputImage = inputImage else { return }
        guard let currentFilter = currentFilter else {
            image = Image(uiImage: inputImage)
            return
        }
        
        let beginImage = CIImage(image: inputImage)
        let context = CIContext()
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        setIntensity?(intensity)
        
        guard let outputImage = currentFilter.outputImage else { return }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)

            image = Image(uiImage: uiImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
