//
//  LockView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 03. 04..
//

import SwiftUI
internal import LocalAuthentication

struct LockView: View {
    @State var vm: LockViewModel
    @AppStorage("isLockEnabled") private var isLockEnabled: Bool = false
    @AppStorage("isPinCodeSet") private var isPinCodeSet: Bool = false
    @AppStorage("pinCode") private var pinCode: String = ""
    
    var body: some View {
        VStack {
            NumberPadView()
        }
        .onAppear {
            vm.unlockWithFaceID()
        }
    }
    
    @ViewBuilder
    private func NumberPadView() -> some View {
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
                vm.showAlert.toggle()
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
                
                Button {
                    vm.unlockWithFaceID()
                } label: {
                    if let biometricType = vm.getBiometricType() {
                        if biometricType == .faceID {
                            Image(systemName: "faceid")
                        } else if biometricType == .touchID {
                            Image(systemName: "touchid")
                        }
                    }
                }
                .frame(width: 40, height: 40)
            }
            .padding()
        }
        .onChange(of: vm.currentPin) { oldValue, newValue in
            if vm.currentPin.count == 4 {
                if vm.currentPin == vm.actualPin {
                    withAnimation(.snappy, completionCriteria: .logicallyComplete) {
                        vm.isUnlocked = true
                    } completion: {
                        vm.currentPin = ""
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        vm.currentPin = ""
                    }
                    vm.animateField.toggle()
                }
            }
        }
        .alert("Elfelejtett jelszó",isPresented: $vm.showAlert) {
            Button("Ok", role: .confirm) {
                pinCode = ""
                isPinCodeSet = false
                isLockEnabled = false
            }
            
            Button("Mégse", role: .cancel) {
                vm.showAlert.toggle()
            }
        } message: {
            Text("Törölni szeretné a jelszót és a pin kódos belépést?")
        }

    }
}

#Preview {
    let vm = LockViewModel(lockType: .both, actualPin: "0123")
    LockView(vm: vm)
}
