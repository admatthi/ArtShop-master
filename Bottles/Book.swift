//
//  Book.swift
//  BookNotesDebug
//
//  Created by Alek Matthiessen on 8/5/19.
//

import UIKit

struct Book {
    
    let bookID: String
    let author: String?
    let description: String?
    let imageURL: String?
    let name: String?
    let genre: String?
    let headline1: String?
    let headline2: String?
    let headline3: String?
    let headline4: String?
    let headline5: String?
    let headline6: String?
    let headline7: String?
    let headline8: String?
    let headline9: String?
    let headline10: String?
    let headline11: String?
    let headline12: String?
    let headline13: String?
    let headline14: String?
    let headline15: String?
    let headline16: String?
    let headline17: String?
    let headline18: String?
    let headline19: String?
    let headline20: String?
    let cliffhanger: Int?
    let audioURL: String?
    let popularity: Int?
    let duration: Int?
    let original: String?
    let amazonURL: String?
    let profession: String?
    let authorImage: String?
    let text1: String?
    let text2: String?
    let text3: String?
    let date: String?
    let intdate: Int?
    let title: String?
    let originalprice: String?
    let newprice: String?
    let brand: String?




    init(withID id: String, json: [String: Any]) {
        self.bookID = id
        self.originalprice = json["orignal_price"] as? String
        self.brand = json["brand"] as? String

        self.newprice = json["new_price"] as? String
        self.author = json["Author"] as? String
        self.description = json["Description"] as? String
        self.imageURL = json["image"] as? String
        self.name = json["name"] as? String
        self.genre = json["Genre"] as? String
        self.headline1 = json["Headline1"] as? String
        self.headline2 = json["Headline2"] as? String
        self.headline3 = json["Headline3"] as? String
        self.headline4 = json["Headline4"] as? String
        self.headline5 = json["Headline5"] as? String
        self.headline6 = json["Headline6"] as? String
        self.headline7 = json["Headline7"] as? String
        self.headline8 = json["Headline8"] as? String
        self.headline9 = json["Headline9"] as? String
        self.headline10 = json["Headline10"] as? String
        self.headline11 = json["Headline11"] as? String
        self.headline12 = json["Headline12"] as? String
        self.headline13 = json["Headline13"] as? String
        self.headline14 = json["Headline14"] as? String
        self.headline15 = json["Headline15"] as? String
        self.headline16 = json["Headline16"] as? String
        self.headline17 = json["Headline17"] as? String
        self.headline18 = json["Headline18"] as? String
        self.headline19 = json["Headline19"] as? String
        self.headline20 = json["Headline20"] as? String
        self.cliffhanger = json["Cliffhanger"] as? Int
        self.popularity = json["Popularity"] as? Int
        self.audioURL = json["AudioURL"] as? String
        self.duration = json["Duration"] as? Int
        self.amazonURL = json["url"] as? String
        self.original = json["Original"] as? String
        self.profession = json["Profession"] as? String
        self.authorImage = json["Author Image"] as? String
        self.text1 = json["Text0"] as? String
        self.text2 = json["Text1"] as? String
        self.text3 = json["Text2"] as? String
        self.date = json["date"] as? String
        self.intdate = json["IntDate"] as? Int
        self.title = json["Title"] as? String




    }
}
