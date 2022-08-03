//
//  MeView.swift
//  HotProspects
//
//  Created by Paul Hudson on 03/01/2022.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    @State private var name = "Anonymous"
    @State private var emailAddress = "you@yoursite.com"
    @State private var qrCode = UIImage()

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name) // helps autocomplete
                    .font(.title)

                TextField("Email address", text: $emailAddress)
                    .textContentType(.emailAddress) // helps autocomplete
                    .font(.title)

                Image(uiImage: qrCode)
                    .resizable()
                    .interpolation(.none) // keep the qr code intact
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                        Button {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: qrCode)
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
            }
            .navigationTitle("Your code")
            .onAppear(perform: updateCode)
            .onChange(of: name) { _ in updateCode() }
            .onChange(of: emailAddress) { _ in updateCode() }
        }
    }

    /// Cache the QR Code
    func updateCode() {
        qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
    }

    /// Generate a QR code from user's name \n email
    /// converts:  String -> Data -> CIImage -> UIImage
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            // cast to a CG image
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                // cast to a UI Image
                return UIImage(cgImage: cgimg)
            }
        }
        // if above code fails. should never happen.
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
