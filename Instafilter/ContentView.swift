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
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var filterIntensity = 0.5
    @State private var showingImagePicker = false
    @State private var showingFilterSheet = false
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    @State private var showingErrorAlert = false
    
    let context = CIContext()
    
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)

                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    showingImagePicker = true
                }

                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }.padding(.vertical)

                HStack {
                    Button("\(CIFilter.localizedName(forFilterName: currentFilter.name) ?? "Filter")") {
                        showingFilterSheet = true
                    }

                    Spacer()

                    Button("Save") {
                        guard let processedImage = processedImage else {
                            showingErrorAlert = true
                            return
                        }
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Success!")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                        
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: ([
                    CIFilter.crystallize(),
                    CIFilter.edges(),
                    CIFilter.gaussianBlur(),
                    CIFilter.pixellate(),
                    CIFilter.sepiaTone(),
                    CIFilter.unsharpMask(),
                    CIFilter.vignette()
                ] as [CIFilter]).map { filter in
                    .default(Text(name(of: filter))) { setFilter(filter) }
                } + [.cancel()])
            }
            .alert(isPresented: $showingErrorAlert, content: {
                Alert(title: Text("Error"), message: Text("No image selected"))
            })
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 100, forKey: kCIInputScaleKey) }
        if currentFilter.name == "CIEdges" {
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputIntensityKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            processedImage = uiImage
            image = Image(uiImage: uiImage)
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    func name(of filter: CIFilter) -> String {
        CIFilter.localizedName(forFilterName: filter.name) ?? ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
