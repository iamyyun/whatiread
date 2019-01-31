//  NSDate+UString
//  liivbank-ios
//
//  Created by Najak2007 on 2017. 7. 09..
//  Copyright © 2017년 ATSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(NSDateExtenstion)
/**
 dateString formate : yyyymmdd
 */
+(NSDate*)getDateFromString:(NSString*)dateString;

/**
 dateString formate : yyyy-mm-dd
 */
+(NSDate*)getDateFromDisplayString:(NSString*)dateString;

/**
 dateString formate : yyyy-MM-dd HH:mm:ss
 */
+ (NSString*)getDateFromFullString:(NSString*)dateString;
+ (NSString *)getDateFromMM_DDString:(NSString *)dateString;
/**
 dateString formate : yyyyMMdd HH:mm
 */
+ (NSDate*)getDateFromYyyyMMddHHmmString:(NSString*)dateString;
+ (NSDate*)getDateFromYyyyMMddHHmmssString:(NSString*)dateString;

/**
 dateString formate : yyyy-MM-dd HH:mm
 */
+ (NSString *)getDateFromYyyy_MM_dd_HHMMString:(NSString *)dateString;
+ (NSDate *) getDateForomYYYYMMDDHHMMSSToYYYYMMDD:(NSString *)dateString;

+ (NSString *)getDateFromYyyy_MM_dd_HHMMSSString:(NSString *)dateString;
+ (NSString *)getDateFromYYYY_MM_DDString:(NSString *)dateString;
+ (NSString *)getDateFromYyyy_MM_dd_HHMMSSString24HAMPM:(NSString *)dateString;
+ (NSString *)getDateFromYYYY_MM_DDArrayString:(NSString *)dateString;
+ (NSString *)getDateFromMM_dd_HHMMSSString24HAMPM:(NSString *)dateString;
+ (NSString *)getDateFromYYYY_MM_DDStringNotSpace:(NSString *)dateString;
+ (NSString *)getDateFromYyyyMMddHHMMSSToyyyyMMddString:(NSString *)dateString;
+ (NSString *)getDateFromYYYY_MMString:(NSString *)dateString;
/**
 dateString formate : yyyy-MM-dd
 */
+ (NSString *)getDateFromYyyy_MM_ddString:(NSString *)dateString;

-(NSString*)getTypeString:(NSDateFormatterStyle)type;
/**
 return formate : yyyyMMdd
 */
-(NSString*)getyyyymmddString;

- (NSString *)getyyyymmDDString;
- (NSString *)getyyyymmDDArrayString;

-(NSString*)getSaveSataKeyString;
/**
 return formate : yyyy-MM-dd
 */
-(NSString*)getyyyymmddDisplayString;
/**
 return formate : yyyy-MM-dd HH:mm:ss
 */
-(NSString*)getDateTimeString;
-(NSString*)getDateTimeECServerDataString;

- (NSDate *) getWeekEndDate:(NSDate *)startDate;
- (NSDate *)getyyyymmddDate;

-(NSInteger)getHowManyDayPass:(NSDate *)startDate endDate:(NSDate*)date;

-(NSInteger)getHowManyWeekPass:(NSDate *)startDate endDate:(NSDate*)date;

-(NSString*)getDashBoardTimeLineString:(NSDate *)date;

-(NSString*)getBashBoardTimeLineCellString:(NSString*)dateString;

-(NSString*)getBashBoardTimeLineMonthString:(NSString*)dateString;

+ (NSString *)getDateFromYyyyMMddHHMMSSArray:(NSString *)dateString;
+ (NSString *)getDateFromYyyyMMddHHMMSSString:(NSString *)dateString;
-(NSString *)getyyyymmddhhmmssStringSeparationSpace;


+ (long long)unixTimestampFromDateString:(NSString *)aDateString;
+ (NSString *)dateStringFromUnixTimestamp:(long long)aTimestamp format:(NSString *)aFormat;
+ (NSDate *)dateFromDateString:(NSString *)aDateString format:(NSString *)aFormat;
- (NSString *)formattedDateString:(NSString *)aFormat;
+ (NSDate *)dateFromYear:(NSInteger)aYear month:(NSInteger)aMonth day:(NSInteger)aDay;
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)hour;
- (NSInteger)minute;
- (NSInteger)second;
- (NSInteger)lastDayOfMonth;


-(NSString*)getWeek:(NSDate *)date;

-(NSString*)getMonth:(NSDate *)date;

-(NSString*)getDay:(NSDate *)date;

-(NSInteger)checkWeekEnd:(NSDate *)date;

-(NSString*)getDateHourString;

-(NSMutableArray*)getAllDateDateWithDateAndSettingWeek:(NSDate*)startDate endDate:(NSDate*)endDate settingWeek:(NSInteger)week;

-(NSMutableArray*)getDateForWeek:(NSDate*)dietStartDate week:(NSInteger)week;

-(NSMutableArray*)getSevenDate:(NSDate*)endDate;

-(NSString*)nsdateChangeToNSString:(NSDate*)date;
+(NSString*)NSDateChangeToNSString:(NSDate*)date;

-(NSDate*)nsstringChangeToNSDate:(NSString*)dateString;

-(NSString*)getScoreBoardString:(NSDate *)date;

-(NSDate*)getSundayDateWithDate:(NSDate*)date;

-(NSString*)getScoreBoardDateString:(NSDate *)date;

- (NSMutableArray *) getRemainingDay:(NSDate *)startDate endDate:(NSDate *)endDate;

- (BOOL)isSameDate:(NSDate*)otherDate;

- (BOOL)isSameDateWidhDate:(NSDate*)startDate endDate:(NSDate*)endDate;

- (NSString *) setAlarmDateToString:(NSDate *)alarmDate;

- (NSString*) getStringOfWeek:(NSDate*)startDate;

-(NSString*)getDashBoardMonthString:(NSDate *)date;

-(NSString*)getDashBoardYearString:(NSDate *)date;
- (NSString *)getyyyymmddhhmmssString;

- (BOOL)isIncludeOfWeekThisDate:(NSDate*)startDate endDate:(NSDate*)thisDate;

- (BOOL)isSameMonth:(NSDate*)startDate endDate:(NSDate*)endDate;

- (BOOL)isSameYear:(NSDate*)startDate endDate:(NSDate*)endDate;

-(NSString*)getWeekEng:(NSDate *)date;

- (NSInteger) dateUntilHour;
+ (NSDate *) dateWithYearTimezone:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day TimeZone:(NSTimeZone*)timezone;

-(NSString*)stringDashboardTimeLineTitle;
//날짜 구분선을 위한 공통 함수
- (NSString*) getSeperatedDateString;

+ (BOOL)isNull:(id)obj;
- (BOOL)isNull:(id)obj;

@end
