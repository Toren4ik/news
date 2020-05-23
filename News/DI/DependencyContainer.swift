//
//  DependencyContainer.swift
//  News
//
//  Created by Nikita Teplyakov on 15.05.2020.
//  Copyright © 2020 Nikita Teplyakov. All rights reserved.
//

class DependencyContainer {

	func makeTabBarBuilder() -> TabBarBuilder {
		let dependencyContainer = TabBarDependencyContainer()
		return TabBarBuilder(dependencyContainer: dependencyContainer)
	}
}
