//
//  FuelConsumptionView.swift
//  tune
//
//  Created by Alperen Çetin on 23.01.2025.
//

import SwiftUI

struct FuelConsumptionView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Fuel Consumption")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top)
                
                if let vehicle = vehicleManager.vehicle {
                    CustomCard(content: AnyView(
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "fuelpump.fill")
                                    .foregroundColor(Color(hex: "00ff87"))
                                Text("Average Consumption")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.1f", vehicleManager.performanceData.fuelConsumption))
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Text("L/100km")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
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
        }
        .background(Color(hex: "1a1a1a"))
    }
}

