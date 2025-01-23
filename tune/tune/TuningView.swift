import SwiftUI

struct TuningView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    @State private var showingTuneWarning = false
    @State private var selectedTuneProfile: String = "Stock"
    
    let tuneProfiles = ["Stock", "Sport", "Race", "Custom"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Tune Profile Selection
                    GroupBox(label: Text("Tune Profile")) {
                        Picker("Select Profile", selection: $selectedTuneProfile) {
                            ForEach(tuneProfiles, id: \.self) { profile in
                                Text(profile)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Tune Parameters
                    GroupBox(label: Text("Tune Parameters")) {
                        VStack(spacing: 15) {
                            TuneSliderView(
                                value: .constant(vehicleManager.tuneProfile.ignitionTiming),
                                range: 0...20,
                                title: "Ignition Timing",
                                unit: "°"
                            )
                            
                            TuneSliderView(
                                value: .constant(vehicleManager.tuneProfile.boostControl),
                                range: 0...2.5,
                                title: "Boost Control",
                                unit: "bar"
                            )
                            
                            TuneSliderView(
                                value: .constant(Double(vehicleManager.tuneProfile.revLimit)),
                                range: 5000...8000,
                                title: "Rev Limit",
                                unit: "RPM"
                            )
                            
                            TuneSliderView(
                                value: .constant(Double(vehicleManager.tuneProfile.launchControl)),
                                range: 2000...4000,
                                title: "Launch Control",
                                unit: "RPM"
                            )
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Fuel Mapping
                    GroupBox(label: Text("Fuel Mapping")) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(vehicleManager.tuneProfile.fuelMapping, id: \.rpm) { map in
                                FuelMapRow(map: map)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Flash Button
                    Button(action: {
                        showingTuneWarning = true
                    }) {
                        Text("Flash Tune")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showingTuneWarning) {
                        Alert(
                            title: Text("Warning"),
                            message: Text("Flashing a new tune may void your vehicle warranty. Do you want to continue?"),
                            primaryButton: .destructive(Text("Flash")) {
                                // Implement flash functionality
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Tuning")
        }
    }
}

struct TuneSliderView: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(String(format: "%.1f", value))\(unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $value, in: range)
        }
    }
}

struct FuelMapRow: View {
    let map: FuelMap
    
    var body: some View {
        HStack {
            Text("\(map.rpm) RPM")
            Spacer()
            Text("Load: \(String(format: "%.1f", map.load))")
            Spacer()
            Text("\(String(format: "%.1f", map.value))")
        }
        .font(.subheadline)
    }
}

// End of file
