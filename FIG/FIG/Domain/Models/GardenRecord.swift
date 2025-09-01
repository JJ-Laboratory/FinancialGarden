//
//  GardenRecord.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

struct GardenRecord: Hashable {
    let totalSeeds: Int
    let totalFruits: Int

    init(totalSeeds: Int = 0, totalFruits: Int = 0) {
        self.totalSeeds = totalSeeds
        self.totalFruits = totalFruits
    }
}
