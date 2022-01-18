//
//  BookView.swift
//  My_Bookself_Application
//
//  Created by sungwook on 1/18/22.
//

import SwiftUI
import Combine


struct BookView: View {
    let isbn13: String
    
    /// ** CAVEAT **
    /// I segmented SwiftUI views by VStack to avoid the following error.
    /// **ERROR**: The compiler is unable to type-check this expression in reasonable time;
    ///             try breaking up the expression into distinct sub-expressions
    @ObservedObject var get_the_selected_book = GetTheSelectedBook()
    
    var body: some View {
        
        List {
            
            /// Only after the loading is finished, `the_selected_book` shall be NOT `nil`,
            if let the_selected_book = get_the_selected_book.the_selected_book {
                
                VStack(alignment: .leading, spacing: 10) {
                    
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
                            ForEach(1...Int(the_selected_book.rating)!, id: \.self) { _ in
                                Image(systemName: "star.fill")
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
                        AsyncImage(url: URL(string: the_selected_book.image), scale: TheControlPanel.BookView_scale) { phase in
                            if case .success(let image) = phase {
                                image
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                    .frame(width: .infinity, height: 150, alignment: .center)
                    
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
                
#if DEBUG /// This is only for debugging
                Text(isbn13)
                    .fontWeight(.light)
#endif
            }
            
        } /// THE END OF List {}
        .onAppear {
            // TODO: incomplete. I need to test this part.
            get_the_selected_book.get_the_selected_book(isbn13: isbn13)
        }
        .onDisappear {
            get_the_selected_book.cleanUp()
        }
    }
    
    
    
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        /// When isbn13 becomes @Binding var, the following is necessary:
        // BookView(isbn13: Binding(get: { preview_of_the_visited_cache_store.the_visited_cached.first!.isbn13 }, set: {_ in }))
        BookView(isbn13: preview_of_the_visited_cache_store.the_visited_cached.first!.isbn13 )
    }
}