//
//  PointInfoView.swift
//  FishingDiary
//
//  Created by Y0000591 on 10/24/25.
//

import SwiftUI

struct PointInfoView: View {
    let locationData: LocationData
    @Binding var dmsType: DMSType
    let onClose: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text("time: \(locationData.time)")
                Text("\(latitudeText)")
                Text("\(longitudeText)")
                Text("\(locationData.kmh) km/h")
                Text("\(locationData.knot) knot")
                Text("sequence: \(locationData.sequence)")
            }
            .font(.system(size: 17))
            
            Spacer()
                       
            VStack() {
                Spacer()
                
                Button(action: {
                    dmsType.next()
                }) {
                    Text(dmsType.desc)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
        }
        .padding()
        .background(Color(.systemBackground))
        .fixedSize(horizontal: false, vertical: true)
        
    }
    
    private var latitudeText: String {
        guard let lat = locationData.latitude.toDouble() else {
            return "lat: \(locationData.latitude)"
        }
        
        switch dmsType {
        case .D:
            return "lat \(locationData.latitude)"
        case .DM:
            return "lat \(String.DtoDM(with: lat))"
        case .DMS:
            return "lat \(String.DtoDMS(with: lat))"
        }
    }
    
    private var longitudeText: String {
        guard let lon = locationData.longitude.toDouble() else {
            return "lon: \(locationData.longitude)"
        }
        
        switch dmsType {
        case .D:
            return "lon \(locationData.longitude)"
        case .DM:
            return "lon \(String.DtoDM(with: lon))"
        case .DMS:
            return "lon \(String.DtoDMS(with: lon))"
        }
    }
}

// 특정 코너만 라운드 처리하기 위한 Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
