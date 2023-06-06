//
//  FontModel.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/5.
//

import RxCocoa
import UIKit

struct FontModel {
    let item: FontItem
    let menu: Driver<String?>
    let state: Driver<FontState?>
    var selected: Bool
}
