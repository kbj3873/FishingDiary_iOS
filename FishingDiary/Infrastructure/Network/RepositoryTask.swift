//
//  RepositoryTask.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/07.
//

import Foundation

class RepositoryTask: Cancellable {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
