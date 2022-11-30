import SwiftUI


// MARK: - Image PreView
struct ImagePreView : View {
    // URL of a loaded image. When set to "", the View is closed
    @Binding var imageURL: String
    
    var body: some View {
        ZStack {
            Color.clear
                .edgesIgnoringSafeArea(.all)
                .background(.black)
                .opacity(0.9)
            
            Button {
                imageURL = ""
            } label: {
                AsyncImage(url: .init(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: { Color.clear }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}


struct ImageView_Previews: PreviewProvider {
    struct TempView: View {
        static let url: String = "https://im3.turbina.ru/photos.4/6/0/2/4/8/2184206/big.photo/Ekspeditsiya-v-Kazakhstan.jpg"
        @State var isPresented: String = ""
        
        var body: some View {
            NavigationView {
                Button("Click me") {
                    isPresented = TempView.url
                }
            }
            .overlay {
                if !isPresented.isEmpty {
                    ImagePreView(imageURL: $isPresented)
                }
            }
        }
    }
    
    static var previews: some View {
        TempView()
    }
}
