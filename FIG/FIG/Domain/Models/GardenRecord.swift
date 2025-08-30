//
//  GardenRecord.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

struct GardenRecord: Hashable {
    let totlaSeeds: Int
    let totalFruits: Int

    init(totlaSeeds: Int = 0, totalFruits: Int = 0) {
        self.totlaSeeds = totlaSeeds
        self.totalFruits = totalFruits
    }
}
