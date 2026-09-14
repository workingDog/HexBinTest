//
//  H3CellMapExampleView.swift
//  HexBinTest
//
//  Created by Ringo Wathelet on 2026/09/13.
//
import SwiftUI
import MapKit
import SwiftyH3

struct H3CellMapExampleView: View {
    var body: some View {
        Map {
            H3Cell("87283082affffff")
            H3DirectedEdge("115283473fffffff").stroke(.blue, lineWidth: 2)
            try? ["8528342ffffffff", "85283093fffffff"].map { H3Cell($0)! }
                .multiPolygon[0]
        }
    }
}


struct H3CellMapExampleView2: View {
    let cellBoundary = try! H3LatLng(latitudeDegs: 37.7955, longitudeDegs: -122.3937).cell(at: .res4).boundary
    
    var body: some View {
        Map {
            MapPolygon(MKPolygon(cellBoundary))
        }
    }
}
