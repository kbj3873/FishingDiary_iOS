//
//  UseCase.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/12/07.
//

import Foundation

protocol UseCase {
    @discardableResult
    func start() -> Cancellable?
}
