//
//  MainViewController.swift
//  example_Combine
//
//  Created by VladimirCH on 20.07.2023.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController {

    var annotationsArray = [MKPointAnnotation]()

    private let viewModel: MainViewModel

    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()

    private let addAdressButton: UIButton = {
        let button = UIButton()
        button.setImage(.add, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let routeButton: UIButton = {
        let button = UIButton()
        button.setImage(.checkmark, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    private let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(.remove, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        setConstraintts()
        setTargets()
    }

    private func setConstraintts() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])

        mapView.addSubview(addAdressButton)
        NSLayoutConstraint.activate([
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAdressButton.heightAnchor.constraint(equalToConstant: 100),
            addAdressButton.widthAnchor.constraint(equalToConstant: 100)
        ])

        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            routeButton.heightAnchor.constraint(equalToConstant: 100),
            routeButton.widthAnchor.constraint(equalToConstant: 100)
        ])

        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            resetButton.heightAnchor.constraint(equalToConstant: 100),
            resetButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func setTargets() {
        addAdressButton.addTarget(self, action: #selector(addAdressButtonTap), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTap), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTap), for: .touchUpInside)
    }

    @objc
    private func addAdressButtonTap() {
        viewModel.alertAddAdress(title: "Добавить", placeholder: "Введите адрес") { [weak self] text in
            self?.setupPlacemark(adressPlace: text)
        }
    }

    @objc
    private func routeButtonTap() {
        for index in 0...annotationsArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationsArray[index].coordinate,
                                             destinationCoordinate: annotationsArray[index + 1].coordinate)

        }
        mapView.showAnnotations(annotationsArray, animated: true)
    }

    @objc
    private func resetButtonTap() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        resetButton.isHidden = true
        routeButton.isHidden = true
    }

    private func setupPlacemark(adressPlace: String) {

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [weak self] (placemarks, error) in

            if let error = error {
                print(error)
                self?.viewModel.alertError(title: "Ошибак",
                                     message: "Сервер не доступен")
                return
            }

            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first

            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"

            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate

            self?.annotationsArray.append(annotation)

            if let annotationsArray = self?.annotationsArray,
               annotationsArray.count > 2 {
                self?.routeButton.isHidden = false
                self?.resetButton.isHidden = false
            }

            guard let annotationsArray = self?.annotationsArray else { return }
            self?.mapView.showAnnotations(annotationsArray, animated: true)
        }
    }

    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {

        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true

        let diraction = MKDirections(request: request)
        diraction.calculate { (responce, error) in

            if let error = error {
                print(error)
                return
            }

            guard let responce = responce else {
                self.viewModel.alertError(title: "Ошибка", message: "Маршрут недоступен")
                return
            }

            var minRoute = responce.routes[0]

            for route in responce.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }

            self.mapView.addOverlay(minRoute.polyline)
        }
    }

}

extension MainViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let renderer = MKPolygonRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
}

