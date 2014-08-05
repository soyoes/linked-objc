//
//  Lang.h
//  LiberObjcExample
//
//  Created by Yu Song on 8/3/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#ifndef __LiberObjcExample__Lang__
#define __LiberObjcExample__Lang__

#include <vector>
#include <regex>
#define radians(degrees) (degrees * M_PI/180)

struct RGBA{
    float r;
    float g;
    float b;
    float a;
};

#define rgba_default (RGBA){0,0,0,0}

//string
NSString * str(const char * cs);
char * cstr(NSString * cs);
bool strstarts(const char* s1, const char* s2);
bool strends(const char* s1, const char* s2);
bool strhas(const char* s1, const char* s2);
char * f2str(float f);
char * strs(int num, const char* s ,...);
char * dec2hex(int dec, int bits);
std::vector<std::string> splitx(const std::string str, const std::regex regex);

//colors
UIColor * str2color(const char * s);
char * colorstr(int r, int g, int b, int a);
char * colorfstr(float r, float g, float b, float a);
RGBA& rgbaf(const char* colorStr); //return rgba values of 0~1
__attribute__((overloadable)) RGBA& rgba(const char* colorStr); //return rgba values of 0~255
__attribute__((overloadable)) RGBA& rgba(float r, float g, float b, float a);
UIColor* rgba_color(RGBA c);
bool rgba_empty(RGBA o);
bool rgba_equals(RGBA o1, RGBA o2);
const char* rgba2hex(RGBA o);

//time
long long milliseconds();
typedef void(^TimeoutHandler)(NSDictionary*);
void $setTimeout(float millisec, TimeoutHandler block, NSDictionary* data);
typedef BOOL(^TimeIntervalHandler)(NSDictionary*,int); //RETURN false to break
void $setInterval(float millisec, TimeIntervalHandler block, NSDictionary*dic);

//Data
extern NSMutableDictionary * __datas;
void $setData(NSString *keyPath, id value);
id $getData(NSString *keyPath);
NSString* $getStr(NSString *keyPath);
int $getInt(NSString *keyPath);
long $getLong(NSString *keyPath);
float $getFloat(NSString *keyPath);
NSArray* $getArr(NSString *keyPath);
NSDictionary* $getHash(NSString *keyPath);
void $removeData(NSString * key);
void $clearData();
void $saveData();
void $loadData();

//memory
void memuse(const char* msg);


#endif /* defined(__LiberObjcExample__Lang__) */
