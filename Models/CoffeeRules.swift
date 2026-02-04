//
//  CoffeeRules.swift
//  BrewTime
//
//  Research-backed validation: returns a single caution message (or nil). Never blocks—warn only.
//

import Foundation

enum CoffeeRules {
    /// Default cutoff: 4:00 PM local (for ~midnight bedtime).
    static let defaultCutoffHour = 16
    static let defaultCutoffMinute = 0
    /// Default max cups per day (FDA ~400 mg ≈ 4 cups).
    static let defaultMaxCups = 4

    /// Cutoff time today: e.g. 4:00 PM in the user's calendar.
    static func cutoffToday(calendar: Calendar = .current, hour: Int = defaultCutoffHour, minute: Int = defaultCutoffMinute) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components) ?? DailyCupLog.startOfToday(calendar: calendar)
    }

    /// Returns the single caution message to show (if any). Priority: cutoff > max cups > first-two-before-noon.
    /// Call this *after* the new cup has been added—pass the full list including the new timestamp.
    static func warning(
        cupTimestamps: [Date],
        now: Date = Date(),
        cutoff: Date? = nil,
        maxCups: Int = defaultMaxCups,
        calendar: Calendar = .current
    ) -> String? {
        let cutoffDate = cutoff ?? cutoffToday(calendar: calendar)
        let noon = DailyCupLog.noonToday(calendar: calendar)

        // 1. Cutoff: current time (the new cup) is after cutoff
        if now >= cutoffDate {
            return "Late caffeine—may affect sleep."
        }

        // 2. Max cups: at or over daily limit
        if cupTimestamps.count >= maxCups {
            return "You're at the daily limit—take it easy."
        }

        // 3. First two before noon: we have 3+ cups but fewer than 2 were before noon
        if cupTimestamps.count >= 3 {
            let beforeNoon = cupTimestamps.filter { $0 < noon }.count
            if beforeNoon < 2 {
                return "For 3+ cups, having the first two before noon helps keep energy steady."
            }
        }

        return nil
    }

    /// Optional daily summary: "You're good for sleep" vs "Last cup late—consider earlier cutoff tomorrow".
    static func dailySummary(
        cupTimestamps: [Date],
        cutoff: Date? = nil,
        calendar: Calendar = .current
    ) -> String? {
        guard let last = cupTimestamps.sorted().last else { return nil }
        let cutoffDate = cutoff ?? cutoffToday(calendar: calendar)
        if last >= cutoffDate {
            return "Last cup late—consider earlier cutoff tomorrow."
        }
        return "You're good for sleep."
    }
}
