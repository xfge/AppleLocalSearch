//
//  LocalSearchService.swift
//  WeddMate
//
//  Created by Robin Kment on 13/10/2020.
//  Copyright © 2020 Robin Kment. All rights reserved.
//

import Combine
import Foundation
import MapKit

final class LocalSearchService {
    let localSearchPublisher = PassthroughSubject<[MKMapItem], Never>()
    private let center: CLLocationCoordinate2D
    private let radius: CLLocationDistance

    private var timer: Timer?
    private var search: MKLocalSearch?

    init(in center: CLLocationCoordinate2D,
         radius: CLLocationDistance = 350000) {
        self.center = center
        self.radius = radius
    }

    public func searchCities(searchText: String) {
        timer?.invalidate()
        search?.cancel()

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.request(resultType: .address, searchText: searchText)
        }
    }

    public func searchPointOfInterests(searchText: String) {
        timer?.invalidate()
        search?.cancel()

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.request(searchText: searchText)
        }
    }

    private func request(resultType: MKLocalSearch.ResultType = .pointOfInterest,
                         searchText: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.pointOfInterestFilter = .includingAll
        request.resultTypes = resultType
        request.region = MKCoordinateRegion(center: center,
                                            latitudinalMeters: radius,
                                            longitudinalMeters: radius)
        let search = MKLocalSearch(request: request)

        search.start { [weak self] response, error in
            if let error {
                print("Error: \(error.localizedDescription)")
            }

            guard let response = response else {
                return
            }

            self?.localSearchPublisher.send(response.mapItems)
        }
    }
}
