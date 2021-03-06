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
	private let reminder: ReminderProtocol

	private var news = [NewsPresenterViewModelProtocol]()
	private var openedNewsCells = Set<String>()

    // MARK: - Construction

    init(interactor: NewsListInteractorProtocol,
		 router: NewsListRouterProtocol,
		 newsSourcesProvider: NewsSourcesProviderProtocol,
		 settingsProvider: SettingsProviderProtocol,
		 newsViewModelFactory: NewsViewModelFactoryProtocol,
		 reminder: ReminderProtocol) {
        self.interactor = interactor
        self.router = router

		self.newsSourcesProvider = newsSourcesProvider
		self.settingsProvider = settingsProvider
		self.newsViewModelFactory = newsViewModelFactory
		self.reminder = reminder

		setup()
    }

	deinit {
		settingsProvider.removeDelegate(self)
	}

	// MARK: - Private Methods

	private func setup() {
		settingsProvider.addDelegate(self)

		update()

		reminder.delegate = self
		reminder.remind(timeInterval: settingsProvider.updatePeriod)
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
		newsModel.isRead = true

		if let url = URL(string: newsModel.link) {
			let request = URLRequest(url: url)

			router.openNews(title: newsModel.title, urlRequest: request)
			interactor.addReadNewsLink(newsModel.link)
		} else {
			router.showWrongUrlError()
		}
	}
}

// MARK: - NewsListInteractorDelegate

extension NewsListPresenter: NewsListInteractorDelegate {
	func newsListInteractor(_ interactor: NewsListInteractorProtocol, didUpdateNews news: [News]) {
		let readNewsLinks = interactor.readNewsLinks
		let openedNews = self.news.filter { $0.isOpen }.reduce(into: Set<String>()) { (set, viewModel) in
			set.insert(viewModel.link)
		}

		self.news = news.map {
			let isRead = readNewsLinks.contains($0.link)
			let isOpened = openedNews.contains($0.link)
			return self.newsViewModelFactory.makeNewsViewModel(news: $0,
															   isRead: isRead,
															   isOpen: isOpened)
		}
		.sorted { $0.date > $1.date }

		delegate?.updateNewsList()

		print("Update \(news.count)")
	}
}

// MARK: - NewsListPresenter

extension NewsListPresenter: SettingsProviderDelegate {
	func settingsService(_ settingsService: SettingsServiceProtocol, didChangeUpdatePeriod updatePeriod: TimeInterval) {
		reminder.remind(timeInterval: updatePeriod)
	}

	func settingsService(_ settingsService: SettingsServiceProtocol,
						 didChangeDisabledNewsSources newsSources: Set<String>) {
		update()
	}
}

// MARK: - ReminderDelegate

extension NewsListPresenter: ReminderDelegate {
	func reminderDidNotificate() {
		update()
	}
}
