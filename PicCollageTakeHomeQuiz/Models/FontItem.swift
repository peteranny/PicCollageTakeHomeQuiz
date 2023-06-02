//
//  FontItem.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import Foundation

/// Reference: https://developers.google.com/fonts/docs/developer_api
struct FontItem: Decodable {

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
    let files: [String: String]

    /// XXX: No documentation, but I assume it's a rough category for the font family
    let category: String

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
        self.files = try container.decode([String: String].self, forKey: .files)
        self.category = try container.decode(String.self, forKey: .category)
    }

}
