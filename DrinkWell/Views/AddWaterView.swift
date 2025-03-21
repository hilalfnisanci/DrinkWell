//
//  AddWaterView.swift
//  DrinkWell
//
//  Created by Hilal on 18.03.2025.
//

import SwiftUI

struct AddWaterView: View {
    @Binding var isPresented: Bool
    var onAdd: (Double, String?) -> Void
    
    @State private var amount: Double = 250
    @State private var note: String = ""
    
    // Preset amounts
    let presetAmounts: [Double] = [100, 200, 250, 330, 500, 750]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("amount_header".localized)) {
                    Slider(value: $amount, in: 50...1000, step: 10)
                        .padding(.vertical)
                    
                    Text("\(Int(amount)) ml")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityIdentifier("amount_text")
                    
                    // Preset amount buttons
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6), spacing: 4) {
                        ForEach(presetAmounts, id: \.self) { preset in
                            Button {
                                amount = preset
                            } label: {
                                Text("\(Int(preset))")
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .buttonStyle(.bordered)
                            .frame(height: 36)
                            .accessibilityIdentifier("preset_amount_\(Int(preset))")
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("note_header".localized)) {
                    TextField("optional_note".localized, text: $note)
                        .accessibilityIdentifier("note_textfield")
                }
            }
            .navigationTitle("add_water_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel_button".localized) {
                        isPresented = false
                    }
                    .accessibilityIdentifier("cancel_button")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("add_button".localized) {
                        onAdd(amount, note.isEmpty ? nil : note)
                        isPresented = false
                    }
                    .accessibilityIdentifier("add_button")
                }
            }
        }
    }
}

struct AddWaterView_Previews: PreviewProvider {
    static var previews: some View {
        AddWaterView(isPresented: .constant(true), onAdd: { _, _ in })
    }
}