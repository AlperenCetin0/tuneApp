import SwiftUI

struct VehicleInfoView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Vehicle Basic Info
                    GroupBox(label: Text("Vehicle Information")) {
                        VStack(alignment: .leading, spacing: 10) {
                            if let vehicle = vehicleManager.vehicle {
                                InfoRow(title: "Make", value: vehicle.make)
                                InfoRow(title: "Model", value: vehicle.model)
                                InfoRow(title: "Year", value: "\(vehicle.year)")
                                InfoRow(title: "Engine", value: "\(vehicle.engineSize)L")
                                InfoRow(title: "Fuel Type", value: vehicle.fuelType.rawValue)
                                InfoRow(title: "Transmission", value: vehicle.transmission.rawValue)
                                InfoRow(title: "Engine Code", value: vehicle.engineCode)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Performance Data
                    GroupBox(label: Text("Performance Data")) {
                        VStack(alignment: .leading, spacing: 10) {
                            InfoRow(title: "Horsepower", value: "\(Int(vehicleManager.performanceData.horsepower)) hp")
                            InfoRow(title: "Torque", value: "\(Int(vehicleManager.performanceData.torque)) Nm")
                            InfoRow(title: "0-100 km/h", value: "\(String(format: "%.1f", vehicleManager.performanceData.acceleration)) sec")
                            InfoRow(title: "Fuel Consumption", value: "\(String(format: "%.1f", vehicleManager.performanceData.fuelConsumption)) L/100km")
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Modifications
                    GroupBox(label: Text("Modifications")) {
                        if let vehicle = vehicleManager.vehicle {
                            ForEach(vehicle.modifications) { mod in
                                ModificationRow(modification: mod)
                            }
                            if vehicle.modifications.isEmpty {
                                Text("No modifications installed")
                                    .foregroundColor(.secondary)
                                    .padding(.vertical)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Vehicle Info")
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct ModificationRow: View {
    let modification: Modification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(modification.name)
                .font(.headline)
            Text(modification.type.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(modification.details)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

// End of file
