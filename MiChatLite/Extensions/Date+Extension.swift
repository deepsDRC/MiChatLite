//
//  Date+Extension.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 18/09/26.
//


import Foundation

nonisolated extension Date {
    func hhmmFormattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter.string(from: self)
    }
}
