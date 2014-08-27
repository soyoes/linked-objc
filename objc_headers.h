//
//  objc_headers.h
//  LiberObjcExample
//
//  Created by soyoes on 8/17/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <functional>
using namespace std;

#define NIL nil
#define radians(degrees) (degrees * M_PI/180)
#define kModeFill @0
#define kModeFit @1
#define kModeCropFit @2
#define kModeOrg @3
#define kModeCustom @4

#define kTextAlignTopLeft   @"topLeft"
#define kTextAlignTopCenter @"topCenter"
#define kTextAlignTopRight  @"topRight"
#define kTextAlignLeft      @"left"
#define kTextAlignCenter    @"center"
#define kTextAlignRight     @"right"
#define kTextAlignBottomLeft    @"bottomLeft"
#define kTextAlignBottomCenter  @"bottomCenter"
#define kTextAlignBottomRight   @"bottomRight"
#define kTextAlignJustified     @"justified"

#define TEXTALIGNS @[kTextAlignTopLeft,kTextAlignTopCenter,kTextAlignTopRight,kTextAlignLeft,kTextAlignCenter,kTextAlignRight,kTextAlignBottomLeft,kTextAlignBottomCenter,kTextAlignBottomRight]
#define EVENTS @[@"tap", @"pinch", @"rotation", @"swipe", @"pan", @"longpress"]

typedef id                      obj_t;
typedef NSNumber *              num_t;
typedef NSString *              str_t;
typedef NSMutableDictionary*    mdic_t;
typedef NSDictionary *          dic_t;
typedef NSMutableArray *        marr_t;
typedef NSArray *               arr_t;
typedef NSData *                data_t;
typedef NSValue *               value_t;
typedef NSDate *                date_t;
typedef NSNumber *              bool_t;

typedef UIFont *                font_t;
typedef UIView *                view_base_t;
typedef UIColor *               color_t;
typedef UIScrollView *          sview_t;
typedef UIImage *               image_t;
typedef CALayer *               layer_base_t;
typedef CATextLayer *           text_layer_t;
typedef CAShapeLayer *          shape_layer_t;
typedef CGPath*                 path_t;

typedef UIGestureRecognizer *   ges_t;

@class LBView;
typedef LBView*                 view_t;


typedef void(^http_f)(obj_t, dic_t);
typedef void(^ges_f)(ges_t, $&, dic_t);
typedef void(^anime_step_f)($&, float);
typedef void(^anime_end_f)($&);
typedef void(^slide_page_f)($&, int);
typedef void(^slide_vertical_scroll_f)($&, int, float, float);
typedef void(^remote_content_f)(obj_t,dic_t);
typedef void(^remote_loader_f)($&, remote_content_f);
typedef str_t(^label_content_f)(obj_t);

/*
typedef function<void (obj_t, dic_t)> http_f;
typedef function<void (ges_t, $&, dic_t)> ges_f;
typedef function<void ($&, float)> anime_step_f;
typedef function<void ($&)> anime_end_f;
typedef function<void ($&, int)> slide_page_f;
typedef function<void ($&, int, float, float)> slide_vertical_scroll_f;
typedef function<void (obj_t, dic_t)> remote_content_f;
typedef function<void ($&, remote_content_f)> remote_loader_f;
typedef function<str_t (obj_t)> label_content_f;
 
#inline
 caller([](obj_t o, dic_t p) {return p[@"key"];});
 
#pre-define outside
 void mycallback(obj_t o, dic_t p) {return p[@"key"];}
 #call
 caller (mycallback);
 
*/
#pragma mark - TextField
/*
 @interface TextEdit : UITextField
 @end
 */
@interface LBTextView : UITextView
@property (nonatomic,retain) str_t dateFormat;
@property (nonatomic,retain) arr_t options;
@property (nonatomic,retain) UIDatePicker* datePicker;
@property (nonatomic,retain) UIPickerView* picker;
@property BOOL nowrap;
@end
typedef LBTextView* textview_t;
typedef LBTextView textview_cls;

#pragma mark - Layer
@interface LBLayer : CALayer
@property (nonatomic, readwrite) BOOL asSubLayer;
@end
typedef LBLayer* layer_t;
typedef LBLayer layer_cls;

#pragma mark - ShapeLayer
@interface LBShapeLayer : CAShapeLayer
@property (nonatomic, retain) str_t type;
@end
typedef LBShapeLayer shape_layer_cls;


typedef void(^TextEditOnInitHandler)($&);

#pragma mark - View
@interface LBView : UIScrollView<UITextViewDelegate,UIPickerViewDelegate>
@property (nonatomic,retain) mdic_t     gestures;
@property (nonatomic,retain) mdic_t     gesmap;
@property (nonatomic,retain) ges_t      ges_a;
@property (nonatomic,retain) mdic_t     data;
@property (nonatomic,retain) textview_t textField;

@property (nonatomic,retain) value_t  styles;           //style specifications
@property (nonatomic,retain) str_t    ID;               //unique id of this View.
@property (nonatomic,readonly) int    idx;
@property (nonatomic,retain) str_t    NS;               //namespace.
@property (nonatomic,retain) view_base_t   parent;           //parent view
@property (nonatomic,retain) marr_t   nodes;            //childs

//@property (nonatomic,retain) layer_t         layer;            //base layer
@property (nonatomic,retain) layer_base_t    frameLayer;       //layers container including shadows
@property (nonatomic,retain) layer_base_t    contentLayer;     //sub of frameLayer, contains bg color, image.
@property (nonatomic,retain) layer_base_t    imageLayer;       //sub of contentLayer, contains image.
@property (nonatomic,retain) text_layer_t    textLayer;    //3rd sublayer of contentLayer, text
@property (nonatomic,retain) shape_layer_t   maskLayer;    //shape mask layer. not sublayer of any layers

@property (nonatomic,retain) marr_t      subLayers;        //contains layers of all subviews, but not sublayers such as frameLayer,contentLayer ...
@property (nonatomic,retain) obj_t       src;              //image src
@property (nonatomic,retain) str_t       text;             //text
@property (nonatomic,retain) str_t       svg;              //svgPath

@property (nonatomic,retain) marr_t  borders;
@property (nonatomic,retain) marr_t  shadows;
@property (nonatomic,retain) marr_t  gradclrs;
@property (nonatomic,retain) marr_t  gradlocs;

@property (nonatomic,assign) float  x,y,w,h,z,rotate,corner,fontsize;

@property (nonatomic,assign) vec2       scale,flip;
@property (nonatomic,assign) vec4       padding;
@property (nonatomic,assign) rotate3d_t  rotate3d;
@property (nonatomic,assign) fill_mode_t fillmode;
@property (nonatomic,assign) bool       truncate,editable,nowrap;
@property (nonatomic,assign) rgba_t     color, bgcolor;
@property (nonatomic,assign) align_t    textalign;
@property (nonatomic,retain) str_t      fontname;

@property (nonatomic,assign) bool        asSubLayer;
@property (nonatomic,assign) bool        slidable;
@property (nonatomic,assign) bool        slideWithPages; //whether or not show pages
@property (nonatomic,retain) marr_t      slides;
@property (nonatomic,retain) view_t      pages;

@property (nonatomic,readonly) $* owner;
//@property (nonatomic,assign) style_t styles;

-(id)   initWithOwner:($*)owner rect:(rect_t)rect viewid:(str_t)_ID idx:(int)_idx;
-(void) gestureHandler:(ges_t)ges;
-(void) switchEditingMode;

-(void) setStyles:(style_t)styles;
-(void) setImage:(id)src;
-(image_t) getImage;
-(void) setText:(str_t)txt;
-(void) setDefaultText:(str_t)text;
-(void) setPickable:(arr_t) opts;
-(void) setPickable:(date_t) date format:(str_t) format;
-(void) setEditable:(BOOL)ea;
-(void) setEditable:(BOOL)ea handler:(TextEditOnInitHandler)startHandler;

-(void) set:(str_t)k value:(obj_t)v;
-(obj_t) get:(str_t)k;
-(void) bind:(str_t)event handler:(ges_f)handler opts:(dic_t)opts;
-(void) unbind:(str_t)event;
-(void) dragable:(ges_f)onDrag end:(ges_f)onEnd;

-(void) animate:(float)ms style:(style_t)toStyle opts:(anime_t)opts;
-(void) animate:(float)ms style:(style_t)toStyle end:(anime_end_f)onEnd opts:(anime_t)opts;
-(void) animate:(float)ms style:(style_t)toStyle svg:(str_t)newSvgPath end:(anime_end_f)onEnd opts:(anime_t)opts;
-(void) animate:(float)ms step:(anime_step_f)onStep end:(anime_end_f)onEnd opts:(anime_t)opts;
-(void) appendTo:(view_base_t)p asLayer:(bool)asLayer;
-(view_t) root;
@end
typedef LBView view_cls;


#pragma mark - Border
@interface LBBorder : NSObject
@property (nonatomic) float width, radius;
@property (nonatomic) color_t color;
@property (nonatomic, retain) image_t image;
+ (LBBorder *) border:(str_t)bd;
+ (LBBorder *) border:(float)w color:(str_t)c radius:(float)r;
- (str_t) toString;
@end
typedef LBBorder* border_t;
typedef LBBorder border_cls;

#pragma mark - Shadow
@interface LBShadow : NSObject
@property (nonatomic) BOOL inset;
@property (nonatomic) float x, y, radius;
@property (nonatomic) color_t color;
+ (LBShadow *) shadow:(str_t)sd;
+ (LBShadow *) shadow:(bool)inset x:(float)x y:(float)y radius:(float)r color:(str_t)c;
- (str_t) toString;
@end
typedef LBShadow* shadow_t;
typedef LBShadow shadow_cls;

typedef void(^HTTPRequestHandler)(obj_t, dic_t);
@interface HTTPRequest : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property (nonatomic, retain)   NSMutableData       *raw;
@property (nonatomic, copy)     HTTPRequestHandler  handler;
@property (nonatomic, retain)   mdic_t   args;
+ (void)call:(str_t)method url:(str_t)url datas:(dic_t)datas handler:(http_f)handler args:(dic_t)args;
@end

