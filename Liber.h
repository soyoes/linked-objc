//
//  Lang.h
//  liberobjc
//
//  Created by @soyoes on 8/3/14.
//  Copyright (c) 2014 Liberhood,.Ltd All rights reserved.
//

#ifndef __liberobjc__lang
#define __liberobjc__lang

#import "types.h"
#import "objc_headers.h"
#import <functional>
#import <map>

extern float SH, SW;
extern long __view_id;
extern mdic_t __datas,      //cache data
            __counters,
            __animes,      //anime cache
            __nodes,       //node list NS <-> ID <-> view_t*
            __idxmap;      //node map view_id <-> view_t*
extern view_base_t __rootview;
extern str_t __controller;

#pragma mark - structs


#pragma mark - blocks

typedef $&(^list_f)(obj_t, int);
typedef $&(^grid_f)(obj_t, int, int);

#pragma mark - style

class style_t {
    
public:
    __unsafe_unretained num_t   x;  //left
    __unsafe_unretained num_t   y;  //top
    __unsafe_unretained num_t   w;  //width
    __unsafe_unretained num_t   h;  //height
    __unsafe_unretained num_t   z;  //z-index
    __unsafe_unretained str_t   bgcolor;
    //format(use rgbcolor) : 213,204,222,1.0
    //format(use rgbcolor) : 213,204,222
    //format(use hexcolor) : #336699CC //CC=alpha
    //format(use gradient) : #336699 #33CCFF
    //format(use gradient + location) : #336699:0 #3399CC:0.5 #33CCFF:1
    //format(use gradient + location + degree) : #336699:0 #3399CC:0.5 #33CCFF:1 90
    __unsafe_unretained str_t   color;
    //color: text color
    //color format @see bgcolor,
    __unsafe_unretained str_t   shadow;
    //format : x y radius colorStr opacity
    __unsafe_unretained str_t   border;
    //format :width color/image corner-radius
    //format(use image) : 1 myline.png 4        //dash|dot ...
    //format(use rgbcolor) : 1 213,204,222
    //format(use hexcolor) : 1 #CCFF33 2
    __unsafe_unretained num_t   alpha;
    //0~1   0.0f:opacity=1, 1.0f:opacity=0
    __unsafe_unretained num_t   corner;
    //@see border
    
    __unsafe_unretained num_t   contentMode;//kModeFill/kModeCropFit/kModeFit/kModeOrg/kModeCustom
    
    __unsafe_unretained num_t   scaleX, scaleY;//<0.00 & <x
    __unsafe_unretained num_t   rotate;
    //formart : degree in float
    //example : 30,45,60 ...
    __unsafe_unretained str_t  rotate3d;
    //format : degree, rotateX, rotateY, rotateZ, respective, anchorX, anchorY, translateX, translateY, translateZ
    //example : 45,1,0,0,500,0.5,1
    __unsafe_unretained str_t   flip;
    //flip "H"=horizontal, "V"=vertical
    
    __unsafe_unretained num_t   padding, paddingLeft, paddingTop, paddingRight, paddingBottom;
    //working with label(text,...) only
    __unsafe_unretained str_t   font;
    //format : fontname,fontsize
    __unsafe_unretained str_t   align;
    //justified | center | left | right
    __unsafe_unretained bool_t    nowrap;
    // wrapped:  wrap text to multiple row , default=true
    //format : false
    __unsafe_unretained bool_t    truncate;
    // truncate:  truncate text to ..., default = no truncate
    //format : true
    __unsafe_unretained bool_t    editable;
    //format : true, if clicked, add dynamical textfield automatically

    __unsafe_unretained str_t   placeHolder;
    //=css placeholder
    __unsafe_unretained str_t   path;
    //svg path
    __unsafe_unretained str_t   ID;

    style_t  operator=(style_t s); //asign values of this with s
    style_t  operator>(style_t s); //use this to override s, and return this
    style_t  operator<(style_t s); //use s to override this, and return this
    
    value_t  encode();
};



#pragma mark - Node

class ${
public:
    
    $();
    ~$();
    
    view_t view();
    $& setStyle(style_t s);
    $& bind(str_t event, ges_f handler, dic_t opts);
    $& unbind(str_t event);
    $& dragable(ges_f onDrag, ges_f onEnd); //shortcut of this->bind(@"pan",...)
    $& hide(float ms);
    $& show(float ms);
    
    str_t ID();
    str_t color();
    str_t bgcolor();
    arr_t shadows();
    arr_t borders();
    rotate3d_t rotate3d();
    str_t fontname();
    str_t svg();
    float x();
    float y();
    float w();
    float h();
    float z();
    float alpha();
    float corner();
    float rotate();
    float fontsize();
    fill_mode_t fillmode();
    align_t align();
    vec4 padding();
    __attribute__((overloadable)) vec2 center();
    __attribute__((overloadable)) void center(float x, float y);
    
    __attribute__((overloadable)) $& image(obj_t src);
    __attribute__((overloadable)) image_t image();
    
    __attribute__((overloadable)) $& text(str_t _text);
    __attribute__((overloadable)) str_t text();
    $& defaultText(str_t _text);
    
    
    __attribute__((overloadable)) $& animate(float ms, style_t s, anime_t opts);
    __attribute__((overloadable)) $& animate(float ms, style_t s, anime_end_f onEnd, anime_t opts);
    __attribute__((overloadable)) $& animate(float ms, style_t s, str_t svgpath, anime_end_f onEnd, anime_t opts);
    __attribute__((overloadable)) $& animate(float ms, anime_step_f onStep, anime_end_f onEnd, anime_t opts);
    
    __attribute__((overloadable)) $& operator>>($& p);   //insert into super
    __attribute__((overloadable)) $& operator>>(view_base_t p);  //insert into super
    __attribute__((overloadable)) $& operator<<($& p);   // append child
    
    __attribute__((overloadable)) $& operator>($& p);   //insert layer into super
    __attribute__((overloadable)) $& operator<($& p);   //append layer
    
    $* operator[](int idx);//get child
    
    rect_t  rect();
    
    obj_t get(str_t key);
    float getFloat(str_t key);
    int   getInt(str_t key);
    bool  getBool(str_t key);
    __attribute__((overloadable))
    $&    set(str_t key, id value);
    __attribute__((overloadable))
    $&    set(dic_t d);
    $&    del(obj_t key);
    $*    root();
    
    void switchEditingMode();
    
    __attribute__((overloadable)) $& setPickable(arr_t opts);
    __attribute__((overloadable)) $& setPickable(date_t date, str_t labelFormat);
    
    __attribute__((overloadable)) $& setEditable(BOOL editable);
    __attribute__((overloadable)) $& setEditable(BOOL editable, TextEditOnInitHandler startEdit);
    __attribute__((overloadable)) $& scrollSize(float x, float y);
    __attribute__((overloadable)) vec2 scrollSize();
    $& scrollTo(float x, float y);
    vec2 scrollPos();
    $& scrollTop(float topMargin);
    $& scrollBack();
    
    void remove();
    value_t  encode();
protected:
    const int view_id;
    bool released;
};
typedef $* node_t;

#pragma mark - controller

class controller_t : public ${
public:
    controller_t();
    __attribute__((overloadable)) void present(effect_in_t instyle, anime_t animeOpts);
    __attribute__((overloadable)) void present(effect_in_t instyle, anime_end_f onEnd, anime_t animeOpts);
    __attribute__((overloadable)) void present(style_t from, style_t to, anime_t animeOpts);
    __attribute__((overloadable)) void present(style_t from, style_t to, anime_end_f onEnd, anime_t animeOpts);
    void dismiss(effect_out_t outstyle, anime_end_f onEnd, anime_t animeOpts);
    
    __attribute__((overloadable)) void show(dic_t params);
    
    __attribute__((overloadable)) virtual void ondraw(dic_t params);
    __attribute__((overloadable)) virtual void onpresented();
    virtual void onbackground();
    virtual void onforeground();
    void clearAll();
    virtual str_t name();
//private:
//    str_t lastCtlName;
};

#pragma mark - animation deltas

typedef float delta_f(float);
float delta_linear(float progress);
float delta_quad(float progress);
float delta_quad5(float progress);
float delta_circ(float progress);
float delta_back(float progress);
float delta_bounce(float progress);
float delta_elastic(float progress);
extern std::map<anime_delta_t, delta_f*> delta_funcs;

float style_easeIn(anime_delta_t deltatype, float progress);
float style_easeOut(anime_delta_t deltatype, float progress);
float style_easeInOut(anime_delta_t deltatype, float progress);
typedef float style_f(anime_delta_t, float);
extern std::map<anime_style_t, style_f*> style_funcs;


#pragma mark - c++ wrapper

//view
void screensize();
bool is_view(obj_t v);
bool is_shape_layer(obj_t v);
bool is_textview(obj_t v);
view_t  view_init(rect_t rect);
layer_t layer_init(rect_t rect);
__attribute__((overloadable)) $& $id(str_t _ID);
__attribute__((overloadable)) $& $id(str_t _ID, str_t ctrlName);


//obj
void decode(value_t v, void* o);//read value and set to struct pointer

//numbers
__attribute__((overloadable))float   numf(num_t n);
__attribute__((overloadable))float   numf(num_t n, float defaultValue);
__attribute__((overloadable))int     numi(num_t n);
__attribute__((overloadable))int     numi(num_t n, float defaultValue);
__attribute__((overloadable))bool    numb(num_t n);
__attribute__((overloadable))bool    numb(num_t n, float defaultValue);

//dic
mdic_t mdic(dic_t d);
void mdic_add(mdic_t d, str_t key, obj_t value);
void mdic_remove(mdic_t d, str_t key);
bool is_dic(obj_t o);
//TODO dic_keys
//TODO dic_vals

//arr
marr_t marr(arr_t a);
void marr_add(marr_t a, obj_t value);
void marr_remove(marr_t a, int idx);
int  arr_size(arr_t a);
bool is_arr(obj_t o);
str_t arr_join(arr_t a, str_t connector);
//TODO arr_map

//str
bool str_eq(str_t s1, str_t s2);
bool str_starts(str_t s1, str_t s2);
bool str_ends(str_t s1, str_t s2);
bool str_has(str_t s1, str_t s2);
bool str_matchs(str_t s, str_t regexp);
arr_t str_split(str_t s, str_t spliter);
str_t str_replace(str_t s, str_t target,  str_t replace);
str_t str_regex_replace(str_t s, str_t regex,  str_t replace);
int   str2i(str_t s);
float str2f(str_t s);
bool  is_str(obj_t o);
int   str_idx(str_t s, str_t target);
const char * cstr(str_t s);
str_t str(const char * s);
str_t sprintf(str_t format,...);
//TODO style_t str2styles(const char * s);

//path
value_t path2value(path_t path);

//color
str_t   dec2hex(int dec, int bits);
color_t str2color(str_t s);
str_t   color2str(color_t color);
color_t color_transparent();
color_t rgba2color(rgba_t c);
str_t   rgba2str(rgba_t rgba);
rgba_t    str2rgba(str_t hex);
rgba_t color2rgba(color_t c);
bool rgba_empty(rgba_t o);
bool rgba_equals(rgba_t o1, rgba_t o2);
bool is_color(obj_t o);
str_t deltacolor(str_t from, str_t to, float delta);

//svg
arr_t  str2svgcmds(str_t pathcmd);   //return list of <svg_cmd_t>
arr_t  svg_tween(str_t path1, str_t path2,  num_t delta); //return list of <svg_cmd_t>
path_t str2svgpath(str_t pathcmd);   //return path_t
path_t arr2svgpath(arr_t cmds); //return path_t
value_t svgcmd2val(svg_cmd_t cmd);
/*
__attribute__((overloadable)) str_t style2svgpath(style_t s);
__attribute__((overloadable)) str_t style2svgpath(style_t s, num_t xoffset, num_t yoffset);
*/

//border
border_t str2border(str_t bd);
border_t border_init(float w, str_t color, float radius);
str_t    border2str(border_t bd);

//shadow
shadow_t str2shadow(str_t sd);
shadow_t shadow_init(bool inset, float x, float y, float radius, str_t color);
str_t    shadow2str(shadow_t sd);

//rotate
str_t      r3d2str(float degree, float x, float y, float z, int resp, float axisX, float axisY, float transX, float transY);
rotate3d_t str2r3d(str_t r3dstr);

//font
font_t str2font(str_t f);


//time
long long time_ms();
//typedef std::function<void (dic_t)> timeout_h;
typedef void(^timeout_h)(dic_t);
void    set_timeout(float millisec, timeout_h block, dic_t data);
//typedef std::function<bool (dic_t, int)> timeinterval_h;
typedef bool(^timeinterval_h)(dic_t,int);
void    set_interval(float millisec, timeinterval_h block, dic_t dic);

//caches
void    set_data(str_t key_path, obj_t value);
obj_t   get_data(str_t key_path);
bool    has_data(str_t key_path);
str_t   get_str (str_t key_path);
int     get_int (str_t key_path);
float   get_float(str_t key_path);
arr_t   get_arr (str_t key_path);
marr_t  get_marr(str_t key_path);
dic_t   get_dic (str_t key_path);
mdic_t  get_mdic(str_t key_path);
node_t  get_node(str_t key_path);
void    remove_data(str_t key);
void    clear_data();
void    save_data();
void    load_data();


//http
void http_get(str_t url, http_f handler, dic_t args);
void http_post(str_t url, dic_t datas, http_f handler, dic_t args);
void http_put(str_t url, dic_t datas, http_f handler, dic_t args);
void http_delete(str_t url, dic_t datas, http_f handler, dic_t args);


//image
image_t image_read(str_t name);
image_t image_scale(image_t img, vec2 size, int style);
image_t image_color_mix(image_t img, float* matrix, float contrast);
image_t image_blend_color(image_t img, color_t color, int mode);
image_t image_blend_image(image_t img, str_t maskname, float alpha);

#pragma mark - drawing funcs


$& box(style_t s);
$& label(str_t txt, style_t s);
$& glabel(str_t url,label_content_f handler,style_t s); //label with remote text

$& img(obj_t src, style_t s);
$& svgp(str_t cmds, style_t sp);
$& list(arr_t data, list_f handler, style_t listStyle);
$& grids(arr_t data, int cols, grid_f handler, style_t gridsStyle);

__attribute__((overloadable))
$& slide(arr_t data, list_f handler, style_t slideStyle);
__attribute__((overloadable))
$& slide(arr_t data,
         list_f handler,
         bool withPages,
         bool enableVerticalSlide,
         slide_vertical_scroll_f onVerticalScroll,
         slide_vertical_scroll_f onVerticalScrollEnd,
         slide_page_f onPageChanged,//slide to left page or right page
         style_t slideStyle);

#endif /* defined(__LiberObjcExample__Lang__) */
