//
//  LockView.swift
//  Planalytics
//
//  Created by Szabó Balázs on 2026. 03. 04..
//

import SwiftUI
internal import LocalAuthentication

struct LockView: View {
    @AppStorage("isLockEnabled") private var isLockEnabled: Bool = false
    @AppStorage("isPinCodeSet") private var isPinCodeSet: Bool = false
    @AppStorage("pinCode") private var pinCode: String = ""
    
    enum LockTypes: String {
        case numeric = "Custom number lock"
        case both = "Biometric or numeric unlock"
    }
    
    @State private var currentPin: String = ""
    @State var lockType: LockTypes
    @State private var animateField: Bool = false
    @State private var lockWhenAppGoesBackground: Bool = true
    @State private var context = LAContext()
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            NumberPadView()
        }
        .onAppear {
            unlockWithFaceID()
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
                        .foregroundStyle(currentPin.count >= index + 1 ? .mint : .primary)
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
            
            Button("Elfelejtett jelszó?") {
                showAlert.toggle()
            }
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(1...9, id: \.self) { number in
                    Button {
                        if currentPin.count < 4 {
                            currentPin.append(String(number))
                        }
                    } label: {
                        Text("\(number)")
                            .font(.title)
                    }
                    .frame(width: 60, height: 60)
                    .buttonStyle(.glass)
                }
                
                Button {
                    if !currentPin.isEmpty {
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
                
                Button {
                    unlockWithFaceID()
                } label: {
                    if let biometricType = getBiometricType() {
                        if biometricType == .faceID {
                            Image(systemName: "faceid")
                                .font(.title)
                        } else if biometricType == .touchID {
                            Image(systemName: "touchid")
                                .font(.title)
                        }
                    }
                }
                .frame(width: 60, height: 60)
                .buttonStyle(.glass)
            }
            .padding()
        }
        .onChange(of: currentPin) { oldValue, newValue in
            if currentPin.count == 4 {
                if currentPin == pinCode {
                    withAnimation(.snappy, completionCriteria: .logicallyComplete) {
                        isLockEnabled = false
                    } completion: {
                        currentPin = ""
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        currentPin = ""
                    }
                    animateField.toggle()
                }
            }
        }
        .alert("Elfelejtett jelszó",isPresented: $showAlert) {
            Button("Ok", role: .confirm) {
                pinCode = ""
                isPinCodeSet = false
                isLockEnabled = false
            }
            
            Button("Mégse", role: .cancel) {
                showAlert.toggle()
            }
        } message: {
            Text("Törölni szeretné a jelszót és a pin kódos belépést?")
        }
    }
    
    var isBiometricAvailable: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func unlockWithFaceID() {
        Task {
            if isBiometricAvailable && lockType != .numeric {
                if let result = try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Alkalmazás feloldása"), result {
                    isLockEnabled = false
                    
                }
            }
        }
    }
    
    func getBiometricType() -> LABiometryType? {
        if #available(iOS 11, *) {
            switch (context.biometryType) {
            case .none:
                return Optional.none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            case .opticID:
                return .opticID

            @unknown default:
                return nil
            }
        }
    }
}

#Preview {
    LockView(lockType: .both)
}
