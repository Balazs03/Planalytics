//
//  SetPinSheet.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 03. 06..
//

import SwiftUI

struct SetPinSheet: View {
    @AppStorage("isPinCodeSet") private var isPinCodeSet: Bool = false
    @AppStorage("pinCode") private var pinCode: String = ""
    @Environment(Coordinator.self) private var coordinator

    @State private var vm: SetPinSheetViewModel
    
    init(vm: SetPinSheetViewModel) {
        self.vm = vm
    }

    var body: some View {
        VStack {
            Spacer()
            
            if vm.isFirstPinSaved {
                Text("Ismételd meg a kódot")
            }
            
            HStack {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .frame(width: 30)
                        .foregroundStyle(vm.currentPin.count > index ? .gray : .black)
                }
            }
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: vm.animateField, content: { content, value in
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
            .padding()
            
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(1...9, id: \.self) { number in
                    Button {
                        if vm.currentPin.count < 4 {
                            vm.currentPin.append("\(number)")
                        }
                    } label: {
                        Text("\(number)")
                    }
                    .frame(width: 40, height: 40)
                }
                
                Button {
                    if vm.currentPin.count > 0 {
                        vm.currentPin = String(vm.currentPin.dropLast())
                    }
                } label: {
                    Image(systemName: "delete.left")
                }
                .frame(width: 40, height: 40)
                
                Button {
                    if vm.currentPin.count < 4 {
                        vm.currentPin.append("0")
                    }
                } label: {
                    Text("0")
                }
                .frame(width: 40, height: 40)
            }
            .padding()
        }
        .onChange(of: vm.currentPin) { oldValue, newValue in
            if vm.currentPin.count >= 4 && vm.isFirstPinSaved == false {
                vm.firstSavedPin = vm.currentPin
                vm.currentPin = ""
                vm.isFirstPinSaved = true
                
            } else if vm.currentPin.count >= 4 && vm.isFirstPinSaved == true {
                if vm.isValid {
                    isPinCodeSet = true
                    pinCode = vm.currentPin
                    coordinator.dismissSheet()
                } else {
                    vm.currentPin = ""
                    vm.animateField.toggle()
                }
            }
        }
    }
}

#Preview {
    let vm = SetPinSheetViewModel()
    SetPinSheet(vm: vm)
}
