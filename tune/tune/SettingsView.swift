//
//  SettingsView.swift
//  tune
//
//  Created by Alperen Çetin on 23.01.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @EnvironmentObject var obdManager: OBDManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    CustomCard(content: AnyView(
                        VStack(alignment: .leading, spacing: 15) {
                            Text("OBD Devices")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(obdManager.availableDevices, id: \.identifier) { device in
                                HStack {
                                    Text(device.name ?? "Unknown Device")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                        }
                    ))
                }
                .padding(.bottom)
            }
            .background(Color(hex: "1a1a1a"))
            .navigationTitle("Settings")
        }
    }
}

