//
//  View.h
//  liberobjc
//
//  Created by soyoes on 6/14/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Styles.h"
//#include <map>
//#include <vector>
//#include <initializer_list>

#define radians(degrees) (degrees * M_PI/180)
#define _events @[@"tap", @"pinch", @"rotation", @"swipe", @"pan", @"longpress"]

#ifndef VIEW_H   
#define VIEW_H

typedef void(^GestureHandler)(UIGestureRecognizer*, NSDictionary*);
/*
@interface View : UIScrollView
@property (nonatomic) CGRect contentRect;
@property  CAShapeLayer *content;
-(id)initWithStyle:(Styles)s;
- (void) set:(NSString*)keyPath value:(id)value;
- (id) get:(NSString*)keyPath;
- (void) del:(NSString*)keyPath;
@end
 */

@class Mask;

#pragma mark - $

class ${
public:
    UIView  * view;
    Mask    * mask;
    CATextLayer *textLayer;
    NSString * text;
    id src;
    bool scrollable;
    
    $* parent;
    std::vector<$*> nodes;
    
    __attribute__((overloadable)) $();
    __attribute__((overloadable)) $(id src); //for image only
    __attribute__((overloadable)) $(bool scoll); //for scroll only
    // Constructor
    ~$();
    
    __attribute__((overloadable)) $& setStyle(Styles s);
    //__attribute__((overloadable)) $* setStyle(Styles s, Styles*ext);
    __attribute__((overloadable)) $& setStyle(Styles s, std::initializer_list<Styles *>ext);
    
    $& bind(NSString* event, GestureHandler handler, NSDictionary * opts);
    $& unbind(NSString* event);
    __attribute__((overloadable)) $& operator>>($&p);
    __attribute__((overloadable)) $& operator>>(UIView *p);
    __attribute__((overloadable)) $& operator<<($&p);
    
    id get(NSString*key);
    void set(NSString*key, id value);
    void del(NSString*key);
    
    void drawShadow(NSString*shadow);
    void drawOutline(NSString*outline);
    void drawGradient(NSString *value);
    void drawBorder(NSString *border);
    
    $& setImage(id src);
    UIImage * getImage();
    
    $& setText(NSString * _text);
    void setTextAlign(NSString* align);
    void setFont(char* font);
    __attribute__((overloadable)) void setColor(id color);
    __attribute__((overloadable)) void setColor(char* color);
    void setFontSize(float s);
    void switchEditingMode();
    void setEditable(BOOL editable);
    
    void setContentSize(float x, float y);
    
    //operators
private:
    Styles styles;
};

typedef $ View;

#pragma mark - Mask

@interface Mask : UIView<UITextFieldDelegate,UITextViewDelegate>
@property (nonatomic,retain) NSMutableDictionary * gestures;
@property (nonatomic,retain) NSMutableDictionary * data;
@property (nonatomic,retain) UIView *textField;
@property $* owner;
-(id) initWithOwner:($*)owner;
-(void) gestureHandler:(UIGestureRecognizer*)ges;
-(void) switchEditingMode;
@end

#pragma mark - CPP wrapper

__attribute__((overloadable)) $& box();
__attribute__((overloadable)) $& box(Styles s);
__attribute__((overloadable)) $& box(Styles* sp);
__attribute__((overloadable)) $& box(Styles s, Styles* sp);
__attribute__((overloadable)) $& box(std::initializer_list<Styles *>ext);
__attribute__((overloadable)) $& box(Styles s, std::initializer_list<Styles *>ext);
__attribute__((overloadable)) $& sbox();
__attribute__((overloadable)) $& sbox(Styles s);
__attribute__((overloadable)) $& sbox(Styles* sp);
__attribute__((overloadable)) $& sbox(Styles s, Styles* sp);
__attribute__((overloadable)) $& sbox(std::initializer_list<Styles *>ext);
__attribute__((overloadable)) $& sbox(Styles s, std::initializer_list<Styles *>ext);
__attribute__((overloadable)) $& label(NSString*txt);
__attribute__((overloadable)) $& label(NSString*txt, Styles s);
__attribute__((overloadable)) $& label(NSString*txt, Styles* sp);
__attribute__((overloadable)) $& label(NSString*txt, Styles s, Styles* sp);
__attribute__((overloadable)) $& label(NSString*txt, std::initializer_list<Styles *>ext);
__attribute__((overloadable)) $& label(NSString*txt, Styles s, std::initializer_list<Styles *>ext);
__attribute__((overloadable)) $& img(id src);
__attribute__((overloadable)) $& img(id src, Styles s);
__attribute__((overloadable)) $& img(id src, Styles* sp);
__attribute__((overloadable)) $& img(id src, Styles s, Styles* sp);
__attribute__((overloadable)) $& img(id src, std::initializer_list<Styles *>ext);
__attribute__((overloadable)) $& img(id src, Styles s, std::initializer_list<Styles *>ext);

typedef $&(^ListHandler)(id, int);
__attribute__((overloadable)) $& list(NSArray*data, ListHandler handler, Styles listStyle);
__attribute__((overloadable)) $& list(NSArray*data, ListHandler handler, Styles listStyle, std::initializer_list<Styles *>ext);
typedef $&(^GridHandler)(id, int, int);
__attribute__((overloadable)) $& grids(NSArray*data, int cols, GridHandler handler, Styles gridsStyle);
__attribute__((overloadable)) $& grids(NSArray*data, int cols, GridHandler handler, Styles gridsStyle, std::initializer_list<Styles *>ext);

#pragma mark - CPP

NSString * str(char * cs);
char * cstr(NSString * cs);

UIColor * str2color(char * s);

//char** split(char *s,const char* delim);

bool strstarts(char* s1, const char* s2);
bool strends(char* s1, const char* s2);
bool strhas(char* s1, const char* s2);

char * f2str(float f);
char * strs(int num, char* s ,...);

Styles str2style(char * s);
Styles style(Styles *custom, Styles *ext);

#endif