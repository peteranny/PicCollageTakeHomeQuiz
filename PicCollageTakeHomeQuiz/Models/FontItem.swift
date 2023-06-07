//
//  FontItem.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import Foundation

/// Reference: https://developers.google.com/fonts/docs/developer_api
struct FontItem {

    /// The kind of object, a webfont object
    let kind: String

    /// The name of the family
    let family: String

    /// A list of scripts supported by the family
    let subsets: [String]

    /// A url to the family subset covering only the name of the family.
    let menu: URL

    /// The different styles available for the family
    let variants: [String]

    /// The font family version.
    let version: String

    /// The date (format "yyyy-MM-dd") the font family was modified for the last time.
    let lastModified: String

    /// The font family files (with all supported scripts) for each one of the available variants.
    let files: [File: URL]
    enum File: String {
        case regular
        case italic
        case oneHundred = "100"
        case oneHundredItalic = "100italic"
        case twoHundred = "200"
        case twoHundredItalic = "200italic"
        case threeHundred = "300"
        case threeHundredItalic = "300italic"
        case fiveHundred = "500"
        case fiveHundredItalic = "500italic"
        case sixHundred = "600"
        case sixHundredItalic = "600italic"
        case sevenHundred = "700"
        case sevenHundredItalic = "700italic"
        case eightHundred = "800"
        case eightHundredItalic = "800italic"
        case nineHundred = "900"
        case nineHundredItalic = "900italic"
    }

    /// XXX: No documentation, but I assume it's a rough category for the font family
    let category: String
}

extension FontItem: Decodable {
    enum CodingKeys: CodingKey {
        case kind
        case family
        case subsets
        case menu
        case variants
        case version
        case lastModified
        case files
        case category
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.kind = try container.decode(String.self, forKey: .kind)
        self.family = try container.decode(String.self, forKey: .family)
        self.subsets = try container.decode([String].self, forKey: .subsets)

        let menu = try container.decode(String.self, forKey: .menu)
        self.menu = URL(string: menu)!

        self.variants = try container.decode([String].self, forKey: .variants)
        self.version = try container.decode(String.self, forKey: .version)
        self.lastModified = try container.decode(String.self, forKey: .lastModified)

        let files = try container.decode([String: String].self, forKey: .files)
        self.files = Dictionary(files.compactMap({ key, value -> (File, URL)? in
            guard let key = File(rawValue: key), let value = URL(string: value) else {
                return nil
            }
            return (key, value)
        }), uniquingKeysWith: { $1 })

        self.category = try container.decode(String.self, forKey: .category)
    }

}
