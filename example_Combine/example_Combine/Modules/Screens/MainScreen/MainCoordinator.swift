//
//  MainCoordinator.swift
//  example_Combine
//
//  Created by VladimirCH on 20.07.2023.
//

import UIKit

final class MainCoordinator {

    init() {
    }

    func start() -> UIViewController {
        let model = MainViewModelImpl()
        let view = MainViewController(viewModel: model)
        model.viewContriller = view
        return view
    }
}
