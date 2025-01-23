import SwiftUI

struct DiagnosticsView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @EnvironmentObject var obdManager: OBDManager
    @State private var isScanning = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection Status
                    GroupBox {
                        HStack {
                            Image(systemName: obdManager.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(obdManager.isConnected ? .green : .red)
                            Text(obdManager.isConnected ? "Connected" : "Disconnected")
                            Spacer()
                            Button(action: {
                                if !obdManager.isConnected {
                                    isScanning = true
                                    obdManager.startScanning()
                                }
                            }) {
                                Text(isScanning ? "Scanning..." : "Connect")
                            }
                            .disabled(obdManager.isConnected || isScanning)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Diagnostic Codes
                    GroupBox(label: Text("Diagnostic Codes")) {
                        if vehicleManager.diagnosticCodes.isEmpty {
                            Text("No diagnostic codes found")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(vehicleManager.diagnosticCodes) { code in
                                DiagnosticCodeRow(code: code)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sensor Data
                    GroupBox(label: Text("Sensor Data")) {
                        VStack(alignment: .leading, spacing: 10) {
                            SensorDataRow(title: "MAF Sensor", value: obdManager.currentData.mafSensor, unit: "g/s")
                            SensorDataRow(title: "O2 Sensor", value: obdManager.currentData.o2Sensor, unit: "V")
                            SensorDataRow(title: "Timing Advance", value: obdManager.currentData.timing, unit: "°")
                            SensorDataRow(title: "Throttle Position", value: obdManager.currentData.throttlePosition, unit: "%")
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Scan Button
                    Button(action: {
                        // Implement diagnostic scan
                    }) {
                        Text("Scan for Codes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Diagnostics")
        }
    }
}

struct DiagnosticCodeRow: View {
    let code: DiagnosticCode
    
    var severityColor: Color {
        switch code.severity {
        case .low: return .yellow
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(code.code)
                    .font(.headline)
                Spacer()
                Text(code.severity.rawValue.capitalized)
                    .font(.caption)
                    .padding(5)
                    .background(severityColor.opacity(0.2))
                    .foregroundColor(severityColor)
                    .cornerRadius(5)
            }
            Text(code.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

struct SensorDataRow: View {
    let title: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(String(format: "%.2f", value)) \(unit)")
                .fontWeight(.medium)
        }
    }
}

// End of file
