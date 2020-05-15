//
//  DependencyContainer.swift
//  News
//
//  Created by Nikita Teplyakov on 15.05.2020.
//  Copyright © 2020 Nikita Teplyakov. All rights reserved.
//

import Foundation

class DependencyContainer {

	func makeTabBarBuilder() -> TabBarBuilder {
		return TabBarBuilder()
	}
}
