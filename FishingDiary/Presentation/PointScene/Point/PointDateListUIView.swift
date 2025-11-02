//
//  PointDateListUIView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/20/25.
//

import SwiftUI

struct PointDateListUIView: View {
    @ObservedObject var viewModel: PointDateListViewModel
    @State var selectedPointDateViewModel = PointDateListItemViewModel(date: "", datePath: URL(fileURLWithPath: ""))
    @State var showPointDataList: Bool = false
    
    var body: some View {
        List(viewModel.pointDateList, id: \.self) { date in
            HStack {
                Button {
                    selectedPointDateViewModel = date
                    showPointDataList = true
                } label: {
                    Text(date.date)
                        .padding(.leading, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            viewModel.viewDidLoad()
        }
        .navigationTitle("포인트 추적날짜")
        
        NavigationLink(destination: viewModel.createPointDataLietView(dateModel: selectedPointDateViewModel),
                       isActive: $showPointDataList)
        {
            EmptyView()
        }
    }
}
