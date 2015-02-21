//
//  CLWeeklyCalendarView.m
//  Deputy
//
//  Created by Caesar on 30/10/2014.
//  Copyright (c) 2014 Caesar Li. All rights reserved.
//

#import "CLWeeklyCalendarView.h"
#import "DailyCalendarView.h"
#import "DayTitleLabel.h"

#import "NSDate+CL.h"
#import "UIColor+CL.h"
#import "NSDictionary+CL.h"
#import "UIImage+CL.h"

#define WEEKLY_VIEW_COUNT 7
#define DAY_TITLE_VIEW_HEIGHT 20.f
#define DAY_TITLE_FONT_SIZE 11.f
#define DATE_TITLE_MARGIN_TOP 22.f

#define DATE_VIEW_MARGIN 3.f
#define DATE_VIEW_HEIGHT 28.f


#define DATE_LABEL_MARGIN_LEFT 9.f
#define DATE_LABEL_INFO_WIDTH 160.f
#define DATE_LABEL_INFO_HEIGHT 40.f

#define WEATHER_ICON_WIDTH 20
#define WEATHER_ICON_HEIGHT 20
#define WEATHER_ICON_LEFT 90
#define WEATHER_ICON_MARGIN_TOP 9

//Attribute Keys
NSString *const CLCalendarWeekStartDay = @"CLCalendarWeekStartDay";
NSString *const CLCalendarDayTitleTextColor = @"CLCalendarDayTitleTextColor";
NSString *const CLCalendarSelectedDatePrintFormat = @"CLCalendarSelectedDatePrintFormat";
NSString *const CLCalendarSelectedDatePrintColor = @"CLCalendarSelectedDatePrintColor";
NSString *const CLCalendarSelectedDatePrintFontSize = @"CLCalendarSelectedDatePrintFontSize";
NSString *const CLCalendarBackgroundImageColor = @"CLCalendarBackgroundImageColor";

//Default Values
static NSInteger const CLCalendarWeekStartDayDefault = 1;
static NSInteger const CLCalendarDayTitleTextColorDefault = 0xC2E8FF;
static NSString* const CLCalendarSelectedDatePrintFormatDefault = @"EEE, d MMM yyyy";
static float const CLCalendarSelectedDatePrintFontSizeDefault = 13.f;


@interface CLWeeklyCalendarView()<DailyCalendarViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *dailySubViewContainer;
@property (nonatomic, strong) UIView *dayTitleSubViewContainer;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *dailyInfoSubViewContainer;
@property (nonatomic, strong) UIImageView *weatherIcon;
@property (nonatomic, strong) UILabel *dateInfoLabel;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDictionary *arrDailyWeather;



@property (nonatomic, strong) NSNumber *weekStartConfig;
@property (nonatomic, strong) UIColor *dayTitleTextColor;
@property (nonatomic, strong) NSString *selectedDatePrintFormat;
@property (nonatomic, strong) UIColor *selectedDatePrintColor;
@property (nonatomic) float selectedDatePrintFontSize;
@property (nonatomic, strong) UIColor *backgroundImageColor;

@end

@implementation CLWeeklyCalendarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
      [self setup];
    }
    return self;
}

- (void)setup
{
    // Initialization code
    [self addSubview:self.backgroundImageView];
    self.arrDailyWeather = @{};
}

-(void)setDelegate:(id<CLWeeklyCalendarViewDelegate>)delegate
{
    _delegate = delegate;
    [self applyCustomDefaults];
}

-(void)applyCustomDefaults
{
    NSDictionary *attributes;
    
    if ([self.delegate respondsToSelector:@selector(CLCalendarBehaviorAttributes)]) {
        attributes = [self.delegate CLCalendarBehaviorAttributes];
    }
    
    self.weekStartConfig = attributes[CLCalendarWeekStartDay] ? attributes[CLCalendarWeekStartDay] : [NSNumber numberWithInt:CLCalendarWeekStartDayDefault];
    
    self.dayTitleTextColor = attributes[CLCalendarDayTitleTextColor]? attributes[CLCalendarDayTitleTextColor]:[UIColor colorWithHex:CLCalendarDayTitleTextColorDefault];
    
    self.selectedDatePrintFormat = attributes[CLCalendarSelectedDatePrintFormat]? attributes[CLCalendarSelectedDatePrintFormat] : CLCalendarSelectedDatePrintFormatDefault;
    
    self.selectedDatePrintColor = attributes[CLCalendarSelectedDatePrintColor]? attributes[CLCalendarSelectedDatePrintColor] : [UIColor whiteColor];
    
    self.selectedDatePrintFontSize = attributes[CLCalendarSelectedDatePrintFontSize]? [attributes[CLCalendarSelectedDatePrintFontSize] floatValue] : CLCalendarSelectedDatePrintFontSizeDefault;
    
    NSLog(@"%@  %f", attributes[CLCalendarBackgroundImageColor],  self.selectedDatePrintFontSize);
    self.backgroundImageColor = attributes[CLCalendarBackgroundImageColor];
    
    [self setNeedsDisplay];
}
-(UIView *)dailyInfoSubViewContainer
{
    if(!_dailyInfoSubViewContainer){
        _dailyInfoSubViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, DATE_TITLE_MARGIN_TOP+DAY_TITLE_VIEW_HEIGHT + DATE_VIEW_HEIGHT + DATE_VIEW_MARGIN * 2, self.bounds.size.width, DATE_LABEL_INFO_HEIGHT)];
        _dailyInfoSubViewContainer.userInteractionEnabled = YES;
        [_dailyInfoSubViewContainer addSubview:self.weatherIcon];
        [_dailyInfoSubViewContainer addSubview:self.dateInfoLabel];
        
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dailyInfoViewDidClick:)];
        [_dailyInfoSubViewContainer addGestureRecognizer:singleFingerTap];
    }
    return _dailyInfoSubViewContainer;
}
-(UIImageView *)weatherIcon
{
    if(!_weatherIcon){
        _weatherIcon = [[UIImageView alloc] initWithFrame:CGRectMake(WEATHER_ICON_LEFT, WEATHER_ICON_MARGIN_TOP, WEATHER_ICON_WIDTH, WEATHER_ICON_HEIGHT)];
    }
    return _weatherIcon;
}
-(UILabel *)dateInfoLabel
{
    if(!_dateInfoLabel){
        _dateInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(WEATHER_ICON_LEFT+WEATHER_ICON_WIDTH+DATE_LABEL_MARGIN_LEFT, 0, DATE_LABEL_INFO_WIDTH, DATE_LABEL_INFO_HEIGHT)];
        _dateInfoLabel.textAlignment = NSTextAlignmentCenter;
        _dateInfoLabel.userInteractionEnabled = YES;
    }
    _dateInfoLabel.font = [UIFont systemFontOfSize: self.selectedDatePrintFontSize];
    _dateInfoLabel.textColor = self.selectedDatePrintColor;
    return _dateInfoLabel;
}
-(UIView *)dayTitleSubViewContainer
{
    if(!_dayTitleSubViewContainer){
        _dayTitleSubViewContainer = [[UIImageView alloc] initWithFrame:CGRectMake(0, DATE_TITLE_MARGIN_TOP, self.bounds.size.width, DAY_TITLE_VIEW_HEIGHT)];
        _dayTitleSubViewContainer.backgroundColor = [UIColor clearColor];
        _dayTitleSubViewContainer.userInteractionEnabled = YES;
        
    }
    return _dayTitleSubViewContainer;
    
}
-(UIView *)dailySubViewContainer
{
    if(!_dailySubViewContainer){
        _dailySubViewContainer = [[UIImageView alloc] initWithFrame:CGRectMake(0, DATE_TITLE_MARGIN_TOP+DAY_TITLE_VIEW_HEIGHT+DATE_VIEW_MARGIN, self.bounds.size.width, DATE_VIEW_HEIGHT)];
        _dailySubViewContainer.backgroundColor = [UIColor clearColor];
        _dailySubViewContainer.userInteractionEnabled = YES;
        
    }
    return _dailySubViewContainer;
}
-(UIImageView *)backgroundImageView
{
    if(!_backgroundImageView){
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        
        _backgroundImageView.userInteractionEnabled = YES;
        [_backgroundImageView addSubview:self.dayTitleSubViewContainer];
        [_backgroundImageView addSubview:self.dailySubViewContainer];
        [_backgroundImageView addSubview:self.dailyInfoSubViewContainer];
        
        
        //Apply swipe gesture
        UISwipeGestureRecognizer *recognizerRight;
        recognizerRight.delegate=self;
        
        recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
        [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [_backgroundImageView addGestureRecognizer:recognizerRight];
        
        
        UISwipeGestureRecognizer *recognizerLeft;
        recognizerLeft.delegate=self;
        recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
        [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [_backgroundImageView addGestureRecognizer:recognizerLeft];
    }
    _backgroundImageView.backgroundColor = self.backgroundImageColor? self.backgroundImageColor : [UIColor colorWithPatternImage:[UIImage calendarBackgroundImage:self.bounds.size.height]];;
    return _backgroundImageView;
}
-(void)initDailyViews
{
    CGFloat dailyWidth = self.bounds.size.width/WEEKLY_VIEW_COUNT;
    NSDate *today = [NSDate new];
    NSDate *dtWeekStart = [today getWeekStartDate:self.weekStartConfig.integerValue];
    self.startDate = dtWeekStart;
    for (UIView *v in [self.dailySubViewContainer subviews]){
        [v removeFromSuperview];
    }
    for (UIView *v in [self.dayTitleSubViewContainer subviews]){
        [v removeFromSuperview];
    }
    
    for(int i = 0; i < WEEKLY_VIEW_COUNT; i++){
        NSDate *dt = [dtWeekStart addDays:i];
        
        [self dayTitleViewForDate: dt inFrame: CGRectMake(dailyWidth*i, 0, dailyWidth, DAY_TITLE_VIEW_HEIGHT)];
        
        
        [self dailyViewForDate:dt inFrame: CGRectMake(dailyWidth*i, 0, dailyWidth, DATE_VIEW_HEIGHT) ];
        
        self.endDate = dt;
    }
    
    [self dailyCalendarViewDidSelect:[NSDate new]];
}

-(UILabel *)dayTitleViewForDate: (NSDate *)date inFrame: (CGRect)frame
{
    DayTitleLabel *dayTitleLabel = [[DayTitleLabel alloc] initWithFrame:frame];
    dayTitleLabel.backgroundColor = [UIColor clearColor];
    dayTitleLabel.textColor = self.dayTitleTextColor;
    dayTitleLabel.textAlignment = NSTextAlignmentCenter;
    dayTitleLabel.font = [UIFont systemFontOfSize:DAY_TITLE_FONT_SIZE];
    
    dayTitleLabel.text = [[date getDayOfWeekShortString] uppercaseString];
    dayTitleLabel.date = date;
    dayTitleLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dayTitleViewDidClick:)];
    [dayTitleLabel addGestureRecognizer:singleFingerTap];
    
    [self.dayTitleSubViewContainer addSubview:dayTitleLabel];
    return dayTitleLabel;
}

-(DailyCalendarView *)dailyViewForDate: (NSDate *)date inFrame: (CGRect)frame
{
    DailyCalendarView *view = [[DailyCalendarView alloc] initWithFrame:frame];
    view.date = date;
    view.backgroundColor = [UIColor clearColor];
    view.delegate = self;
    [self.dailySubViewContainer addSubview:view];
    return view;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [self initDailyViews];
    
}

-(void)markDateSelected:(NSDate *)date
{
    for (DailyCalendarView *v in [self.dailySubViewContainer subviews]){
        [v markSelected:([v.date isSameDateWith:date])];
    }
    self.selectedDate = date;
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:self.selectedDatePrintFormat];
    NSString *strDate = [dayFormatter stringFromDate:date];
    if([date isDateToday]){
        strDate = [NSString stringWithFormat:@"Today, %@", strDate ];
    }
    
    
    [self adjustDailyInfoLabelAndWeatherIcon : NO];
    
    
    self.dateInfoLabel.text = strDate;
}
-(void)dailyInfoViewDidClick: (UIGestureRecognizer *)tap
{
    //Click to jump back to today
    [self redrawToDate:[NSDate new] ];
}
-(void)dayTitleViewDidClick: (UIGestureRecognizer *)tap
{
    [self redrawToDate:((DayTitleLabel *)tap.view).date];
}
-(void)redrawToDate:(NSDate *)dt
{
    if(![dt isWithinDate:self.startDate toDate:self.endDate]){
        BOOL swipeRight = ([dt compare:self.startDate] == NSOrderedAscending);
        [self delegateSwipeAnimation:swipeRight blnToday:[dt isDateToday] selectedDate:dt];
    }
    
    [self dailyCalendarViewDidSelect:dt];
}
-(void)redrawCalenderData
{
    [self redrawToDate:self.selectedDate];
    
}
-(void)adjustDailyInfoLabelAndWeatherIcon: (BOOL)blnShowWeatherIcon
{
    self.dateInfoLabel.textAlignment = (blnShowWeatherIcon)?NSTextAlignmentLeft:NSTextAlignmentCenter;
    if(blnShowWeatherIcon){
        if([self.selectedDate isDateToday]){
            self.weatherIcon.frame = CGRectMake(WEATHER_ICON_LEFT-20, WEATHER_ICON_MARGIN_TOP, WEATHER_ICON_WIDTH, WEATHER_ICON_HEIGHT);
            self.dateInfoLabel.frame = CGRectMake(WEATHER_ICON_LEFT+WEATHER_ICON_WIDTH+DATE_LABEL_MARGIN_LEFT-20, 0, DATE_LABEL_INFO_WIDTH, DATE_LABEL_INFO_HEIGHT);
        }else{
            self.weatherIcon.frame = CGRectMake(WEATHER_ICON_LEFT, WEATHER_ICON_MARGIN_TOP, WEATHER_ICON_WIDTH, WEATHER_ICON_HEIGHT);
            self.dateInfoLabel.frame = CGRectMake(WEATHER_ICON_LEFT+WEATHER_ICON_WIDTH+DATE_LABEL_MARGIN_LEFT, 0, DATE_LABEL_INFO_WIDTH, DATE_LABEL_INFO_HEIGHT);
        }
    }else{
        self.dateInfoLabel.frame = CGRectMake( (self.bounds.size.width - DATE_LABEL_INFO_WIDTH)/2, 0, DATE_LABEL_INFO_WIDTH, DATE_LABEL_INFO_HEIGHT);
    }
    
    self.weatherIcon.hidden = !blnShowWeatherIcon;
}

#pragma swipe
-(void)swipeLeft: (UISwipeGestureRecognizer *)swipe
{
    [self delegateSwipeAnimation: NO blnToday:NO selectedDate:nil];
}
-(void)swipeRight: (UISwipeGestureRecognizer *)swipe
{
    [self delegateSwipeAnimation: YES blnToday:NO selectedDate:nil];
}
-(void)delegateSwipeAnimation: (BOOL)blnSwipeRight blnToday: (BOOL)blnToday selectedDate:(NSDate *)selectedDate
{
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:(blnSwipeRight)?kCATransitionFromLeft:kCATransitionFromRight];
    [animation setDuration:0.50];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.dailySubViewContainer.layer addAnimation:animation forKey:kCATransition];
    
    NSMutableDictionary *data = @{@"blnSwipeRight": [NSNumber numberWithBool:blnSwipeRight], @"blnToday":[NSNumber numberWithBool:blnToday]}.mutableCopy;
    
    if(selectedDate){
        [data setObject:selectedDate forKey:@"selectedDate"];
    }
    
    [self performSelector:@selector(renderSwipeDates:) withObject:data afterDelay:0.05f];
}

-(void)renderSwipeDates: (NSDictionary*)param
{
    int step = ([[param objectForKey:@"blnSwipeRight"] boolValue])? -1 : 1;
    BOOL blnToday = [[param objectForKey:@"blnToday"] boolValue];
    NSDate *selectedDate = [param objectForKeyWithNil:@"selectedDate"];
    CGFloat dailyWidth = self.bounds.size.width/WEEKLY_VIEW_COUNT;
    
    
    NSDate *dtStart;
    if(blnToday){
        dtStart = [[NSDate new] getWeekStartDate:self.weekStartConfig.integerValue];
    }else{
        dtStart = (selectedDate)? [selectedDate getWeekStartDate:self.weekStartConfig.integerValue]:[self.startDate addDays:step*7];
    }
    
    self.startDate = dtStart;
    for (UIView *v in [self.dailySubViewContainer subviews]){
        [v removeFromSuperview];
    }
    
    for(int i = 0; i < WEEKLY_VIEW_COUNT; i++){
        NSDate *dt = [dtStart addDays:i];
        
        DailyCalendarView* view = [self dailyViewForDate:dt inFrame: CGRectMake(dailyWidth*i, 0, dailyWidth, DATE_VIEW_HEIGHT) ];
        DayTitleLabel *titleLabel = [[self.dayTitleSubViewContainer subviews] objectAtIndex:i];
        titleLabel.date = dt;
        
        [view markSelected:([view.date isSameDateWith:self.selectedDate])];
        self.endDate = dt;
    }
}

-(void)updateWeatherIconByKey:(NSString *)key
{
    if(!key){
        [self adjustDailyInfoLabelAndWeatherIcon:NO];
        return;
    }
    
    self.weatherIcon.image = [UIImage imageNamed:key];
    [self adjustDailyInfoLabelAndWeatherIcon:YES];
}

#pragma DeputyDailyCalendarViewDelegate
-(void)dailyCalendarViewDidSelect:(NSDate *)date
{
    [self markDateSelected:date];
    
    [self.delegate dailyCalendarViewDidSelect:date];
}

@end
