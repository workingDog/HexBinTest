//
//  H3MapKit.swift
//  HexBinTest
//
//  Created by Ringo Wathelet on 2026/09/14.
//
import Foundation
import MapKit
import SwiftyH3


enum H3MapKit {

    // MARK: - MKPolygon → H3

    static func cells(in polygon: MKPolygon,resolution: H3Cell.Resolution) throws -> [H3Cell] {
        let boundary = polygon.coordinates.map(H3LatLng.init)
        guard boundary.count >= 3 else {
            throw H3Error.invalidPolygon
        }
        return try H3Polygon(boundary).cells(at: resolution)
    }

    // MARK: - H3Cell → MKPolygon

    static func polygon(for cell: H3Cell) throws -> MKPolygon {
        MKPolygon(try cell.boundary)
    }
    
    static func polygons(for cells: [H3Cell]) throws -> [MKPolygon] {
        try cells.map { MKPolygon(try $0.boundary) }
    }

    // MARK: - H3Cell array → MKMultiPolygon

    static func multiPolygon(for cells: [H3Cell]) throws -> MKMultiPolygon {
        let polygons = try cells.map { cell in
            try polygon(for: cell)
        }
        return MKMultiPolygon(polygons)
    }

    // MARK: - H3Cell array → Combined outline

    static func outline(for cells: [H3Cell]) throws -> MKMultiPolygon {
        let h3MultiPolygon = try cells.multiPolygon
        let polygons = h3MultiPolygon.map { h3Polygon in
            let exterior = h3Polygon.boundary.map(\.coordinate)
            let holes = h3Polygon.holes.map { hole in
                MKPolygon(coordinates: hole.map(\.coordinate),count: hole.count)
            }
            return MKPolygon(coordinates: exterior,count: exterior.count,interiorPolygons: holes)
        }
        return MKMultiPolygon(polygons)
    }

    // MARK: - Coordinate → H3

    static func cell(
        containing coordinate: CLLocationCoordinate2D,
        resolution: H3Cell.Resolution
    ) throws -> H3Cell {
        try H3LatLng(coordinate)
            .cell(at: resolution)
    }
}

// MARK: - Errors

enum H3Error: Error {
    case invalidPolygon
}

// MARK: - H3LatLng → CLLocationCoordinate2D

private extension H3LatLng {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitudeRads,longitude: longitudeRads)
    }
}

// MARK: - MKPolygon coordinates

private extension MKPolygon {

    var coordinates: [CLLocationCoordinate2D] {
        var coordinates = Array(repeating: CLLocationCoordinate2D(),count: pointCount)
        getCoordinates(&coordinates,range: NSRange(location: 0,length: pointCount))
        return coordinates
    }
    
}
