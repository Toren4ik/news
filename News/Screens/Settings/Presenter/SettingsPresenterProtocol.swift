//
//  SettingsPresenterProtocol.swift
//  News
//
//  Created by Nikita Teplyakov on 28/05/2020.
//  Copyright © 2020 Nikita Teplyakov. All rights reserved.
//

protocol SettingsPresenterProtocol {

	var sections: [SettingsSection] { get }

	func selectSourceAtIndex(_ index: Int)
}
