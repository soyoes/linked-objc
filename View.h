//
//  View.h
//  liberobjc
//
//  Created by soyoes on 6/14/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <OpenGLES/EAGL.h>

#import "Styles.h"
#import "HTTPRequest.h"
#include <initializer_list>

#define radians(degrees) (degrees * M_PI/180)
#define _events @[@"tap", @"pinch", @"rotation", @"swipe", @"pan", @"longpress"]
#define _rootController [UIApplication sharedApplication].keyWindow.rootViewController 

#ifndef VIEW_H
#define VIEW_H
@class View;
@class Layer;

class $;

extern NSMutableDictionary * __datas;
extern NSMutableDictionary * __counters;

typedef void(^GestureHandler)(GR*, $&, Dic*);
typedef void(^AnimateStepHandler)($&, float);
typedef void(^AnimateFinishedHandler)($&);
typedef void(^TextEditOnInitHandler)($&);


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
    View       * view;             //a uiview extension which can save data and response to UIGesture.
    //Mask        * mask;           //a mask to respond
    NSString    * ID;               //unique id of this View.
    NSString    * NS;               //namespace.
    
    Layer     * layer;            //base layer
    CATransformLayer * transLayer;  //container layer to perform 3d transfrom
    
    CALayer      * contentLayer;    //visible layer, contains bg color and other styles.
    
    CALayer      * imageLayer;      //1st sublayer of contentLayer, contains image data
    CAShapeLayer * shapeLayer;      //2nd sublayer of contentLayer, shape mask
    CATextLayer  * textLayer;       //3rd sublayer of contentLayer, text
    
    NSMutableArray  *subLayers;

    UIDynamicAnimator   * animator;
    NSMutableArray      * behaviors;
    NSMutableArray      * dummys;

    id          src;
    NSString   *text;
    bool        scrollable;
    
    $*              parent;
    NSMutableArray *nodes;
    
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
    
    __attribute__((overloadable)) $& animate(float ms, Styles s);
    __attribute__((overloadable)) $& animate(float ms, Styles s, AnimateFinishedHandler onEnd);
    __attribute__((overloadable)) $& animate(float ms, AnimateStepHandler onStep, AnimateFinishedHandler onEnd);
    __attribute__((overloadable)) $& animate(float ms, Styles s, Dic* opts);
    __attribute__((overloadable)) $& animate(float ms, Styles s, AnimateFinishedHandler onEnd, Dic* opts);
    __attribute__((overloadable)) $& animate(float ms, AnimateStepHandler onStep, AnimateFinishedHandler onEnd, Dic*opts);
    
    __attribute__((overloadable)) $& operator>>($&p);   //insert into super
    __attribute__((overloadable)) $& operator>>(UIView *p); //insert into super
    __attribute__((overloadable)) $& operator<<($&p); // append child
    
    __attribute__((overloadable)) $& operator>($&p);   //insert layer into super
    __attribute__((overloadable)) $& operator<($&p);   //append layer
    
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
    void setTextAlign(const char* align);
    void setFont(char* font);
    __attribute__((overloadable)) void setColor(id color);
    __attribute__((overloadable)) void setColor(char* color);
    void setFontSize(float s);
    void switchEditingMode();
    $& setEditable(BOOL editable, TextEditOnInitHandler startEdit);
    $& setContentSize(float x, float y);
    //void setBgcolor(id color);
    
    static NSMutableDictionary * s_views;
    static NSString * s_controllerName;
    static int s_views_idx;
    
    static $* getView(NSString * ID, NSString *ctrlerName);
    static void clearAll(NSString * controllerName);
    static void setControllerName(NSString *controllerName);
    
    void remove();
    //TODO remove from super
    
private:
    Styles styles;
    const char* svgPath;
    __attribute__((overloadable)) static void registerView($* vp);
    __attribute__((overloadable)) static void removeView($* vp);
    bool released;
};

#pragma mark - View

@interface View : UIScrollView<UITextFieldDelegate,UITextViewDelegate>
@property (nonatomic,retain) NSMutableDictionary * gestures;
@property (nonatomic,retain) NSMutableDictionary * data;
@property (nonatomic,retain) UIView *textField;
@property $* owner;
-(id)   initWithOwner:($*)owner rect:(CGRect)rect;
-(void) gestureHandler:(UIGestureRecognizer*)ges;
-(void) switchEditingMode;
@end

#pragma mark - Layer
@interface Layer : CALayer
@property (nonatomic, readwrite) BOOL asSubLayer;
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


#pragma mark - CPP style funcs

//string
NSString * str(char * cs);
char * cstr(NSString * cs);
UIColor * str2color(char * s);
char * dec2hex(int dec, int bits);
char * colorstr(int r, int g, int b, int a);
char * colorfstr(float r, float g, float b, float a);
bool strstarts(char* s1, const char* s2);
bool strends(char* s1, const char* s2);
bool strhas(char* s1, const char* s2);
char * f2str(float f);
char * strs(int num, char* s ,...);
long long milliseconds();

//styles
Styles str2style(char * s);
__attribute__((overloadable)) Styles style(Styles *custom, Styles *ext);
__attribute__((overloadable)) Styles style(Styles *custom, std::initializer_list<Styles *>exts);

//time
typedef void(^TimeoutHandler)(NSDictionary*);
void $setTimeout(float millisec, TimeoutHandler block, NSDictionary* data);
typedef BOOL(^TimeIntervalHandler)(NSDictionary*,int); //RETURN false to break
void $setInterval(float millisec, TimeIntervalHandler block, NSDictionary*dic);

//Controller
UIViewController * $controller(NSString *controllerName);
UIViewController * $transition(UIViewController*from, NSString* toControllerName, UIModalTransitionStyle style);

//Data
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

#pragma mark - OpenGL


#endif