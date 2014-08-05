//
//  styles.h
//  liberobjc
//
//  Created by soyoes on 6/14/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#ifndef LIBEROBJC_SHORTCUT_NAMES
#define LIBEROBJC_SHORTCUT_NAMES
    typedef UIGestureRecognizer GR;
    typedef NSDictionary Dic;
    typedef NSMutableDictionary MDic;
    typedef NSArray Arr;
    typedef NSMutableArray MArr;
    typedef NSString Str;
    typedef NSMutableString MStr;
#endif

#import "Lang.h"
#import <initializer_list>

#ifndef STYLES_H
#define STYLES_H

#define IPAD UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()

#define radians(degrees) (degrees * M_PI/180)

#define logRect(name,rect) (NSLog(@"--\nRECT:%@ = (%f,%f), (%f,%f) \n--",(name),(rect.origin.x),(rect.origin.y),(rect.size.width),(rect.size.height)))
#define logSize(name,size) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(size.width),(size.height)))
#define logPoint(name,p) (NSLog(@"--\nRECT:%@ = (%f,%f) \n--",(name),(p.x),(p.y)))

#define m_FILL 0
#define m_FIT 1
#define m_CROP_FIT 2
#define m_ORG 3

#define m_NOBORDER 0
#define m_SOLID 1
#define m_DASHED 2
#define m_DOTTED 3

#define m_filpN 0
#define m_filpH 1
#define m_filpV 2

typedef enum {
    s_easeIn,
    s_easeOut,
    s_easeInOut
} AnimationStyle;

typedef enum {
    d_linear,
    d_quad,
    d_quad5,
    d_circ,
    d_bounce,
    d_arrow,
    d_back,
    d_elastic,
} AnimationDelta;
/*
typedef enum{
    l_solid,
    l_dashed,
    l_dotted
} LineStyles;
*/

struct animete_opt{
    AnimationDelta delta;
    AnimationStyle style;
    int delay;
};

struct Rotate3DOpt{
    float degree;
    float x;
    float y;
    float z;
    float resp;
    float axisX;
    float axisY;
    float transX;
    float transY;
    float transZ;
};

/*
struct ShadowOpt{
    bool  inset;
    float x;
    float y;
    float radius;
    __unsafe_unretained const char* color;
};

struct LineOpt{
    float w;
    __unsafe_unretained const char* color;
    int style;
};
/*
class OutlineOpt{
public:
    float w;
    const char* color;
    int style;
    float space;
};


struct BorderlineOpt{
    float w;
    __unsafe_unretained const char* color;
    int style;
    float radius;
};
 */

@interface BorderDef : NSObject
@property (nonatomic) float width, radius;
@property (nonatomic) RGBA color;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic) int type;
+ (BorderDef *) border:(const char* )bd;
+ (BorderDef *) border:(float)w type:(int)t color:(const char* )c radius:(float)r;
- (const char *) toString;
@end

@interface ShadowDef : NSObject
@property (nonatomic) BOOL inset;
@property (nonatomic) float x, y, radius;
@property (nonatomic) RGBA color;
+ (ShadowDef *) shadow:(const char* )sd;
+ (ShadowDef *) shadow:(bool)inset x:(float)x y:(float)y radius:(float)r color:(const char* )c;
- (const char *) toString;
@end


struct Styles{
    float   x;  //left
    float   y;  //top
    float   w;  //width
    float   h;  //height
    float   z;  //z-index
    const char *  bgcolor;
    //format(use rgbcolor) : 213,204,222,1.0
    //format(use rgbcolor) : 213,204,222
    //format(use hexcolor) : #336699CC //CC=alpha
    //format(use gradient) : #336699 #33CCFF
    //format(use gradient + location) : #336699:0 #3399CC:0.5 #33CCFF:1
    //format(use gradient + location + degree) : #336699:0 #3399CC:0.5 #33CCFF:1 90
    const char *  color;
    //color: text color
    //color format @see bgcolor,
    const char *  shadow;
    //format : x y radius colorStr opacity
    const char *  border;
            //format :width color/image corner-radius
            //format(use image) : 1 myline.png 4        //dash|dot ...
            //format(use rgbcolor) : 1 213,204,222
            //format(use hexcolor) : 1 #CCFF33 2
    float   alpha;
            //0~1   0.0f:opacity=1, 1.0f:opacity=0
    float   cornerRadius;
            //@see border
    
    //const char *  outlineColor;
    //float   outlineSpace,outlineWidth;
    //LineStyles outlineStyle;
            //@see outline
    
    int     contentMode;//m_FIT/m_FILL/m_CROP
    
    float   scaleX, scaleY;//<0.00 & <x
    float   rotate;
            //formart : degree in float
            //example : 30,45,60 ...
    const char*  rotate3d;
            //format : degree, rotateX, rotateY, rotateZ, respective, anchorX, anchorY, translateX, translateY, translateZ
            //example : 45,1,0,0,500,0.5,1
    const char*   flip;
            //flip 'H'=horizontal, 'V'=vertical
    
    float   padding, paddingLeft, paddingTop, paddingRight, paddingBottom;
            //working with label(text,...) only
    const char*  font;
            //format : fontname,fontsize
    const char*  fontName;
    float   fontSize;
            //float
    const char*  textAlign;
            //justified | center | left | right
    bool    nowrap;
            // wrapped:  wrap text to multiple row , default=true
            //format : false
    bool    truncate;
            // truncate:  truncate text to ..., default = no truncate
            //format : true
    bool    editable;
            //format : true, if clicked, add dynamical textfield automatically
    const char* placeHolder;
            //=css placeholder
    const char* path;
            //svg path
    __strong NSString * ID;
};


@interface StyleDef : NSObject
@property (nonatomic, assign) float x,y,w,h,z,alpha,corner,scaleX,scaleY,rotate,
paddingLeft, paddingTop, paddingRight, paddingBottom;
//@property (nonatomic, assign) RGBA bgcolor, color;
@property (nonatomic, retain) NSMutableArray * shadows, * borders, *grads;
@property (nonatomic, assign) int contentMode;
//@property (nonatomic, assign) Rotate3DOpt rotate3d;
@property (nonatomic, assign) int flip;
@property (nonatomic, retain) UIFont * font;
@property (nonatomic) BOOL nowrap,truncate,editable;
@property (nonatomic, retain) NSString *ID,*placeHolder,*align,*bgcolor,*color,*rotate3d,*path;
+(StyleDef*)style:(Styles)s;
//-(void)setStyles:(Styles)s;
-(void)mergeStyle:(StyleDef*)s;
-(StyleDef *)duplicate;
-(void)setBorderStyle:(const char*)s;
-(void)setShadowStyle:(const char*)s;
-(void)setAlignStyle:(const char*)s;
-(void)setFlipStyle:(const char*)s;
-(void)setFontStyle:(const char*)s;

@end

#define nos (Styles){0,0,0,0,0,NULL,NULL,NULL,NULL,0,0,0,1,1,0,NULL,NULL,0,0,0,0,0,NULL,NULL,0,NULL,false,false,false,NULL}
#define dfs (Styles){0,0,0,0,0,"#FFFFFF00","#333333",NULL,NULL,0,0,m_FIT,1,1,0,NULL,NULL,0,0,0,0,0,NULL,NULL,14,"center",false,false,false,NULL}

#define nor3d (Rotate3DOpt){0,0,0,0}
#define no_3d_rotate(o) (return o.degree==0&&o.x==0&&o.y==0&&o.z==0;)

//styles
Styles str2style(const char * s);
__attribute__((overloadable)) Styles style(Styles *custom, Styles *ext);
__attribute__((overloadable)) Styles style(Styles *custom, std::initializer_list<Styles *>exts);
NSValue * style2val(Styles s);
Styles val2style(NSValue *v);

#pragma mark - CPP style funcs

//styles : rotate 3d opts
char* r3dstr(float degree, float x, float y, int resp, float axisX, float axisY, float transX, float transY);
Rotate3DOpt r3dopt(const char * rotate3dStr);

//styles : font
char* fontstr(const char*fname, float fontsize);
UIFont* ftopt(const char*s);

#endif
