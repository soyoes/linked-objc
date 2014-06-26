//
//  View.h
//  liberobjc
//
//  Created by soyoes on 6/14/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

#import "Styles.h"
#import "HTTPRequest.h"
#include <initializer_list>

#define radians(degrees) (degrees * M_PI/180)
#define _events @[@"tap", @"pinch", @"rotation", @"swipe", @"pan", @"longpress"]
#define _rootController [UIApplication sharedApplication].keyWindow.rootViewController 

#ifndef VIEW_H
#define VIEW_H
@class Mask;

typedef void(^GestureHandler)(GR*, Dic*);

typedef struct{
    char cmd;
    float coords[6];
}SVGPathCmd;


#pragma mark - SVG

class SVG{
public :
    static CGPathRef path(const char* pathcmd);
};


#pragma mark - $

class ${
public:
    UIView  * view;
    Mask    * mask;
    NSString * ID;
    CALayer * contentLayer;
    CAShapeLayer * shapeLayer;
    CATextLayer *textLayer;
    NSString * text;
    UIDynamicAnimator * animator;
    NSMutableArray * behaviors;
    NSMutableArray * dummys;
    id src;
    bool scrollable;
    
    $* parent;
    NSMutableArray * nodes;
    
    __attribute__((overloadable)) $();
    __attribute__((overloadable)) $(id src); //for image only
    __attribute__((overloadable)) $(bool scoll); //for scroll only
    __attribute__((overloadable)) $(const char* svgPath); //for svgpath only
    
    // Constructor
    ~$();
    
    $* initView(Styles s);
    
    __attribute__((overloadable))
    $& setStyle(Styles s);
    __attribute__((overloadable))
    $& setStyle(Styles s, std::initializer_list<Styles *>ext);
    
    $& bind(NSString* event, GestureHandler handler, NSDictionary * opts);
    $& unbind(NSString* event);
    $& dragable(GestureHandler onDrag, GestureHandler onEnd); //shortcut of this->bind(@"pan",...)
    
    $& addGravity(Dic *opt);
    $& addPush(Dic *opt);
    $& addSnap(Dic *opt);
    $& addCollision(Dic *opt);
    $& startMove();
    //$& addBounds(Dic *opt);
    //TODO $& addAttachment();
    //TODO $& addCollision();
    //TODO $&
    //TODO remove ...
    
    __attribute__((overloadable)) $& operator>>($&p);   //insert into super
    __attribute__((overloadable)) $& operator>>(UIView *p); //insert into super
    __attribute__((overloadable)) $& operator<<($&p); // append child
    $* operator[](int idx);//get child
    
    CGRect rect();
    
    id get(NSString*key);
    void set(NSString*key, id value);
    void del(NSString*key);
    
    void drawShadow(NSString*shadow);
    void drawOutline(NSString*outline);
    void drawGradient(NSString *value);
    
    void drawBorder(NSString *border);
    

    //H V S T are unsupported
    void drawSvgPath (const char* svgpathcmd);
    
    
    $& setImage(id src);
    UIImage * getImage();
    
    $& setText(NSString * _text);
    $& setDefaultText(NSString * _text);
    void setTextAlign(NSString* align);
    void setFont(char* font);
    __attribute__((overloadable)) void setColor(id color);
    __attribute__((overloadable)) void setColor(char* color);
    void setFontSize(float s);
    void switchEditingMode();
    void setEditable(BOOL editable);
    
    void setContentSize(float x, float y);
    
    
    static NSMutableDictionary * s_views;
    static NSString * s_controllerName;
    static int s_views_idx;
    
    static $* getView(NSString * ID, NSString *ctrlerName);
    static void clearAll(NSString * controllerName);
    static void setControllerName(NSString *controllerName);
    
    void remove();
    
    //operators
private:
    Styles styles;
    const char* svgPath;
    static void registerView($* vp);
    
    bool released;
    
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

typedef void(^RemoteContentsHandler)(id,Dic*);
typedef void(^RemoteContentsLoader)($&, RemoteContentsHandler);

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

typedef NSString*(^LabelContentHandler)(id);
/**
 label with remote text 
 @param handler: extract text(NSString*) from response data.
 */
__attribute__((overloadable)) $& glabel(NSString*url,LabelContentHandler handler,Styles s);
__attribute__((overloadable)) $& glabel(NSString*url,LabelContentHandler handler,Styles *sp);
__attribute__((overloadable)) $& glabel(NSString*url,LabelContentHandler handler,Styles s, Styles *sp);

__attribute__((overloadable)) $& svgp(NSString* cmds, Styles s);
__attribute__((overloadable)) $& svgp(NSString* cmds, Styles* sp);
__attribute__((overloadable)) $& svgp(NSString* cmds, Styles s, Styles* sp);
__attribute__((overloadable)) $& svgp(NSString* cmds, std::initializer_list<Styles *>ext);
__attribute__((overloadable)) $& svgp(NSString* cmds, Styles s, std::initializer_list<Styles *>ext);



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

void memuse(const char* msg);

bool strstarts(char* s1, const char* s2);
bool strends(char* s1, const char* s2);
bool strhas(char* s1, const char* s2);

char * f2str(float f);
char * strs(int num, char* s ,...);

Styles str2style(char * s);
__attribute__((overloadable)) Styles style(Styles *custom, Styles *ext);
__attribute__((overloadable)) Styles style(Styles *custom, std::initializer_list<Styles *>exts);



#pragma mark - OpenGL


#endif