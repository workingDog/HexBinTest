//
//  ContentView.swift
//  HexBinTest
//
//  Created by Ringo Wathelet on 2026/09/13.
//
import SwiftUI
import MapKit
import SwiftyH3


struct ContentView: View {
    var body: some View {
        H3GridMap()
    }
}

struct H3GridMap: View {
    @State private var cells: [H3Cell] = []
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.681105, longitude:  139.780862),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    private let resolution: H3Cell.Resolution = .res2

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(cells, id: \.description) { cell in
                let boundary = try? cell.boundary
                MapPolygon(MKPolygon(boundary!))
                    .foregroundStyle(.clear)
                    .stroke(Color.black, lineWidth: 1)
            }
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            let resolution = resolution(for: context.region)
            cells = (try? cellsCovering(context.region, at: resolution)) ?? []
        }
    }

    private func cellsCovering(_ region: MKCoordinateRegion, at resolution: H3Cell.Resolution) throws -> [H3Cell] {
        
        let north = region.center.latitude + region.span.latitudeDelta / 2
        let south = region.center.latitude - region.span.latitudeDelta / 2
        let east  = region.center.longitude + region.span.longitudeDelta / 2
        let west  = region.center.longitude - region.span.longitudeDelta / 2

        let visibleArea = H3Polygon([
            H3LatLng(latitudeDegs: north, longitudeDegs: west),
            H3LatLng(latitudeDegs: north, longitudeDegs: east),
            H3LatLng(latitudeDegs: south, longitudeDegs: east),
            H3LatLng(latitudeDegs: south, longitudeDegs: west)
        ])

        return try visibleArea.cells(at: resolution)
    }
    
    private func resolution(for region: MKCoordinateRegion) -> H3Cell.Resolution {
        let span = max(region.span.latitudeDelta, region.span.longitudeDelta)

        switch span {
            case 15...: return .res2   // country / large region
            case 4...:  return .res3
            case 1...:  return .res4
            case 0.25...: return .res5
            case 0.07...: return .res6
            case 0.02...: return .res7
            case 0.01...: return .res8
            case 0.005...: return .res10
            case 0.0005...: return .res12
            default: return .res12 // when very closely zoomed in
        }
    }

}
