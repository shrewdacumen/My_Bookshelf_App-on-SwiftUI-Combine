//
//  BookView.swift
//  My_Bookself_Application
//
//  Created by sungwook on 1/18/22.
//

import SwiftUI
import Combine


/// The implementation for `DetailBook` in the diagram.
struct BookView: View {
    let isbn13: String
    
    @State var fulltext = "Write your note here"
    
    /// ** CAVEAT **
    /// This is an observed object: `a reference type`, not a value type!!!
    @StateObject var get_the_selected_book = GetTheSelectedBook()
    
    @ObservedObject var the_visited_cache_store: Store_of_The_Visited_Cached
    
    @ObservedObject var the_visited_cached: TheVisitedCached
    
    @EnvironmentObject var userNote: UserNote
    
    var body: some View {
        
        /// ** CAVEAT **
        /// I segmented SwiftUI views by VStack to avoid the following error.
        /// **ERROR**: The compiler is unable to type-check this expression in reasonable time;
        ///             try breaking up the expression into distinct sub-expressions
        List {
            
            /// Only after the loading is finished, `the_selected_book` shall be NOT `nil`,
            if let the_selected_book = get_the_selected_book.the_selected_book {
                
                VStack(alignment: .leading, spacing: 10) {

                    /// This section will appear only when `error_code != 0`,
                    if let error_code = Int(the_selected_book.error), error_code != 0 {
                        HStack {
                            Text("error code")
                                .padding(.trailing, 20)
                            Text(the_selected_book.error)
                        }
                    }
                    
                    TextEditor(text: $fulltext)
                        .foregroundColor(Color.gray)
                        .font(.custom("HelveticaNeue", size: 13))
                        .onAppear {
                            if let note_string_stored = userNote.notes[isbn13] {
                                fulltext = note_string_stored
                            }
                        }
                        .onChange(of: fulltext) { newValue in
                            userNote.notes[isbn13] = newValue
                        }
                    
                    HStack {
                        Text("title")
                            .padding(.trailing, 20)
                        Text(the_selected_book.title)
                    }
                    
                    HStack {
                        Text("subtitle")
                            .padding(.trailing, 20)
                        Text(the_selected_book.subtitle)
                    }
                }
                
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    HStack {
                        Text("authors")
                            .padding(.trailing, 20)
                        Text(the_selected_book.authors)
                    }
                    
                    HStack {
                        Text("publisher")
                            .padding(.trailing, 20)
                        Text(the_selected_book.publisher)
                    }
                    
                    HStack {
                        Text("isbn10")
                            .padding(.trailing, 20)
                        Text(the_selected_book.isbn10)
                            .fontWeight(.light)
                    }
                    
                    HStack {
                        Text("isbn13")
                            .padding(.trailing, 20)
                        Text(the_selected_book.isbn13)
                            .fontWeight(.light)
                    }
                    
                    HStack {
                        Text("pages")
                            .padding(.trailing, 20)
                        Text(the_selected_book.pages)
                    }
                    
                    HStack {
                        Text("year")
                            .padding(.trailing, 20)
                        Text(the_selected_book.year)
                    }
                    
                }
                
                
                /// * CAVEAT *
                /// `VStack` has a limit of 13 views to produce the resulting `View protocol`,
                ///   related to `@ViewBuilder`
                /// * Its Solution *
                /// I fragmented 14 elements by two VStacks.
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("rating")
                            .padding(.trailing, 20)
                        HStack {
                            if let rating = Int(the_selected_book.rating), rating >= 1 {
                                ForEach(1...rating, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                }
                            } else {
                                Image(systemName: "xmark.octagon")
                            }
                        }
                    }
                    
                    HStack {
                        Text("descrition")
                            .padding(.trailing, 20)
                        Text(the_selected_book.desc)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                    
                    HStack {
                        Text("price")
                            .padding(.trailing, 20)
                        Text(the_selected_book.price)
                    }
                    
                    HStack {
                        Text("image")
                            .padding(.trailing, 20)
                        AsyncImage(url: URL(string: the_selected_book.image)) { image in
                            image
                                .resizable()
                                .frame(width: TheControlPanel.BookView_image_size.width, height: TheControlPanel.BookView_image_size.height, alignment: .center)
                            
                        } placeholder: {
                            ZStack {
                                Text("Loading ...")
                                    .foregroundColor(Color.yellow)
                                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                                    .frame(width: TheControlPanel.BookView_image_size.width, height: TheControlPanel.BookView_image_size.height, alignment: .center)
                                    .foregroundColor(Color.blue)
                            }
                        }
                    }
                    .frame(height: TheControlPanel.BookView_image_size.height, alignment: .leading)
                    //                    .padding(.top, 15)
                    //                    .padding(.bottom, 15)
                    
                    HStack {
                        Text("URL")
                            .padding(.trailing, 20)
                        Link("Click to Open", destination: URL(string: the_selected_book.url)!)
                    }
                    
                    HStack {
                        Text("PDF")
                            .padding(.trailing, 20)
                        VStack {
                            /// ** The Previous Error **
                            /// Generic struct 'ForEach' requires that 'Dictionary<String, String>.Keys' conform to 'RandomAccessCollection'
                            /// ** Its Solution **
                            /// The return value of keys.sorted() has solved under `ForEach()`
                            if the_selected_book.pdf != nil {
                                ForEach(the_selected_book.pdf!.keys.sorted(), id: \.self) { key in
                                    Text(key)
                                    Link("Click to Open", destination: URL(string: the_selected_book.pdf![key]!)!)
                                }
                            } else {
                                Text("NOT FOUND")
                            }
                        }
                    }
                    
                }
                
            } else { /// As long as `get_the_selected_book.the_selected_book == nil`
                
                Text("Getting the data from a remote endpoint...")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                
#if DEBUG /// This is only for debugging
                Text(isbn13)
                    .fontWeight(.light)
                    .padding(.top, 50)
#endif
            }
            
        } /// THE END OF List {}
        .onAppear {
            /// accessing the remote end point IT Bookstore API/books
            get_the_selected_book.get_the_selected_book(isbn13: isbn13)
            
            /// add the visited book to the cache.
            add_the_data_to_the_cache(the_cached: the_visited_cached)
        }
        .onDisappear {
            /// clean up threadings to avoid memory leaks.
            get_the_selected_book.cleanUp()
        }
    }
    
    /// `func add_the_data_to_the_cache()`
    /// add the visited book to the cache.
    ///
    ///  ** ASSUMPTION **
    /// when tapped, textField_mode == .showCached
    /// To paraphrase it, when tapping the searched item, it will be cached,
    func add_the_data_to_the_cache(the_cached: TheVisitedCached) {
        /// When clicking the NavigationLink, it will cache it by appending it
        the_visited_cache_store.the_visited_cached.insert(TheVisitedCached(title: the_cached.title, isbn13: the_cached.isbn13, image_string: the_cached.image_string, thumbnail: the_cached.thumbnail))
    }
    
}

//struct BookView_Previews: PreviewProvider {
//    static var previews: some View {
//        /// When isbn13 becomes @Binding var, the following is necessary:
//        // BookView(isbn13: Binding(get: { preview_of_the_visited_cache_store.the_visited_cached.first!.isbn13 }, set: {_ in }))
//        BookView(isbn13: preview_of_the_visited_cache_store.the_visited_cached.first!.isbn13 )
//    }
//}
