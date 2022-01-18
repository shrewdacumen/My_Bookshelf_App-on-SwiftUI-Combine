//
//  ContentView.swift
//  My_Bookself_Application
//
//  Created by sungwook on 1/17/22.
//

import SwiftUI

/// This controls the states of user interaction with `the textField`.
enum TheTextFieldMode {
    /// when tapping the textField and it is before the search execution by pressing the enter key.
    case showCached
    /// the mode when the search result is about to see or shown.
    case showSearchResult
}


struct ContentView: View {
    
    @ObservedObject var the_visited_cache_store: Store_of_The_Visited_Cached
    
    @State var search_key: String = ""
    @State var textField_mode: TheTextFieldMode = .showCached
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Spacer()
                TextField("Enter Book Name Here!", text: $search_key, prompt: Text("mongodb"))
                    .onSubmit {
                        //TODO: incomplete. put REST search query here.
                        
                        //TODO: The following shall be set after getting at least a result.
                        textField_mode = .showSearchResult
                    }
                Spacer()
            }
            .padding(.top, 15)

            
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                Text("Recently Searched")
                Spacer()
                Button {
                    the_visited_cache_store.the_visited_cached.removeAll(keepingCapacity: true)
                } label: {
                    Text("Clear")
                        .font(.headline)
                        .foregroundColor(Color.red)
                }
                Spacer()
            }
            
        }
            
        Divider()
        
        NavigationView {
            List {
                ForEach(the_visited_cache_store.the_visited_cached) { the_cached in
                    VStack(alignment: .center, spacing: 5) {
                        Text(the_cached.isbn13)
                            .fontWeight(.ultraLight)
                        Text(the_cached.title)
                            .font(.headline)
                        
                        
                        /// Those cases of both before thumbnail is cached or when it is being used by `ContentView_Previews`
                        if let thumbnail = the_cached.thumbnail {
                            
                            NavigationLink(destination: BookView(isbn13: the_cached.isbn13)) {
                                thumbnail
                            }
                            // when tapped, textField_mode == .showCached
                            .onTapGesture {
                                textField_mode = .showCached
                            }
                        } else { /// When the cached thumbnail exists,
                            
                            NavigationLink(destination: BookView(isbn13: the_cached.isbn13)) {
                                AsyncImage(url: URL(string: the_cached.image_string), scale: TheControlPanel.thumbnail_scale) { phase in
                                    if case .success(let image) = phase {
                                        image.resizable().onAppear {
                                            the_cached.thumbnail = image
                                        }
                                    }
                                }
                            }
                            // when tapped, textField_mode == .showCached
                            .onTapGesture {
                                textField_mode = .showCached
                            }
                        }
                        
                        
                    }
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(the_visited_cache_store: preview_of_the_visited_cache_store).preferredColorScheme(.dark)
            
            ContentView(the_visited_cache_store: preview_of_the_visited_cache_store).preferredColorScheme(.light)
        }
    }
}
