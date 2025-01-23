//
//  PerformanceCard.swift
//  tune
//
//  Created by Alperen Çetin on 23.01.2025.
//

import SwiftUI

struct PerformanceCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .rotationEffect(.degrees(animate ? 360 : 0))
                .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: animate)
                .onAppear { animate = true }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}
