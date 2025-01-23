//
//  VehicleSetupView.swift
//  tune
//
//  Created by Alperen Çetin on 23.01.2025.
//

import SwiftUI


struct VehicleSetupView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @State private var make = ""
    @State private var model = ""
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var engineSize = 2.0
    @State private var selectedFuelType = FuelType.gasoline
    @State private var transmission = TransmissionType.automatic
    @State private var engineCode = ""
    @State private var showingSuccess = false
    @State private var currentStep = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [
                    Color(hex: "1a1a1a"),
                    Color(hex: "2a2a2a")
                ]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress indicator
                        HStack(spacing: 4) {
                            ForEach(0..<4) { index in
                                Capsule()
                                    .fill(index <= currentStep ? Color(hex: "00ff87") : Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                    .animation(.spring(), value: currentStep)
                            }
                        }
                        .padding(.top)
                        
                        // Setup steps
                        TabView(selection: $currentStep) {
                            // Basic Info
                            VStack {
                                Text("Car Details")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                
                                CustomCard(content: AnyView(
                                    VStack(spacing: 15) {
                                        CustomTextField(title: "Make", text: $make, icon: "car.fill")
                                        CustomTextField(title: "Model", text: $model, icon: "tag.fill")
                                    }
                                ))
                            }
                            .tag(0)
                            
                            // Engine Info
                            VStack {
                                Text("Engine Details")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                
                                CustomCard(content: AnyView(
                                    VStack(spacing: 15) {
                                        CustomTextField(title: "Engine Code", text: $engineCode, icon: "engine.combustion.fill")
                                        
                                        // Engine Size Slider with modern design
                                        VStack(alignment: .leading) {
                                            Text("Engine Size")
                                                .foregroundColor(.gray)
                                            HStack {
                                                Image(systemName: "engine.combustion.fill")
                                                    .foregroundColor(Color(hex: "00ff87"))
                                                Slider(value: $engineSize, in: 0.5...8.0, step: 0.1)
                                                    .accentColor(Color(hex: "00ff87"))
                                                Text(String(format: "%.1f L", engineSize))
                                                    .foregroundColor(.white)
                                                    .font(.system(.body, design: .rounded))
                                            }
                                        }
                                    }
                                ))
                            }
                            .tag(1)
                            
                            // Additional Info
                            VStack {
                                Text("Additional Details")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                
                                CustomCard(content: AnyView(
                                    VStack(spacing: 15) {
                                        // Fuel Type Picker with modern design
                                        VStack(alignment: .leading) {
                                            Text("Fuel Type")
                                                .foregroundColor(.gray)
                                            HStack {
                                                ForEach(FuelType.allCases, id: \.self) { type in
                                                    Button(action: {
                                                        selectedFuelType = type
                                                    }) {
                                                        Text(type.rawValue)
                                                            .padding(.vertical, 8)
                                                            .padding(.horizontal, 12)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .fill(selectedFuelType == type ?
                                                                          Color(hex: "00ff87") :
                                                                            Color.gray.opacity(0.2))
                                                            )
                                                            .foregroundColor(selectedFuelType == type ? .black : .white)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Transmission Type Picker
                                        VStack(alignment: .leading) {
                                            Text("Transmission")
                                                .foregroundColor(.gray)
                                            HStack {
                                                ForEach(TransmissionType.allCases, id: \.self) { type in
                                                    Button(action: {
                                                        transmission = type
                                                    }) {
                                                        Text(type.rawValue)
                                                            .padding(.vertical, 8)
                                                            .padding(.horizontal, 12)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .fill(transmission == type ?
                                                                          Color(hex: "00ff87") :
                                                                            Color.gray.opacity(0.2))
                                                            )
                                                            .foregroundColor(transmission == type ? .black : .white)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                ))
                            }
                            .tag(2)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 350)
                        
                        // Navigation buttons
                        HStack {
                            if currentStep > 0 {
                                Button(action: {
                                    withAnimation {
                                        currentStep -= 1
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }
                                    .foregroundColor(Color(hex: "00ff87"))
                                }
                            }
                            
                            Spacer()
                            
                            if currentStep < 3 {
                                Button(action: {
                                    withAnimation {
                                        if currentStep == 2 {
                                            saveVehicle()
                                        } else {
                                            currentStep += 1
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text(currentStep == 2 ? "Save" : "Next")
                                        Image(systemName: currentStep == 2 ? "checkmark" : "chevron.right")
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "00ff87"))
                                    .foregroundColor(.black)
                                    .clipShape(Capsule())
                                }
                                .disabled(currentStep == 0 && (make.isEmpty || model.isEmpty))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                if showingSuccess {
                    SuccessOverlay()
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func saveVehicle() {
        var newVehicle = Vehicle(
            make: make,
            model: model,
            year: year,
            engineSize: engineSize,
            fuelType: selectedFuelType
        )
        newVehicle.transmission = transmission
        newVehicle.engineCode = engineCode
        vehicleManager.vehicle = newVehicle
        
        withAnimation {
            showingSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingSuccess = false
            }
        }
    }
}
