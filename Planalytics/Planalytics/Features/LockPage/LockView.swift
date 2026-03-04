//
//  LockView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 03. 04..
//

import SwiftUI

struct LockView: View {
    @State var vm: LockViewModel
    
    var body: some View {
        if vm.isEnabled && !vm.isUnlocked {
            if vm.lockType == .both {
                if vm.biometricAvailable {
                    VStack {
                        Button{
                            
                        } label: {
                            VStack {
                                Image(systemName: "lock")
                                    .font(.largeTitle)
                                Text("Érintsd meg a feloldáshoz")
                            }
                            .padding()
                        }
                        .background(.green, in: .rect(cornerRadius: 10))
                        
                        Button {
                        } label: {
                            Text("Feloldás pin kóddal")
                                .padding()
                        }
                        .background(.green, in: .rect(cornerRadius: 10))
                        
                    }
                } else {
                    Text("Unlock biometric recongition in the Settings to use it")
                }
                
            } else {
                NumberPadView()
            }
        }
    }
    
    @ViewBuilder
    func NumberPadView() -> some View {
        VStack(spacing: 15) {
            Spacer()
            Text("Pin megadása")
            HStack {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .frame(width: 30)
                        .foregroundStyle(vm.currentPin.count >= index + 1 ? .blue : .black)
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
            
            Button("Elfelejtett jelszó?") {
                
            }
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(1...9, id: \.self) { number in
                    Button {
                        if vm.currentPin.count < 4 {
                            vm.currentPin.append(String(number))
                        }
                    } label: {
                        Text("\(number)")
                    }
                    .frame(width: 40, height: 40)
                }
                
                Button {
                    if !vm.currentPin.isEmpty {
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
            if vm.currentPin.count == 4 {
                if vm.currentPin == vm.actualPin {
                    print("Unlocked")
                } else {
                    print("Wrong")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        vm.currentPin = ""
                    }
                    vm.animateField.toggle()
                }
            }
        }
    }
}

#Preview {
    let vm = LockViewModel(currentPin: "", lockType: .both, actualPin: "0123", isEnabled: true)
    LockView(vm: vm)
}
