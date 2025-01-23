//
//  DrivingModesView.swift
//  tune
//
//  Created by Alperen Çetin on 23.01.2025.
//

import SwiftUI

struct DrivingModesView: View {
    @State private var selectedMode = 0
    @State private var showingModeDetails = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Driving Modes")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top)
                
                CustomCard(content: AnyView(
                    VStack(spacing: 15) {
                        Picker("Driving Mode", selection: $selectedMode) {
                            Text("Eco").tag(0)
                            Text("Normal").tag(1)
                            Text("Sport").tag(2)
                            Text("Sport+").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .colorMultiply(Color(hex: "00ff87"))
                        
                        // Mode description
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: modeIcon)
                                    .foregroundColor(Color(hex: "00ff87"))
                                Text(modeDescription)
                                    .foregroundColor(.white)
                            }
                            .padding(.top)
                        }
                    }
                ))
            }
        }
        .background(Color(hex: "1a1a1a"))
    }
    
    var modeIcon: String {
        switch selectedMode {
        case 0: return "leaf.fill"
        case 1: return "car.fill"
        case 2: return "flame.fill"
        case 3: return "bolt.car.fill"
        default: return "car.fill"
        }
    }
    
    var modeDescription: String {
        switch selectedMode {
        case 0: return "Optimized for maximum efficiency"
        case 1: return "Balanced performance and efficiency"
        case 2: return "Enhanced performance and response"
        case 3: return "Maximum performance settings"
        default: return ""
        }
    }
}
