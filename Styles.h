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

typedef struct{
    float   x;  //left
    float   y;  //top
    float   w;  //width
    float   h;  //height
    float   z;  //z-index
    char *  bgcolor;
    //format(use rgbcolor) : 213,204,222,1.0
    //format(use rgbcolor) : 213,204,222
    //format(use hexcolor) : #336699CC //CC=alpha
    //format(use gradient) : #336699 #33CCFF
    //format(use gradient + location) : #336699:0 #3399CC:0.5 #33CCFF:1
    char *  color;
    //color: text color
    //color format @see bgcolor,
    char *  shadow;
    //format : x y radius colorStr opacity
    char *  border;
            //format :width color/image corner-radius
            //format(use image) : 1 myline.png 4        //dash|dot ...
            //format(use rgbcolor) : 1 213,204,222
            //format(use hexcolor) : 1 #CCFF33 2
    char *  outline;
            //format: width space color ...  1 1 #333333
    float   alpha;
            //0~1   0.0f:opacity=1, 1.0f:opacity=0
    
    float   borderWidth;
    char *  borderColor;
    float   cornerRadius;
            //@see border
    
    char *  outlineColor;
    float   outlineSpace,
            outlineWidth;
            //@see outline
    
    int     contentMode;//m_FIT/m_FILL/m_CROP
    
    float   scaleX, scaleY;//<0.00 & <x
    float   rotate;
            //formart : degree in float
            //example : 30,45,60 ...

    char *  rotate3d;
            //format : degree, rotateX, rotateY, rotateZ, respective, anchorX, anchorY, translateX, translateY, translateZ
            //example : 45,1,0,0,500,0.5,1

    char*   flip;
            //flip 'H'=horizontal, 'V'=vertical
    
    float   padding, paddingLeft, paddingTop, paddingRight, paddingBottom;
            //working with label(text,...) only
    char *  font;
            //format : fontname,fontsize
    char *  fontName;
    float   fontSize;
            //float
    char *  textAlign;
            //justified | center | left | right
    bool    nowrap;
            // wrapped:  wrap text to multiple row , default=true
            //format : false
    bool    truncate;
            // truncate:  truncate text to ..., default = no truncate
            //format : true
    bool    editable;
            //format : true, if clicked, add dynamical textfield automatically
    
    
    char *  placeHolder;
            //=css placeholder
    NSString * ID;

}Styles;

#endif
