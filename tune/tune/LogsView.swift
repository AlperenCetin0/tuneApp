import SwiftUI
import Charts

struct LogsView: View {
    @EnvironmentObject var dataLogger: DataLogger
    @State private var selectedDataType = DataType.rpm
    @State private var isRecording = false
    
    enum DataType: String, CaseIterable {
        case rpm = "RPM"
        case speed = "Speed"
        case boost = "Boost Pressure"
        case afr = "Air/Fuel Ratio"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Data Type Selection
                    Picker("Data Type", selection: $selectedDataType) {
                        ForEach(DataType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Chart
                    GroupBox {
                        if dataLogger.logs.isEmpty {
                            Text("No log data available")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            Chart {
                                ForEach(dataLogger.logs) { entry in
                                    LineMark(
                                        x: .value("Time", entry.timestamp),
                                        y: .value("Value", getValue(for: selectedDataType, from: entry.data))
                                    )
                                }
                            }
                            .frame(height: 200)
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Log Controls
                    HStack {
                        Button(action: {
                            isRecording.toggle()
                        }) {
                            HStack {
                                Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                                Text(isRecording ? "Stop Recording" : "Start Recording")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isRecording ? Color.red : Color.green)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Implement export functionality
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Log List
                    GroupBox(label: Text("Log Entries")) {
                        ForEach(dataLogger.logs) { entry in
                            LogEntryRow(entry: entry)
                            if entry.id != dataLogger.logs.last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Data Logs")
            .toolbar {
                Button(action: {
                    // Implement clear logs functionality
                }) {
                    Text("Clear")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func getValue(for type: DataType, from data: OBDData) -> Double {
        switch type {
        case .rpm: return Double(data.rpm)
        case .speed: return data.speed
        case .boost: return data.throttlePosition
        case .afr: return data.o2Sensor
        }
    }
}

struct LogEntryRow: View {
    let entry: LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(entry.timestamp, style: .time)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("RPM: \(entry.data.rpm)")
                    Text("Speed: \(String(format: "%.1f", entry.data.speed)) km/h")
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Throttle: \(String(format: "%.1f", entry.data.throttlePosition))%")
                    Text("O2: \(String(format: "%.2f", entry.data.o2Sensor))V")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

// End of file
