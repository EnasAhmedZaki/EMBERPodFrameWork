//
//  DateUtility.swift
//  OsirisBio Provider
//
//  Created by Pramod More on 8/17/18.
//  Copyright © 2018 Biz4Solutions. All rights reserved.
//

import Foundation

enum DateFormats: String {

    case timeTweleveHours = "hh:mm a"
    case timeTeleveHoursWithoutAm = "hh:mm"
    case dayMonthNameYear = "d MMM, yyyy" // 17 Sept 2018
    case dayMonthNameYearTime = "d MMM, yyyy. hh:mm a" // 17 Sept 2018
    case dayNameMontheNameMonthNumberYearTime = "E, MMM d, yyyy"
    case dayNameMontheNameMonthNumberYearTimeWithHours = "E, MMM d, yyyy - hh:mm a"

}

// Swift 3:
typealias UnixTime = Int

let TWELVE_HOURS_DATE_FORMAT = "hh:mm a"
let TWENTYFOUR_HOURS_DATE_FORMAT = "HH:mm"
let MONTH_DATE_YEAR_FORMAT = "MM/dd/yyyy"
let DAYNAME_MONTH_DATE_YEAR_FORMAT = "E, MM/dd/yyyy"

let MONTH_DATE_YEAR_HH_MM_A_FORMAT = "MM/dd/yyyy, hh:mm a"
let MONTH_DATE_YEAR_TIME_FORMAT = "MM/dd/yyyy h:mm a"
let MONTH_DAY_YEAR_FORMAT = "MMM d, yyyy"

let YEAR_MONTH_DATE_FORMAT = "yyyy-MM-dd"
let DAYNAME_MONTHNAME_DATE_FORMAT = "EEE, MMM d"
let DAYNAME_DATE_MONTHNAME_FORMAT = "EEE, d MMM"
let DAY_MONTH_DATE = "E, MMMM d"
let MONTH_DATE_TIME_FORMAT = "MMM d, h:mm a"

let LOCAL_UTC_DATE_FORMAT = "yyyy-MM-dd HH:mm:ss.SSS"
let FULL_DATE_WITH_ZONE = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
let FULL_DATE_HOURS_MINUTE_ZONE = "yyyy-MM-dd'T'HH:mmZ"
let TWENTYFOUR_HOURS_TIME_FORMAT = "HH:mm:ss"
let HOURS_MINUTE_FORMAT = "HH:mm"
let HOURS_MINUTE_AM_FORMAT = "h:mm a"

let DAY_MONTH_YEAR_FORMAT = "d MMM, yyyy"
let THIRTY_MIN_TIMESTAMP = 1800

class DateUtility {

    static func getDateFormatter() -> DateFormatter {
        var dateFormatter: DateFormatter!

        dateFormatter = DateFormatter()
        let twelveHourLocale = Locale(identifier: L102Language.currentAppleLanguage())
        dateFormatter.locale = twelveHourLocale as Locale

        return dateFormatter
    }

    static func getUTCFormateDate(_ localDate: Date) -> String {
        let dateFormatter = DateFormatter()
        if let timeZone = TimeZone(abbreviation: "UTC") {
            dateFormatter.timeZone = timeZone
        }
        let twelveHourLocale = Locale(identifier: L102Language.currentAppleLanguage())

        dateFormatter.locale = twelveHourLocale as Locale?
        dateFormatter.dateFormat = FULL_DATE_HOURS_MINUTE_ZONE
        let dateString: String = dateFormatter.string(from: localDate)
        return dateString
    }

    static func dateFromTimeStamp(timeStamp: Double) -> Date {
        var date = Date(timeIntervalSince1970: TimeInterval(timeStamp))

        date = NSDate(timeIntervalSince1970: TimeInterval(Double(timeStamp))) as Date
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") // Set timezone that you want
        // dateFormatter.locale = NSLocale.current
        dateFormatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // Specify your format that you want
        // let strDate = dateFormatter.string(from: date)
        return date as Date
    }

    static func dateFromTimeStamp(timeStamp: Int64) -> Date {
        var date = Date(timeIntervalSince1970: TimeInterval(timeStamp) / 1000)

        date = NSDate(timeIntervalSince1970: TimeInterval(Double(timeStamp) / 1000)) as Date
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") // Set timezone that you want
        // dateFormatter.locale = NSLocale.current
        dateFormatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // Specify your format that you want
        // let strDate = dateFormatter.string(from: date)
        return date as Date
    }
    
    static func getUTCFormateDateString(_ localDate: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        let timeZone = NSTimeZone.system
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        let dateString: String = dateFormatter.string(from: localDate)
        return dateString
    }

    static func stringFromDate(fromDate: Date, dateFormat: String!) -> String {
        var dateFormatter = DateFormatter()
        
        if dateFormat == DateFormats.dayMonthNameYear.rawValue || dateFormat == DateFormats.dayNameMontheNameMonthNumberYearTime.rawValue {
            
            if  fromDate.shortDate == Date().yesterday.shortDate {
                dateFormatter.dateStyle = .short
                dateFormatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
                dateFormatter.doesRelativeDateFormatting = true
                return dateFormatter.string(from: fromDate)
            } else if fromDate.shortDate == Date().shortDate {
                dateFormatter.dateStyle = .short
                dateFormatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
                dateFormatter.doesRelativeDateFormatting = true
                return dateFormatter.string(from: fromDate)
            }
        }
        
        dateFormatter = self.getDateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
        let strDate = dateFormatter.string(from: fromDate)
        return strDate
        
    }

    static func stringFromDateDOB(fromDate: Date, dateFormat: String!) -> String {
        let dateFormatter = self.getDateFormatter()
        dateFormatter.dateFormat = dateFormat
        // let timeZone = TimeZone(abbreviation: "UTC")
        // dateFormatter.timeZone = timeZone!
        let twelveHourLocale = Locale(identifier: L102Language.currentAppleLanguage())
        dateFormatter.locale = twelveHourLocale

        let strDate = dateFormatter.string(from: fromDate)
        return strDate
    }

    static func timeAgoSinceDate(_ date: Date, numericDates: Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest, to: latest)

        if let year = components.year, year >= 2 {
            return "\(year) " + "years ago".localized
        } else if let year = components.year, year >= 1 {
            if numericDates {
                return "1 year ago".localized
            } else {
                return "Last year".localized
            }
        } else if let month = components.month, month >= 2 {
            return "\(month)" + "months ago".localized
        } else if let month = components.month, month >= 1 {
            if numericDates {
                return "1 month ago".localized
            } else {
                return "Last month".localized
            }
        } else if let week = components.weekOfYear, week >= 2 {
            return "\(week) " + "weeks ago".localized
        } else if let week = components.weekOfYear, week >= 1 {
            if numericDates {
                return "1 week ago".localized
            } else {
                return "Last week".localized
            }
        } else if let day = components.day, day >= 2 {
            return "\(day)" + "days ago".localized
        } else if let day = components.day, day >= 1 {
            if numericDates {
                return "1 day ago".localized
            } else {
                return "Yesterday".localized
            }
        } else if let hour = components.hour, hour >= 2 {
            return "\(hour) " + "hrs ago".localized
        } else if let hour = components.hour, hour >= 1 {
            if numericDates {
                return "1 hr ago".localized
            } else {
                return "An hr ago".localized
            }
        } else if let minute = components.minute, minute >= 2 {
            return "\(minute) " + "mins ago".localized
        } else if let minute = components.minute, minute >= 1 {
            if numericDates {
                return "1 min ago".localized
            } else {
                return "A min ago".localized
            }
        } else if let second = components.second, second >= 3 {
            return "\(second)" + "sec ago".localized
        } else {
            return "Just now".localized
        }

    }

    static func localTimezoneStringFromDate(fromDate: Date, dateFormat: String!) -> String {
        let dateFormatter = self.getDateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone.current
        let strDate = dateFormatter.string(from: fromDate)
        return strDate
    }

    static func formatStringDateForDateWithSubscribt(_ date: Date) -> String {

        let dateFormatter = DateFormatter()

        if  date.shortDate == Date().yesterday.shortDate {
            dateFormatter.dateStyle = .short
            dateFormatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter.string(from: date)
        } else if date.shortDate == Date().shortDate {
            dateFormatter.dateStyle = .short
            dateFormatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter.string(from: date)
        } else {

            let dateStr = DateUtility.dateFormatWithDateOnly(date) ?? ""
            dateFormatter.dateFormat = "MMM"
            dateFormatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
            let dateString = dateFormatter.string(from: date)

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            formatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
            let yearString = formatter.string(from: date)
            let daySuffix = L102Language.currentAppleLanguage() != "ar" ? DateUtility.daySuffix(date) : ""
            let finalString = "\(dateStr)\(daySuffix)" + " " + "\(dateString)" + " " + "\(yearString)"
            return finalString
        }
    }

    static func dateFormatWithDateOnly(_ date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
        formatter.dateFormat = "d" // day
        let dateString = formatter.string(from: date)
        return dateString
    }

    static func daySuffix(_ date: Date) -> String {

        let calendar = Calendar.current
        let dayOfMonth = (calendar as NSCalendar).component(.day, from: date)
        var suffixString = ""
        switch dayOfMonth {
        case 1, 21, 31: suffixString = "st"
        case 2, 22: suffixString = "nd"
        case 3, 23: suffixString = "rd"
        default: suffixString = "th"
        }
        return suffixString
    }
    
    static func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    static func printSecondsToHoursMinutesSeconds (seconds: Int) -> String {
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: seconds)
        
        if h != 0 {
            return ("\(h) \("hrs".localized), \(m) \("min".localized), \(s) \("sec".localized)")
        }
        
        if m != 0 {
            return ("\(m) \("min".localized), \(s) \("sec".localized)")
        }
        
        return ("\(s) \("sec".localized)")
        
    }
    
    static func printSecondsToHoursMinutesSecondsInRequestList (seconds: Int) -> String {
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: seconds)
        
        if h != 0 {
            return ("\(h)".localizingTheNumbers() + " \("hrsRequest".localized) " + "\(m)".localizingTheNumbers() + " \("Mins".localized) " + "\(s)".localizingTheNumbers() + " \("secRequest".localized) ")
        }
        
        if m != 0 {
            return ("\(m)".localizingTheNumbers() + " \("Mins".localized) " + "\(s)".localizingTheNumbers() + " \("secRequest".localized) ")
        }
        
        return ("\(s)".localizingTheNumbers() + " \("secRequest".localized) ")
        
    }
    
    static func getHourAndMinAndSecFromADate(date: Date) -> (Int, Int, Int) {

        var calendar = Calendar.current

        let timeZone = TimeZone(identifier: "GMT") ?? TimeZone.current
        calendar.timeZone = timeZone
        
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return (hour, minute, second)

    }
    
    static func getHourAndMinAndSecFromADateCurrentTZ(date: Date) -> (Int, Int, Int) {
        
        var calendar = Calendar.current
        
        let timeZone = TimeZone.current
        calendar.timeZone = timeZone
        
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return (hour, minute, second)
        
    }
    
    static func getLocaleDateFromGMT(date: Date) -> Date {
        return Date(timeIntervalSince1970: date.timeIntervalSince1970 + Double(TimeZone.current.secondsFromGMT()))
    }
}

extension Date {
    var ticks: Double {
        return Double(self.timeIntervalSince1970 )
    }

    var startOfDay: Date {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? TimeZone.current
        return calendar.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1

        return Calendar.current.date(byAdding: components, to: startOfDay) ?? Date()
    }
    
    func toLocalTime() -> Date {

        let timezone = TimeZone.current

        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))

        return Date(timeInterval: seconds, since: self)

    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: self)
    }
    
    var dataWithDotsFormat: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
    
    var timeWithHoursMinutes: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: L102Language.currentAppleLanguage())
        formatter.dateFormat = HOURS_MINUTE_AM_FORMAT
        return formatter.string(from: self)
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]

        guard let timeString = formatter.string(from: self, to: Date()) else {
            return nil
        }

        let formatString = NSLocalizedString("ago".localized, comment: "")
        return String(format: formatString, timeString)
    }

    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
    
    var startOfMonth: Date {

         let calendar = Calendar(identifier: .gregorian)
         let components = calendar.dateComponents([.year, .month], from: self)

         return  calendar.date(from: components) ?? Date()
     }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth) ?? Date()
    }
  
}

extension TimeInterval {

    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)

        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d", hours, minutes, seconds, ms)
    }

    func longFromTimeInterval() -> Int64 {
        let ms = Int64((self.truncatingRemainder(dividingBy: 1)) * 1000)
        return ms
    }

}

extension Int {
    var msToSeconds: Int {
        return Int(self) / 1000
    }
}

extension Int64 {
    var msToDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }
    
    var startOfDayInMillisecond: Int64 {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone.current
        
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: DateUtility.dateFromTimeStamp(timeStamp: self))?.millisecondsSince1970 ?? 0
    }
    
    var endOfDayInMillisecond: Int64 {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone.current
        
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: DateUtility.dateFromTimeStamp(timeStamp: self))?.millisecondsSince1970 ?? 0
    }
    
}
