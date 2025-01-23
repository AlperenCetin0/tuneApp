//
//  PerformanceMetricView.swift
//  tune
//
//  Created by Alperen Çetin on 23.01.2025.
//

import SwiftUI

struct PerformanceMetricView: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "00ff87"))
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
                .font(.headline)
            
            Text(unit)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
    }
}

