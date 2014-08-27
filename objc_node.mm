//
//  node.mm
//  testapp
//
//  Created by soyoes on 8/17/14.
//  Copyright (c) 2014 soyoes. All rights reserved.
//

#import "liber.h"
#import "objc_categories.h"

#import <string>
#import <regex>

#pragma mark - $

long __view_id;

using namespace std;

$::$():view_id(__view_id++){}
$::~$(){
    //FIXME remove this from __nodes
}
str_t $::ID(){view_t v = view();return v?v.ID:nil;}

str_t $::color(){view_t v = view();return v?rgba2str(v.color):nil;}
str_t $::bgcolor(){view_t v = view();return v?rgba2str(v.bgcolor):nil;}
arr_t $::shadows(){view_t v = view();return v && v.shadows? v.shadows:@[];}
arr_t $::borders(){view_t v = view();return v && v.borders? v.borders:@[];}
rotate3d_t $::rotate3d(){view_t v = view();return v?v.rotate3d:(rotate3d_t){};}
str_t $::fontname(){view_t v = view();return v? v.fontname:[UIFont systemFontOfSize:14].fontName;}

str_t $::svg(){view_t v = view();return v?v.svg:nil;}
float $::x(){view_t v = view();return v?v.x:0;}
float $::y(){view_t v = view();return v?v.y:0;}
float $::w(){view_t v = view();return v?v.w:0;}
float $::h(){view_t v = view();return v?v.h:0;}
float $::z(){view_t v = view();return v?v.z:0;}
float $::alpha(){view_t v = view();return v?v.alpha:1;}
float $::corner(){view_t v = view();return v?v.corner:0;}
float $::rotate(){view_t v = view();return v?v.rotate:0;}
float $::fontsize(){view_t v = view();return v? v.fontsize:14;}
fill_mode_t $::fillmode(){view_t v = view();return v?v.fillmode:kFill;}
align_t $::align(){view_t v = view();return v?v.textalign:kCenter;}
vec4 $::padding(){view_t v = view();return v?v.padding:(vec4){0,0,0,0};}
vec2 $::center(){view_t v = view();return v?(vec2){v.x,v.y}:(vec2){0,0};}
void $::center(float x, float y){view_t v = view();if(v){v.center = {x,y};}}


#pragma mark -

$& $::setStyle(style_t ss){
    view_t v = view();
    if(!v)
        v = [[LBView alloc] initWithOwner:this rect:{numf(ss.x),numf(ss.y),numf(ss.w),numf(ss.h)}
                                   viewid:ss.ID idx:view_id];
    [v setStyles:ss];
    return *this;
}

$& $::bind(str_t event, ges_f handler, dic_t opts){
    view_t v = view();
    if(v)[v bind:event handler:handler opts:opts];
    return *this;
}
$& $::unbind(str_t event){
    view_t v = view();
    if(v)[v unbind:event];
    return *this;
}

$& $::dragable(ges_f onDrag, ges_f onEnd){
    view_t v = view();
    if(v)[v dragable:onDrag end:onEnd];
    return *this;
}

rect_t $::rect(){
    view_t v = view();
    return v? (rect_t){v.x,v.y,v.w,v.h} : (rect_t){0,0,0,0};
}

void $::remove(){
    view_t v = view();
    if(v){
        [v removeFromSuperview];
        if(__nodes && __nodes[v.NS]){
            [__nodes[v.NS] removeObjectForKey:v.ID];
        }
    }
    //delete this;
}

$& $::hide(float ms){
    view_t v = view();
    if(v) v.alpha = 0;
    return *this;
}
$& $::show(float ms){
    view_t v = view();
    if(v) v.alpha = 1;
    return *this;
}

/**
 supported style animation
 .x, .y, .w, .h
 .alpha
 .cornerRadius
 .rotate
 .rotate3d
 .bgcolor;
 .color;
 .shadow;
 .border;
 */
$& $::animate(float ms, style_t s, anime_t opts){return animate(ms, s, NIL,^($&){}, opts);}
$& $::animate(float ms, style_t s, anime_end_f onEnd, anime_t opts){return animate(ms, s, NIL, onEnd, opts);}
$& $::animate(float ms, style_t s, str_t svgpath, anime_end_f onEnd, anime_t opts){
    view_t v = view();
    if(v) [v animate:ms style:s svg:svgpath end:onEnd opts:opts];
    return *this;
}
$& $::animate(float ms, anime_step_f onStep, anime_end_f onEnd, anime_t opts){
    view_t v = view();
    if(v) [v animate:ms step:onStep end:onEnd opts:opts];
    return *this;
}


#pragma mark $ operator

__attribute__((overloadable)) $& $::operator>>($& p){
    view_t v = view();
    view_t vp = p.view();
    if(v && vp)[v appendTo:vp asLayer:false];
    return *this;
}
__attribute__((overloadable)) $& $::operator>>(view_base_t p){
    //FIXME solve sublayers
    view_t v = view();
    if(v && p)[v appendTo:p asLayer:false];
    return *this;
}
__attribute__((overloadable)) $& $::operator<<($& p){
    p >> *this;
    return *this;
}

$* $::operator[](int idx){
    view_t v = view();
    if(v && v.nodes && [v.nodes count]>idx){
        return ($*)([[v.nodes objectAtIndex:idx] owner]);
    }
    return NULL;
}

//insert layer into super
$& $::operator>($&p){
    view_t v = view();
    view_t vp = p.view();
    if(v && vp)[v appendTo:vp asLayer:true];
    return *this;
}
//append layer
$& $::operator<($&p){
    p > *this;
    return *this;
}

#pragma mark $ data

id $::get(str_t key){
    view_t v = view();
    if(v){return [v get:key];}
    return nil;
}
float $::getFloat(str_t key){obj_t r = get(key); return r? numf(r):0;}
int $::getInt(str_t key){obj_t r = get(key); return r? numi(r):0;}
bool $::getBool(str_t key){obj_t r = get(key); return r? numb(r):0;}
__attribute__((overloadable)) $& $::set(str_t key, obj_t value){
    view_t v = view();
    if(v){[v set:key value:value];}
    return *this;
}
__attribute__((overloadable)) $& $::set(dic_t p){
    view_t v = view();
    if(v&&p){for (id k in p) {[v set:k value:p[k]];}}
    return *this;
}

$& $::del(obj_t key){
    view_t v = view();
    if(v){
        if(is_str(key))
            mdic_remove(v.data, key);
        else if(is_arr(key)){
            for (str_t k in (arr_t)key) {
                mdic_remove(v.data, k);
            }
        }
    }
    return *this;
}

#pragma mark $ scroll
$& $::scrollSize(float x, float y){
    view_t v = view();
    if(v)v.contentSize = CGSizeMake(x, y);
    return *this;
}
vec2 $::scrollSize(){
    view_t v = view();return v?(vec2){static_cast<float>(v.contentSize.width),static_cast<float>(v.contentSize.height)}:(vec2){};
}

$& $::scrollTo(float x, float y){
    view_t v = view();
    if(v)[v setContentOffset:{x,y} animated:YES];
    return *this;
}
vec2 $::scrollPos(){
    view_t v = view();return v?(vec2){static_cast<float>(v.contentOffset.x),static_cast<float>(v.contentOffset.y)}:(vec2){};
}

$& $::scrollTop(float topMargin){
    view_t v = view();
    if(v){
        view_t p = [v root];
        if(p){
            [p set:@"orgContentOffset" value:@(p.contentOffset.y)];
            [p setContentOffset:{0,p.frame.origin.y-topMargin} animated:YES];
        }
    }
    return *this;
}
$& $::scrollBack(){
    view_t v = view();
    if(v){
        view_t p = [v root];
        if(p){
            id off = [p get:@"orgContentOffset"];
            if(off){
                [v setContentOffset:{0,[off floatValue]} animated:YES];
                [p.data removeObjectForKey:@"orgContentOffset"];
            }
        }
    }
    return *this;
}

#pragma mark $ image

$& $::image(obj_t src){
    view_t v = view();
    if(v) [v setImage:src];
    return *this;
}
image_t $::image(){
    view_t v = view();
    return (v)? [v getImage]:nil;
}

#pragma mark $ text

$& $::text(str_t _text){
    view_t v = view();
    if(v) [v setText:_text];
    return *this;
}

$& $::defaultText(str_t _text){
    view_t v = view();
    if(v) [v setDefaultText:_text];
    return *this;
}
str_t $::text(){view_t v = view();return v?v.text:nil;}

__attribute__((overloadable)) $& $::setPickable(arr_t opts){
    view_t v = view();
    if(v) [v setPickable:opts];
    return *this;
}
__attribute__((overloadable)) $& $::setPickable(date_t date, str_t format){
    view_t v = view();
    if(v) [v setPickable:date format:format];
    return *this;
}

__attribute__((overloadable)) $& $::setEditable(BOOL editable){return setEditable(editable, ^($&v){});}
__attribute__((overloadable)) $& $::setEditable(BOOL editable, TextEditOnInitHandler startHandler){
    view_t v = view();
    if(v) [v setEditable:editable handler:startHandler];
    return *this;
}

view_t $::view(){
    return (__idxmap)?__idxmap[@(view_id)]:nil;
}

value_t $::encode(){
    return [NSValue value:this withObjCType:@encode($)];
}

