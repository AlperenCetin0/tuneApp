//
//  tuneApp.swift
//  tune
//
//  Created by Alperen Çetin on 22.01.2025.
//

import SwiftUI
import CoreBluetooth

@main
struct tuneApp: App {
    // Initialize managers with demo data for testing
    @StateObject private var vehicleManager: VehicleManager = {
        let manager = VehicleManager()
        
        // Set up a demo vehicle
        var vehicle = Vehicle(
            make: "BMW",
            model: "M3",
            year: 2023,
            engineSize: 3.0,
            fuelType: .gasoline
        )
        vehicle.transmission = .automatic
        vehicle.engineCode = "S58B30T0"
        vehicle.modifications = [
            Modification(name: "Stage 1 ECU Tune", type: .ecu, details: "+50hp, +70Nm"),
            Modification(name: "Downpipe", type: .exhaust, details: "Decat, 200 cell")
        ]
        manager.saveVehicle(vehicle)
        
        // Set up performance data
        let performanceData = PerformanceData(
            horsepower: 510,
            torque: 650,
            acceleration: 3.8,
            fuelConsumption: 12.5,
            boostPressure: 1.8,
            afr: 14.7,
            engineTemp: 90,
            oilTemp: 95,
            oilPressure: 5.2
        )
        manager.savePerformanceData(performanceData)
        
        // Set up tune profile
        let tuneProfile = TuneProfile(
            ignitionTiming: 12.5,
            fuelMapping: [
                FuelMap(rpm: 2000, load: 0.5, value: 12.5),
                FuelMap(rpm: 4000, load: 0.8, value: 13.2)
            ],
            boostControl: 1.8,
            revLimit: 7200,
            launchControl: 3000
        )
        manager.saveTuneProfile(tuneProfile)
        
        // Add some diagnostic codes
        manager.diagnosticCodes = [
            DiagnosticCode(code: "P0300", description: "Random/Multiple Cylinder Misfire", severity: .medium)
        ]
        
        return manager
    }()
    
    @StateObject private var obdManager: OBDManager = {
        let manager = OBDManager()
        // Set demo data for OBD
        manager.currentData = OBDData(
            rpm: 2500,
            speed: 60.0,
            throttlePosition: 25.0,
            mafSensor: 15.5,
            o2Sensor: 0.95,
            timing: 14.0
        )
        manager.isConnected = true
        return manager
    }()
    
    @StateObject private var dataLogger: DataLogger = {
        let obdManager = OBDManager()
        let logger = DataLogger(obdManager: obdManager)
        
        // Add some sample log entries
        let sampleData = OBDData(
            rpm: 3000,
            speed: 75.0,
            throttlePosition: 45.0,
            mafSensor: 18.2,
            o2Sensor: 0.92,
            timing: 15.5
        )
        logger.logs = [
            LogEntry(timestamp: Date().addingTimeInterval(-3600), data: sampleData),
            LogEntry(timestamp: Date().addingTimeInterval(-1800), data: sampleData)
        ]
        return logger
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vehicleManager)
                .environmentObject(obdManager)
                .environmentObject(dataLogger)
        }
    }
}

// Add VehicleManager class to handle app data
class VehicleManager: ObservableObject {
    @Published var vehicle: Vehicle?
    @Published var performanceData: PerformanceData
    @Published var tuneProfile: TuneProfile
    @Published var diagnosticCodes: [DiagnosticCode]
    
    private let vehicleKey = "savedVehicle"
    private let performanceKey = "savedPerformance"
    private let tuneProfileKey = "savedTuneProfile"
    
    init() {
        self.performanceData = PerformanceData()
        self.tuneProfile = TuneProfile()
        self.diagnosticCodes = []
        
        loadSavedData()
    }
    
    func saveVehicle(_ vehicle: Vehicle) {
        self.vehicle = vehicle
        if let encoded = try? JSONEncoder().encode(vehicle) {
            UserDefaults.standard.set(encoded, forKey: vehicleKey)
        }
    }
    
    func savePerformanceData(_ data: PerformanceData) {
        self.performanceData = data
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: performanceKey)
        }
    }
    
    func saveTuneProfile(_ profile: TuneProfile) {
        self.tuneProfile = profile
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: tuneProfileKey)
        }
    }
    
    private func loadSavedData() {
        if let vehicleData = UserDefaults.standard.data(forKey: vehicleKey),
           let vehicle = try? JSONDecoder().decode(Vehicle.self, from: vehicleData) {
            self.vehicle = vehicle
        }
        
        if let performanceData = UserDefaults.standard.data(forKey: performanceKey),
           let performance = try? JSONDecoder().decode(PerformanceData.self, from: performanceData) {
            self.performanceData = performance
        }
        
        if let tuneData = UserDefaults.standard.data(forKey: tuneProfileKey),
           let tune = try? JSONDecoder().decode(TuneProfile.self, from: tuneData) {
            self.tuneProfile = tune
        }
    }
    
    func resetToDefaults() {
        UserDefaults.standard.removeObject(forKey: vehicleKey)
        UserDefaults.standard.removeObject(forKey: performanceKey)
        UserDefaults.standard.removeObject(forKey: tuneProfileKey)
        
        self.vehicle = nil
        self.performanceData = PerformanceData()
        self.tuneProfile = TuneProfile()
        self.diagnosticCodes.removeAll()
    }
}

class OBDManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isConnected = false
    @Published var availableDevices: [CBPeripheral] = []
    @Published var currentData = OBDData()
    @Published var currentDevice: CBPeripheral?
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func updateData() {
        // Simüle edilmiş veri güncellemesi
        DispatchQueue.main.async {
            self.currentData.rpm = Int.random(in: 800...3500)
            self.currentData.speed = Double.random(in: 0...120)
            self.currentData.throttlePosition = Double.random(in: 0...100)
            self.currentData.mafSensor = Double.random(in: 10...20)
            self.currentData.o2Sensor = Double.random(in: 0.8...1.1)
            self.currentData.timing = Double.random(in: 10...18)
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        currentDevice = peripheral
        centralManager.connect(peripheral, options: nil)
    }
}

class DataLogger: ObservableObject {
    @Published var logs: [LogEntry] = []
    @Published var isRecording = false
    private var timer: Timer?
    private let obdManager: OBDManager
    
    init(obdManager: OBDManager) {
        self.obdManager = obdManager
    }
    
    func startRecording() {
        isRecording = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.logCurrentData()
        }
    }
    
    func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
    }
    
    private func logCurrentData() {
        let entry = LogEntry(timestamp: Date(), data: obdManager.currentData)
        logs.append(entry)
    }
}

enum ModificationType: String, Codable, CaseIterable {
    case engine = "Engine"
    case intake = "Intake"
    case exhaust = "Exhaust"
    case turbo = "Turbo"
    case ecu = "ECU"
    case suspension = "Suspension"
    case other = "Other"
}

enum TransmissionType: String, Codable, CaseIterable {
    case manual = "Manual"
    case automatic = "Automatic"
    case dct = "Dual Clutch"
    case cvt = "CVT"
}

struct Modification: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: ModificationType
    let details: String
}

struct Vehicle: Identifiable, Codable {
    let id = UUID()
    var make: String
    var model: String
    var year: Int
    var engineSize: Double
    var fuelType: FuelType
    var transmission: TransmissionType
    var engineCode: String
    var modifications: [Modification]
    
    init(make: String, model: String, year: Int, engineSize: Double, fuelType: FuelType) {
        self.make = make
        self.model = model
        self.year = year
        self.engineSize = engineSize
        self.fuelType = fuelType
        self.transmission = .automatic
        self.engineCode = ""
        self.modifications = []
    }
}

struct PerformanceData: Codable {
    var horsepower: Double = 0.0
    var torque: Double = 0.0
    var acceleration: Double = 0.0
    var fuelConsumption: Double = 0.0
    var boostPressure: Double = 0.0
    var afr: Double = 0.0  // Air/Fuel Ratio
    var engineTemp: Double = 0.0
    var oilTemp: Double = 0.0
    var oilPressure: Double = 0.0
}

struct TuneProfile: Codable {
    var ignitionTiming: Double = 0.0
    var fuelMapping: [FuelMap] = []
    var boostControl: Double = 0.0
    var revLimit: Int = 0
    var launchControl: Int = 0
}

struct FuelMap: Codable {
    var rpm: Int
    var load: Double
    var value: Double
}

struct OBDData: Codable {
    var rpm: Int = 0
    var speed: Double = 0.0
    var throttlePosition: Double = 0.0
    var mafSensor: Double = 0.0
    var o2Sensor: Double = 0.0
    var timing: Double = 0.0
}

struct LogEntry: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let data: OBDData
}

struct DiagnosticCode: Identifiable, Codable {
    let id = UUID()
    let code: String
    let description: String
    let severity: DiagnosticSeverity
}

enum FuelType: String, Codable, CaseIterable {
    case gasoline = "Gasoline"
    case diesel = "Diesel"
    case electric = "Electric"
    case hybrid = "Hybrid"
}

enum DiagnosticSeverity: String, Codable {
    case low, medium, high, critical
}
