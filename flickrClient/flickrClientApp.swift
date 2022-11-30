//
//  flickrClientApp.swift
//  flickrClient
//
//  Created by Artem Ilyumzhinov on 11/28/22.
//

import SwiftUI

@main
struct flickrClientApp: App {
    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: .init())
        }
    }
}
