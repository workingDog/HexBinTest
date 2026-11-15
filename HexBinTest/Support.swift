//
//  Support.swift
//  HexBinTest
//
//  Created by Ringo Wathelet on 2026/11/15.
//
import SwiftUI
import MapKit
import SwiftyH3


struct MeshVertex: Identifiable {
    let id: String
    var coordinate: CLLocationCoordinate2D
}

struct MeshFace: Identifiable {
    let id: String
    let vertices: [String]
}

struct MeshEdge: Identifiable {
    let id: String
    let start: String
    let end: String
}

struct H3Mesh {
    var vertices: [String: MeshVertex] = [:]
    var faces: [MeshFace] = []

    var edges: [MeshEdge] {
        var result: [String: MeshEdge] = [:]

        for face in faces {
            let ids = face.vertices
            for index in ids.indices {
                let start = ids[index]
                let end = ids[(index + 1) % ids.count]
                let key = start < end  ? "\(start)|\(end)" : "\(end)|\(start)"
                result[key] = MeshEdge(id: key, start: start, end: end)
            }
        }
        return Array(result.values)
    }

    mutating func updateVertex(_ id: String, coordinate: CLLocationCoordinate2D) {
        vertices[id]?.coordinate = coordinate
    }

    static func create(from cells: [H3Cell]) throws -> H3Mesh {
        var mesh = H3Mesh()

        for cell in cells {
            let h3Vertices = try cell.vertices
            let vertexIDs = h3Vertices.map(\.description)

            for vertex in h3Vertices {
                let id = vertex.description
                if mesh.vertices[id] == nil {
                    mesh.vertices[id] = MeshVertex(
                        id: id,
                        coordinate: try vertex.latLng.coordinates
                    )
                }
            }

            mesh.faces.append(MeshFace(id: cell.description, vertices: vertexIDs))
        }

        return mesh
    }
}

struct DraggableVertex: View {
    let coordinate: CLLocationCoordinate2D
    let proxy: MapProxy
    let onChanged: (CLLocationCoordinate2D) -> Void
    let onDragChanged: (Bool) -> Void

    @State private var startPoint: CGPoint?

    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: 18, height: 18)
            .overlay {
                Circle().stroke(.blue, lineWidth: 2)
            }
            .shadow(radius: 2)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if startPoint == nil {
                            startPoint = proxy.convert(coordinate, to: .local)
                            onDragChanged(true)
                        }

                        guard let startPoint else { return }

                        let point = CGPoint(
                            x: startPoint.x + value.translation.width,
                            y: startPoint.y + value.translation.height
                        )

                        if let newCoordinate = proxy.convert(point, from: .local) {
                            onChanged(newCoordinate)
                        }
                    }
                    .onEnded { _ in
                        startPoint = nil
                        onDragChanged(false)
                    }
            )
    }
}
