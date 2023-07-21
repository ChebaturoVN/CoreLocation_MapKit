//
//  MainViewModel.swift
//  example_Combine
//
//  Created by VladimirCH on 20.07.2023.
//

import UIKit
import CoreLocation
import MapKit

protocol MainViewModel {
    func alertAddAdress(title: String,
                        placeholder: String,
                        complitionHandler: @escaping(String) -> Void)
    func alertError(title: String, message: String)

//    func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D)
}

final class MainViewModelImpl: MainViewModel {

    var viewContriller: MainViewController?

    func alertAddAdress(title: String,
                        placeholder: String,
                        complitionHandler: @escaping(String) -> Void) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { (action) in

            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else { return }
            complitionHandler(text)
        }

        alertController.addTextField { (tf) in
            tf.placeholder = placeholder
        }

        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { (_) in

        }

        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)

        viewContriller?.present(alertController, animated: true, completion: nil)
    }

    func alertError(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK",
                                    style: .default)

        alertController.addAction(alertOk)

        viewContriller?.present(alertController, animated: true)
    }

//    func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
//
//        let startLocation = MKPlacemark(coordinate: startCoordinate)
//        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
//
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: startLocation)
//        request.destination = MKMapItem(placemark: destinationLocation)
//        request.transportType = .walking
//        request.requestsAlternateRoutes = true
//
//        let diraction = MKDirections(request: request)
//        diraction.calculate { (responce, error) in
//
//            if let error = error {
//                print(error)
//                return
//            }
//
//            guard let responce = responce else {
//                self.alertError(title: "Ошибка", message: "Маршрут недоступен")
//                return
//            }
//
//            var minRoute = responce.routes[0]
//
//            for route in responce.routes {
//                minRoute = (route.distance < minRoute.distance) ? route : minRoute
//            }
//
//            self.viewContriller?.mapView.addOverlay(minRoute.polyline)
//        }
//    }

}
