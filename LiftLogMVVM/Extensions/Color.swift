//
//  Color.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 7/30/25.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let green = Color("GreenColor")
    let red = Color("RedColor")
    let blue = Color("BlueColor")
    let secondaryText = Color("SecondaryTextColor")
}
// If wanted to make an alternative color theme
struct ColorTheme2 {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let green = Color("GreenColor")
    let red = Color("RedColor")
    let secondaryText = Color("SecondaryTextColor")
}
