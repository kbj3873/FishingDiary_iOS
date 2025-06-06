//
//  DispatchQueueType.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/11.
//

import Foundation

/// Used to easily mock main and background queues in tests
protocol DispatchQueueType {
    func async(execute work: @escaping () -> Void)
}

extension DispatchQueue: DispatchQueueType {
    func async(execute work: @escaping () -> Void) {
        async(group: nil, execute: work)
    }
}
