//
//  FontLoader.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/6.
//

import Foundation
import UIKit

enum FontLoader {
    /// Download the font data from the given URL and register it
    /// - Parameter url: The URL to the font data
    /// - Returns: The registered font. Return `nil` when something goes wrong.
    static func loadFont(for data: NSData) -> String? {
        var error: Unmanaged<CFError>?
        let bytes = UnsafePointer<UInt8>(OpaquePointer(data.bytes))
        guard let cfdata = CFDataCreate(nil, bytes, data.length) else {
            return nil
        }
        guard let provider = CGDataProvider(data: cfdata) else {
            return nil
        }
        guard let fontRef = CGFont(provider) else {
            return nil
        }
        guard CTFontManagerRegisterGraphicsFont(fontRef, &error) else {
            return nil
        }
        guard let font = fontRef.postScriptName as? String else {
            return nil
        }
        return font
    }
}
