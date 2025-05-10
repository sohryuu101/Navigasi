import Foundation
import SwiftUI
import SwiftData
import CoreLocation

@Model
class Place: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, desc, sysImage, coordinates, building, imageNames
    }
    
    var id: Int
    var name: String
    var desc: String
    var sysImage: String
    var coordinates: Coordinates
    var building: String
    
    private var imageNames: [String]
    
    var images: [Image] {
        return imageNames.map { imageName in
            Image(imageName)
        }
    }
    
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
    }
    
    struct Coordinates: Hashable, Codable {
        var latitude: Double
        var longitude: Double
    }
    
    init(id: Int, name: String, desc: String, sysImage: String, coordinates: Coordinates, building: String, imageNames: [String]) {
        self.id = id
        self.name = name
        self.desc = desc
        self.sysImage = sysImage
        self.coordinates = coordinates
        self.building = building
        self.imageNames = imageNames
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.sysImage = try container.decode(String.self, forKey: .sysImage)
        self.coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
        self.building = try container.decode(String.self, forKey: .building)
        self.imageNames = try container.decode([String].self, forKey: .imageNames)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(desc, forKey: .desc)
        try container.encode(sysImage, forKey: .sysImage)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(building, forKey: .building)
        try container.encode(imageNames, forKey: .imageNames)
    }
}
