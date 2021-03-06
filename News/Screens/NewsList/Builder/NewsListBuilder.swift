//
//  NewsListBuilder.swift
//  News
//
//  Created by Nikita Teplyakov on 18/05/2020.
//  Copyright © 2020 Nikita Teplyakov. All rights reserved.
//

import UIKit

class NewsListBuilder {

	// MARK: - Private Properties

	private let dependencyContainer: NewsListDependencyContainer

	// MARK: - Construction

	init(dependencyContainer: NewsListDependencyContainer) {
		self.dependencyContainer = dependencyContainer
	}

    // MARK: - Methods
    
    func buildModule() -> UIViewController {
		let interactor = NewsListInteractor(networkService: dependencyContainer.networkService,
											newsParserFactory: dependencyContainer.newsParserFactory,
											saveService: dependencyContainer.saveService)

		let webBuilder = dependencyContainer.makeWebBuilder()
		let router = NewsListRouter(webBuilder: webBuilder)

		let presenter = NewsListPresenter(interactor: interactor,
										  router: router,
										  newsSourcesProvider: dependencyContainer.tabBarDependencyContainer.newsSourcesProvider,
										  settingsProvider: dependencyContainer.tabBarDependencyContainer.settingsService,
										  newsViewModelFactory: dependencyContainer.newsViewModelFactory,
										  reminder: dependencyContainer.reminder)
		let viewController = NewsListViewController(presenter: presenter)

        interactor.delegate = presenter
        presenter.delegate = viewController
		router.viewController = viewController

        return viewController
    }
}
