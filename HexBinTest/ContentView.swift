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
    @State private var cells: [H3Cell] = []
    
    // Tokyo
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.681105, longitude:  139.780862),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(cells) { cell in
                if let boundary = try? cell.boundary {
                    MapPolygon(MKPolygon(boundary))
                        .foregroundStyle(.blue.opacity(0.1))
                        .stroke(Color.blue, lineWidth: 1)
                }
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
        
        return switch span {
            case 15...:     .res2   // country / large region
            case 4...:      .res3
            case 1...:      .res4
            case 0.25...:   .res5
            case 0.07...:   .res6
            case 0.02...:   .res7
            case 0.01...:   .res8
            case 0.005...:  .res10
            case 0.0005...: .res12
            default:        .res12 // when very closely zoomed in
        }
    }
    
}
