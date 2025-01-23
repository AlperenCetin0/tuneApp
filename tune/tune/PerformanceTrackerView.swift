import SwiftUI

struct PerformanceTrackerView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @EnvironmentObject var obdManager: OBDManager
    @State private var isTracking = false
    @State private var selectedTest = PerformanceTest.zeroToHundred
    @State private var startSpeed: Double = 0.0
    @State private var endSpeed: Double = 0.0
    @State private var elapsedTime: TimeInterval = 0.0
    @State private var timer: Timer?
    @State private var startTime: Date?
    
    enum PerformanceTest: String, CaseIterable {
        case zeroToHundred = "0-100 km/h"
        case quarterMile = "1/4 Mile"
        case hundredToTwo = "100-200 km/h"
        case rollingRace = "Rolling Race"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Test Selection
                    Picker("Test Type", selection: $selectedTest) {
                        ForEach(PerformanceTest.allCases, id: \.self) { test in
                            Text(test.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Current Speed Display
                    SpeedGauge(speed: obdManager.currentData.speed)
                        .frame(height: 200)
                        .padding()
                    
                    // Timer Display
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 8)
                            .opacity(0.3)
                            .foregroundColor(.blue)
                        
                        Circle()
                            .trim(from: 0, to: isTracking ? CGFloat(min(elapsedTime / 10.0, 1.0)) : 0)
                            .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.blue)
                            .rotationEffect(Angle(degrees: -90))
                        
                        Text(String(format: "%.2f s", elapsedTime))
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(width: 200, height: 200)
                    .padding()
                    
                    // Start/Stop Button
                    Button(action: {
                        if isTracking {
                            stopTracking()
                        } else {
                            startTracking()
                        }
                    }) {
                        Text(isTracking ? "Stop" : "Start")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isTracking ? Color.red : Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Results Display
                    if !isTracking && elapsedTime > 0 {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Results")
                                .font(.headline)
                            
                            Group {
                                InfoRow(title: "Total Time", value: String(format: "%.2f s", elapsedTime))
                                InfoRow(title: "Start Speed", value: String(format: "%.1f km/h", startSpeed))
                                InfoRow(title: "End Speed", value: String(format: "%.1f km/h", endSpeed))
                                InfoRow(title: "Average Acceleration", value: String(format: "%.1f m/s²", calculateAcceleration()))
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Performance Tracker")
        }
    }
    
    private func startTracking() {
        isTracking = true
        startTime = Date()
        startSpeed = obdManager.currentData.speed
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let start = startTime else { return }
            elapsedTime = Date().timeIntervalSince(start)
            
            let currentSpeed = obdManager.currentData.speed
            if shouldStopTracking(currentSpeed) {
                stopTracking()
            }
        }
    }
    
    private func stopTracking() {
        timer?.invalidate()
        timer = nil
        isTracking = false
        endSpeed = obdManager.currentData.speed
    }
    
    private func shouldStopTracking(_ currentSpeed: Double) -> Bool {
        switch selectedTest {
        case .zeroToHundred:
            return currentSpeed >= 100
        case .quarterMile:
            // Assuming average car length is 4.5 meters
            return (currentSpeed * elapsedTime) >= 402.336 // 1/4 mile in meters
        case .hundredToTwo:
            return currentSpeed >= 200
        case .rollingRace:
            return elapsedTime >= 10 // 10 second limit
        }
    }
    
    private func calculateAcceleration() -> Double {
        let speedDiff = endSpeed - startSpeed // km/h
        let speedInMS = speedDiff * 0.277778 // Convert to m/s
        return speedInMS / elapsedTime // m/s²
    }
}

struct SpeedGauge: View {
    let speed: Double
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(speed / 280.0, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: -90))
                
                VStack {
                    Text(String(format: "%.0f", speed))
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                    Text("km/h")
                        .font(.caption)
                }
            }
        }
    }
}

// End of file
