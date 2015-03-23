//
//  DailyCalendarView.h
//  Deputy
//
//  Created by Caesar on 30/10/2014.
//  Copyright (c) 2014 Caesar Li. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DailyCalendarViewDelegate <NSObject>
-(void)dailyCalendarViewDidSelect: (NSDate *)date;


@end
@interface DailyCalendarView : UIView
@property (nonatomic, weak) id<DailyCalendarViewDelegate> delegate;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) BOOL blnSelected;

@property (nonatomic, strong) UIColor *pastDayNumberTextColor;
@property (nonatomic, strong) UIColor *futureDayNumberTextColor;
@property (nonatomic, strong) UIColor *currentDayNumberTextColor;
@property (nonatomic, strong) UIColor *selectedDayNumberTextColor;
@property (nonatomic, strong) UIColor *selectedCurrentDayNumberTextColor;
@property (nonatomic, strong) UIColor *currentDayNumberBackgroundColor;
@property (nonatomic, strong) UIColor *selectedDayNumberBackgroundColor;
@property (nonatomic, strong) UIColor *selectedCurrentDayNumberBackgroundColor;

-(void)markSelected:(BOOL)blnSelected;
@end
