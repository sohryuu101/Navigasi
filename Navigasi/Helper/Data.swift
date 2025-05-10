import Foundation
import SwiftData

class DataRelated: ObservableObject {
    func initializeData(context: ModelContext) {
        do {
            guard let url = Bundle.main.url(forResource: "places", withExtension: "json") else {
                fatalError("Failed to find users.json")
            }
            let data = try Data(contentsOf: url)
            let places = try JSONDecoder().decode([Place].self, from: data)

            for place in places {
                context.insert(place)
            }
            try context.save()
        } catch {
            print("Failed to pre-seed database.")
        }
    }
}
