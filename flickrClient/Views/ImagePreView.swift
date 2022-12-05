import SwiftUI


// MARK: - Image PreView
/// Shows an image in full screen
struct ImagePreView : View {
    // URL of a loaded image. When set to "", the View is closed
    @Binding var imageURL: String
    @State var offset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.clear
                .edgesIgnoringSafeArea(.all)
                .background(.black)
                .opacity(0.9 - Double(abs(offset.height / 1000)))
            
            AsyncImage(url: .init(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: { Color.clear }
                .modifier(SwipeToDismissModifier(offset: $offset, onDismiss:  { imageURL = "" }))
        }
        .onTapGesture {
            imageURL = ""
        }
    }
}


/// Special modifier to drag a view
/// Reference: https://onmyway133.com/posts/how-to-make-simple-swipe-vertically-to-dismiss-in-swiftui/
struct SwipeToDismissModifier: ViewModifier {
    @Binding var offset: CGSize
    var onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset.width/1.5, y: offset.height/1.5)
            .animation(.interactiveSpring(), value: offset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 50 {
                            offset = gesture.translation
                        }
                    }
                    .onEnded { _ in
                        if abs(offset.height) > 100 {
                            onDismiss()
                        } else {
                            offset = .zero
                        }
                    }
            )
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
