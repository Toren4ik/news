//
//  NewsListPresenter.swift
//  News
//
//  Created by Nikita Teplyakov on 18/05/2020.
//  Copyright © 2020 Nikita Teplyakov. All rights reserved.
//

import NewsKit

class NewsListPresenter {

    // MARK: - Properties
    
    weak var delegate: NewsListPresenterDelegate?

	// MARK: - Private Properties

    private let interactor: NewsListInteractorProtocol
    private let router: NewsListRouterProtocol

	private let newsSourcesProvider: NewsSourcesProviderProtocol
	private let settingsProvider: SettingsProviderProtocol
	private let newsViewModelFactory: NewsViewModelFactoryProtocol

	private var news = [NewsPresenterViewModelProtocol]()

    // MARK: - Construction

    init(interactor: NewsListInteractorProtocol,
		 router: NewsListRouterProtocol,
		 newsSourcesProvider: NewsSourcesProviderProtocol,
		 settingsProvider: SettingsProviderProtocol,
		 newsViewModelFactory: NewsViewModelFactoryProtocol) {
        self.interactor = interactor
        self.router = router

		self.newsSourcesProvider = newsSourcesProvider
		self.settingsProvider = settingsProvider
		self.newsViewModelFactory = newsViewModelFactory

		setup()
    }

	deinit {
		settingsProvider.removeDelegate(self)
	}

	// MARK: - Private Methods

	private func setup() {
		settingsProvider.addDelegate(self)

		update()
	}

	private func update() {
		let disabledSources = settingsProvider.disabledNewsSources
		let sources = newsSourcesProvider.fetchNewsSources().filter { !disabledSources.contains($0.link) }

		interactor.updateNews(from: sources)
	}
}

// MARK: - NewsListPresenterProtocol

extension NewsListPresenter: NewsListPresenterProtocol {

	var viewModelsCount: Int {
		return news.count
	}

	func viewModelAtIndex(_ index: Int) -> NewsViewModelProtocol {
		return news[index]
	}

	func selectViewAtIndex(_ index: Int) {
		let newsModel = news[index]
		interactor.addReadNewsLink(newsModel.link)
	}
}

// MARK: - NewsListInteractorDelegate

extension NewsListPresenter: NewsListInteractorDelegate {
	func newsListInteractor(_ interactor: NewsListInteractorProtocol, didUpdateNews news: [News]) {
		let readNewsLinks = interactor.readNewsLinks
		let shouldShowSource = settingsProvider.shouldShowSource

		self.news = news.map {
			let isRead = readNewsLinks.contains($0.link)
			return self.newsViewModelFactory.makeNewsViewModel(news: $0, shouldShowSource: shouldShowSource, isRead: isRead)
		}
		.sorted { $0.date > $1.date }

		delegate?.updateNewsList()
	}

	func newsListInteractor(_ interactor: NewsListInteractorProtocol, didUpdateReadNewsLinks links: Set<String>) {
		news.forEach {
			$0.isRead = links.contains($0.link)
		}

		delegate?.updateNewsList()
	}
}

// MARK: - NewsListPresenter

extension NewsListPresenter: SettingsProviderDelegate {
	func settingsService(_ settingsService: SettingsServiceProtocol, didChangeUpdatePeriod updatePeriod: TimeInterval) {
		
	}

	func settingsService(_ settingsService: SettingsServiceProtocol, didChangeShowingSourcePolicy shouldShowSource: Bool) {
		delegate?.updateNewsList()
	}

	func settingsService(_ settingsService: SettingsServiceProtocol,
						 didChangeDisabledNewsSources newsSources: Set<String>) {
		update()
	}
}