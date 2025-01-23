//
//  ContentView.swift
//  tune
//
//  Created by Alperen Çetin on 22.01.2025.
//

import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @EnvironmentObject var obdManager: OBDManager
    @EnvironmentObject var dataLogger: DataLogger
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Image(systemName: "gauge")
                    Text("Dashboard")
                }
                .tag(0)
            
            // Vehicle Info Tab
            VehicleInfoView()
                .tabItem {
                    Image(systemName: "car")
                    Text("Vehicle")
                }
                .tag(1)
            
            // Tuning Tab
            TuningView()
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Tuning")
                }
                .tag(2)
            
            // Performance Tracker Tab
            PerformanceTrackerView()
                .tabItem {
                    Image(systemName: "stopwatch")
                    Text("Performance")
                }
                .tag(3)
            
            // Diagnostics Tab
            DiagnosticsView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Diagnostics")
                }
                .tag(4)
            
            // Logs Tab
            LogsView()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Logs")
                }
                .tag(5)
        }
        .accentColor(Color(hex: "00ff87"))
        .preferredColorScheme(.dark)
    }
}


struct StatusRow: View {
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


struct CustomCard: View {
    var content: AnyView
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: "2a2a2a"))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
    }
}


struct SuccessOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "00ff87"))
                
                Text("Vehicle saved successfully!")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.gray)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "00ff87"))
                TextField(title, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
            }
            Divider()
                .background(Color(hex: "00ff87"))
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

