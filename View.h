//
//  View.h
//  liberobjc
//
//  Created by soyoes on 6/14/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>

#import "Styles.h"
#import "HTTPRequest.h"
#import <initializer_list>
#import <vector>
#import <regex>

#define _events @[@"tap", @"pinch", @"rotation", @"swipe", @"pan", @"longpress"]
#define _rootController [UIApplication sharedApplication].keyWindow.rootViewController 

#ifndef VIEW_H
#define VIEW_H
@class View;
@class Layer;

class $;

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
    static const char * pathFromStyle(StyleDef *s);
    static const char * pathFromStyle(StyleDef *s, bool customOrigin, float left, float top);
};


#pragma mark - App

class App{

};

#pragma mark - Controller

class Controller{
    $* view;
};


#pragma mark - $

class ${
public:
    __strong View        * view;             //a uiview extension which can save data and response to UIGesture.
    //Mask        * mask;           //a mask to respond
    __strong StyleDef    * styles;
    __strong NSString    * ID;               //unique id of this View.
    __strong NSString    * NS;               //namespace.
    __strong NSString    * svg;              //svgPath
    
    __strong Layer        * layer;            //base layer
    
    __strong CALayer      * frameLayer;      //layers container including shadows
    __strong CALayer      * contentLayer;    //sub of frameLayer, contains bg color, image.
    __strong CALayer      * imageLayer;      //sub of contentLayer, contains image.
    //CAShapeLayer * shadowLayer;     //sub of frameLayer, layer under contentLayer
    //CAShapeLayer * innerShadowLayer;      //sub of contentLayer, show inner shadow
    //ShapeLayer * borderLayer;      //sub of contentLayer, show border.
    __strong CATextLayer  * textLayer;       //3rd sublayer of contentLayer, text
    
    __strong CAShapeLayer * maskLayer;      //shape mask layer. not sublayer of any layers
    
    __strong NSMutableArray  *subLayers;

    __strong UIDynamicAnimator   * animator;
    __strong NSMutableArray      * behaviors;
    __strong NSMutableArray      * dummys;

    __strong id          src;
    __strong NSString   *text;
    bool        scrollable;
    bool        slidable;
    $* pages;
    
    $*              parent;
    __strong NSMutableArray *nodes;
    
#pragma mark methods
    
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
    $& setStyle(Styles st, Styles *ex);
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

    void setBgcolor(const char* color);
    //void setShadow(const char* shadow);
    void addShadow(ShadowDef* shad);
    void clearShadows();
    
    void setOutline(const char* outline);
    void setGradient(const char* value);
    
    //void setBorder(const char* border);
    void addBorder(BorderDef*bd);
    void clearBorders();
    
    //H V S T are unsupported
    void setSvgPath (const char* svgpathcmd);
    void setMask (CGPathRef path);
    
    
    $& setImage(id src);
    UIImage * getImage();
    
    $& setText(NSString * _text);
    $& setDefaultText(NSString * _text);
    $* root();
    void setTextstyle(StyleDef *s);
    __attribute__((overloadable)) void setTextAlign(const char* align);
    __attribute__((overloadable)) void setTextAlign(NSString* align);
    __attribute__((overloadable)) void setFont(const char* font);
    __attribute__((overloadable)) void setFont(UIFont* font);
    __attribute__((overloadable)) void setColor(id color);
    __attribute__((overloadable)) void setColor(const char* color);
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
    static NSMutableDictionary * s_trash;
    static NSString * s_controllerName;
    static int s_views_idx;
    
    __attribute__((overloadable)) static $* const getView(NSString * ID, NSString *ctrlerName);
    __attribute__((overloadable)) static $& getView(NSString * ID);
    static void clearAll(NSString * controllerName);
    static void setControllerName(NSString *controllerName);
    
    void remove();
    
    NSValue* value();
    //TODO remove from super
    
private:
    //Styles styles;
    //const char* svgPath;
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
@property (nonatomic,readonly) $* owner;
-(id)   initWithOwner:($*)owner rect:(CGRect)rect;
-(void) gestureHandler:(UIGestureRecognizer*)ges;
-(void) switchEditingMode;
@end

#pragma mark - Layer
@interface Layer : CALayer
@property (nonatomic, readwrite) BOOL asSubLayer;
@end

#pragma mark - Layer
@interface ShapeLayer : CAShapeLayer
@property (nonatomic, retain) NSString *type;
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


/*
//styles : shadow
char* shadstr(bool inset, float x, float y, float blur, const char*color);
ShadowOpt shadopt(const char*);

//styles : border
char* bordstr(float w, int style, const char*color, float radius);
BorderlineOpt& bordopt(const char*s);

//styles : outline
char* olstr(float w, int style, const char*color, float space);
OutlineOpt olopt(const char*s);
*/



//Controller
UIViewController * $controller(NSString *controllerName);
UIViewController * $transition(UIViewController*from, NSString* toControllerName, UIModalTransitionStyle style);

#pragma mark - OpenGL


#endif