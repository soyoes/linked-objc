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
#include <vector>
#include <regex>

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
    static std::vector<SVGPathCmd> str2cmds(const char* pathcmd);
    static std::vector<SVGPathCmd> tween(const char* path1, const char* path2,  float delta);
    __attribute__((overloadable)) static CGPathRef path(const char* pathcmd);
    __attribute__((overloadable)) static CGPathRef path(std::vector<SVGPathCmd> cmds);
    static const char * pathFromStyle(Styles s);
};


#pragma mark - $

class ${
public:
    View       * view;             //a uiview extension which can save data and response to UIGesture.
    //Mask        * mask;           //a mask to respond
    NSString    * ID;               //unique id of this View.
    NSString    * NS;               //namespace.
    
    Layer     * layer;            //base layer
    
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
    bool        slidable;
    $* pages;
    
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
    __attribute__((overloadable)) $& animate(float ms, Styles s, const char* svgpath, AnimateFinishedHandler onEnd, Dic* opts);
    __attribute__((overloadable)) $& animate(float ms, AnimateStepHandler onStep, AnimateFinishedHandler onEnd, Dic*opts);
    
    __attribute__((overloadable)) $& operator>>($&p);   //insert into super
    __attribute__((overloadable)) $& operator>>(UIView *p); //insert into super
    __attribute__((overloadable)) $& operator<<($&p); // append child
    
    __attribute__((overloadable)) $& operator>($&p);   //insert layer into super
    __attribute__((overloadable)) $& operator<($&p);   //append layer
    
    $* operator[](int idx);//get child
    
    CGRect rect();
    
    id get(NSString*key);
    float getFloat(NSString*key);
    int getInt(NSString*key);
    __attribute__((overloadable)) $& set(NSString*key, id value);
    __attribute__((overloadable)) $& set(Dic*d);
    $& del(id key);
    
    void setShadow(const char* shadow);
    void setOutline(const char* outline);
    void setGradient(const char* value);
    void setBorder(const char* border);
    
    //H V S T are unsupported
    __attribute__((overloadable)) void setSvgPath (const char* svgpathcmd);
    __attribute__((overloadable)) void setSvgPath (CGPathRef path);
    
    
    $& setImage(id src);
    UIImage * getImage();
    
    $& setText(NSString * _text);
    $& setDefaultText(NSString * _text);
    $* root();
    void setTextAlign(const char* align);
    void setFont(char* font);
    __attribute__((overloadable)) void setColor(id color);
    __attribute__((overloadable)) void setColor(char* color);
    void setFontSize(float s);
    void switchEditingMode();
    
    __attribute__((overloadable)) $& setPickable(Arr* opts);
    __attribute__((overloadable)) $& setPickable(NSDate *date, const char* labelFormat);
    
    __attribute__((overloadable)) $& setEditable(BOOL editable);
    __attribute__((overloadable)) $& setEditable(BOOL editable, TextEditOnInitHandler startEdit);
    $& setContentSize(float x, float y);
    $& scrollTo(float , float y);
    $& scrollTop(float topMargin);
    $& scrollBack();
    //void setBgcolor(id color);
    
    static NSMutableDictionary * s_views;
    static NSString * s_controllerName;
    static int s_views_idx;
    
    static $* getView(NSString * ID, NSString *ctrlerName);
    static void clearAll(NSString * controllerName);
    static void setControllerName(NSString *controllerName);
    
    void remove();
    
    NSValue* value();
    //TODO remove from super
    
private:
    Styles styles;
    const char* svgPath;
    __attribute__((overloadable)) static void registerView($* vp);
    __attribute__((overloadable)) static void removeView($* vp);
    bool released;
    
};


#pragma mark - TextField
/*
 @interface TextEdit : UITextField
 @end
 */
@interface TextView : UITextView
@property (nonatomic,retain) NSString * dateFormat;
@property (nonatomic,retain) NSArray * options;
@property (nonatomic,retain) UIDatePicker *datePicker;
@property (nonatomic,retain) UIPickerView *picker;
@property BOOL nowrap;
@end

#pragma mark - View
@interface View : UIScrollView<UITextViewDelegate,UIPickerViewDelegate>
@property (nonatomic,retain) NSMutableDictionary * gestures;
@property (nonatomic,retain) NSMutableDictionary * data;
@property (nonatomic,retain) TextView *textField;
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


__attribute__((overloadable)) $& slide(NSArray*data, ListHandler handler, Styles slideStyle);
__attribute__((overloadable)) $& slide(NSArray*data, ListHandler handler, Styles slideStyle, std::initializer_list<Styles *>ext);

typedef $&(^GridHandler)(id, int, int);
__attribute__((overloadable)) $& grids(NSArray*data, int cols, GridHandler handler, Styles gridsStyle);
__attribute__((overloadable)) $& grids(NSArray*data, int cols, GridHandler handler, Styles gridsStyle, std::initializer_list<Styles *>ext);


#pragma mark - CPP style funcs

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
RGBA rgbaf(const char* colorStr); //return rgba values of 0~1
RGBA rgba(const char* colorStr); //return rgba values of 0~255

//styles
Styles str2style(const char * s);
__attribute__((overloadable)) Styles style(Styles *custom, Styles *ext);
__attribute__((overloadable)) Styles style(Styles *custom, std::initializer_list<Styles *>exts);
NSValue * style2val(Styles s);
Styles val2style(NSValue *v);

//styles : rotate 3d opts
char* r3dstr(float degree, float x, float y, int resp, float axisX, float axisY, float transX, float transY);
Rotate3DOpt r3dopt(const char * rotate3dStr);

//styles : shadow
char* shadstr(bool inset, float x, float y, float blur, const char*color);
ShadowOpt shadopt(const char*);

//styles : border
char* bordstr(float w, LineStyles style, const char*color, float radius);
BorderlineOpt bordopt(const char*s);

//styles : outline
char* olstr(float w, LineStyles style, const char*color, float space);
OutlineOpt olopt(const char*s);

//styles : font
char* fontstr(const char*fname, float fontsize);
FontRef ftopt(const char*s);



//time
long long milliseconds();
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