//
//  AppCoordinator.swift
//  example_Combine
//
//  Created by VladimirCH on 20.07.2023.
//

import UIKit

protocol AppCoordinatorProtocol {
    func start() -> UIViewController
}

final class AppCoordinator: AppCoordinatorProtocol {

    private let mainViewController: MainCoordinator

    init() {
        self.mainViewController = MainCoordinator()
    }

    func start() -> UIViewController {
        return mainViewController.start()
    }
}
