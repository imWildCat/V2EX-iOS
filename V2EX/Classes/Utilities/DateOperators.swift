//
//  DateOperators for Swift
//
// A set of Swift operators to manipulate dates.
// The idea here is to use dates the same way you would do in Rails.
//
//  Created by Aurélien Noce on 08/01/2015.
//  Copyright (c) 2015 Aurélien Noce. All rights reserved.
//
//  The MIT License
//  https://github.com/ushu/DateOperators.swift/blob/master/DateOperators.swift

import Foundation

// MARK: constants

// to avoid a type issue in Swift with NSUndefinedDateComponent being Uint
let InvalidDateComponentInt = Int(NSDateComponentUndefined)
let SummableCalendarUnits = [ NSCalendarUnit.CalendarUnitYear
    , NSCalendarUnit.CalendarUnitMonth
    , NSCalendarUnit.CalendarUnitDay
    , NSCalendarUnit.CalendarUnitHour
    , NSCalendarUnit.CalendarUnitMinute
    , NSCalendarUnit.CalendarUnitSecond
    , NSCalendarUnit.CalendarUnitNanosecond ]
// OR all summable calendar units for bitmask usage
let AllSummableCalendarUnits = SummableCalendarUnits.reduce(NSCalendarUnit.allZeros) { (all, unit) in return all | unit }

// MARK: Extension to the Int class to generate NSDateComponents from Int

private func components(selectedComponent: NSCalendarUnit, withValue value: Int) -> NSDateComponents {
    let dateComponents = NSDateComponents()
    dateComponents.setValue(value, forComponent: selectedComponent)
    return dateComponents
}

extension Int {
    
    /** Retuns a `NSDateComponents` instance representing `self` years.
    *
    * @return a new `NSDateComponents` instance.
    */
    var year: NSDateComponents {
        return components(.CalendarUnitYear, withValue: self)
    }
    /** Alias to `year`.
    *
    * @see year.
    */
    var years: NSDateComponents { return year }
    
    /** Retuns a `NSDateComponents` instance representing `self` months.
    *
    * @return a new `NSDateComponents` instance.
    */
    var month: NSDateComponents {
        return components(.CalendarUnitMonth, withValue: self)
    }
    /** Alias to `month`.
    *
    * @see months.
    */
    var months: NSDateComponents { return month }
    
    /** Retuns a `NSDateComponents` instance representing `self` days.
    *
    * @return a new `NSDateComponents` instance.
    */
    var day: NSDateComponents {
        return components(.CalendarUnitDay, withValue: self)
    }
    /** Alias to `day`.
    *
    * @see day.
    */
    var days: NSDateComponents { return day }
    
    /** Retuns a `NSDateComponents` instance representing `self` hours.
    *
    * @return a new `NSDateComponents` instance.
    */
    var hour: NSDateComponents {
        return components(.CalendarUnitHour, withValue: self)
    }
    /** Alias to `hour`.
    *
    * @see hour.
    */
    var hours: NSDateComponents { return hour }
    
    /** Retuns a `NSDateComponents` instance representing `self` minutes.
    *
    * @return a new `NSDateComponents` instance.
    */
    var minute: NSDateComponents {
        return components(.CalendarUnitMinute, withValue: self)
    }
    /** Alias to `minute`.
    *
    * @see minute.
    */
    var minutes: NSDateComponents { return minute }
    
    /** Retuns a `NSDateComponents` instance representing `self` seconds.
    *
    * @return a new `NSDateComponents` instance.
    */
    var second: NSDateComponents {
        return components(.CalendarUnitSecond, withValue: self)
    }
    /** Alias to `second`.
    *
    * @see second.
    */
    var seconds: NSDateComponents { return second }
    
    /** Retuns a `NSDateComponents` instance representing `self` seconds.
    *
    * @return a new `NSDateComponents` instance.
    */
    var millisecond: NSDateComponents {
        return (self * 1000).nanosecond
    }
    /** Alias to `second`.
    *
    * @see second.
    */
    var milliseconds: NSDateComponents { return millisecond }
    
    /** Retuns a `NSDateComponents` instance representing `self` nanoseconds.
    *
    * @return a new `NSDateComponents` instance.
    */
    var nanosecond: NSDateComponents {
        return components(.CalendarUnitNanosecond, withValue: self)
    }
    /** Alias to `nanosecond`.
    *
    * @see nanosecond.
    */
    var nanoseconds: NSDateComponents { return nanosecond }
    
}

// MARK: sum and subsctract date components

/** Sums two `NSDateComponents` by adding all present field values.
*
* @return a new `NSDateComponents` holding the sum of all components.
* @see `SummableCalendarUnits` for a list of the considered date components.
*/
func + (dateComponents: NSDateComponents, otherComponents: NSDateComponents) -> NSDateComponents {
    let summedComponents = NSDateComponents()
    
    for calendarUnit in SummableCalendarUnits {
        let leftValue = dateComponents.valueForComponent(calendarUnit)
        let rightValue = otherComponents.valueForComponent(calendarUnit)
        
        // avoid accounting for invalid components
        var sum: Int?
        switch (leftValue, rightValue) {
        case (InvalidDateComponentInt, InvalidDateComponentInt):
            break
        case (InvalidDateComponentInt, _):
            sum = rightValue
        case (_, InvalidDateComponentInt):
            sum = leftValue
        default:
            sum = leftValue + rightValue
        }
        
        if let summedValue = sum {
            summedComponents.setValue(summedValue, forComponent: calendarUnit)
        }
    }
    
    return summedComponents
}

/** Substracts two `NSDateComponents` by subscracting all present field values.
*
* @return a new `NSDateComponents` holding the difference of all components.
* @see `SummableCalendarUnits` for a list of the considered date components.
*/
func - (dateComponents: NSDateComponents, otherComponents: NSDateComponents) -> NSDateComponents {
    let summedComponents = NSDateComponents()
    
    for calendarUnit in SummableCalendarUnits {
        let leftValue = dateComponents.valueForComponent(calendarUnit)
        let rightValue = otherComponents.valueForComponent(calendarUnit)
        
        // avoid accounting for invalid components
        var sum: Int?
        switch (leftValue, rightValue) {
        case (InvalidDateComponentInt, InvalidDateComponentInt):
            break
        case (InvalidDateComponentInt, _):
            sum = -rightValue
        case (_, InvalidDateComponentInt):
            sum = leftValue
        default:
            sum = leftValue - rightValue
        }
        
        if let summedValue = sum {
            summedComponents.setValue(summedValue, forComponent: calendarUnit)
        }
    }
    
    return summedComponents
}

// MARK: invert date components

/** Returns the opposite value of the given `NSDateComponents`.
*
* @return a new `NSDateComponents` holding the same components with opposite values.
* @see `SummableCalendarUnits` for a list of the considered date components.
*/
prefix func - (dateComponents: NSDateComponents) -> NSDateComponents {
    let invertedComponents = NSDateComponents()
    // to avoid a type issue in Swift with NSUndefinedDateComponent being Uint
    for calendarUnit in SummableCalendarUnits {
        let component = dateComponents.valueForComponent(calendarUnit)
        if component != InvalidDateComponentInt {
            invertedComponents.setValue(-component, forComponent: calendarUnit)
        }
    }
    
    return invertedComponents
}

// MARK: Date comparison operators
// I don't think I have to comment these...)

func > (letfDate: NSDate, rightDate: NSDate) -> Bool {
    return letfDate.compare(rightDate) == NSComparisonResult.OrderedDescending
}

func < (letfDate: NSDate, rightDate: NSDate) -> Bool {
    return letfDate.compare(rightDate) == NSComparisonResult.OrderedAscending
}

func == (letfDate: NSDate, rightDate: NSDate) -> Bool {
    return letfDate.compare(rightDate) == NSComparisonResult.OrderedSame
}

func <= (letfDate: NSDate, rightDate: NSDate) -> Bool {
    let comparison = letfDate.compare(rightDate)
    return comparison == NSComparisonResult.OrderedAscending || comparison == NSComparisonResult.OrderedSame
}

func >= (letfDate: NSDate, rightDate: NSDate) -> Bool {
    let comparison = letfDate.compare(rightDate)
    return comparison == NSComparisonResult.OrderedDescending || comparison == NSComparisonResult.OrderedSame
}

// MARK: Add support for adding/substracting NSDateComponents from a NSDate

/** Adds a `NSDateComponents` to a `NSDate`.
*
* @return a new `NSDate` when the adding is successful, of nil.
*/
func + (date: NSDate, dateComponents: NSDateComponents) -> NSDate! {
    let calendar = NSCalendar.currentCalendar()
    return calendar.dateByAddingComponents(dateComponents, toDate: date, options: NSCalendarOptions.allZeros)
}

/** Subsctracts a `NSDateComponents` from a `NSDate`.
*
* @return a new `NSDate` when the adding is successful, of nil.
*/
func - (date: NSDate, dateComponents: NSDateComponents) -> NSDate! {
    let calendar = NSCalendar.currentCalendar()
    return calendar.dateByAddingComponents(-dateComponents, toDate: date, options: NSCalendarOptions.allZeros)
}

// MARK: "light" comparison for NSDateComponents

private func reduceComponentValue(value: Int) -> Int {
    return value == 0 ? InvalidDateComponentInt : value
}

/**Compares two dates, ignoring the Difference between 0-values components and undefined components.
*
* @return true if all non-zero/non-undefined components are identical.
*/
infix operator =~{}
func =~(leftComponents: NSDateComponents, rightComponents: NSDateComponents) -> Bool {
    for component in SummableCalendarUnits {
        let leftValue  = reduceComponentValue(leftComponents.valueForComponent(component))
        let rightValue = reduceComponentValue(rightComponents.valueForComponent(component))
        
        if leftValue != rightValue {
            return false
        }
    }
    
    return true
}

// MARK: Add support to subtract two NSDate instances.

/** A subclass of `NSDateComponents` that keeps a track to a `fromDate` and `toDate` `NSDate` instances.
*/
class DateDelta : NSDateComponents {
    let fromDate: NSDate
    let toDate: NSDate
    
    /** Returns a new `UDateDelta` from two given dates.
    *
    * @return a new `UDateDelta` with `fromDate` and `toDate` populated, and components set to toDate-fromDate.
    */
    init(fromDate: NSDate, toDate: NSDate) {
        self.fromDate = fromDate
        self.toDate = toDate
        super.init()
        
        let calendar = NSCalendar.currentCalendar()
        let delta = calendar.components(AllSummableCalendarUnits, fromDate: fromDate, toDate: toDate, options: NSCalendarOptions.WrapComponents)
        for component in SummableCalendarUnits {
            // here we call reduceComponentValue to avoid lots of 0 components
            let value = reduceComponentValue(delta.valueForComponent(component))
            self.setValue(value, forComponent: component)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fromDate = aDecoder.decodeObjectForKey("fromDate") as! NSDate
        toDate = aDecoder.decodeObjectForKey("toDate") as! NSDate
        
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeObject(toDate, forKey: "toDate")
        aCoder.encodeObject(fromDate, forKey: "fromDate")
    }
    
    /** Compares a `UDateDelta` to a `NSDateComponents`.
    * Internally is calls the `==` operator between self and the `NSDateComponents`.
    *
    * @see `==`.
    */
    override func isEqual(object: AnyObject?) -> Bool {
        if let components = object as? NSDateComponents {
            return self == components
        } else {
            return super.isEqual(object)
        }
    }
}

/** Substracts two `NSDate` and retruns a new `UDateDelta`.
*
* @return a new `UDateDelta` holding the difference between the two dates.
* @see `UDateDelta`.
*/
func - (leftDate: NSDate, rightDate: NSDate) -> DateDelta! {
    return DateDelta(fromDate: rightDate, toDate: leftDate)
}

// MARK: operators for UDateDelta

private func sumDeltaToComponents(delta: DateDelta, components: NSDateComponents) -> (NSDate, NSDate)? {
    // compute the date by adding components to delta
    let calendar = NSCalendar.currentCalendar()
    let rightDate = calendar.dateByAddingComponents(components, toDate: delta.fromDate, options: NSCalendarOptions.allZeros)
    
    if let theRightDate = rightDate {
        let leftDate = delta.toDate
        return (leftDate, theRightDate)
    } else {
        return nil
    }
}

private func applyDeltaToComponents(delta: DateDelta, components: NSDateComponents, op: (NSDate, NSDate) -> Bool) -> Bool {
    if let sum = sumDeltaToComponents(delta, components) {
        let (left, right) = sum
        return op(left, right)
    } else {
        return false
    }
}

/** Compares a `UDateDelta` to a `NSDateComponents`.
* This makes the `UDateDelta` class conform to `Equatable`.
*
* Internally it compares fromDate+components to toDate.
*
* @return true if fromDate+components is the same as toDate, false otherwise.
*/
func ==(delta: DateDelta, components: NSDateComponents) -> Bool {
    return applyDeltaToComponents(delta, components, ==)
}
func ==(components: NSDateComponents, delta: DateDelta) -> Bool {
    return delta == components
}

/** Compares a `UDateDelta` to a `NSDateComponents`.
*
* Internally it compares fromDate+components to toDate.
*
* @return true if fromDate+components is less or equal to as toDate, false otherwise.
*/
func <=(delta: DateDelta, components: NSDateComponents) -> Bool {
    return applyDeltaToComponents(delta, components, <=)
}
func <=(components: NSDateComponents, delta: DateDelta) -> Bool {
    return delta >= components
}


/** Compares a `UDateDelta` to a `NSDateComponents`.
*
* Internally it compares fromDate+components to toDate.
*
* @return true if fromDate+components is greater or equal to as toDate, false otherwise.
*/
func >=(delta: DateDelta, components: NSDateComponents) -> Bool {
    return applyDeltaToComponents(delta, components, >=)
}
func >=(components: NSDateComponents, delta: DateDelta) -> Bool {
    return delta <= components
}

/** Compares a `UDateDelta` to a `NSDateComponents`.
*
* Internally it compares fromDate+components to toDate.
*
* @return true if fromDate+components is less to as toDate, false otherwise.
*/
func <(delta: DateDelta, components: NSDateComponents) -> Bool {
    return applyDeltaToComponents(delta, components, <)
}
func <(components: NSDateComponents, delta: DateDelta) -> Bool {
    return delta > components
}

/** Compares a `UDateDelta` to a `NSDateComponents`.
*
* Internally it compares fromDate+components to toDate.
*
* @return true if fromDate+components is greater to as toDate, false otherwise.
*/
func >(delta: DateDelta, components: NSDateComponents) -> Bool {
    return applyDeltaToComponents(delta, components, >)
}
func >(components: NSDateComponents, delta: DateDelta) -> Bool {
    return delta < components
}

// MARK: NSDateComponents extension

extension NSDateComponents {
    var ago: NSDate! {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        return calendar.dateByAddingComponents(-self, toDate: now, options: NSCalendarOptions.allZeros)
    }
}

// MARK: NSDate extension: class methods

extension NSDate {
    
    class func now() -> NSDate {
        return NSDate()
    }
    
    class func today() -> NSDate! {
        return now().beginningOfDay
    }
    
    class func yesterday() -> NSDate {
        return today() - 1.day
    }
    
    class func tomorrow() -> NSDate {
        return today() + 1.day
    }
}

// MARK: NSDate extension: instance methods

extension NSDate {
    
    var beginningOfDay: NSDate! {
        let calendar = NSCalendar.currentCalendar()
        return calendar.startOfDayForDate(self)
    }
    
    var beginningOfNextDay: NSDate! {
        return self + 1.day
    }
    
    var endOfDay: NSDate! {
        return self + (1.day - 1.nanosecond)
    }
    
    var inWeekend: Bool {
        let calendar = NSCalendar.currentCalendar()
        return calendar.isDateInWeekend(self)
    }
    
}

// MARK: NSDate extension: instance methods (comparison to today)

extension NSDate {
    
    var inToday: Bool {
        let calendar = NSCalendar.currentCalendar()
        return calendar.isDateInToday(self)
    }
    
    var inTomorrow: Bool {
        let calendar = NSCalendar.currentCalendar()
        return calendar.isDateInTomorrow(self)
    }
    
    var inYesterday: Bool {
        let calendar = NSCalendar.currentCalendar()
        return calendar.isDateInYesterday(self)
    }
    
}

// MARK: Compare NSDates for "the same day"

func =~(date: NSDate, otherDate: NSDate) -> Bool {
    let calendar = NSCalendar.currentCalendar()
    return calendar.isDate(date, inSameDayAsDate: otherDate)
}
