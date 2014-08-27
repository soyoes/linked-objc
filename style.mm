//
//  style.cpp
//  LiberObjcExample
//
//  Created by soyoes on 8/17/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#include <stdio.h>

#include "liber.h"

style_t style_merge(style_t custom, style_t base){
    style_t ss=base;
    if(custom.ID) ss.ID = custom.ID;
    if(custom.x)ss.x = custom.x;
    if(custom.y)ss.y = custom.y;
    if(custom.z) ss.z = custom.z;
    if(custom.w) ss.w = custom.w;
    if(custom.h) ss.h = custom.h;
    
    if(custom.border) ss.border = custom.border;
    if(custom.corner) ss.corner = custom.corner;
    
    if(custom.contentMode) ss.contentMode = custom.contentMode;
    
    if(custom.shadow) ss.shadow = custom.shadow;
    if(custom.alpha) ss.alpha = custom.alpha;
    if(custom.bgcolor) ss.bgcolor = custom.bgcolor;
    
    if(custom.scaleX) ss.scaleX = custom.scaleX;
    if(custom.scaleY) ss.scaleY = custom.scaleY;
    if(custom.rotate) ss.rotate = custom.rotate;
    if(custom.rotate3d) ss.rotate3d = custom.rotate3d;
    if(custom.flip) ss.flip = custom.flip;
    
    if(custom.font) ss.font = custom.font;
    if(custom.color) ss.color = custom.color;
    if(custom.align) ss.align = custom.align;
    if(custom.nowrap) ss.nowrap = custom.nowrap;
    if(custom.truncate) ss.truncate = custom.truncate;
    if(custom.editable) ss.editable = custom.editable;
    if(custom.placeHolder) ss.placeHolder = custom.placeHolder;
    
    
    if(custom.padding) ss.padding = custom.padding;
    if(custom.paddingLeft) ss.paddingLeft = custom.paddingLeft;
    if(custom.paddingRight) ss.paddingRight = custom.paddingRight;
    if(custom.paddingBottom) ss.paddingBottom = custom.paddingBottom;
    if(custom.paddingTop) ss.paddingTop = custom.paddingTop;
    
    if(custom.path) ss.path = custom.path;
    return ss;
}

style_t style_t::operator=(style_t s){
    ID = (s.ID != NIL) ? s.ID : NIL;
    x  = (s.x  != NIL) ? s.x  : NIL;
    y  = (s.y  != NIL) ? s.y  : NIL;
    z  = (s.z  != NIL) ? s.z  : NIL;
    w  = (s.w  != NIL) ? s.w  : NIL;
    h  = (s.h  != NIL) ? s.h  : NIL;
    
    border = (s.border != NIL) ? s.border : NIL;
    corner = (s.corner != NIL) ? s.corner : NIL;
    
    contentMode =  (s.contentMode != NIL) ? s.contentMode : NIL;
    
    shadow = (s.shadow != NIL) ? s.shadow : NIL;
    alpha = (s.alpha  != NIL) ? s.alpha : NIL;
    bgcolor = (s.bgcolor != NIL) ? s.bgcolor : NIL;
    
    scaleX = (s.scaleX != NIL) ? s.scaleX : NIL;
    scaleY = (s.scaleY != NIL) ? s.scaleY : NIL;
    rotate = (s.rotate != NIL) ? s.rotate : NIL;
    rotate3d = (s.rotate3d != NIL) ? s.rotate3d : NIL;
    flip = (s.flip != NIL) ? s.flip : NIL;
    
    font = (s.font != NIL) ? s.font : NIL;
    color = (s.color != NIL) ? s.color : NIL;
    nowrap = (s.nowrap != NIL) ? s.nowrap : NIL;
    align = (s.align != NIL) ? s.align : NIL;
    truncate = (s.truncate != NIL) ? s.truncate : NIL;
    editable = (s.editable != NIL) ? s.editable : NIL;
    placeHolder = (s.placeHolder != NIL) ? s.placeHolder : NIL;
    
    padding = (s.padding != NIL) ? s.padding : NIL;
    paddingLeft = (s.paddingLeft != NIL) ? s.paddingLeft : NIL;
    paddingRight = (s.paddingRight != NIL) ? s.paddingRight : NIL;
    paddingBottom = (s.paddingBottom != NIL) ? s.paddingBottom : NIL;
    paddingTop = (s.paddingTop != NIL) ? s.paddingTop : NIL;
    path = (s.path) ? s.path : NIL;
    return *this;
}
style_t style_t::operator>(style_t s){
    return *this=style_merge(*this,s);
}
style_t style_t::operator<(style_t s){
    /*
    if(s.ID != NIL) ID = s.ID;
    if(s.x  != NIL) x = s.x;
    if(s.y  != NIL) y = s.y;
    if(s.z  != NIL) z = s.z;
    if(s.w  != NIL) w = s.w;
    if(s.h  != NIL) h = s.h;
    
    if(s.border != NIL) border = s.border;
    if(s.corner != NIL) corner = s.corner;
    if(s.contentMode != NIL) contentMode = s.contentMode;
    
    if(s.shadow != NIL) shadow = s.shadow;
    if(s.alpha  != NIL)  alpha = s.alpha;
    if(s.bgcolor != NIL) bgcolor = s.bgcolor;
    
    if(s.scaleX != NIL) scaleX = s.scaleX;
    if(s.scaleY != NIL) scaleY = s.scaleY;
    if(s.rotate != NIL) rotate = s.rotate;
    if(s.rotate3d != NIL) rotate3d = s.rotate3d;
    if(s.flip   != NIL) flip = s.flip;
    
    if(s.font   != NIL) font = s.font;
    if(s.color  != NIL) color = s.color;
    if(s.nowrap != NIL) nowrap = s.nowrap;
    if(s.align  != NIL) align = s.align;
    if(s.truncate   != NIL) truncate = s.truncate;
    if(s.editable   != NIL) editable = s.editable;
    if(s.placeHolder!= NIL) placeHolder = s.placeHolder;
    
    if(s.padding != NIL) padding = s.padding;
    if(s.paddingLeft    != NIL) paddingLeft = s.paddingLeft;
    if(s.paddingRight   != NIL) paddingRight = s.paddingRight;
    if(s.paddingBottom  != NIL) paddingBottom = s.paddingBottom;
    if(s.paddingTop     != NIL) paddingTop = s.paddingTop;
    
    if(s.path) path = s.path;
    return *this;
    */
    
    return *this=style_merge(s,*this);
}

/*
rect_t  style_t::rect(){
    return {numf(x),numf(y),numf(w),numf(h)};
}

float style_t::x$(){return numf(x);}
float style_t::y$(){return numf(y);}
float style_t::w$(){return numf(w);}
float style_t::h$(){return numf(h);}
float style_t::z$(){return numf(z);}
float style_t::alpha$(){return numf(alpha);}
float style_t::corner$(){return numf(corner);}
vec4 style_t::padding$(){
    float p = numf(padding);
    return {paddingLeft?numf(paddingLeft):p,paddingTop?numf(paddingTop):p,
        paddingRight?numf(paddingRight):p,paddingBottom?numf(paddingBottom):p};
}
bool style_t::editable$(){return numb(editable);}
bool style_t::nowrap$(){return numb(x);}
bool style_t::truncate$(){return numb(x);}

style_t style_t::copy(){
    return style_merge(*this,{});
}

value_t style_t::encode(){
    style_t s = {@0,@1};
    return [NSValue valueWithBytes:this objCType:@encode(style_t)];
}

*/