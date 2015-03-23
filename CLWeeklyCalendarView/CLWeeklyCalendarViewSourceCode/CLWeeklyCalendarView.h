//
//  CLWeeklyCalendarView.h
//  Deputy
//
//  Created by Caesar on 30/10/2014.
//  Copyright (c) 2014 Caesar Li. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CLWeeklyCalendarViewDelegate <NSObject>

// Keys for customize the calendar behavior
extern NSString *const CLCalendarWeekStartDay;    //The Day of weekStart from 1 - 7 - Default: 1
extern NSString *const CLCalendarDayTitleTextColor; //Day Title text color,  Mon, Tue, etc label text color
extern NSString *const CLCalendarPastDayNumberTextColor;    //Day number text color for dates in the past
extern NSString *const CLCalendarFutureDayNumberTextColor;  //Day number text color for dates in the future
extern NSString *const CLCalendarCurrentDayNumberTextColor; //Day number text color for today
extern NSString *const CLCalendarSelectedDayNumberTextColor;    //Day number text color for the selected day
extern NSString *const CLCalendarSelectedCurrentDayNumberTextColor; //Day number text color when today is selected
extern NSString *const CLCalendarCurrentDayNumberBackgroundColor;   //Day number background color for today when not selected
extern NSString *const CLCalendarSelectedDayNumberBackgroundColor;  //Day number background color for selected day
extern NSString *const CLCalendarSelectedCurrentDayNumberBackgroundColor;   //Day number background color when today is selected
extern NSString *const CLCalendarSelectedDatePrintFormat;   //Selected Date print format,  - Default: @"EEE, d MMM yyyy"
extern NSString *const CLCalendarSelectedDatePrintColor;    //Selected Date print text color -Default: [UIColor whiteColor]
extern NSString *const CLCalendarSelectedDatePrintFontSize; //Selected Date print font size - Default : 13.f
extern NSString *const CLCalendarBackgroundImageColor;      //BackgroundImage color - Default : see applyCustomDefaults.

-(NSDictionary *)CLCalendarBehaviorAttributes;       //Optional Function, Set the calendar behavior attributes by using above keys

-(void)dailyCalendarViewDidSelect: (NSDate *)date;


@end


@interface CLWeeklyCalendarView : UIView

@property (nonatomic, weak) id<CLWeeklyCalendarViewDelegate> delegate;
@property (nonatomic, strong) NSDate *selectedDate;

- (void)redrawToDate: (NSDate *)dt;

-(void)updateWeatherIconByKey: (NSString *)key;

@end
