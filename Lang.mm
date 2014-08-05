//
//  Lang.cpp
//  LiberObjcExample
//
//  Created by Yu Song on 8/3/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#include "Lang.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#include <stdlib.h>
#include <sstream>

using namespace std;

NSMutableDictionary * __datas=nil;

void memuse(const char* msg) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),TASK_BASIC_INFO,(task_info_t)&info,&size);
    NSLog(@"MEM : %@ %u KB",[NSString stringWithUTF8String:msg],info.resident_size/1024);
}

NSString * str(const char * cs){return cs?
    [NSString stringWithCString:cs encoding:NSASCIIStringEncoding]:nil;
}

char * cstr(NSString * cs){
    return const_cast<char*>([cs cStringUsingEncoding:NSASCIIStringEncoding]);
}

vector<string> splitx(const string str, const regex regex){
    vector<string> result;
    sregex_token_iterator it( str.begin(), str.end(), regex, -1 );
    sregex_token_iterator reg_end;
    for ( ;it != reg_end; ++it) {
        if (!it->str().empty())
            result.emplace_back( it->str() );
    }
    return result;
}

UIColor * str2color(const char * s){
    RGBA r = rgbaf(s);
    return [UIColor colorWithRed:r.r green:r.g blue:r.b alpha:r.a];
}

char* dec2hex(int dec, int bits){
    ostringstream ss;
    ss<< std::hex << dec;
    string st = ss.str();
    while(st.length()<bits)
        st = "0"+st;
    char *cstr = new char[bits+1];
    strcpy(cstr, st.c_str());
    return const_cast<char*>(cstr);
}

char * colorstr(int r, int g, int b, int a){
    char * ar=dec2hex(MIN(r,255),2), *ag=dec2hex(MIN(g,255),2), *ab=dec2hex(MIN(b,255),2), *aa=dec2hex(MIN(a,255),2);
    NSString *s = [NSString stringWithFormat:@"#%@%@%@%@",str(ar),str(ag),str(ab),str(aa)];
    return cstr(s);
}
char * colorfstr(float r, float g, float b, float a){
    return colorstr(r*255, g*255, b*255, a*255);
}

RGBA& rgbaf(const char* s){
    string cs(s);
    if(strstarts(s, "#")){
        int red, green, blue, alpha=255;
        sscanf(cs.substr(1,2).c_str(), "%x", &red);
        sscanf(cs.substr(3,2).c_str(), "%x", &green);
        sscanf(cs.substr(5,2).c_str(), "%x", &blue);
        if(cs.size()==9) sscanf(cs.substr(7,2).c_str(), "%x", &alpha);
        return rgba((float)red/255,(float)green/255,(float)blue/255,(float)alpha/255);
    }else if(strhas(s,",")==true){
        cs = regex_replace(cs, regex("\\s"), "");
        float clr []= {0,0,0,1};
        int start = 0, end = 0, i=0;
        do {
            end = (int)cs.find(',', start);
            string sc =cs.substr(start, end - start);
            clr[i] = ((float)std::stoi(sc))/255;
            start = end + 1;
            i++;
        }while(end != string::npos);
        return rgba(clr[0],clr[1],clr[2],clr[3]);
    }
    return rgba(0,0,0,0);
}
__attribute__((overloadable)) RGBA& rgba(const char* s){
    RGBA res = rgbaf(s);
    return rgba(res.r*255, res.g*255, res.b*255, res.a*255);
}
__attribute__((overloadable)) RGBA& rgba(float r, float g, float b, float a){
    RGBA *c=new RGBA(); c->r=r;c->g=g,c->b=b;c->a=a; return *c;
}
UIColor* rgba_color(RGBA c){
    return [UIColor colorWithRed:c.r green:c.g blue:c.b alpha:c.a];
}
bool rgba_empty(RGBA o){
    return o.r==0&&o.g==0&&o.b==0&&o.a==0;
}
bool rgba_equals(RGBA o1, RGBA o2){
    return o1.r==o2.r&&o1.g==o2.g&&o1.b==o2.b&&o1.a==o2.a;
}
const char* rgba2hex(RGBA o){
    return colorfstr(o.r, o.g, o.b, o.a);
}


/*
 char** split(char *s, const char* delim){
 char * pch;
 char * arr[]={};
 char ss[] = "- This, a sample string.";
 pch = strtok (ss, delim);
 int i = 0;
 while (pch != NULL){
 arr[i++] = pch;
 pch = strtok (NULL, delim);
 }
 return arr;
 }*/

bool strstarts(const char* s1, const char* s2){
    string ss1(s1), ss2(s2);
    return ss2.size() <= ss1.size() && ss1.compare(0, ss2.size(), ss2) == 0;
}

bool strends(const char* s1, const char* s2){
    string ss1(s1), ss2(s2);
    return ss2.size() <= ss1.size() && ss1.compare(ss1.size()-ss2.size(), ss2.size(), ss2) == 0;
}

bool strhas(const char* s1, const char* s2){
    if(!s1 || !s2) return false;
    string ss1(s1), ss2(s2);
    return (ss1.find(ss2) != string::npos);
}

char * f2str(float f){
    ostringstream ss;
    ss << f;
    string st = ss.str();
    char *cstr = new char[st.length() + 1];
    strcpy(cstr, st.c_str());
    return cstr;
    //return const_cast<char *>(ss.str().c_str());
}


char * strs(int num, const char* s ,...){
    va_list ap;
    va_start(ap, s);
    string st(s);
    for(int i = 0; i < num-1; i++) {
        char * ss =va_arg(ap, char*);
        if(ss) st = st + string(ss);
    }
    va_end(ap);
    //char * r= const_cast<char *>(st.c_str());
    char *cstr = new char[st.length() + 1];
    strcpy(cstr, st.c_str());
    return cstr;
}


//milliseconds
long long milliseconds(){
    return (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
}

MDic* __counters;

#pragma mark time
void $setTimeout(float millisec, TimeoutHandler block, NSDictionary*dic){
    dispatch_time_t span = dispatch_time(DISPATCH_TIME_NOW, millisec*0.001f * NSEC_PER_SEC);
    dispatch_after(span, dispatch_get_main_queue(), ^(void){
        block(dic);
    });
}

/**
 @exmample
 $& __block ico = $ico(@"train",{0,30}) >> self.view;
 $setInterval(40, ^BOOL(NSDictionary*d, int i){
 ico.view.center = CGPointMake(i*10, 30);   //move this ico
 return (i>100) ? NO:YES; // exec for 100 times.
 }, @{});
 
 */
void $setInterval(float millisec, TimeIntervalHandler block, NSDictionary*dic){
    if(!__counters) __counters=[[MDic alloc] init];
    id vp =block;
    if(!__counters[vp])
        __counters[vp]=@0;
    
    dispatch_time_t span = dispatch_time(DISPATCH_TIME_NOW, millisec*0.001f * NSEC_PER_SEC);
    dispatch_after(span, dispatch_get_main_queue(), ^(void){
        int counter = [__counters[vp] intValue];
        if(block(dic, counter++)) {
            $setInterval(millisec, block, dic);
            __counters[vp] = @(counter);
        }else {
            [__counters removeObjectForKey:vp];
        }
        
    });
}

#pragma mark data

void $setData(NSString *keyPath, id value){
    //AppDelegate *casya = $app();
    if(__datas==nil) $loadData();
    [__datas setValue:value forKeyPath:keyPath];
}
id $getData(NSString *keyPath){
    //AppDelegate *casya = $app();
    if(__datas==nil) $loadData();
    return [__datas valueForKeyPath:keyPath];
}
NSString* $getStr(NSString *keyPath){
    id v =$getData(keyPath);
    return (NSString*)v;
}
int $getInt(NSString *keyPath){
    id v =$getData(keyPath);
    return v!=nil? [(NSNumber*)v integerValue]:0;
}
long $getLong(NSString *keyPath){
    id v =$getData(keyPath);
    return v!=nil? [(NSNumber*)v longValue]:0;
}
float $getFloat(NSString *keyPath){
    id v =$getData(keyPath);
    return v!=nil? [(NSNumber*)v floatValue]:0;
}
NSArray* $getArr(NSString *keyPath){
    id v =$getData(keyPath);
    return (NSArray*)v;
}
NSDictionary* $getHash(NSString *keyPath){
    id v =$getData(keyPath);
    return (NSDictionary*)v;
}

void $removeData(NSString * key){
    if(__datas==nil)return;
    [__datas removeObjectForKey:key];
}
void $clearData(){
    if(__datas==nil)return;
    [__datas removeAllObjects];
}

void $saveData(){
#ifdef DATA_FILE_NAME
    if(__datas!=nil)
        [__datas writeToFile:[NSString stringWithUTF8String:DATA_FILE_NAME] atomically:YES];
#endif
}

void $loadData(){
#ifdef DATA_FILE_NAME
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString * fpath = [docDir stringByAppendingPathComponent:[NSString stringWithUTF8String:DATA_FILE_NAME]];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fpath]){
        __datas = [[NSMutableDictionary alloc] initWithContentsOfFile:fpath];
    }else{
        __datas = [[NSMutableDictionary alloc] init];
    }
#else
    __datas = [[NSMutableDictionary alloc] init];
#endif
}
