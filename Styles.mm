//
//  Styles.mm
//  LiberObjcExample
//
//  Created by Yu Song on 8/3/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#import "Styles.h"
#import "Lang.h"
#import <string>
#import <vector>
#import <regex>
#import <map>
#import <iostream>

#import <objc/runtime.h>

using namespace std;

@implementation BorderDef
+ (BorderDef *) border:(const char* )bd{
    BorderDef *def = [[BorderDef alloc] init];
    def.color = {1,1,1,0};
    def.type = m_SOLID;
    string border(bd);
    border = regex_replace(border,regex("\\s+")," ");
    vector<string> parts = splitx(border, regex("\\s+"));
    int size = parts.size();
    if(size==0)return def;
    
    if(regex_match(parts[0],regex("[0-9\\.]+")))
        def.width =stof(parts[0]);
    
    for (int i=1; i<size; i++) {
        const char * cst = parts[i].c_str();
        if(strhas(cst, "#")){
            def.color = rgbaf(cst);
        }else if(strhas(cst, ".png")||strhas(cst, ".jpg")){
            def.image = [UIImage imageNamed:str(cst)];
            def.color = rgba_default;
        }else if(parts[i].compare("solid")==0){
            def.type = m_SOLID;
        }else if(parts[i].compare("dashed")==0){
            def.type = m_DASHED;
        }else if(parts[i].compare("dotted")==0){
            def.type = m_DOTTED;
        }else if(regex_match(parts[i],regex("[0-9\\.]+"))){
            def.radius = stof(parts[i]);
        }
    }
    return def;
}
+ (BorderDef *) border:(float)w type:(int)t color:(const char* )c radius:(float)r{
    BorderDef *def = [[BorderDef alloc] init];
    def.width = w;
    def.type = t;
    def.radius = r;
    if(strhas(c, "#")){
        def.color = rgbaf(c);
    }else{
        def.image = [UIImage imageNamed:str(c)];
        def.color = rgba_default;
    }
    return def;
}
- (const char *) toString{
    NSString * snames[4] = {@"",@" solid",@" dashed",@" dotted"};
    NSString *ststr = snames[(int)self.type];
    return cstr([NSString stringWithFormat:@"%f%@ %@ %f",self.width,ststr,str(colorfstr(self.color.r,self.color.g,self.color.b,self.color.a)),self.radius]);
}
@end
@implementation ShadowDef
+ (ShadowDef *) shadow:(const char* )sd{
    ShadowDef *def = [[ShadowDef alloc] init];
    if(!sd)return def;
    string shad(sd);
    
    string p[5] = {};
    shad = regex_replace(shad, regex("\\s+"), ",");
    int start = 0, end = 0, i=0;
    do {
        end = (int)shad.find(',', start);
        if(end<0)break;
        p[i++] =shad.substr(start, end - start);
        start = end + 1;
    }while(end != string::npos && i<=5);
    p[i++] =shad.substr(start, shad.length() - start);
    
    if (p[0].compare("inset")==0) {
        def.inset = true;
        def.x = stof(p[1]);
        def.y = stof(p[2]);
        def.radius = stof(p[3]);
        def.color = rgbaf(p[4].c_str());
    }else{
        def.x = stof(p[0]);
        def.y = stof(p[1]);
        def.radius = stof(p[2]);
        def.color = rgbaf(p[3].c_str());
    }
    return def;
}
+ (ShadowDef *) shadow:(bool)inset x:(float)x y:(float)y radius:(float)r color:(const char* )c{
    ShadowDef *def = [[ShadowDef alloc] init];
    def.inset = inset;
    def.x = x;
    def.y = y;
    def.radius = r;
    def.color = rgbaf(c);
    return def;
}
- (const char *) toString{
    return cstr([NSString stringWithFormat:@"%@%f %f %f %@",self.inset?@"inset ":@"",self.x,self.y,self.radius,str(colorfstr(self.color.r,self.color.g,self.color.b,self.color.a))]);
}
@end
@implementation StyleDef
+(StyleDef*)style:(Styles)s{
    StyleDef *def = [[StyleDef alloc] init];
    def.ID = s.ID?s.ID:nil;
    def.x = s.x;
    def.y = s.y;
    def.w = s.w;
    def.h = s.h;
    def.z = s.z;
    
    [def setBorderStyle:s.border];
    [def setShadowStyle:s.shadow];
    
    def.corner = s.cornerRadius;
    def.contentMode = s.contentMode;
    def.alpha = s.alpha;
    def.bgcolor = s.bgcolor?str(s.bgcolor):nil;
    //if(s.bgcolor)
    //cout << "bg=" << s.bgcolor << endl;
    def.color = s.color?str(s.color):nil;
    //if(s.color)
    //cout << "cr=" << s.color << endl;
    
    
    def.scaleX = s.scaleX?s.scaleX:1;
    def.scaleY = s.scaleY?s.scaleY:1;
    def.rotate = s.rotate;
    def.rotate3d = s.rotate3d?str(s.rotate3d):nil;
    
    def.rotate = s.rotate;
    
    [def setFlipStyle:s.flip];
    [def setAlignStyle:s.textAlign];
    
    [def setFontStyle:s.font];
    
    def.nowrap = s.nowrap;
    def.truncate = s.truncate;
    def.editable = s.editable;
    
    def.placeHolder = s.placeHolder? str(s.placeHolder):nil;
    def.path = s.path? str(s.path):nil;
    
    def.paddingLeft = s.paddingLeft?s.paddingLeft:s.padding;
    def.paddingRight = s.paddingRight?s.paddingRight:s.padding;
    def.paddingBottom = s.paddingBottom?s.paddingBottom:s.padding;
    def.paddingTop = s.paddingTop?s.paddingTop:s.padding;
    return def;
}
-(void)setStyles:(Styles)s{
    self.ID = s.ID?s.ID:nil;
    self.x = s.x;
    self.y = s.y;
    self.w = s.w;
    self.h = s.h;
    self.z = s.z;
    
    [self setBorderStyle:s.border];
    [self setShadowStyle:s.shadow];
    
    self.corner = s.cornerRadius;
    self.contentMode = s.contentMode;
    self.alpha = s.alpha;
    self.bgcolor = s.bgcolor?str(s.bgcolor):nil;
    self.color = s.color?str(s.color):nil;
    
    self.scaleX = s.scaleX?s.scaleX:1;
    self.scaleY = s.scaleY?s.scaleY:1;
    self.rotate = s.rotate;
    self.rotate3d = s.rotate3d?str(s.rotate3d):nil;
    
    self.rotate = s.rotate;
    
    [self setFlipStyle:s.flip];
    [self setAlignStyle:s.textAlign];
    
    [self setFontStyle:s.font];
    
    self.nowrap = s.nowrap;
    self.truncate = s.truncate;
    self.editable = s.editable;
    
    self.placeHolder = s.placeHolder? str(s.placeHolder):nil;
    
    self.paddingLeft = s.paddingLeft?s.paddingLeft:s.padding;
    self.paddingRight = s.paddingRight?s.paddingRight:s.padding;
    self.paddingBottom = s.paddingBottom?s.paddingBottom:s.padding;
    self.paddingTop = s.paddingTop?s.paddingTop:s.padding;
    
}

-(void)mergeStyle:(StyleDef*)s{
    Class clazz = [self class];
    u_int count;
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    for (int i = 0; i < count ; i++){
        NSString * f = str( property_getName(properties[i]) );
        id o = [s valueForKey:f];
        if(o) [self setValue:o forKey:f];
    }
    //free(properties);
}

-(StyleDef *)duplicate{
    Class clazz = [self class];
    u_int count;
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    StyleDef * def = [[StyleDef alloc] init];
    for (int i = 0; i < count ; i++){
        NSString * f = str( property_getName(properties[i]) );
        id o = [self valueForKey:f];
        if(o) [def setValue:o forKey:f];
    }
    return def;
}

-(void)setBorderStyle:(const char*)s{
    if(s){
        string border(s);
        if(!self.borders)
            self.borders = [[NSMutableArray alloc] init];
        border = regex_replace(border,regex("\\s+")," ");
        if(strhas(s,",")){
            vector<string> borders = splitx(border,regex(","));
            int size = borders.size();
            for(int i=0;i<size;i++){
                [self.borders addObject:[BorderDef border:borders[i].c_str()]];
            }
        }else{
            [self.borders addObject:[BorderDef border:border.c_str()]];
        }
    }
}
-(void)setShadowStyle:(const char*)s{
    if(s){
        string shadow(s);
        if(!self.shadows)
            self.shadows = [[NSMutableArray alloc] init];
        shadow = regex_replace(shadow,regex("\\s+")," ");
        if(strhas(s,",")){
            vector<string> shadows = splitx(shadow,regex(","));
            int size = shadows.size();
            for(int i=0;i<size;i++){
                [self.shadows addObject:[ShadowDef shadow:shadows[i].c_str()]];
            }
        }else{
            [self.shadows addObject:[ShadowDef shadow:shadow.c_str()]];
        }
    }
}
-(void)setAlignStyle:(const char*)s{
    if(!s) s = "left";
    static std::map<const char*, NSString*> def = {
        {"center",kCAAlignmentCenter},
        {"left",kCAAlignmentLeft},
        {"right",kCAAlignmentRight},
        {"justified",kCAAlignmentJustified},
        {"natural",kCAAlignmentNatural}
    };
    self.align = def[s];
}
-(void)setFlipStyle:(const char*)s{
    self.flip = m_filpN;
    if(s){
        if(s[0]=='H')self.flip=m_filpH;
        if(s[0]=='V')self.flip=m_filpV;
    }
}
-(void)setFontStyle:(const char*)s{
    self.font = s ? ftopt(s) : [UIFont systemFontOfSize:[UIFont systemFontSize]];
}


@end

#pragma mark styles

__attribute__((overloadable)) Styles style(Styles *custom, Styles *ext){
    
    if(!ext) return *custom;
    
    Styles ss = *ext;
    Styles sc = *custom;
    if(sc.ID) ss.ID = sc.ID;
    if(sc.x) ss.x = sc.x;
    if(sc.y) ss.y = sc.y;
    if(sc.z) ss.z = sc.z;
    if(sc.w) ss.w = sc.w;
    if(sc.h) ss.h = sc.h;
    
    if(sc.border) ss.border = sc.border;
    if(sc.cornerRadius) ss.cornerRadius = sc.cornerRadius;
    
    /*
    if(sc.borderWidth) ss.borderWidth = sc.borderWidth;
    if(sc.borderColor) ss.borderColor = sc.borderColor;
     if(sc.outlineColor) ss.outlineColor = sc.outlineColor;
     if(sc.outline) ss.outline = sc.outline;
     if(sc.outlineSpace) ss.outlineSpace = sc.outlineSpace;
     if(sc.outlineWidth) ss.outlineWidth = sc.outlineWidth;
     */
    if(sc.contentMode) ss.contentMode = sc.contentMode;
    
    if(sc.shadow) ss.shadow = sc.shadow;
    if(sc.alpha) ss.alpha = sc.alpha;
    if(sc.bgcolor) ss.bgcolor = sc.bgcolor;
    
    if(sc.scaleX) ss.scaleX = sc.scaleX;
    if(sc.scaleY) ss.scaleY = sc.scaleY;
    if(sc.rotate) ss.rotate = sc.rotate;
    if(sc.rotate3d) ss.rotate3d = sc.rotate3d;
    if(sc.flip) ss.flip = sc.flip;
    
    if(sc.font) ss.font = sc.font;
    if(sc.fontName) ss.fontName = sc.fontName;
    if(sc.fontSize) ss.fontSize = sc.fontSize;
    if(sc.color) ss.color = sc.color;
    if(sc.textAlign) ss.textAlign = sc.textAlign;
    if(sc.nowrap) ss.nowrap = sc.nowrap;
    if(sc.truncate) ss.truncate = sc.truncate;
    if(sc.editable) ss.editable = sc.editable;
    if(sc.placeHolder) ss.placeHolder = sc.placeHolder;
    
    
    if(sc.padding) ss.padding = sc.padding;
    if(sc.paddingLeft) ss.paddingLeft = sc.paddingLeft;
    if(sc.paddingRight) ss.paddingRight = sc.paddingRight;
    if(sc.paddingBottom) ss.paddingBottom = sc.paddingBottom;
    if(sc.paddingTop) ss.paddingTop = sc.paddingTop;
    
    if(sc.path) ss.path = sc.path;
    
    *custom = ss;
    return ss;
}
__attribute__((overloadable)) Styles style(Styles *custom, std::initializer_list<Styles *>exts){
    Styles o = *custom;
    for (Styles *ext  : exts) {
        style(&o,ext);
    }
    return o;
}

Styles str2style(const char * s){
    string cs(s);
    regex_replace(cs, regex("\\s*;\\s*"), "");
    Styles s0 = nos;
    int start = 0, end = 0;
    do {
        end = (int)cs.find(';', start);
        string ss =cs.substr(start, end - start);
        int sl = (int)ss.length();
        if(sl==0)continue;
        int el =(int)ss.find(':',0);
        if(el>=0){
            string k = ss.substr(0,el);
            int vl = sl-el-1;
            char* v = new char[vl];
            for (int i=0; i<vl; i++) {
                v[i] = ss[i+el+1];
            }
            if(k=="x") s0.x = atof(v);
            if(k=="y") s0.y = atof(v);
            if(k=="z") s0.z = atof(v);
            if(k=="w") s0.w = atof(v);
            if(k=="h") s0.h = atoi(v);
            
            if(k=="border") s0.border = v;
//            if(k=="borderWidth") s0.borderWidth = atof(v);
//            if(k=="borderColor") s0.borderColor = v;
//            
            if(k=="cornerRadius") s0.cornerRadius = atoi(v);
            /*
             if(k=="outlineColor") s0.outlineColor = v;
             if(k=="outline") s0.outline = v;
             if(k=="outlineSpace") s0.outlineSpace = atoi(v);
             if(k=="outlineWidth") s0.outlineWidth = atoi(v);
             */
            if(k=="contentMode") s0.contentMode = atoi(v);
            
            if(k=="shadow") s0.shadow = v;
            if(k=="alpha") s0.alpha = atof(v);
            if(k=="bgcolor") s0.bgcolor = v;
            
            if(k=="scaleX") s0.scaleX = atof(v);
            if(k=="scaleY") s0.scaleY = atof(v);
            if(k=="rotate") s0.rotate = atof(v);
            if(k=="rotate3d") s0.rotate3d = v;
            if(k=="flip") s0.flip = v;
            
            if(k=="font") s0.font = v;
            if(k=="fontName") s0.fontName = v;
            if(k=="fontSize") s0.fontSize = atof(v);
            if(k=="color") s0.color = v;
            if(k=="textAlign") s0.textAlign = v;
            if(k=="nowrap") s0.nowrap = v;
            if(k=="truncate") s0.truncate = v;
            if(k=="editable") s0.editable = v;
            if(k=="placeHolder") s0.placeHolder = v;
            
            if(k=="padding") s0.padding = atoi(v);
            if(k=="paddingLeft") s0.paddingLeft = atoi(v);
            if(k=="paddingTop") s0.paddingTop = atoi(v);
            if(k=="paddingRight") s0.paddingRight = atoi(v);
            if(k=="paddingBottom") s0.paddingBottom = atoi(v);
            
        }
        start = end + 1;
    }while(end != string::npos);
    return s0;
}

NSValue * style2val(Styles s){
    return [NSValue value:&s withObjCType:@encode(Styles)];
}
Styles val2style(NSValue *v){
    Styles s;
    [v getValue:&s];
    return s;
}

/*
 build rotate3d string with data
 */
char* r3dstr(float degree, float x, float y, int resp, float axisX, float axisY, float transX, float transY){
    return cstr([NSString stringWithFormat:@"%f,%f,%f,0,%d,%f,%f,%f,%f,0", degree, x, y,resp, axisX, axisY, transX, transY]);
}
/*
 string to rotate3d options
 */
Rotate3DOpt r3dopt(const char * rotate3dStr){
    string rotate(rotate3dStr);
    //degree, rotateX, rotateY, rotateZ, respective, anchorX, anchorY, translateX, translateY, translateZ
    float p[] = {0,0,0,0,500,0.5,0.5,0,0,0};
    rotate = regex_replace(rotate, regex("\\s*,\\s*"), ",");
    int start = 0, end = 0, i=0;
    do {
        end = (int)rotate.find(',', start);
        if(end<0)break;
        string sc =rotate.substr(start, end - start);
        p[i] = stof(sc);
        start = end + 1;
        i++;
    }while(end != string::npos);
    return {p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9]};
}

char* fontstr(const char*fname, float fontsize){
    return cstr([NSString stringWithFormat:@"%@,%f",str(fname),fontsize]);
}
/*
 font
 */
UIFont* ftopt(const char*s){
    if(!s || sizeof(s)==0)
        return [UIFont systemFontOfSize:14];
    string fstr(s);
    fstr = regex_replace(fstr, regex("\\s+"), "");
    int idx=(int)fstr.find(',', 0);
    const char* fn  = idx? fstr.substr(0, idx).c_str():cstr([UIFont systemFontOfSize:14].fontName);
    float fsize  = idx? stof(fstr.substr(idx+1, fstr.length() - idx - 1)) : 14;
    return [UIFont fontWithName:str(fn) size:fsize];
}
