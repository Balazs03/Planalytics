//
//  YearMonthSelection.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 04. 04..
//

import SwiftUI

struct YearMonthSelection: View {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    let firstYear: Int
    @AppStorage("appLanguage") private var appLanguage: String = "hu"
    
    var body: some View {
        HStack {
            Picker(selection: $selectedYear) {
                ForEach(firstYear...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                    Text(String(year))
                }
            } label: {
                Text("Év")
            }
            
            Divider()
                .frame(height: 20)
                .foregroundStyle(.black)
            
            Picker(selection: $selectedMonth) {
                ForEach(Months.allCases, id: \.self) { month in
                    Text(appLanguage == "hu" ? month.nameHU: month.nameEN).tag(month.rawValue)
                }
            } label: {
                Text("Hónap")
            }
        }
        .tint(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.mainBackground, lineWidth: 2)
        )
    }
}

enum Months: Int, Identifiable, CaseIterable {
    case jan = 1
    case febr
    case march
    case apr
    case may
    case june
    case july
    case aug
    case sept
    case oct
    case nov
    case dec
    
    var id: Int { self.rawValue }
    
    var nameHU: String {
        switch self {
        case .jan:
            "január"
        case .febr:
            "február"
        case .march:
            "március"
        case .apr:
            "április"
        case .may:
            "május"
        case .june:
            "június"
        case .july:
            "július"
        case .aug:
            "augusztus"
        case .sept:
            "szeptember"
        case .oct:
            "október"
        case .nov:
            "november"
        case .dec:
            "december"
        }
    }
    
    var nameEN: String {
        switch self {
        case .jan:
            "january"
        case .febr:
            "february"
        case .march:
            "march"
        case .apr:
            "april"
        case .may:
            "may"
        case .june:
            "june"
        case .july:
            "july"
        case .aug:
            "august"
        case .sept:
            "september"
        case .oct:
            "october"
        case .nov:
            "november"
        case .dec:
            "december"
        }
    }
}
