//
//  PerformanceView.swift
//  tune
//
//  Created by Alperen Çetin on 23.01.2025.
//

import SwiftUI

struct PerformanceView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Performance Metrics")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top)
                
                if let vehicle = vehicleManager.vehicle {
                    // Vehicle Info Card
                    CustomCard(content: AnyView(
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(vehicle.make) \(vehicle.model) \(vehicle.year)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(String(format: "%.1f L", vehicle.engineSize)) - \(vehicle.fuelType.rawValue)")
                                .foregroundColor(.gray)
                        }
                    ))
                    
                    // Performance Metrics
                    CustomCard(content: AnyView(
                        VStack(spacing: 15) {
                            PerformanceMetricView(title: "Horsepower",
                                                value: "\(Int(vehicleManager.performanceData.horsepower))",
                                                unit: "hp",
                                                icon: "bolt.fill")
                            
                            PerformanceMetricView(title: "Torque",
                                                value: "\(Int(vehicleManager.performanceData.torque))",
                                                unit: "Nm",
                                                icon: "rotate.right.fill")
                            
                            PerformanceMetricView(title: "0-60 mph",
                                                value: String(format: "%.1f", vehicleManager.performanceData.acceleration),
                                                unit: "sec",
                                                icon: "speedometer")
                        }
                    ))
                } else {
                    CustomCard(content: AnyView(
                        Text("Please set up your vehicle first")
                            .foregroundColor(.gray)
                            .font(.headline)
                    ))
                }
            }
            .padding(.bottom)
        }
        .background(Color(hex: "1a1a1a"))
    }
}
