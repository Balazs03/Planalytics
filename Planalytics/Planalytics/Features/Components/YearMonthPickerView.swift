//
//  YearMonthPickerView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 01. 13..
//

import SwiftUI

struct YearMonthPickerView: View {
    @Binding var selectedDate: Date
    @State private var showPicker: Bool = false
    
    let months: [String] = Calendar.current.shortMonthSymbols
    let columns = [
            GridItem(.adaptive(minimum: 80))
        ]
    
    var body: some View {
        VStack {
            //year picker
            HStack {
                Image(systemName: "chevron.left")
                    .frame(width: 24.0)
                    .onTapGesture {
                        changeYear(by: -1)
                    }
                
                Text(String(Calendar.current.component(.year, from: selectedDate)))
                         .fontWeight(.bold)
                         .transition(.move(edge: .trailing))
                
                Image(systemName: "chevron.right")
                    .frame(width: 24.0)
                    .onTapGesture {
                        changeYear(by: 1)
                    }
                
                Image(systemName: showPicker ? "chevron.up" : "chevron.down" )
                    .frame(width: 24)
                    .onTapGesture {
                        showPicker.toggle()
                    }
            }.padding(15)
            
            if showPicker {
                //month picker
                LazyVGrid(columns: columns, spacing: 20) {
                   ForEach(months, id: \.self) { item in
                        Text(item)
                        .font(.headline)
                        .frame(width: 60, height: 33)
                        .bold()
                        .cornerRadius(8)
                        .onTapGesture {
                            changeMonth(to: item)
                        }
                   }
                }
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    private func changeYear(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .year, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func changeMonth(to value: String) {
        guard let monthIndex = months.firstIndex(of: value) else { return }
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        
        dateComponents.month = monthIndex + 1
        
        if let newDate = Calendar.current.date(from: dateComponents) {
            selectedDate = newDate
        }
    }
}
