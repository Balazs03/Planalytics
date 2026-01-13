//
//  AppColors.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 13..
//

import SwiftUI

extension Color {
    // 1. #F8FAFC - Háttér
    static let appBackground = Color.white.mix(with: .blue, by: 0.03)
    
    // 2. #D9EAFD - Kiemelés / Akcentus (pl. kártyák háttere)
    static let appAccent = Color.blue.mix(with: .white, by: 0.75)
    
    // 3. #BCCCDC - Másodlagos elemek (pl. inaktív gombok, szegélyek)
    static let appSlate = Color.gray.mix(with: .blue, by: 0.3)
    
    // 4. #9AA6B2 - Szövegek és ikonok
    static let appText = Color.gray.mix(with: .blue, by: 0.15)
}
