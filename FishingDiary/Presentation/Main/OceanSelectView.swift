//
//  OceanSelectView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/16/25.
//

import SwiftUI

struct OceanSelectView: View {
    @ObservedObject var viewModel: OceanSelectViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.oceanStations, id: \.self) { item in
                Button {
                    viewModel.saveCheckList(!item.isChecked, model: item)
                } label: {
                    HStack(spacing: 0) {
                        Text(item.stationName)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Image(item.isChecked ? "checkbox_selected" : "checkbox_normal")
                            .resizable()
                            .frame(width: 34, height: 34)
                            .contentShape(Rectangle())
                            .padding(.trailing, 4)
                        
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("수온 즐겨찾기")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.viewDidLoad()
        }
    }
}
