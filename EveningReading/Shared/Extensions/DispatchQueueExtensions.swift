//
//  DispatchQueueExtensions.swift
//  EveningReading (iOS)
//
//  Created by Willie Zutz on 8/20/21.
//

import Foundation

extension DispatchQueue {
    public func asyncAfterPostDelay(execute work: @escaping @convention(block) () -> Void) {
        self.asyncAfter(deadline: .now() + .seconds(2)) {
            work()
        }
    }
}
