//
//  SetPinSheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 03. 06..
//

import SwiftUI

struct SetPinSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPinCodeSet") private var isPinCodeSet: Bool = false
    @AppStorage("pinCode") private var pinCode: String = ""
    @State var currentPin = ""
    @State var firstSavedPin: String?
    @State var isFirstPinSaved: Bool = false
    @State var animateField: Bool = false
    var isValid: Bool {
        return !currentPin.isEmpty && currentPin == self.firstSavedPin && currentPin.count == 4
    }

    var body: some View {
        VStack {
            Spacer()
            Text("Pin megadása")
            
            if isFirstPinSaved {
                Text("Ismételd meg a kódot")
            }
            
            HStack {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .frame(width: 30)
                        .foregroundStyle(currentPin.count > index ? Color.mint : .primary)
                }
            }
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: animateField, content: { content, value in
                content.offset(x: value)
                
            }, keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(30, duration: 0.05)
                    CubicKeyframe(-30, duration: 0.05)
                    CubicKeyframe(20, duration: 0.05)
                    CubicKeyframe(-20, duration: 0.05)
                    CubicKeyframe(0, duration: 0.05)

                }
            })
            .padding()
            
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(1...9, id: \.self) { number in
                    Button {
                        if currentPin.count < 4 {
                            currentPin.append("\(number)")
                        }
                    } label: {
                        Text("\(number)")
                            .font(.title)
                    }
                    .frame(width: 60, height: 60)
                    .buttonStyle(.glass)
                }
                
                Button {
                    if currentPin.count > 0 {
                        currentPin = String(currentPin.dropLast())
                    }
                } label: {
                    Image(systemName: "delete.left")
                        .font(.title)
                }
                .frame(width: 60, height: 60)
                .buttonStyle(.glass)
                
                Button {
                    if currentPin.count < 4 {
                        currentPin.append("0")
                    }
                } label: {
                    Text("0")
                        .font(.title)
                }
                .frame(width: 60, height: 60)
                .buttonStyle(.glass)
            }
            .padding()
        }
        .background()
        .onChange(of: currentPin) { oldValue, newValue in
            if currentPin.count >= 4 && isFirstPinSaved == false {
                firstSavedPin = currentPin
                currentPin = ""
                isFirstPinSaved = true
                
            } else if currentPin.count >= 4 && isFirstPinSaved == true {
                if isValid {
                    isPinCodeSet = true
                    pinCode = currentPin
                    dismiss()
                } else {
                    currentPin = ""
                    animateField.toggle()
                }
            }
        }
    }
}

#Preview {
    SetPinSheet()
}
