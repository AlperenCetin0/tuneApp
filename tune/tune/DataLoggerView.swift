//
//  DataLoggerView.swift
//  tune
//
//  Created by Alperen Çetin on 23.01.2025.
//

import SwiftUI

struct DataLoggerView: View {
    @EnvironmentObject var dataLogger: DataLogger
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Data Logger")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    CustomCard(content: AnyView(
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Logged Sessions")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(dataLogger.logs) { log in
                                VStack(alignment: .leading) {
                                    Text(log.timestamp, style: .date)
                                        .foregroundColor(.white)
                                    Text("RPM: \(log.data.rpm)")
                                        .foregroundColor(.gray)
                                    Text("Speed: \(String(format: "%.1f km/h", log.data.speed))")
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
            .navigationTitle("Data Logger")
        }
    }
}
