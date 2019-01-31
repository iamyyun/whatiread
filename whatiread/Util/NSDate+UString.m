//  NSDate+UString
//  liivbank-ios
//
//  Created by Najak2007 on 2017. 7. 09..
//  Copyright © 2017년 ATSolutions. All rights reserved.
//

#import "NSDate+UString.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@implementation NSDate(NSDateExtenstion)

+(NSDate*)getDateFromString:(NSString*)dateString
{
    if(dateString != nil && [dateString length] > 0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"YYYYMMdd"];
        return [formatter dateFromString:dateString];
    
    }
    return nil;
}

+(NSDate*)getDateFromDisplayString:(NSString*)dateString;
{
    if(dateString != nil && [dateString length] > 0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        return [formatter dateFromString:dateString];
        
    }
    return nil;
}

+ (NSString*)getDateFromFullString:(NSString*)dateString
{
    if(dateString != nil && [dateString length] > 0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy/MM/dd/HH/mm/ss"];
        NSDate * fromDate = [formatter dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}

+ (NSString *)getDateFromYYYY_MMString:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 5)
    {
        if([dateString length] > 6)
        {
            dateString = [dateString substringWithRange:NSMakeRange(0, 6)];
        }
        
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMM"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy년 MM월"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}


+ (NSString *)getDateFromYYYY_MM_DDString:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy년 MM월 dd일"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}

+ (NSString *)getDateFromYYYY_MM_DDStringNotSpace:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy년 MM월dd일"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}


+ (NSString *)getDateFromMM_DDString:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"MM월 dd일"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}

+ (NSString *)getDateFromYYYY_MM_DDArrayString:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy/MM/dd"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}


+ (NSString *)getDateFromYyyy_MM_dd_HHMMString:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMddHHmm"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}

+ (NSString *)getDateFromYyyy_MM_dd_HHMMSSString:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}

+ (NSString *)getDateFromYyyyMMddHHMMSSToyyyyMMddString:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy.MM.dd"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}


+ (NSString *)getDateFromYyyyMMddHHMMSSString:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}

+ (NSString *)getDateFromYyyyMMddHHMMSSArray:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy/MM/dd/HH/mm/SS"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}


+ (long long)unixTimestampFromDateString:(NSString *)aDateString {
    if ([self isNull:aDateString] == YES)
        return 0;
    
    NSDateFormatter* formatter  = [[NSDateFormatter alloc] init];
    formatter.locale            = [NSLocale currentLocale];
    formatter.dateFormat        = @"yyyyMMddHHmmSS";
    
    NSDate* date = [formatter dateFromString:aDateString];
    
    return ([date timeIntervalSince1970] * 1000.0);
}


+ (NSString *)dateStringFromUnixTimestamp:(long long)aTimestamp format:(NSString *)aFormat {
    if (aTimestamp == 0)
        return nil;
    
    NSString* sFormat = aFormat;
    
    // format이 null이면 default format을 설정한다.
    if ([self isNull:sFormat] == YES) {
        sFormat = @"yyyyMMddHHmmSS";
    }
    
    
    NSDateFormatter* formatter  = [[NSDateFormatter alloc] init];
    formatter.locale            = [NSLocale currentLocale];
    formatter.dateFormat        = sFormat;
    
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:aTimestamp]];
}


+ (NSDate *)dateFromDateString:(NSString *)aDateString format:(NSString *)aFormat {
    if ([self isNull:aDateString] == YES) {
        return nil;
    }
    
    NSString* sFormat = aFormat;
    
    // format이 null이면 default format을 설정한다.
    if ([self isNull:sFormat] == YES) {
        sFormat = @"yyyyMMddHHmmSS";
    }


    NSDateFormatter* formatter  = [[NSDateFormatter alloc] init];
    formatter.locale            = [NSLocale currentLocale];
    formatter.dateFormat        = sFormat;
    
    return [formatter dateFromString:aDateString];
}


- (NSString *)formattedDateString:(NSString *)aFormat {
    NSString* sFormat = aFormat;
    
    // format이 null이면 default format을 설정한다.
    if ([self isNull:sFormat] == YES) {
        sFormat = @"yyyyMMddHHmmSS";
    }
    
    
    NSDateFormatter* formatter  = [[NSDateFormatter alloc] init];
    formatter.locale            = [NSLocale currentLocale];
    formatter.dateFormat        = sFormat;
    
    return [formatter stringFromDate:self];
}


+ (NSDate *)dateFromYear:(NSInteger)aYear month:(NSInteger)aMonth day:(NSInteger)aDay {
    NSDateComponents* components    = [[NSDateComponents alloc] init];
    components.year                 = aYear;
    components.month                = aMonth;
    components.day                  = aDay;
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}


- (NSInteger)year {
    NSInteger iYear = 0;
    
    [[NSCalendar currentCalendar] getEra:nil year:&iYear month:nil day:nil fromDate:self];

    return iYear;
}


- (NSInteger)month {
    NSInteger iMonth = 0;
    
    [[NSCalendar currentCalendar] getEra:nil year:nil month:&iMonth day:nil fromDate:self];
    
    return iMonth;
}


- (NSInteger)day {
    NSInteger iDay = 0;
    
    [[NSCalendar currentCalendar] getEra:nil year:nil month:nil day:&iDay fromDate:self];
    
    return iDay;
}


- (NSInteger)hour {
    NSInteger iHour = 0;
    
    [[NSCalendar currentCalendar] getHour:&iHour minute:nil second:nil nanosecond:nil fromDate:self];
    
    return iHour;
}


- (NSInteger)minute {
    NSInteger iMinute = 0;
    
    [[NSCalendar currentCalendar] getHour:nil minute:&iMinute second:nil nanosecond:nil fromDate:self];
    
    return iMinute;
}


- (NSInteger)second {
    NSInteger iSecond = 0;
    
    [[NSCalendar currentCalendar] getHour:nil minute:nil second:&iSecond nanosecond:nil fromDate:self];
    
    return iSecond;
}


- (NSInteger)lastDayOfMonth {
    NSCalendar* calendar            = [NSCalendar currentCalendar];
    NSDateComponents* components    = [[NSDateComponents alloc] init];
    NSInteger iYear                 = 0;
    NSInteger iMonth                = 0;
    
    [calendar getEra:nil year:&iYear month:&iMonth day:nil fromDate:self];
    
    // Set year and month
    [components setYear:iYear];
    [components setMonth:iMonth];
    
    NSDate *date = [calendar dateFromComponents:components];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    return range.length;
}


+ (NSDate *) getDateForomYYYYMMDDHHMMSSToYYYYMMDD:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyyMMdd"];
        
        return [fromForm dateFromString:dateString];
    }
    return nil;
}

+ (NSString *)getDateFromYyyy_MM_dd_HHMMSSString24HAMPM:(NSString *)dateString
{
    if([dateString length] > 14)
    {
        dateString = [dateString substringToIndex:14];
    }
    
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy/MM/dd/HH/mm/SS"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        NSArray * dateArray = [[toForm stringFromDate:fromDate] componentsSeparatedByString:@"/"];
        
        NSInteger hourValue = [[dateArray objectAtIndex:3] integerValue];
        
        NSString * _year = [dateArray objectAtIndex:0];
        NSString * _month = [dateArray objectAtIndex:1];
        NSString * _day = [dateArray objectAtIndex:2];
        
        NSString * _mm = [dateArray objectAtIndex:4];
        
        if(hourValue > 12)      // 오후
        {
            return [NSString stringWithFormat:@"%@.%@.%@ %@ %02d:%@", _year, _month, _day, NSLocalizedString(@"오후", @"") ,(int)(hourValue - 12), _mm];
        }
        else if(hourValue == 12)
        {
            return [NSString stringWithFormat:@"%@.%@.%@ %@ 12:%@", _year, _month, _day, NSLocalizedString(@"오후", @"") ,_mm];
        }
        else                    // 오전
        {
            return [NSString stringWithFormat:@"%@.%@.%@ %@ %02lu:%@", _year, _month, _day, NSLocalizedString(@"오전", @"") ,hourValue, _mm];
        }
    }
    return nil;
}


+ (NSString *)getDateFromMM_dd_HHMMSSString24HAMPM:(NSString *)dateString
{
    if([dateString length] > 14)
    {
        dateString = [dateString substringToIndex:14];
    }
    
    NSCalendar * currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents * components = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    
    NSInteger currentYear = [components year];
    NSInteger currentMonth = [components month];
    NSInteger currentdDay = [components day];
    
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy/MM/dd/HH/mm/SS"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        NSArray * dateArray = [[toForm stringFromDate:fromDate] componentsSeparatedByString:@"/"];
        
        NSInteger hourValue = [[dateArray objectAtIndex:3] integerValue];
        
        NSString * _year = [dateArray objectAtIndex:0];
        NSString * _month = [dateArray objectAtIndex:1];
        NSString * _day = [dateArray objectAtIndex:2];
        
        NSString * _mm = [dateArray objectAtIndex:4];
        
        
        
        if(currentYear == [_year integerValue])
        {
            
            if(currentMonth == [_month integerValue] && currentdDay == [_day integerValue])
            {
                if(hourValue > 12)      // 오후
                {
                    return [NSString stringWithFormat:@"오늘 %@ %02d:%@",  NSLocalizedString(@"오후", @"") ,(int)(hourValue - 12), _mm];
                }
                else if(hourValue == 12)
                {
                    return [NSString stringWithFormat:@"오늘 %@ 12:%@",  NSLocalizedString(@"오후", @"") ,_mm];
                }
                else                    // 오전
                {
                    return [NSString stringWithFormat:@"오늘 %@ %02lu:%@", NSLocalizedString(@"오전", @"") ,hourValue, _mm];
                }
            }
            else
            {
                if(hourValue > 12)      // 오후
                {
                    return [NSString stringWithFormat:@"%@월%@일 %@ %02d:%@", _month, _day, NSLocalizedString(@"오후", @"") ,(int)(hourValue - 12), _mm];
                }
                else if(hourValue == 12)
                {
                    return [NSString stringWithFormat:@"%@월%@일 %@ 12:%@", _month, _day, NSLocalizedString(@"오후", @"") ,_mm];
                }
                else                    // 오전
                {
                    return [NSString stringWithFormat:@"%@월%@일 %@ %02lu:%@",_month, _day, NSLocalizedString(@"오전", @"") ,hourValue, _mm];
                }
            }
        }
        else
        {
            if(hourValue > 12)      // 오후
            {
                return [NSString stringWithFormat:@"%@.%@.%@ %@ %02d:%@", _year, _month, _day, NSLocalizedString(@"오후", @"") ,(int)(hourValue - 12), _mm];
            }
            else if(hourValue == 12)
            {
                return [NSString stringWithFormat:@"%@.%@.%@ %@ 12:%@", _year, _month, _day, NSLocalizedString(@"오후", @"") ,_mm];
            }
            else                    // 오전
            {
                return [NSString stringWithFormat:@"%@.%@.%@ %@ %02lu:%@", _year, _month, _day, NSLocalizedString(@"오전", @"") ,hourValue, _mm];
            }
        }
    }
    return nil;
}


+ (NSString *)getDateFromYyyy_MM_ddString:(NSString *)dateString
{
    if(dateString != nil && [dateString length] > 0)
    {
        NSDateFormatter * fromForm = [NSDateFormatter new];
        [fromForm setDateFormat:@"yyyyMMddHHmm"];
        
        NSDateFormatter * toForm = [NSDateFormatter new];
        [toForm setDateFormat:@"yyyy-MM-dd"];
        
        NSDate * fromDate = [fromForm dateFromString:dateString];
        
        return [toForm stringFromDate:fromDate];
    }
    return nil;
}


+ (NSDate*)getDateFromYyyyMMddHHmmString:(NSString*)dateString
{
    if(dateString != nil && [dateString length] > 0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyyMMdd HH:mm"];
        return [formatter dateFromString:dateString];
        
    }
    return nil;
}

+ (NSDate*)getDateFromYyyyMMddHHmmssString:(NSString*)dateString
{
    if(dateString != nil && [dateString length] > 0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        return [formatter dateFromString:dateString];
        
    }
    return nil;
}

-(NSString*)getAgeString
{
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"] ;
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+00"]];
    unsigned long time = (unsigned long)[todayDate timeIntervalSinceDate:self];
    float allDays = (float)(((time/60.0f)/60.0f)/24.0f);
    int years = (float)(allDays)/365.0f;
    int month = (float)(allDays)/30.0f;
    
    if(years > 1)
        return [NSString stringWithFormat:@"%d세", years];
    else
        return [NSString stringWithFormat:@"%d개월", month];
}

-(NSString*)getTypeString:(NSDateFormatterStyle)type
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:type];
    NSString *dateString = [formatter stringFromDate:self];
    
    return dateString;
}

-(NSString*)getyyyymmddString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

- (NSDate *)getyyyymmddDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyyMMdd"];
    return self;
}

- (NSString *)getyyyymmddhhmmssString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

- (NSString *)getyyyymmddhhmmssStringSeparationSpace
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

-(NSString*)getSaveSataKeyString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

- (NSString *)getyyyymmDDString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy년 MM월 dd일"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

- (NSString *)getyyyymmDDArrayString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}


-(NSString*)getyyyymmddDisplayString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

-(NSString*)getDateTimeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

-(NSString*)getDateTimeECServerDataString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss'.'SSS"];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

-(NSString*)getDateHourString
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
//    NSLocale * pLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
//    
//    [dateFormatter setTimeZone:timeZone];
//    [dateFormatter setLocale:pLocale];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:self];
    
    NSArray *array = [dateString componentsSeparatedByString:@" "];
    
    NSString* retString = [array objectAtIndex:1];
    
    return [retString substringToIndex:2];
}

-(NSInteger)getHowManyDayPass:(NSDate *)startDate endDate:(NSDate*)date
{
    NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:startDate toDate:date options:0];
    
    if([dateComp day] < 0){
        return 0;
    }else{
        return [dateComp day] + 1;
    }
}

-(NSInteger)getHowManyWeekPass:(NSDate *)startDate endDate:(NSDate*)date
{
    NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:startDate toDate:date options:0];
    
    return ([dateComp day] / 7) + 1;
}

-(NSString*)getWeek:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    return [array objectAtIndex:3];
}

-(NSString*)getWeekEng:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSLocale *loc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:loc];
    [formatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    return [array objectAtIndex:3];
}

-(NSString*)getDay:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    return [array objectAtIndex:2];
}

-(NSString*)getMonth:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    return [array objectAtIndex:1];
}

- (NSInteger)checkWeekEnd:(NSDate *)date
{
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date] weekday];
}

- (NSMutableArray*)getAllDateDateWithDateAndSettingWeek:(NSDate*)startDate endDate:(NSDate*)endDate settingWeek:(NSInteger)week
{
    @autoreleasepool {        
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:startDate];
        // minDate and maxDate represent your date range
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *days = [[NSDateComponents alloc] init];
        NSInteger dayCount = 0;
        //설정한 주차 이후 정보는 가져 오지 않는다. 
        for(int i = 0 ; i < (week * 7) ; i++){
            [days setDay: ++dayCount];
            NSDate *date = [gregorianCalendar dateByAddingComponents: days toDate: startDate options: 0];
            if ( [date compare: endDate] == NSOrderedDescending ){
                break;
            }else{
                [array addObject:date];
            }
        }
        
        return array;
    }
}

-(NSMutableArray*)getDateForWeek:(NSDate*)dietStartDate week:(NSInteger)week
{
    @autoreleasepool {
        NSMutableArray *array = [NSMutableArray array];
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *days = [[NSDateComponents alloc] init];
        NSInteger dayCount = 0;
        if(week == 1){
            for(int i = 0 ; i < 7 ; i++){
                [days setDay: dayCount++];
                NSDate *date = [gregorianCalendar dateByAddingComponents: days toDate: dietStartDate options: 0];
                [array addObject:date];
            }
        }else{
            for(int i = 0 ; i < (7 * (week -1)) ; i++){
                [days setDay: dayCount++];
            }
            
            for(int i = 0 ; i < 7 ; i++){
                [days setDay: dayCount++];
                NSDate *date = [gregorianCalendar dateByAddingComponents: days toDate: dietStartDate options: 0];
                [array addObject:date];
            }
        }
        
        return array;
    }
}

-(NSMutableArray*)getSevenDate:(NSDate*)endDate
{
    @autoreleasepool
    {
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:endDate];
        // minDate and maxDate represent your date range
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *days = [[NSDateComponents alloc] init];
        NSInteger dayCount = 0;
        //설정한 주차 이후 정보는 가져 오지 않는다.
        for(int i = 0 ; i <  6 ; i++){
            [days setDay: --dayCount];
            NSDate *date = [gregorianCalendar dateByAddingComponents: days toDate: endDate options: 0];
            [array addObject:date];
        }
        
        array = [[[array reverseObjectEnumerator] allObjects] mutableCopy];
        
        return array;
    }
}

- (NSDate*)getSundayDateWithDate:(NSDate*)date
{
    @autoreleasepool {
        NSDate *findDate;
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *days = [[NSDateComponents alloc] init];
        NSInteger dayCount = 0;
        while ( YES ) {
            findDate = [gregorianCalendar dateByAddingComponents: days toDate: date options: 0];
            if([self checkWeekEnd:findDate] == 1){
                break;
            }else{
                [days setDay: --dayCount];
            }
        }
        
        return findDate;
    }
}

-(NSString*)nsdateChangeToNSString:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSDateFormatter * toForm = [NSDateFormatter new];
    [toForm setDateFormat:@"yyyy/MM/dd/HH/mm/ss"];
    
    NSDate * fromDate = [formatter dateFromString:dateString];
    
    return [toForm stringFromDate:fromDate];
}

+(NSString*)NSDateChangeToNSString:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:date];
    
//    NSDateFormatter * toForm = [NSDateFormatter new];
//    [toForm setDateFormat:@"yyyy/MM/dd/HH/mm/ss"];
//
//    NSDate * fromDate = [formatter dateFromString:dateString];
//
//    return [toForm stringFromDate:fromDate];
    return dateString;
}

-(NSDate*)nsstringChangeToNSDate:(NSString*)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateFromDate = [[NSDate alloc] init];
    // voila!
    dateFromDate = [dateFormatter dateFromString:dateString];
    
    if(dateFromDate == nil){
        [dateFormatter setDateFormat:@"yyyy-MM-dd-EEEE"];
        NSDate *dateFromDate = [[NSDate alloc] init];
        // voila!
        dateFromDate = [dateFormatter dateFromString:dateString];
    }
    
    return dateFromDate;
}

-(NSString*)getDashBoardTimeLineString:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    return [NSString stringWithFormat:@"%@.%@.%@(%@)",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2],[[array objectAtIndex:3] substringToIndex:1]];
}

-(NSString*)getScoreBoardString:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    NSString *weekString = [array objectAtIndex:3];
    
    return [NSString stringWithFormat:@"%@.%@.%@(%@)",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2],[weekString substringToIndex:1]];
}

-(NSString*)getScoreBoardDateString:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    return [NSString stringWithFormat:@"%@.%@.%@",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]];
}

-(NSString*)getBashBoardTimeLineMonthString:(NSString*)dateString
{
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    return [NSString stringWithFormat:@"%@월",[array objectAtIndex:1]];
}

-(NSString*)getBashBoardTimeLineCellString:(NSString*)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateFromDate = [[NSDate alloc] init];
    // voila!
    dateFromDate = [dateFormatter dateFromString:dateString];

    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *cuString = [dateFormatter stringFromDate:dateFromDate];
    
    NSArray *array = [cuString componentsSeparatedByString:@"-"];
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-EEEE HH:mm"];
    cuString = [dateFormatter stringFromDate:dateFromDate];
    
    //NSArray *timearray = [cuString componentsSeparatedByString:@" "];
    
    //return [NSString stringWithFormat:@"%@.%@.%@(%@) %@",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2],[array objectAtIndex:3],[timearray objectAtIndex:1]];
    
    return [NSString stringWithFormat:@"%@.%@.%@(%@)",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2],[array objectAtIndex:3]];
}

- (BOOL)isSameDate:(NSDate*)otherDate
{
    NSString *currentString = [self nsdateChangeToNSString:self];
    NSString *otherString = [self nsdateChangeToNSString:otherDate];
    
    
    if([[currentString substringToIndex:10] isEqualToString:[otherString substringToIndex:10]]){
        return YES;
    }
    
    return NO;
}

- (BOOL)isSameDateWidhDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    NSString *currentString = [self nsdateChangeToNSString:startDate];
    NSString *otherString = [self nsdateChangeToNSString:endDate];
    
    
    if([[currentString substringToIndex:10] isEqualToString:[otherString substringToIndex:10]]){
        return YES;
    }
    
    return NO;
}

- (NSString *) setAlarmDateToString:(NSDate *)alarmDate
{
    if(alarmDate == nil)
    {
        alarmDate = [NSDate date];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
    NSLocale * pLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
    
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:pLocale];
    
    [dateFormatter setDateFormat:@"hh'시'mm'분'"];
    
    NSString * strDate = [dateFormatter stringFromDate:alarmDate];
    
    [dateFormatter setDateFormat:@"HH"];
    int hour = [[dateFormatter stringFromDate:alarmDate] intValue];
    
    NSString * timeText;
    
    if(hour < 12)
        timeText = [NSString stringWithFormat:@"%@%@", @"오전",  strDate];
    else
        timeText = [NSString stringWithFormat:@"%@%@", @"오후",  strDate];
    
    return timeText;
}

#pragma mark -
#pragma mark getWeekEndDate
- (NSDate *) getWeekEndDate:(NSDate *)startDate
{
    int daysToAdd = 6;
    
    return [startDate dateByAddingTimeInterval:60*60*24*daysToAdd];
}

- (NSString*) getStringOfWeek:(NSDate*)startDate
{
    int daysToAdd = 6;
    
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60*24*daysToAdd];
    
    NSString *retString;
    
    retString = [NSString stringWithFormat:@"%@ ~ %@",[self getScoreBoardDateString:startDate],[self getScoreBoardDateString:endDate]];
    
    return retString;
}

-(NSString*)getDashBoardMonthString:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    return [NSString stringWithFormat:@"%@.%@",[array objectAtIndex:0],[array objectAtIndex:1]];
}

-(NSString*)getDashBoardYearString:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd-EEEE"];
    NSString *dateString = [formatter stringFromDate:date];
    
    NSArray *array = [dateString componentsSeparatedByString:@"-"];
    
    return [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
}

- (BOOL)isIncludeOfWeekThisDate:(NSDate*)startDate endDate:(NSDate*)thisDate
{
    for(int i = 0 ; i < 7 ; i++){
        if([self isSameDateWidhDate:startDate endDate:thisDate]){
            return YES;
        }
        
        thisDate = [thisDate dateByAddingTimeInterval:60*60*24];
    }
    
    return NO;
}

- (BOOL)isSameMonth:(NSDate*)startDate endDate:(NSDate*)endDate
{
    NSString *currentString = [self nsdateChangeToNSString:startDate];
    NSString *otherString = [self nsdateChangeToNSString:endDate];
    
    NSArray *array = [currentString componentsSeparatedByString:@"-"];
    NSArray *array1 = [otherString componentsSeparatedByString:@"-"];
    
    if([[array objectAtIndex:0] isEqualToString:[array1 objectAtIndex:0]] && [[array objectAtIndex:1] isEqualToString:[array1 objectAtIndex:1]]){
        return YES;
    }
    
    return NO;
}

- (BOOL)isSameYear:(NSDate*)startDate endDate:(NSDate*)endDate
{
    NSString *currentString = [self nsdateChangeToNSString:startDate];
    NSString *otherString = [self nsdateChangeToNSString:endDate];
    
    NSArray *array = [currentString componentsSeparatedByString:@"-"];
    NSArray *array1 = [otherString componentsSeparatedByString:@"-"];
    
    if([[array objectAtIndex:0] isEqualToString:[array1 objectAtIndex:0]]){
        return YES;
    }
    
    return NO;
}

-(NSInteger) dateUntilHour
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour
                                               fromDate:self];
//    
//    NSDate* newDate = [calendar dateFromComponents:components];
//    NSLog(@"self=%@, newDate=%@, hour=%ld", self, newDate, components.hour);
    return components.hour;
}

+(NSDate *) dateWithYearTimezone:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day TimeZone:(NSTimeZone*)timezone
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    if (!timezone)
        [components setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    else
        [components setTimeZone:timezone];
    
    components.year = year;
    components.month = month;
    components.day = day;

    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

-(NSString*)stringDashboardTimeLineTitle
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    
    return [formatter stringFromDate:self];
}

//날짜 구분선을 위한 공통 함수
- (NSString*) getSeperatedDateString {
    
    NSDateFormatter *seperatorDateFormatter = [[NSDateFormatter alloc] init];
    [seperatorDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [seperatorDateFormatter setDateFormat:@"yyyy.M.d EEEE"];
    return [seperatorDateFormatter stringFromDate:self];
}

+ (BOOL)isNull:(id)obj {
    @try {
        if (obj == nil || obj == [NSNull null])
            return YES;
        
        // obj가 NSString이거나 NSString을 상속받은 객체일 경우 empty string을 체크한다.
        if ([obj isKindOfClass:[NSString class]] == YES) {
            if ([(NSString *)obj isEqualToString:@""] == YES)
                return YES;
        }
        
        return NO;
    } @catch(NSException* exception) {
        // Dangling pointer에 의한 오류 처리. Dangling pointer는 그 대상 자체가 해제된 상태인 객체이기 때문에 nil로 체크한다.
        
        return YES;
    }
}

- (BOOL)isNull:(id)obj {
    @try {
        if (obj == nil || obj == [NSNull null])
            return YES;
        
        // obj가 NSString이거나 NSString을 상속받은 객체일 경우 empty string을 체크한다.
        if ([obj isKindOfClass:[NSString class]] == YES) {
            if ([(NSString *)obj isEqualToString:@""] == YES)
                return YES;
        }
        
        return NO;
    } @catch(NSException* exception) {
        // Dangling pointer에 의한 오류 처리. Dangling pointer는 그 대상 자체가 해제된 상태인 객체이기 때문에 nil로 체크한다.
        
        return YES;
    }
}


@end
