/*
 This file is part of Mac Eve Tools.
 
 Mac Eve Tools is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Mac Eve Tools is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Mac Eve Tools.  If not, see <http://www.gnu.org/licenses/>.
 
 Copyright Matt Tyson, 2009.
 */

#import "Helpers.h"
#import "macros.h"
#import <sqlite3.h>
#import <assert.h>

NSString* romanForString(NSString *value)
{
	return romanForInteger([value integerValue]);
}

NSString* romanForInteger(NSInteger value)
{
	switch (value) {
		case 0:
			return @"0";
		case 1:
			return @"I";
		case 2:
			return @"II";
		case 3:
			return @"III";
		case 4:
			return @"IV";
		case 5:
			return @"V";
	}
	return nil;
}

NSInteger attrCodeForString(NSString *str)
{
	if([str isEqualToString:ATTR_INTELLIGENCE_STR]){
		return ATTR_INTELLIGENCE;
	}else if([str isEqualToString: ATTR_MEMORY_STR]){
		return ATTR_MEMORY;
	}else if([str isEqualToString:ATTR_CHARISMA_STR]){
		return ATTR_CHARISMA;
	}else if([str isEqualToString:ATTR_WILLPOWER_STR]){
		return ATTR_WILLPOWER;
	}else if([str isEqualToString:ATTR_PERCEPTION_STR]){
		return ATTR_PERCEPTION;
	}
	assert(0);
	return -1;
}

NSString *strForAttrCode(NSInteger code)
{
	switch(code)
	{
		case ATTR_MEMORY:
			return ATTR_MEMORY_STR_UPPER;
		case ATTR_INTELLIGENCE:
			return ATTR_INTELLIGENCE_STR_UPPER;
		case ATTR_CHARISMA:
			return ATTR_CHARISMA_STR_UPPER;
		case ATTR_WILLPOWER:
			return ATTR_WILLPOWER_STR_UPPER;
		case ATTR_PERCEPTION:
			return ATTR_PERCEPTION_STR_UPPER;
	}
	assert(0);
	return nil;
}

BOOL createDirectory(NSString *path)
{
	BOOL rc = NO;
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if(! [fm fileExistsAtPath:path isDirectory:nil]){
		if(![fm createDirectoryAtPath:path  withIntermediateDirectories:YES attributes:nil error:nil]){
			NSLog(@"Could not create directory %@",path);
		}else{
			NSLog(@"Created directory %@",path);
			rc = YES;
		}
	}
	return rc;
}

static NSInteger sp[] = {0, 250, 1414, 8000, 45255, 256000};

NSInteger skillPointsForLevel(NSInteger skillLevel, NSInteger skillRank)
{
	return (sp[skillLevel] * skillRank) - (sp[skillLevel-1] * skillRank);
}

NSInteger totalSkillPointsForLevel(NSInteger skillLevel, NSInteger skillRank)
{
	return (sp[skillLevel] * skillRank);
}

NSInteger spPerHour(NSInteger primary, NSInteger secondary)
{
	return ((primary / 100.0) + ((secondary / 100.0) / 2.0)) * 60.0;
}

NSInteger minutesTrainingTime(NSInteger skillLevel, NSInteger skillRank, NSInteger primary, NSInteger secondary)
{
	NSInteger skillPoints = skillPointsForLevel(skillLevel, skillRank);
	NSInteger sphr = spPerHour(primary, secondary);
	CGFloat spMin = sphr / 60.0;
	return skillPoints / spMin;
}

NSString* stringTrainingTime(NSInteger trainingTime)
{
	return stringTrainingTime2(trainingTime,TTF_Days | TTF_Hours | TTF_Minutes);
}

NSString* stringTrainingTime2(NSInteger trainingTime , enum TrainingTimeFields ttf)
{
	NSInteger remain, days, hours , min, sec;
	days = trainingTime / SEC_DAY;
	remain = trainingTime - (days * SEC_DAY);
	
	hours = remain / SEC_HOUR;
	remain = remain - (hours * SEC_HOUR);
	
	min = remain / SEC_MINUTE;
	sec = remain - (min * SEC_MINUTE);
	
	NSMutableString *str = [[[NSMutableString alloc]init]autorelease];
	if(days > 0 && (ttf & TTF_Days)){
		[str appendFormat:@"%ldd ",days];
	}
	if(hours > 0 && (ttf & TTF_Hours)){
		[str appendFormat:@"%ldh ",hours];
	}
	if(min > 0 && (ttf & TTF_Minutes)){
		[str appendFormat:@"%ldm ",min];
	}
	if(sec > 0 && (ttf & TTF_Seconds)){
		[str appendFormat:@"%lds",sec];
	}
	return str;
}

CGFloat skillPercentCompleted(NSInteger startingPoints, NSInteger finishingPoints, NSInteger currentPoints)
{
	return ((CGFloat)(currentPoints - startingPoints) / (CGFloat)(finishingPoints - startingPoints));
}

NSString* sqlite3_column_nsstr(void *stmt, int col)
{
	const unsigned char *str = sqlite3_column_text(stmt,col);
	if(str == NULL){
		return [NSString stringWithString:@""];
	}else{
		return [NSString stringWithUTF8String:(const char*)str];
	}
}
