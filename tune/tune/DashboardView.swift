//
//  DashboardView.swift
//  tune
//
//  Created by Alperen Çetin on 23.01.2025.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @EnvironmentObject var obdManager: OBDManager
    @EnvironmentObject var dataLogger: DataLogger
    
    // Add animation properties
    @State private var animate = false
    @State private var showDetails = false
    @State private var isRecording = false
    @State private var showConnectionSheet = false
    
    // Add timer for real-time updates
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Main Speed & RPM Display
                    SpeedRPMDisplay(rpm: obdManager.currentData.rpm)
                    
                    // Add recording indicator
                    if isRecording {
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .opacity(animate ? 0.3 : 1)
                                .animation(Animation.easeInOut(duration: 1).repeatForever(), value: animate)
                            Text("Recording")
                                .foregroundColor(.red)
                        }
                        .onAppear { animate = true }
                    }
                    
                    // Speed Bar
                    SpeedDisplay(speed: Double(obdManager.currentData.speed))
                    
                    // Primary Performance Metrics
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        PerformanceCard(
                            title: "Boost",
                            value: String(format: "%.1f", vehicleManager.performanceData.boostPressure),
                            unit: "bar",
                            icon: "gauge.medium",
                            color: .blue
                        )
                        PerformanceCard(
                            title: "AFR",
                            value: String(format: "%.1f", vehicleManager.performanceData.afr),
                            unit: ":",
                            icon: "aqi.medium",
                            color: .green
                        )
                        PerformanceCard(
                            title: "Throttle",
                            value: String(format: "%.0f", obdManager.currentData.throttlePosition),
                            unit: "%",
                            icon: "pedal.accelerator",
                            color: .orange
                        )
                        PerformanceCard(
                            title: "Engine Temp",
                            value: String(format: "%.0f", vehicleManager.performanceData.engineTemp),
                            unit: "°C",
                            icon: "thermometer.medium",
                            color: .red
                        )
                    }
                    .padding(.horizontal)
                    
                    // Engine Status Section
                    EngineStatusSection(performanceData: vehicleManager.performanceData, obdData: obdManager.currentData)
                    
                    // Performance Stats Section
                    PerformanceStatsSection(performanceData: vehicleManager.performanceData)
                    
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            isRecording.toggle()
                            if isRecording {
                                dataLogger.startRecording()
                            } else {
                                dataLogger.stopRecording()
                            }
                        }) {
                            Image(systemName: isRecording ? "stop.circle.fill" : "circle.fill")
                                .foregroundColor(isRecording ? .red : .gray)
                        }
                        
                        Button(action: {
                            showConnectionSheet = true
                        }) {
                            Image(systemName: obdManager.isConnected ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                                .foregroundColor(obdManager.isConnected ? Color(hex: "00ff87") : .red)
                        }
                    }
                }
            }
            .sheet(isPresented: $showConnectionSheet) {
                ConnectionView()
            }
            .onReceive(timer) { _ in
                if obdManager.isConnected {
                    obdManager.updateData()
                }
            }
        }
    }
}

struct SpeedRPMDisplay: View {
    let rpm: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.2), lineWidth: 20)
                .frame(width: 250, height: 250)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(Double(rpm) / 8000.0, 1.0)))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: rpm)
            
            VStack {
                Text("\(rpm)")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("RPM")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top)
    }
}

struct SpeedDisplay: View {
    let speed: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(Int(speed))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Text("km/h")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(height: 20)
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: min(CGFloat(speed) / 300 * geometry.size.width, geometry.size.width), height: 20)
                        .animation(.linear(duration: 0.5), value: speed)
                }
                .cornerRadius(10)
            }
            .frame(height: 20)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct EngineStatusSection: View {
    let performanceData: PerformanceData
    let obdData: OBDData
    
    var body: some View {
        GroupBox(label: Text("Engine Status").bold()) {
            VStack(spacing: 15) {
                StatusRow(title: "Oil Temperature", value: String(format: "%.1f°C", performanceData.oilTemp))
                StatusRow(title: "Oil Pressure", value: String(format: "%.1f bar", performanceData.oilPressure))
                StatusRow(title: "MAF Sensor", value: String(format: "%.1f g/s", obdData.mafSensor))
                StatusRow(title: "O2 Sensor", value: String(format: "%.2f V", obdData.o2Sensor))
                StatusRow(title: "Timing", value: String(format: "%.1f°", obdData.timing))
            }
            .padding(.vertical, 5)
        }
        .padding(.horizontal)
    }
}

struct PerformanceStatsSection: View {
    let performanceData: PerformanceData
    
    var body: some View {
        GroupBox(label: Text("Performance Stats").bold()) {
            VStack(spacing: 15) {
                StatusRow(title: "Horsepower", value: String(format: "%.0f hp", performanceData.horsepower))
                StatusRow(title: "Torque", value: String(format: "%.0f Nm", performanceData.torque))
                StatusRow(title: "0-100 km/h", value: String(format: "%.1f s", performanceData.acceleration))
                StatusRow(title: "Fuel Consumption", value: String(format: "%.1f L/100km", performanceData.fuelConsumption))
            }
            .padding(.vertical, 5)
        }
        .padding(.horizontal)
    }
}

struct ConnectionView: View {
    @EnvironmentObject var obdManager: OBDManager
    @Environment(\.dismiss) var dismiss
    @State private var isScanning = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(obdManager.availableDevices, id: \.identifier) { device in
                        Button {
                            obdManager.connect(to: device)
                            dismiss()
                        } label: {
                            HStack {
                                Text(device.name ?? "Bilinmeyen Cihaz")
                                Spacer()
                                if obdManager.currentDevice?.identifier == device.identifier {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Kullanılabilir Cihazlar")
                }
                
                Section {
                    Button {
                        isScanning = true
                        obdManager.startScanning()
                    } label: {
                        HStack {
                            Text("Cihazları Tara")
                            if isScanning {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Cihaz Bağlantısı")
            .navigationBarItems(trailing: Button("Tamam") {
                dismiss()
            })
        }
    }
}
