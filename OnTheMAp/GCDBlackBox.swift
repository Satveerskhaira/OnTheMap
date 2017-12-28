//
//  GCDBlackBox.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/16/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
