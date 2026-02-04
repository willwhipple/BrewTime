//
//  DailyCupLog.swift
//  BrewTime
//
//  Persists cup timestamps for "today"; calendar-day filtering and encoding for AppStorage.
//

import Foundation

enum DailyCupLog {
    static let storageKey = "dailyCupTimestamps"

    /// Encode dates as JSON array of timeIntervalSince1970 for AppStorage.
    static func encode(_ dates: [Date]) -> String {
        let intervals = dates.map { $0.timeIntervalSince1970 }
        guard let data = try? JSONEncoder().encode(intervals) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    /// Decode JSON array of timeIntervalSince1970 to dates.
    static func decode(_ string: String) -> [Date] {
        guard let data = string.data(using: .utf8),
              let intervals = try? JSONDecoder().decode([Double].self, from: data) else {
            return []
        }
        return intervals.map { Date(timeIntervalSince1970: $0) }
    }

    /// Return only timestamps that fall in the current calendar day.
    static func todayTimestamps(from raw: String, calendar: Calendar = .current) -> [Date] {
        let all = decode(raw)
        let start = startOfToday(calendar: calendar)
        let end = endOfToday(calendar: calendar)
        return all.filter { $0 >= start && $0 < end }
    }

    static func startOfToday(calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: Date())
    }

    static func endOfToday(calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: 1, to: startOfToday(calendar: calendar)) ?? startOfToday(calendar: calendar)
    }

    /// Noon today in the user's calendar (for "first two before noon" rule).
    static func noonToday(calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 12
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? startOfToday(calendar: calendar)
    }
}
