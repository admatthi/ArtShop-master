//
//  Genre.swift
//  BookNotesDebug
//
//  Created by Alek Matthiessen on 8/5/19.
//

import UIKit

public struct Genre {
    let books: [Book]?

    public init(withJSON json: [String: Any]) {
        self.books = json.enumerated().compactMap({ (_, element) -> Book? in
            let bookID = element.key
            if let bookJSON = element.value as? [String: Any] {

                return Book(withID: bookID, json: bookJSON)
            }
            return nil
        })
    }
}
