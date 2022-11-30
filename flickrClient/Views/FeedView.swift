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
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(itemsFeed, id: \.self) { item in
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
                }
            }
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
        Picker("Sort items by...", selection: $sortSelection) {
            ForEach([ViewModel.SortBy.defaults, ViewModel.SortBy.title, ViewModel.SortBy.titleDesc, ViewModel.SortBy.date, ViewModel.SortBy.dateDesc], id: \.self) {
                Text($0.rawValue)
            }
        }
        .pickerStyle(.menu)
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
                    .frame(minHeight: 250, maxHeight: 250)
                    .clipped()
            } placeholder: {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(height: 250)
                    ProgressView()
                }
            }
        }.buttonStyle(PlainButtonStyle())
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
                .padding(.horizontal)
            PostContentView(imageURL: image, showingImage: $showingImage)
            PostDescriptionView(title: title, tags: tags, searchText: $searchText)
                .padding(.horizontal)
        }
        .padding(.bottom)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let dates: [Date] = [
            "2022-11-28T18:21:57-08:00",
            "2022-11-22T10:35:42-08:00"
        ]
            .map { ISO8601DateFormatter().date(from: $0)! }
        
        let items: [Item] = [
            .init(author: "nobody@flickr.com (\"Ww Yo\")", title: "My multiline mega long title that spans across unbelievable lengths", link: "https://ic.pics.livejournal.com/region111/14528387/40279/40279_original.jpg", date_taken: dates[0], tags: "tag1 tag2 tag3 tag4 tag5 tag6 tag7 tag8 tag9 tag10", media: .init(m: "https://ic.pics.livejournal.com/region111/14528387/40279/40279_original.jpg")),
            .init(author: "nobody@flickr.com (\"You 2\")", title: "Hail U", link: "https://im3.turbina.ru/photos.4/6/0/2/4/8/2184206/big.photo/Ekspeditsiya-v-Kazakhstan.jpg", date_taken: dates[1], tags: "tag3 tag4 tag33", media: .init(m: "https://im3.turbina.ru/photos.4/6/0/2/4/8/2184206/big.photo/Ekspeditsiya-v-Kazakhstan.jpg"))]
        let vm = ViewModel(items: items)
        
        return FeedView(viewModel: vm)
    }
}
