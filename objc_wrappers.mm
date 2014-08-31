//
//  objc_wrappers.mm
//  LiberObjcExample
//
//  Created by soyoes on 8/17/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#import "liber.h"
#import "objc_categories.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <stdlib.h>
#import <sstream>
#import <string>
#import <regex>
#import <stdarg.h>

using namespace std;

#pragma mark extern

float SH, SW;
mdic_t __datas, __counters, __animes;

#pragma mark - deltas

float delta_linear(float progress){return progress;}
float delta_quad(float progress){return pow(progress, 2);}
float delta_quad5(float progress){return pow(progress, 5);}
float delta_circ(float progress){return 1 - sin(acos(progress));}
float delta_back(float progress){float x=1.5;return pow(progress, 2) * ((x + 1) * progress - x);}
float delta_bounce(float progress){for(float a=0, b=1; 1; a+=b, b/=2) {if(progress >= (7-4*a)/11)return pow(b, 2)-pow((11-6*a-11*progress)/4,2);}}
float delta_elastic(float progress){float x = 0.1;return pow(2, 10 * (progress-1)) * cos(20*M_PI*x/3*progress);}

std::map<anime_delta_t, delta_f*> delta_funcs = {
    {kDeltaLinear,delta_linear},
    //accelerator2x     :o > >> >>> >>>> >>>>>
    {kDeltaQuad,delta_quad},
    //accelerator5x     :o > >>> >>>>> >>>>>>> >>>>>>>>>>>
    {kDeltaQuad5,delta_quad5},
    //throwing          :o >> > ... > >> >>> >>>>
    {kDeltaCirc,delta_circ},
    //bow - arrow       :<< < o > >> >>> >>>>
    {kDeltaBack,delta_back},
    //bounce            :< > < > < > o > >> >>> >>>>
    {kDeltaBounce,delta_bounce},
    //elastic           :< > << >> <<< >>> o > >> >>> >>>>
    {kDeltaElastic,delta_elastic},
};

float style_easeIn(anime_delta_t deltatype, float progress){
    delta_f* func = delta_funcs[deltatype];
    //return pow(func(progress),2);
    return func(progress);
}
float style_easeOut(anime_delta_t deltatype, float progress){
    delta_f* func = delta_funcs[deltatype];
    return 1-func(1-progress);
}
float style_easeInOut(anime_delta_t deltatype, float progress){
    delta_f* func = delta_funcs[deltatype];
    return (progress<=0.5) ? func(2*progress)/2 : (2-func(2*(1-progress)))/2;
}
std::map<anime_style_t, style_f*> style_funcs = {
    {kEaseIn,style_easeIn},
    // reverse
    {kEaseOut,style_easeOut},
    // repeat 0~50% and reverse.
    {kEaseInOut,style_easeInOut}
};

/*
 get view by ID
 */
__attribute__((overloadable)) $& $id(str_t _ID, str_t ctrlerName){
    if(__nodes && __nodes[ctrlerName] && __nodes[ctrlerName][_ID]){
        view_t v = __nodes[ctrlerName][_ID];
        return *v.owner;
    }
    static $ dummy;
    return dummy;
}
__attribute__((overloadable)) $& $id(str_t _ID){
    return $id(_ID,__controller);
}


#pragma mark - view

void screensize(){if(!SW){
    CGSize s =[[UIScreen mainScreen] bounds].size;
    SW = s.width, SH = s.height;
}}

bool is_view(obj_t v){
    return v && [v isKindOfClass:[view_cls class]];
}
bool is_shape_layer(obj_t v){
    return v && [v isKindOfClass:[shape_layer_cls class]];
}
bool is_textview(obj_t v){
    return v && [v isKindOfClass:[textview_cls class]];
}

view_t  view_init(rect_t rect){
    return [[view_cls alloc] initWithFrame:{rect.x,rect.y,rect.w,rect.h}];
}
layer_t layer_init(rect_t rect){
    layer_t l = [layer_cls layer];
    l.frame = {rect.x,rect.y,rect.w,rect.h};
    return l;
}

//obj
void decode(value_t v, void* o){
    if(v) [v getValue:o];
}

//numbers
float   numf(num_t n){return n?[n floatValue]:0;}
float   numf(num_t n, float defaultValue){return n?[n floatValue]:defaultValue;}
int     numi(num_t n){return n?[n intValue]:0;}
int     numi(num_t n, float defaultValue){return n?[n intValue]:defaultValue;}
bool    numb(num_t n){return n?[n boolValue]:false;}
bool    numb(num_t n, float defaultValue){return n?[n boolValue]:defaultValue;}


#pragma mark lang

//dic

mdic_t mdic(dic_t d){
    return d? [[NSMutableDictionary alloc] initWithDictionary:d]:[[NSMutableDictionary alloc] init];
}
void mdic_add(mdic_t d, str_t key, obj_t value){
    if (d && key && value) d[key] = value;
}
void mdic_remove(mdic_t d, str_t key){
    if (d && key) [d removeObjectForKey:key];
}
bool is_dic(obj_t o){
    return o&&[o isKindOfClass:[NSDictionary class]];
}


//array

marr_t marr(arr_t a){
    return a?[[NSMutableArray alloc] initWithArray:a]:[[NSMutableArray alloc] init];
}
void marr_add(marr_t a, obj_t value){
    if(a && value) [a addObject:value];
}
void marr_remove(marr_t a, int idx){
    if(a && idx>=0 && idx<[a count]) [a removeObjectAtIndex:idx];
}
int arr_size(arr_t a){return a!=nil?(int)[a count]:0;}
bool is_arr(obj_t o){
    return o&&[o isKindOfClass:[NSArray class]];
}
str_t arr_join(arr_t a, str_t connector){
    return (a)? [a componentsJoinedByString:connector?connector:@""]:@"";
}
//string

bool str_eq(str_t s1, str_t s2){return s1&&s2&&[s1 isEqualToString:s2];}

bool str_starts(str_t s1, str_t s2){
    return s1&&s2&&[s1 hasPrefix:s2];
}
bool str_ends(str_t s1, str_t s2){
    return s1&&s2&&[s1 hasSuffix:s2];
}
bool str_has(str_t s1, str_t s2){
    return s1&&s2&&[s1 contains:s2];
}
bool str_matchs(str_t s, str_t regexp){
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexp options:0 error:NULL];
    return [regex firstMatchInString:s options:0 range:NSMakeRange(0, [s length])]!=nil;
}
arr_t str_split(str_t s, str_t spliter){
    return [s componentsSeparatedByString:spliter];
}
str_t str_replace(str_t s, str_t target,  str_t replace){
    return [s stringByReplacingOccurrencesOfString:target withString:replace];
}
str_t str_regex_replace(str_t s, str_t regex,  str_t replace){
    return [s regexpReplace:regex replace:replace];
}
int str2i(str_t s){
    return s?[s intValue]:0;
}
float str2f(str_t s){
    return s?[s floatValue]:0;
}
num_t str2numf(str_t s) {
    if ([s isInt])   return [NSNumber numberWithFloat: [s integerValue]];
    else if ([s isFloat]) return [NSNumber numberWithFloat: [s floatValue]];
    return nil;
}
int str_idx(str_t s, str_t t){
    return [s indexOf:t];
}

bool is_str(obj_t o){
    return o&&[o isKindOfClass:[NSString class]];
}

str_t str(const char * cs){return cs?
    [NSString stringWithCString:cs encoding:NSASCIIStringEncoding]:nil;
}

const char * cstr(str_t cs){
    return [cs cStringUsingEncoding:NSASCIIStringEncoding];
}

str_t sprintf(str_t format,...){
    str_t res;
    va_list arguments;
    va_start(arguments, format);
    va_list argsCopy;
    va_copy(argsCopy, arguments);
    res = [[NSString alloc] initWithFormat:format arguments:argsCopy];
    va_end(argsCopy);
    va_end(arguments);
    return res;
}

//color

str_t dec2hex(int dec, int bits){
    ostringstream ss;
    ss<< std::hex << dec;
    string st = ss.str();
    while(st.length()<bits)
        st = "0"+st;
    return [NSString stringWithCString:st.c_str() encoding:NSASCIIStringEncoding];
}

color_t str2color(str_t s){
    return [s colorValue];
}
str_t color2str(color_t color){
    rgba_t rgba = color2rgba(color);
    return rgba2str(rgba);
}
color_t color_transparent(){return [UIColor clearColor];}
color_t rgba2color(rgba_t c){
    return [UIColor colorWithRed:c.r green:c.g blue:c.b alpha:c.a];
}
str_t rgba2str(rgba_t rgba){
    return sprintf(@"#%@%@%@%@",dec2hex(rgba.r*255,2),dec2hex(rgba.g*255,2),dec2hex(rgba.b*255,2),dec2hex(rgba.a*255,2));
}
rgba_t str2rgba(str_t hex){
    color_t cl = [hex colorValue];
    return color2rgba(cl);
}
rgba_t color2rgba(color_t cl){
    CGFloat r,g,b,a;
    [cl getRed:&r green:&g blue:&b alpha:&a];
    return {(float)r,(float)g,(float)b,(float)a};
}
bool rgba_empty(rgba_t o){
    return o.r==0&&o.g==0&&o.b==0&&o.a==0;
}
bool rgba_equals(rgba_t o1, rgba_t o2){
    return o1.r==o2.r&&o1.g==o2.g&&o1.b==o2.b&&o1.a==o2.a;
}
bool is_color(obj_t o){
    return o&&[o isKindOfClass:[UIColor class]];
}
str_t deltacolor(str_t from, str_t to, float delta){
    rgba_t o = str2rgba(from);
    rgba_t t = str2rgba(to);
    rgba_t r = {(o.r+(t.r-o.r)*delta), (o.g+(t.g-o.g)*delta), (o.b+(t.b-o.b)*delta), (o.a+(t.a-o.a)*delta)};
    return rgba2str(r);
}


// SVG
arr_t str2svgcmds(str_t pathcmd){
    string svgpath(cstr(pathcmd));
    svgpath = regex_replace(svgpath, regex("[\\s+,]"), " ");
    svgpath = regex_replace(svgpath, regex("([A-Z])\\s+"), "$1");
    smatch m;
    regex e("\\b[MLCSQTAZ]*[\\d\\.]*\\b");
    //vector<svg_cmd_t> cmds;
    marr_t cmds = marr(nil);
    svg_cmd_t cmd=(svg_cmd_t){};
    int cidx = 0;
    while (regex_search(svgpath,m,e)) {
        string o = m[0];
        char pref = o.at(0);
        if(pref>='A' && pref<'Z'){//CMD
            if(cmd.cmd){
                marr_add(cmds, svgcmd2val(cmd));
                cmd = {};
                cidx = 0;
            }
            cmd.cmd = pref;
            cmd.coords[cidx++]=atof(o.substr(1).c_str());
        }else if(pref=='Z'){//VALUE
            marr_add(cmds, svgcmd2val(cmd));
            marr_add(cmds, svgcmd2val((svg_cmd_t){'Z'}));
            break;
        }else{
            cmd.coords[cidx++]=atof(o.c_str());
        }
        svgpath = m.suffix().str();
    }
    return cmds;
}
arr_t svg_tween(str_t path1, str_t path2,  num_t delta){
    arr_t cs1 = str2svgcmds(path1);
    arr_t cs2 = str2svgcmds(path2);
    marr_t cs = marr(nil);
    
    int size_min = MIN(arr_size(cs1),arr_size(cs2));
    int size_max = MAX(arr_size(cs1),arr_size(cs2));
    for (int i=0; i<size_min; i++) {
        svg_cmd_t  c1,c2,c;
        decode(cs1[i],&c1);
        decode(cs2[i],&c2);
        decode(cs1[i],&c);
        for (int j=0; j<6; j++) {
            float cf1 = c1.coords[j]?c1.coords[j]:0,
            cf2 = c2.coords[j]?c2.coords[j]:0;
            if(cf1!=cf2) c.coords[j] = cf1 + (cf2-cf1)*numf(delta);
        }
        c.cmd = c2.cmd;
        marr_add(cs, svgcmd2val(c));
    }
    if(size_max!=size_min){
        arr_t cx = arr_size(cs1)>arr_size(cs2)? cs1:cs2;
        for (int i=size_min; i<size_max; i++) {
            marr_add(cs, cx[i]);
        }
    }
    return cs;
}
path_t str2svgpath(str_t pathcmd){
    arr_t cmds = str2svgcmds(pathcmd);
    return arr2svgpath(cmds);
}

path_t arr2svgpath(arr_t cmds){
    CGMutablePathRef path = CGPathCreateMutable();
    for (value_t cmd in cmds) {
        svg_cmd_t c;
        decode(cmd, &c);
        switch (c.cmd) {
            case 'M':
                CGPathMoveToPoint(path, NULL, c.coords[0], c.coords[1]);
                break;
            case 'L':
                CGPathAddLineToPoint(path, NULL, c.coords[0], c.coords[1]);
                break;
            case 'C':
                CGPathAddCurveToPoint(path, NULL, c.coords[0], c.coords[1], c.coords[2], c.coords[3], c.coords[4], c.coords[5]);
                break;
            case 'Q':
                CGPathAddQuadCurveToPoint(path, NULL, c.coords[0], c.coords[1],c.coords[2], c.coords[3]);
                break;
            case 'A':
                CGPathAddArcToPoint(path, NULL, c.coords[0], c.coords[1], c.coords[2], c.coords[3], c.coords[4]);
                break;
            case 'Z':
                CGPathCloseSubpath(path);
                break;
            default:
                break;
        }
    }
    return path;
}
value_t svgcmd2val(svg_cmd_t cmd){
    return [NSValue value:&cmd withObjCType:@encode(svg_cmd_t)];
}

//font
font_t str2font(str_t f){
    if(!f)
        return [UIFont systemFontOfSize:14];
    f = str_regex_replace(f, @"\\s+", @"");
    arr_t parts = str_split(f, @",");
    str_t fname = parts[0];
    float fsize = (arr_size(parts)>1) ? str2f(parts[1]):14;
    return [UIFont fontWithName:fname size:fsize];
}

//border
border_t str2border(str_t bd){
    return [border_cls border:bd];
}
border_t border_init(float w, str_t color, float radius){
    return [border_cls border:w color:color radius:radius];
}
str_t border2str(border_t bd){return bd? [bd toString]:nil;}

//shadow
shadow_t str2shadow(str_t sd){
    return [shadow_cls shadow:sd];
}
shadow_t shadow_init(bool inset, float x, float y, float radius, str_t color){
    return [shadow_cls shadow:inset x:x y:y radius:radius color:color];
}
str_t shadow2str(shadow_t sd){return sd? [sd toString]:nil;}

//rotate 3d
str_t r3d2str(float degree, float x, float y, float z, int resp, float axisX, float axisY, float transX, float transY){
    return sprintf(@"%f,%f,%f,%f,%d,%f,%f,%f,%f,0", degree, x, y,z,resp, axisX, axisY, transX, transY);
}
rotate3d_t str2r3d(str_t r3dstr){
    //degree, rotateX, rotateY, rotateZ, respective, anchorX, anchorY, translateX, translateY, translateZ
    float p[] = {0,0,0,0,500,0.5,0.5,0,0,0};
    r3dstr = str_regex_replace(r3dstr, @"\\s*,\\s*", @",");
    arr_t ps = str_split(r3dstr, @",");
    int i = 0;
    for(str_t s in ps)
        if(i<10) p[i++] = str2f(s);
    return {p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9]};
}

//anime_t
dic_t anime2dic(anime_t a){
    return @{@"delta":@(a.delta),@"delay":@(a.delay),@"style":@(a.style)};
}
anime_t dic2anime(dic_t d){
    return {(anime_delta_t)numi(d[@"delta"]), (anime_style_t)numi(d[@"style"]), numi(d[@"delay"])};
}


#pragma mark time functions

void set_interval(float millisec, timeinterval_h block, dic_t dic);

long long time_ms(){
    return (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
}
void set_timeout(float millisec, timeout_h block, dic_t dic){
    dispatch_time_t span = dispatch_time(DISPATCH_TIME_NOW, millisec*0.001f * NSEC_PER_SEC);
    dispatch_after(span, dispatch_get_main_queue(), ^(void){
        block(dic);
    });
}

/**
 @exmample
 $& __block ico = $ico(@"train",{0,30}) >> self.view;
 set_interval(40, ^BOOL(NSDictionary*d, int i){
 ico.view.center = CGPointMake(i*10, 30);   //move this ico
 return (i>100) ? NO:YES; // exec for 100 times.
 }, @{});
 
 FIXME : make new objc class TimeTask, the current one is not safe
 
 */
void set_interval(float millisec, timeinterval_h block, dic_t dic){
    if(!__animes) __animes=mdic(nil);
    //value_t nv = [NSValue valueWithBytes:&block objCType:@encode(timeinterval_h)];
    id nv = [block copy];
    if(!__animes[nv])
        __animes[nv]=@0;
    dispatch_time_t span = dispatch_time(DISPATCH_TIME_NOW, millisec*0.001f * NSEC_PER_SEC);
    dispatch_after(span, dispatch_get_main_queue(), ^(void){
        int counter = [__animes[nv] intValue];
        if(block(dic, counter++)) {
            set_interval(millisec, block, dic);
            __animes[nv] = @(counter);
        }else {
            [__animes removeObjectForKey:nv];
        }
    });
}



#pragma mark data & cache

void set_data(str_t key_path, obj_t value){
    if(__datas==nil) load_data();
    [__datas setValue:value forKeyPath:key_path];
}
obj_t get_data(str_t key_path){
    if(__datas==nil) load_data();
    return [__datas valueForKeyPath:key_path];
}
bool has_data(str_t key_path){
    if(__datas==nil) load_data();
    return [__datas valueForKeyPath:key_path]!=nil;
}
str_t get_str (str_t key_path){
    id v = get_data(key_path);
    return v?(str_t)v:nil;
}
int get_int (str_t key_path){
    id v = get_data(key_path);
    return v!=nil? [(num_t)v intValue]:0;
}
float   get_float(str_t key_path){
    id v = get_data(key_path);
    return v!=nil? [(num_t)v floatValue]:0;
}
arr_t   get_arr (str_t key_path){
    id v = get_data(key_path);
    return (arr_t)v;
}
marr_t  get_marr(str_t key_path){
    id v = get_data(key_path);
    return v?(marr_t)v:nil;
}
dic_t   get_dic (str_t key_path){
    id v = get_data(key_path);
    return v?(dic_t)v:nil;
}
mdic_t  get_mdic(str_t key_path){
    id v = get_data(key_path);
    return v?(mdic_t)v:nil;
}
node_t  get_node(str_t key_path){
    id v = get_data(key_path);
    return v?(node_t)[v pointerValue]:nullptr;
}

void remove_data(str_t key){
    if(__datas==nil)return;
    [__datas removeObjectForKey:key];
}
void clear_data(){
    if(__datas==nil)return;
    [__datas removeAllObjects];
}
void save_data(){
    #ifdef DATA_FILE_NAME
    if(__datas!=nil)
        [__datas writeToFile:[NSString stringWithUTF8String:DATA_FILE_NAME] atomically:YES];
    #endif
}
void load_data(){
    #ifdef DATA_FILE_NAME
        arr_t paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        str_t docDir = [paths objectAtIndex:0];
        str_t fpath = [docDir stringByAppendingPathComponent:[NSString stringWithUTF8String:DATA_FILE_NAME]];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:fpath]){
            __datas = [[NSMutableDictionary alloc] initWithContentsOfFile:fpath];
        }else{
            __datas = [[NSMutableDictionary alloc] init];
        }
    #else
        __datas = [[NSMutableDictionary alloc] init];
    #endif
}

image_t image_read(str_t name){return name?[UIImage imageNamed:name]:nil;}

image_t image_scale(image_t img, vec2 size, int style){
    return [img imageByScale:CGSizeMake(size.x, size.y) style:style];
}

image_t image_color_mix(image_t img, float* matrix,float contrast){
    return [img colorMix:(float[3][3]){{matrix[0],matrix[1],matrix[2]},{matrix[3],matrix[4],matrix[5]},{matrix[6],matrix[7],matrix[8]}} contrast:contrast];
}

image_t image_blend_color(image_t img, color_t color,int mode){
    return [img imageWithBlendColor:color mode:(CGBlendMode)mode];
}

image_t image_blend_image(image_t img, str_t mask,float alpha){
    return [img imageWithBlendImage:mask alpha:alpha];
}


//http
void http_get(str_t url, HTTPRequestHandler handler, dic_t args){
    [HTTPRequest call:@"GET" url:url datas:nil handler:handler args:args];
}
void http_post(str_t url, dic_t datas, HTTPRequestHandler handler, dic_t args){
    [HTTPRequest call:@"POST" url:url datas:nil handler:handler args:args];
}
void http_put(str_t url, dic_t datas, HTTPRequestHandler handler, dic_t args){
    [HTTPRequest call:@"PUT" url:url datas:nil handler:handler args:args];
}
void http_delete(str_t url, dic_t datas, HTTPRequestHandler handler, dic_t args){
    [HTTPRequest call:@"DELETE" url:url datas:datas handler:handler args:args];
}


#pragma mark - drawing funcs

$& box(style_t s){return (new $())->setStyle(s);}

$& label(str_t txt, style_t s){return (new $())->setStyle(s).text(txt);}

$& glabel(str_t url,label_content_f handler,style_t s){
    $* v = new $;
    v->setStyle(s);
    if(url){
        dispatch_async(dispatch_get_main_queue(), ^{
            http_get(url, ^void(id res, NSDictionary *params) {
                NSString * str = handler(res);
                $* v = ($*) [params[@"view"] pointerValue];
                v->text(str);
            }, @{@"view":[NSValue valueWithPointer:v]});
        });
    }else{
        v->text(handler(nil));
    }
    return *v;
}

$& img(obj_t src, style_t s){return (new $())->setStyle(s).image(src);};

$& svgp(str_t cmds, style_t s){s.path = cmds;return (new $())->setStyle(s);}

$& list(arr_t data, list_f handler, style_t listStyle){
    if(data && handler){
        int i = 0;
        //listStyle.scrollable = @(YES);
        $& ul = box(listStyle);
        ul.view().clipsToBounds = YES;
        float maxX = 0, maxY = 0;
        for (id item in data){
            $& it = handler(item, i++) >> ul;
            maxX = MAX(maxX, (it.x()+it.w()));
            maxY = MAX(maxY, (it.y()+it.h()));
        }
        ul.scrollSize(maxX, maxY);
        return ul;
    }
    return box(listStyle);
}


$& slide(arr_t data, list_f handler, style_t slideStyle){return slide(data, handler,true,false,nil,nil,nil,slideStyle);}
$& slide(arr_t data,
         list_f handler,
         bool withPages,
         bool enableVerticalSlide,
         slide_vertical_scroll_f onVerticalScroll,
         slide_vertical_scroll_f onVerticalScrollEnd,
         slide_page_f onPageChanged,
         style_t slideStyle){
    
    //slideStyle.scrollable = @(YES);
    if(!data || !handler)return box(slideStyle);
    int i = 0;

    $& b = box(slideStyle);
    view_t v = b.view();
    v.slidable = true;
    v.slideWithPages = withPages;
    v.clipsToBounds = YES;
    v.slides = marr(nil);
    //std::array<$&, 5> slides;
    for (obj_t item in data){
        $& pg = handler(item, i++);
        pg >> b;
        marr_add(v.slides, pg.encode());
    }
    
    //add scroll event
    b.bind(@"pan", ^(ges_t g, $& n, dic_t p) {
        if(n.getInt(@"_sliding"))return;
        view_t v = n.view();
        //[g requireGestureRecognizerToFail:v.view.panGestureRecognizer];
        CGPoint coords = [g locationInView:v.superview];
        float orgX = n.getFloat(@"_slideOrgX");
        float orgY = n.getFloat(@"_slideOrgY");
        int   lastPage = n.getInt(@"_slideLastPage");
        float w = v.bounds.size.width;
        float factor = 2.0f;
        if(g.state == UIGestureRecognizerStateEnded){
            float dis = orgX>coords.x?orgX-coords.x:coords.x-orgX;
            int page = lastPage;
            float diss;
            int speed=100;
            slide_page_f onPageChanged = p[@"_slidePageChanged"];
            
            bool directionVertical = n.getBool(@"_slideDirectionVertical");
            
            if(directionVertical){
                //TODO call callback. etc. get next page.
                if(onVerticalScrollEnd){
                    NSValue* pva = v.slides[lastPage];
                    $* pv = ($*)[pva pointerValue];
                    onVerticalScrollEnd(*pv, lastPage, n.getFloat(@"_slideOrgContentY"), pv->view().contentOffset.y);
                }
                n.del(@[@"_sliding",@"_slideDis",@"_slideStart",@"_slideOrgX",@"_slideOrgY",@"_slideOrgContentY",@"_slideDirectionVertical",@"_slideDirectionDecided"]);
                return;
            }
            
            anime_step_f sh = ^($ & vv, float d) {
                float start = vv.getFloat(@"_slideStart");
                float ds = vv.getFloat(@"_slideDis");
                vv.scrollTo(start+ds*d,0);
            };
            anime_end_f se =^($ & nn) {
                int p = nn.getInt(@"_slideLastPage");
                nn.scrollTo(p*w,0);
                nn.del(@[@"_sliding",@"_slideDis",@"_slideStart",@"_slideOrgX",@"_slideOrgY",@"_slideOrgContentY",@"_slideDirectionVertical",@"_slideDirectionDecided"]);
                view_t vv = n.view();
                if(vv.slideWithPages && vv.pages){
                    if(vv.pages.text){
                        [vv.pages setText:sprintf(@"(%d/%d)",p+1,(int)[vv.nodes count])];
                    }else{
                        for (int i=0; i<[vv.nodes count]; i++)
                            (*vv.pages.owner)[i]->setStyle({.bgcolor=@"#ffffff66"});
                        (*vv.pages.owner)[p]->setStyle({.bgcolor=@"#ffffffcc"});
                    }
                }
                
            };
            
            if(dis*factor>w/4){ //move to the next page.
                page += orgX>coords.x? 1:-1;
                page = MIN((int)[v.nodes count]-1,MAX(page, 0));
                diss =page*w-v.contentOffset.x;
            }else{//move to the previous page.
                if(!page) page = 0;
                diss =dis*((orgX>coords.x)?-1:1)*factor;
            }
            if(onPageChanged)
                onPageChanged(n,page);
            
            n.set(@"_sliding", @(1))
            .set(@"_slideStart",@(n.scrollPos().x))
            .set(@"_slideDis",@(diss))
            .set(@"_slideLastPage", @(page))
            .animate(speed, sh, se, {});
        }else{
            bool vert = [p[@"_slideVerticalOK"] boolValue];
            bool directionDecided = n.getBool(@"_slideDirectionDecided");
            if(!orgX){
                n.set(@"_slideOrgX", @(coords.x));
                n.set(@"_slideOrgY", @(coords.y));
                if(vert){
                    int pa = n.getInt(@"_slideLastPage");
                    view_t pv = v.slides[pa];
//                    view_t pv;
//                    decode(v.slides[pa], &pv);
                    if(pv){//FIXME  && pv.scrollable
                        n.set(@"_slideOrgContentY", @(pv.contentOffset.y));
                    }
                }
            }else{
                if(vert){
                    bool directionVertical;
                    if(!directionDecided){
                        directionVertical = (ABS(coords.y-orgY) > 3* ABS(coords.x-orgX));
                        n.set(@"_slideDirectionVertical", @(directionVertical));
                        n.set(@"_slideDirectionDecided", @(true));
                    }else{
                        directionVertical = n.getBool(@"_slideDirectionVertical");
                    }
                    
                    if(directionVertical){
                        int pa = n.getInt(@"_slideLastPage");
                        view_t pv = v.slides[pa];
                        if(pv){// && pv->scrollable
                            float orgCY = n.getFloat(@"_slideOrgContentY");
                            // cout << "scroll y = " << orgCY-(coords.y-orgY) << endl;
                            pv.contentOffset = {0,orgCY-(coords.y-orgY)};
                            if(onVerticalScroll)
                                onVerticalScroll(*pv.owner, pa, orgCY, orgCY-(coords.y-orgY));
                        }
                    }else{
                        v.contentOffset ={lastPage*w-(coords.x-orgX)*factor,0};
                    }
                }else{
                    v.contentOffset ={lastPage*w-(coords.x-orgX)*factor,0};
                }
            }
        }
    }, @{@"_slideVerticalOK":@(enableVerticalSlide), @"_slidePageChanged":onPageChanged ? onPageChanged : ^($&v,int page){} });
    return b;
}

$& grids(arr_t data, int cols, grid_f handler, style_t gridsStyle){
    //gridsStyle.scrollable = @(YES);
    if(data && handler){
        int i = 0;
        $& ul = box(gridsStyle);
        for (id item in data){
            int row = floor(i/cols);
            int col = i%cols;
            //TODO dispatch async
            ul << handler(item, row, col);
            i++;
        }
        return ul;
    }
    return box(gridsStyle);
}
