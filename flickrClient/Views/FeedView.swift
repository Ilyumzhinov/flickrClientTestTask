import SwiftUI

struct FeedView: View {
    @StateObject var viewModel: ViewModel
    /// Search reference: https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-a-search-bar-to-filter-your-data
    @State private var searchText = ""
    /// Seleted sort type. Default = unsorted
    @State private var sortSelection: ViewModel.SortBy = .defaults
    /// URL of an image preview. If empty, do not show preview
    @State private var showingImage: String = ""
    
    var body: some View {
        NavigationView {
            List(itemsFeed, id: \.self) { item in
                PostView(
                    icon: (item.color, item.authorInitials),
                    image: item.image,
                    author: item.author,
                    date: item.date_taten,
                    tags: item.tags,
                    title: item.title,
                    searchText: $searchText,
                    showingImage: $showingImage
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .searchable(text: $searchText, prompt: "Search for #tag1 #tag2")
            .navigationTitle(searchText.isEmpty ? "Flickr Feed" : "Search: \(searchText)" )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SortView(sortSelection: $sortSelection)
                }
            }
        }
        .overlay {
            if !showingImage.isEmpty {
                ImagePreView(imageURL: $showingImage)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    /// Manages what items are displayed based on search and sort
    var itemsFeed: [ItemWrap] {
        if searchText.isEmpty {
            return viewModel.sortItems(sortSelection)
        }
        else {
            return viewModel.sortItems(sortSelection, viewModel.searchTags(searchText))
        }
    }
}


// MARK: - Sort View
/// A menu to pick a sort
struct SortView: View {
    @Binding var sortSelection: ViewModel.SortBy
    
    var body: some View {
        Menu(content: {
            Picker("Sort items by...", selection: $sortSelection) {
                ForEach([ViewModel.SortBy.defaults, ViewModel.SortBy.title, ViewModel.SortBy.titleDesc, ViewModel.SortBy.date, ViewModel.SortBy.dateDesc], id: \.self) {
                    Text($0.rawValue)
                }
            }
        }, label: {
            sortSelection == .defaults ?
            Image(systemName: "arrow.up.arrow.down.circle") :
            Image(systemName: "arrow.up.arrow.down.circle.fill")
        })
    }
}


// MARK: - Post Header View
/// A view that displays a user avatar, login and publication date
struct PostHeaderView: View {
    let icon: (color: Color, text: String)
    let image: String
    let person: String
    let date: Date
    
    var iconView: some View {
        ZStack {
            Circle()
                .fill(icon.color)
            
            Text(icon.text.uppercased())
        }
        .frame(width: 40, height: 40)
    }
    
    var body: some View {
        HStack {
            HStack {
                iconView
                
                VStack(alignment: .leading) {
                    Text(person)
                        .font(.caption)
                        .bold()
                    Text(date, format: .dateTime)
                        .font(.caption2)
                }
            }
            
            Spacer()
        }
    }
}

/// A view that shows the post image
struct PostContentView: View {
    let imageURL: String
    /// Indicates whether this image is selected. Set to imageURL to select
    @Binding var showingImage: String
    
    var body: some View {
        Button {
            showingImage = imageURL
        } label: {
            AsyncImage(url: .init(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                    ProgressView()
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 250, maxHeight: 250, alignment: .center)
        .clipped()
        .buttonStyle(PlainButtonStyle())
        .cornerRadius(12)
        .contentShape(Rectangle())
    }
    
    struct TapShape : Shape {
        func path(in rect: CGRect) -> Path {
            return Path(CGRect(x: 0, y: 0, width: rect.width, height: 200))
        }
    }
}

/// A view that shows a description and tags
struct PostDescriptionView: View {
    var title: String?
    var tags: [String]
    /// On tag press, set search string to the tag's value
    @Binding var searchText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Button {
                            searchText = tag
                        } label: {
                            Text(tag)
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }
}

/// An individual post view
struct PostView: View {
    let icon: (color: Color, text: String),
        image: String,
        author: String,
        date: Date,
        tags: [String],
        title: String?
    @Binding var searchText: String
    @Binding var showingImage: String
    
    var body: some View {
        VStack {
            PostHeaderView(icon: icon, image: image, person: author, date: date)
            PostContentView(imageURL: image, showingImage: $showingImage)
            PostDescriptionView(title: title, tags: tags, searchText: $searchText)
                .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(viewModel: .init())
    }
}
