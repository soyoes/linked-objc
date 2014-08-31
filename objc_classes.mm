//
//  objc_classes.mm
//  testapp
//
//  Created by soyoes on 8/17/14.
//  Copyright (c) 2014 soyoes. All rights reserved.
//

#import "liber.h"
#import "objc_categories.h"

mdic_t __nodes, __idxmap;

using namespace std;

style_t style_t::clone() {
    return style_t::decode(this->encode());
}

str_t style_t::encode(){
    //return [NSValue value:this withObjCType:@encode(style_t)];
    return style_t::encode(*this);
}
str_t style_t::encode(style_t s){
    NSString* delimiter_k_v  = @"\a";
    NSString* delimiter_data = @"\b";
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:20];
    [arr addStringKeyValue:@"x" value:s.x separator:delimiter_k_v];
    [arr addStringKeyValue:@"y" value:s.y separator:delimiter_k_v];
    [arr addStringKeyValue:@"w" value:s.w separator:delimiter_k_v];
    [arr addStringKeyValue:@"h" value:s.h separator:delimiter_k_v];
    [arr addStringKeyValue:@"z" value:s.z separator:delimiter_k_v];
    [arr addStringKeyValue:@"bgcolor"         value:s.bgcolor         separator:delimiter_k_v];
    [arr addStringKeyValue:@"color"           value:s.color           separator:delimiter_k_v];
    [arr addStringKeyValue:@"shadow"          value:s.shadow          separator:delimiter_k_v];
    [arr addStringKeyValue:@"border"          value:s.border          separator:delimiter_k_v];
    [arr addStringKeyValue:@"alpha"           value:s.alpha           separator:delimiter_k_v];
    [arr addStringKeyValue:@"corner"          value:s.corner          separator:delimiter_k_v];
    [arr addStringKeyValue:@"contentMode"     value:s.contentMode     separator:delimiter_k_v];
    [arr addStringKeyValue:@"scaleX"          value:s.scaleX          separator:delimiter_k_v];
    [arr addStringKeyValue:@"scaleY"          value:s.scaleY          separator:delimiter_k_v];
    [arr addStringKeyValue:@"rotate"          value:s.rotate          separator:delimiter_k_v];
    [arr addStringKeyValue:@"rotate3d"        value:s.rotate3d        separator:delimiter_k_v];
    [arr addStringKeyValue:@"flip"            value:s.flip            separator:delimiter_k_v];
    [arr addStringKeyValue:@"padding"         value:s.padding         separator:delimiter_k_v];
    [arr addStringKeyValue:@"paddingLeft"     value:s.paddingLeft     separator:delimiter_k_v];
    [arr addStringKeyValue:@"paddingTop"      value:s.paddingTop      separator:delimiter_k_v];
    [arr addStringKeyValue:@"paddingRight"    value:s.paddingRight    separator:delimiter_k_v];
    [arr addStringKeyValue:@"paddingBottom"   value:s.paddingBottom   separator:delimiter_k_v];
    [arr addStringKeyValue:@"font"            value:s.font            separator:delimiter_k_v];
    [arr addStringKeyValue:@"align"           value:s.align           separator:delimiter_k_v];
    [arr addStringKeyValue:@"nowrap"          value:s.nowrap          separator:delimiter_k_v];
    [arr addStringKeyValue:@"truncate"        value:s.truncate        separator:delimiter_k_v];
    [arr addStringKeyValue:@"editable"        value:s.editable        separator:delimiter_k_v];
    [arr addStringKeyValue:@"placeHolder"     value:s.placeHolder     separator:delimiter_k_v];
    [arr addStringKeyValue:@"path"            value:s.path            separator:delimiter_k_v];
    [arr addStringKeyValue:@"ID"              value:s.ID              separator:delimiter_k_v];
    
    return [arr componentsJoinedByString:delimiter_data];
}

style_t style_t::decode(str_t str) {
    if (str) {
        style_t ss;
        NSString* delimiter_k_v  = @"\a";
        NSString* delimiter_data = @"\b";
        NSArray*  arr = str_split(str, delimiter_data);
        for (NSString* data in arr) {
            //NSLog(@"result :%@", data);
            NSArray* kv = str_split(data, delimiter_k_v);
            NSString* key   = [kv objectAtIndex:0];
            NSString* value = [kv objectAtIndex:1];
            BOOL isNull = str_eq(@"(null)",value);
            
            if (str_eq(@"x",key)) ss.x = isNull ? ss.x : str2numf(value);
            else if (str_eq(@"y",key)) ss.y = isNull ? ss.y : str2numf(value);
            else if (str_eq(@"w",key)) ss.w = isNull ? ss.w : str2numf(value);
            else if (str_eq(@"h",key)) ss.h = isNull ? ss.h : str2numf(value);
            else if (str_eq(@"z",key)) ss.z = isNull ? ss.z : str2numf(value);
            
            else if (str_eq(@"bgcolor",key)) ss.bgcolor = isNull ? ss.bgcolor : value;
            else if (str_eq(@"color",key)) ss.color = isNull ? ss.color : value;
            else if (str_eq(@"shadow",key)) ss.shadow = isNull ? ss.shadow : value;
            else if (str_eq(@"border",key)) ss.border = isNull ? ss.border : value;
            else if (str_eq(@"corner",key)) ss.corner = isNull ? ss.corner : str2numf(value);
            else if (str_eq(@"contentMode",key)) ss.contentMode = isNull ? ss.contentMode : str2numf(value);
            else if (str_eq(@"scaleX",key)) ss.scaleX = isNull ? ss.scaleX : str2numf(value);
            else if (str_eq(@"scaleY",key)) ss.scaleY = isNull ? ss.scaleY : str2numf(value);
            else if (str_eq(@"rotate",key)) ss.rotate = isNull ? ss.rotate : str2numf(value);
            else if (str_eq(@"rotate3d",key)) ss.rotate3d = isNull ? ss.rotate3d : value;
            else if (str_eq(@"flip",key)) ss.flip = isNull ? ss.flip : value;
            else if (str_eq(@"padding",key)) ss.padding = isNull ? ss.padding : str2numf(value);
            else if (str_eq(@"paddingLeft",key)) ss.paddingLeft = isNull ? ss.paddingLeft : str2numf(value);
            else if (str_eq(@"paddingTop",key)) ss.paddingTop = isNull ? ss.paddingTop : str2numf(value);
            else if (str_eq(@"paddingRight",key)) ss.paddingRight = isNull ? ss.paddingRight : str2numf(value);
            else if (str_eq(@"paddingBottom",key)) ss.paddingBottom = isNull ? ss.paddingBottom : str2numf(value);
            else if (str_eq(@"font",key)) ss.font = isNull ? ss.font : value;
            else if (str_eq(@"align",key)) ss.align = isNull ? ss.align : value;
            else if (str_eq(@"nowrap",key)) ss.nowrap = isNull ? ss.nowrap : str2numf(value);
            else if (str_eq(@"truncate",key)) ss.truncate = isNull ? ss.truncate : str2numf(value);
            else if (str_eq(@"editable",key)) ss.editable = isNull ? ss.editable : str2numf(value);
            else if (str_eq(@"placeHolder",key)) ss.placeHolder = isNull ? ss.placeHolder : value;
            else if (str_eq(@"path",key)) ss.path = isNull ? ss.path : value;
            else if (str_eq(@"ID",key)) ss.ID = isNull ? ss.ID : value;
        }
        return ss;
    }
    return {};
}

#pragma mark - $View

@implementation LBView

@synthesize x,y,w,h,z,rotate,corner,fontsize;
@synthesize scale,flip,padding,rotate3d,fillmode;
@synthesize truncate,editable,nowrap;
@synthesize color, bgcolor;
@synthesize textalign;
@synthesize fontname;

-(id) initWithOwner:($*)owner rect:(rect_t)rect viewid:(str_t)ID idx:(int)idx{
    self = [super initWithFrame:{rect.x, rect.y, rect.w, rect.h}];
    _data = [[NSMutableDictionary alloc] init];
    _gestures = [[NSMutableDictionary alloc] init];
    _owner = owner;
    self.userInteractionEnabled = YES;
    _idx = idx;
    _ID = ID;
    [self _registerView];
    _frameLayer = [CALayer layer];
    _frameLayer.frame = self.bounds;
    [[self layer] addSublayer:_frameLayer];
    _contentLayer = [CALayer layer];
    _contentLayer.frame = self.bounds;
    _contentLayer.masksToBounds = YES;
    [_frameLayer addSublayer:_contentLayer];
    return self;
}

-(void) gestureHandler:(ges_t)ges{
    str_t className = [[ges class] description];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(UI|GestureRecognizer)"
                                                                           options:NSRegularExpressionCaseInsensitive error:nil];
    className = [[regex stringByReplacingMatchesInString:className options:0 range:NSMakeRange(0, [className length]) withTemplate:@""] lowercaseString];
    //NSLog(@"ges : %@", className);
    if(_gestures!=nil && _gestures[className]!=nil){
        ges_f handler = _gestures[className];
        if(handler){
            LBView * v = (LBView*)ges.view;
            handler(ges, *_owner, [v.data valueForKey:@"gestureData"]);
        }
    }
}

-(void) switchEditingMode{
    if(_textField!=nil){
        if(_textField.hidden){
            set_data(@"textEditViewOwner",_owner->encode());
            [self addSubview:_textField];//FIXME
            ((textview_t)_textField).text = _text;
            _textField.hidden = NO;
            _textLayer.hidden = YES;
            [_textField becomeFirstResponder];
            _owner->scrollTop(10);
        }else{
            _textField.hidden = YES;
            _owner->text(((textview_t)_textField).text);
            [_textField resignFirstResponder];
            _owner->scrollBack();
        }
    }
}

-(void) setStyles:(style_t)ss{

    w = ss.w ? numf(ss.w) : w;
    h = ss.h ? numf(ss.h) : h;
    x = ss.x ? numf(ss.x) : x;
    y = ss.y ? numf(ss.y) : y;
    
    layer_t layer = [self layer];
    
    bool rendered = _parent != nullptr|| self.superview;
    bool need_redraw = !rendered
        || (ss.x||ss.y||ss.w||ss.h||ss.corner||ss.path);
    if(need_redraw){
        self.frame = {x,y,w,h};
        layer.bounds = self.bounds;
        _frameLayer.frame = layer.bounds;
        _contentLayer.frame = layer.bounds;
        if(_textLayer)
            _textLayer.frame = layer.bounds;
        corner = numf(ss.corner);
        if(ss.path){
            [self _setSvgPath:ss.path];
        }else{
            //[self _setMask:[self _getSvgPath:0 orgY:0]];
            [self _setMask:nil];
            if(!_src && corner){
                _contentLayer.cornerRadius = corner;
            }
        }
    }
    
    if(ss.z){
        z = numf(ss.z);
        layer.zPosition = z;
    }
    
    self.alpha = (ss.alpha)?numf(ss.alpha):1;
    //layer.opacity = alpha;
    
    if(ss.bgcolor){
        if(str_has(ss.bgcolor, @":")){//gradient
            [self _setGradient:ss.bgcolor];
        }else{
            [self _setBgcolor:ss.bgcolor];
        }
    }
    
    if(ss.shadow){
        [self _setShadow:ss.shadow];
    }
    
    if(ss.border){
        [self _setBorder:ss.border];
    }

    CGAffineTransform transf;
    bool trasDefined=false;
    if(ss.scaleX || ss.scaleY){
        trasDefined = true;
        scale = {numf(ss.scaleX,1), numf(ss.scaleY,1)};
        transf = CGAffineTransformMakeScale(scale.x, scale.y);
    }
    
    if(ss.flip){
        flip = {0,0};
        CGAffineTransform fliptrans;
        if (str_has(ss.flip, @"H")) {
            fliptrans =CGAffineTransformMake(self.transform.a * -1, 0, 0, 1, self.transform.tx, 0);
            transf = trasDefined? CGAffineTransformConcat(transf,fliptrans):fliptrans;
            trasDefined = true;
            flip.x = 1;
        }
        if(str_has(ss.flip, @"V")){
            fliptrans = CGAffineTransformMake(1, 0, 0, self.transform.d * -1, 0, self.transform.ty);
            transf = trasDefined? CGAffineTransformConcat(transf,fliptrans):fliptrans;
            trasDefined = true;
            flip.y = 1;
        }
    }
    
    if(ss.rotate){
        rotate = numf(ss.rotate);
        CGAffineTransform rotatetrans = CGAffineTransformMakeRotation(radians(rotate));
        transf = trasDefined? CGAffineTransformConcat(transf,rotatetrans):rotatetrans;
        trasDefined = true;
    }
    
    if(trasDefined)
        self.transform = transf;
    
    if(ss.rotate3d){
        rotate3d = str2r3d(ss.rotate3d);
        layer.anchorPoint = CGPointMake(rotate3d.axisX, rotate3d.axisY);
        CATransform3D rt = CATransform3DIdentity;
        rt.m34 = 1.0f / (-1*rotate3d.resp);
        rt = CATransform3DRotate(rt, radians(rotate3d.degree), rotate3d.x, rotate3d.y, rotate3d.z);
        rt = CATransform3DTranslate(rt, rotate3d.transX, rotate3d.transY, rotate3d.transZ);
        layer.transform = rt;//CATransform3DConcat
    }
    
    //set image styles
    fillmode = (fill_mode_t) numi(ss.contentMode);
    
    //set text styles
    if(ss.font){
        font_t f = str2font(ss.font);
        fontname = f.fontName;
        fontsize = (float)f.pointSize;
    }
    
    truncate = numb(ss.truncate);
    editable = numb(ss.editable);
    nowrap   = numb(ss.nowrap);
    
    textalign= (align_t)[TEXTALIGNS indexOfObject:ss.align];
    if(textalign<0) textalign = kTopLeft;
    color    = ss.color?str2rgba(ss.color):(rgba_t){0,0,0,1};
    
    float p = numf(ss.padding);
    padding = {
        numf(ss.paddingLeft, p),
        numf(ss.paddingTop, p),
        numf(ss.paddingRight, p),
        numf(ss.paddingBottom, p)
    };
    
    if(rendered && _text){
        [self _applyTextstyle];
    }
    
    _styles = ss.encode();
}
#pragma mark set style methods
-(void) _setBgcolor:(str_t)colstr{
    color_t bc = str2color(colstr);
    _contentLayer.backgroundColor=bc.CGColor;
    bgcolor = str2rgba(colstr);
}
-(void) _setGradient:(str_t) value{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self layer].bounds;
    gradient.cornerRadius = corner;
    arr_t parts = str_split(str_regex_replace(value, @"\\s+", @" "), @" ");
    int size = arr_size(parts);
    _gradclrs = marr(nil);
    _gradlocs = marr(nil);
    int degree = 0;
    for (int i=0;i<size;i++) {
        str_t v = parts[i];
        int sidx = str_idx(v, @":");
        if(sidx>=0){
            arr_t cparts = str_split(v, @":");
            marr_add(_gradclrs, (id)str2color(cparts[0]).CGColor);
            marr_add(_gradlocs, @(numf(cparts[1])));
        }else{
            if(i==size-1 && !str_has(v, @"#")){
                degree = str2f(v);
            }else{
                marr_add(_gradclrs, (id)str2color(v).CGColor);
                marr_add(_gradlocs, @((float)i/(float)(size-1)));
            }
        }
    }
    gradient.colors = _gradclrs;
    gradient.locations = _gradlocs;
    if(degree)
        gradient.affineTransform = CGAffineTransformMakeRotation(radians(degree));
    [_contentLayer insertSublayer:gradient atIndex:0];
    bgcolor = {0,0,0,0};
}

-(void) _setBorder:(str_t)border{
    [self _clearBorders];
    if(!_borders) _borders = marr(nil);
    border = str_regex_replace(border, @"\\s+",@" ");
    if(str_has(border,@",")){
        arr_t bds = str_split(border,@",");
        int size = (int) arr_size(bds);
        for(int i=0;i<size;i++){
            marr_add(_borders, str2border(bds[i]));
        }
    }else{
        marr_add(_borders, str2border(border));
    }
    for(border_t bd in _borders){
        [self _addBorder:bd];
    }
}
-(void) _addBorder:(border_t)bo{
    if(!bo)return;
    shape_layer_cls* borderLayer = [shape_layer_cls layer];
    borderLayer.type = @"border";
    borderLayer.path = _maskLayer.path;
    borderLayer.strokeColor = !bo.color?
    (bo.image?[UIColor colorWithPatternImage:bo.image].CGColor:
     [UIColor clearColor].CGColor) : bo.color.CGColor;
    borderLayer.lineWidth=bo.width;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.lineCap = kCALineCapSquare;
    borderLayer.lineJoin = kCALineJoinRound;
    [_frameLayer addSublayer:borderLayer];
}
-(void) _clearBorders{
    NSEnumerator *enumerator = [_frameLayer.sublayers reverseObjectEnumerator];
    for (layer_t la in enumerator){
        if(is_shape_layer(la)
           && [@"border" isEqualToString:((shape_layer_cls*)la).type]){
            [la removeFromSuperlayer];
        }
    }
}

-(void) _setShadow:(str_t)shadow{
    [self _clearShadows];
    if(!_shadows) _shadows = marr(nil);
    shadow = str_regex_replace(shadow, @"\\s+",@" ");
    if(str_has(shadow,@",")){
        arr_t sds = str_split(shadow,@",");
        int size = (int) arr_size(sds);
        for(int i=0;i<size;i++)
            marr_add(_shadows, str2shadow(sds[i]));
    }else{
        marr_add(_shadows, str2shadow(shadow));
    }
    for(shadow_t sh in _shadows){
        [self _addShadow:sh];
    }
}
-(void) _addShadow:(shadow_t)opt{
    if(opt){
        color_t cl = !opt.color?[UIColor darkGrayColor]:opt.color;
        self.clipsToBounds = NO;
        shape_layer_cls *shad = [shape_layer_cls layer];
        shad.type = @"shadow";
        shad.path=_maskLayer.path;
        shad.shadowRadius = opt.radius;
        shad.shadowOpacity = 1.0;
        //shad.frame = self.bounds;
        if(opt.inset){
            shad.zPosition = 10;
            shad.strokeColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            shad.fillColor = [UIColor clearColor].CGColor;
            shad.lineWidth = MAX(opt.x, opt.y);
            shad.shadowOffset = CGSizeMake(opt.x/2, opt.y/2);
            shad.shadowColor = cl.CGColor;
            CGRect fr = CGPathGetPathBoundingBox(_maskLayer.path);
            float w = fr.size.width,h = fr.size.height;
            shad.transform = CATransform3DMakeScale((4.0f+w)/w, (4.0f+h)/h, 1);
            shad.position = (CGPoint){-2,-2};
            [_contentLayer addSublayer:shad];
        }else{
            shad.shadowOffset = CGSizeMake(opt.x, opt.y);
            shad.shadowColor = cl.CGColor;
            [_frameLayer insertSublayer:shad atIndex:0];
        }
        shad = nil;
        cl = nil;
    }
}
-(void) _clearShadows{
    NSEnumerator *enumerator = [_frameLayer.sublayers reverseObjectEnumerator];
    for (CALayer *la in enumerator){
        if(is_shape_layer(la)
           && [@"shadow" isEqualToString:((shape_layer_cls*)la).type]){
            [la removeFromSuperlayer];
        }
    }
}

-(void) _setSvgPath:(str_t)svgpathcmd{
    _svg = svgpathcmd;
    path_t path = str2svgpath(svgpathcmd);
    [self _setMaskPath:path];
}

-(str_t) _getSvgPath:(float)orgX orgY:(float)orgY{
    if(_svg) return _svg;
    float x1=orgX, y1=orgY;
    float x2=x1+w, y2=y1+h, r=corner;
    return r>0?
    sprintf(@"M%f %f L%f %f A%f,%f %f,%f %f L%f %f A%f,%f %f,%f %f L%f %f A%f,%f %f,%f %f L%f,%f A%f,%f %f,%f %f Z",
     x1+r,  y1,     //left-up corner p2
     x2-r,  y1,     //right-up corner p1
     x2-r,  y1,     x2,    y1+r,    r,  //right-up corner p1, p2, r
     x2,    y2-r,   //right-down corner p1
     x2,    y2-r,   x2-r,  y2,      r,  //right-down corner p1, p2, r
     x1+r,  y2,     //left-down corner p1
     x1+r,  y2,     x1,    y2-r,    r,  //left-down corner p1, p2, r
     x1,    y1+r,   //left-up corner p1
     x1,    y1+r,   x1+r,  y1,      r   //left-up corner p1,p2,r
     ):sprintf(@"M%f %f L%f %f L%f %f L%f %f Z", x1,y1, x2,y1, x2,y2, x1,y2);
}

-(void) _setMask:(str_t)mask{
    if(!_maskLayer)
        _maskLayer = [CAShapeLayer layer];
    _maskLayer.frame = _contentLayer.bounds;
    _maskLayer.path = mask? str2svgpath(mask):
        //str2svgpath([self _getSvgPath:0 orgY:0]);
        [UIBezierPath bezierPathWithRoundedRect:_contentLayer.bounds cornerRadius:corner].CGPath;
    if(_src || _svg)
        _contentLayer.mask = _maskLayer;
}
-(void) _setMaskPath:(path_t)mask{
    if(!_maskLayer)
        _maskLayer = [CAShapeLayer layer];
    _maskLayer.frame = _contentLayer.bounds;
    _maskLayer.path = mask;
    if(_src || _svg)
        _contentLayer.mask = _maskLayer;
}

-(void) setImage:(id)src{
    if(!src || (is_str(src)&&[src length]==0))
        return;
    image_t img;
    if([src isKindOfClass:[NSString class]]){
        _src = src;
        if([src hasPrefix:@"http:"]||[src hasPrefix:@"https:"]||[src hasPrefix:@"ftp:"]){//URL
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSError* error = nil;
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_src] options:NSDataReadingUncached error:&error];
                if(data&&!error){
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self setImage:[UIImage imageWithData:data]];
                    });
                }else{
                    NSLog(@"Failed To Load Image From URL:%@",_src);
                }
            });
        }else if([src hasPrefix:@"assets-library:"]){//asset
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @autoreleasepool {
                    [UIImage loadImageFromAssetURL:[NSURL URLWithString:src] handler:^(image_t im,dic_t p) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self setImage:im];
                        });
                        im = nil;
                    } params:@{}];
                }
            });
        }else if([src length]>0)
            img = [UIImage imageNamed:src];
    }else if([src isKindOfClass:[UIImage class]])
        img = src;
    if(img){
        if(!_imageLayer){
            _imageLayer=[CALayer layer];
            [_contentLayer addSublayer:_imageLayer];
        }
        CGFloat imgW = CGImageGetWidth(img.CGImage);
        CGFloat imgH = CGImageGetHeight(img.CGImage);
        if(imgW && imgH){
            CGFloat cw = _contentLayer.bounds.size.width;
            CGFloat ch = _contentLayer.bounds.size.height;
            CGFloat wScale = cw / imgW;
            CGFloat hScale = ch / imgH;
            CGFloat w,h;
            switch (fillmode) {
                case kFit:
                    w = wScale>hScale?imgW*hScale:cw;
                    h = wScale>hScale?ch:imgH*wScale;
                    _imageLayer.frame = {{wScale>hScale?(cw-w)/2:0,wScale>hScale?0:(ch-h)/2},{w,h}};
                    break;
                case kCropFit:
                    w = wScale>hScale?cw:imgW*hScale;
                    h = wScale>hScale?imgH*wScale:ch;
                    _imageLayer.frame = {{wScale>hScale?0:(cw-w)/2,wScale>hScale?(ch-h)/2:0},{w,h}};
                    break;
                case kOrg:
                    _imageLayer.frame = {{(cw-imgW)/2,(ch-imgH)/2},{imgW,imgH}};
                    break;
                default://m_FILL
                    _imageLayer.frame = {{0,0},{cw,ch}};
                    break;
            }
            _imageLayer.contents =(__bridge id)img.CGImage;
        }
    }
    img = nil;
}

-(image_t) getImage{
    if(_imageLayer)
        return [UIImage imageWithCGImage:(CGImageRef)_imageLayer.contents];
    return nil;
}

#pragma mark - TEXT

-(void) setText:(str_t)txt{
    _text = txt;
    // TODO
    // - (CGSize)sizeThatFits:(CGSize)size //calculate a size to make the superview to fit its all subviews
    // - (void)sizeToFit //auto adjust super view to fit its all subviews
    //logRect(@"txt",rect);
    if(_textLayer==nil){
        _textLayer= [[CATextLayer alloc] init];
        [_contentLayer addSublayer:_textLayer];
    }else
        _textLayer.hidden = NO;

    if([_textLayer respondsToSelector:@selector(setContentsScale:)])
        _textLayer.contentsScale = [[UIScreen mainScreen] scale];
    
    [_textLayer setString:_text];
    [_textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    
    [self _applyTextstyle];
}

-(void) setDefaultText:(str_t)text{
    if(!_text){
        [self setText:text];
        _text = nil;
    }
}

-(void) _applyTextstyle{
    if(!_textLayer)return;
    _textLayer.wrapped = !nowrap;
    _textLayer.truncationMode = truncate ? kCATruncationEnd:kCATruncationNone;
    
    [_textLayer setFrame:{padding.x,padding.y,
        _contentLayer.bounds.size.width-padding.x-padding.z,
        _contentLayer.bounds.size.height-padding.y-padding.w}];
    
    if(!fontsize)fontsize = 14;
    if(!fontname)
        fontname = [UIFont systemFontOfSize:fontsize].fontName;
    
    [_textLayer setFont:CGFontCreateWithFontName((CFStringRef)fontname)];
    [_textLayer setFontSize:fontsize];
    
    color_t cl = rgba2color(color);
    [_textLayer setForegroundColor:cl.CGColor];
    
    str_t ta ;
    if(textalign==kJustified){
        ta = (str_t)kCAAlignmentJustified;
    }else{
        static arr_t aligns = @[kCAAlignmentLeft, kCAAlignmentCenter, kCAAlignmentRight];
        ta = [aligns objectAtIndex:(textalign % 3)];
    }
    [_textLayer setAlignmentMode:ta];
}
-(void)setEditable:(BOOL)ea{[self setEditable:ea handler:^($&v){}];}
-(void)setEditable:(BOOL)ea handler:(TextEditOnInitHandler)startHandler{
    if(_textField==nil){
        textview_t t = [[textview_cls alloc] initWithFrame:_textLayer.frame];
        t.delegate = self;
        t.textContainer.lineFragmentPadding = 0;
        t.textContainerInset = UIEdgeInsetsZero;
        int al =textalign==kJustified?4:textalign%3;
        bool isphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
        if((al==1 || al==2) && !isphone) al = al==1?2:1;
        t.textAlignment = (NSTextAlignment)al;
        t.font = [UIFont fontWithName:fontname size:fontsize];
        t.editable = YES;
        t.nowrap = nowrap;
        _textField = t;
        _textField.hidden = YES;
        [self set:@"initHandler" value:(id)startHandler];
        editable = ea;
    }
    [self bind:@"tap" handler:^void (ges_t ges, $& o, dic_t params){
        view_t v = (view_t)ges.view;
        [v switchEditingMode];
        TextEditOnInitHandler sh = o.get(@"initHandler");
        if(sh){sh(o);}
    } opts:nil];
}

#pragma mark - Picker
-(void) setPickable:(arr_t) opts{
    if(!_text){
        NSLog(@"ERR: setPickable requires label()");
        return;
    }
    [self setEditable:true];
    UIPickerView * pv = [[UIPickerView alloc] init];
    pv.delegate = self;
    _textField.picker = pv;
    _textField.options = opts;
}
-(void) setPickable:(date_t) date format:(str_t) format{
    if(!_text){
        NSLog(@"ERR: setPickable requires label()");
        return;
    }
    [self setEditable:true];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString * val = [formatter stringFromDate:date?date:[NSDate date]];
    [self set:@"_dateFormat" value:format];
    [self setText:val];
    
    UIDatePicker * picker = [[UIDatePicker alloc]init];
    UIDatePickerMode mode = UIDatePickerModeDate;
    
    if(str_has(format,@"ss")||str_has(format,@"mm")||str_has(format,@"HH")){
        mode = (str_has(format,@"yy")||str_has(format,@"MM")||str_has(format,@"dd"))
        ? UIDatePickerModeDateAndTime : UIDatePickerModeTime;
    }
    [picker setDatePickerMode:mode];
    ((textview_t) _textField).datePicker = picker;
    [picker addTarget:self action:@selector(datePicked) forControlEvents:UIControlEventValueChanged];
}


#pragma mark - Cache
-(void) set:(str_t)k value:(obj_t)v{_data[k] = v;}
-(obj_t) get:(str_t)k{return _data[k];}

#pragma mark - Events Binds
-(void) bind:(str_t)event handler:(ges_f)handler opts:(dic_t)opts{
    if([EVENTS indexOfObject:event]==NSNotFound || handler==NULL)
        return;
    _gestures[event] = (id) handler;
    _gesmap = !_gesmap?mdic(nil):_gesmap;
    
    event = [event stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[event substringToIndex:1] uppercaseString]];
    str_t className = sprintf(@"UI%@GestureRecognizer",event);
    UIGestureRecognizer *gesture = [[NSClassFromString(className) alloc]
                                    initWithTarget:self action:@selector(gestureHandler:)];
    if(opts!=nil && [[opts allKeys] count]>0){
        [_data setValue:opts forKey:@"gestureData"];
    }
    if([event isEqualToString:@"swipe"]){
        UISwipeGestureRecognizer * gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
        [gr setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:gr];
        [(UISwipeGestureRecognizer*)gesture setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    }
    _gesmap[@"tap"]=gesture;
    _ges_a = gesture;
    [self addGestureRecognizer:gesture];
}

-(void)unbind:(str_t) event{
    ges_f gh = _gestures[event];
    if(gh){
        //[self removeGestureRecognizer:gh];
        [_gestures removeObjectForKey:event];
    }
}

-(void)dragable:(ges_f)onDrag end:(ges_f)onEnd{
    [self bind:@"pan" handler:^(ges_t ges, $& n, dic_t params) {
        UIPanGestureRecognizer * r = (UIPanGestureRecognizer *) ges;
        if(r.state == UIGestureRecognizerStateEnded){
            [_data removeObjectForKey:@"diffX"];
            [_data removeObjectForKey:@"diffY"];
            onEnd(r,n,params);
        }else{
            CGPoint trans = [r translationInView:self];
            if(![_data valueForKey:@"diffX"]){
                [_data setValue:@(trans.x-self.center.x) forKey:@"diffX"];
                [_data setValue:@(trans.y-self.center.y) forKey:@"diffY"];
            }
            self.center = CGPointMake(trans.x-[[_data valueForKey:@"diffX"] floatValue], trans.y-[[_data valueForKey:@"diffY"] floatValue]) ;
            onDrag(r,n,params);
        }
    } opts:@{}];
}


-(void) animate:(float)ms step:(anime_step_f)onStep end:(anime_end_f)onEnd opts:(anime_t)opts{
    if(opts.delay){
        anime_t newOpt = {.style=opts.style, .delta=opts.delta, .delay=0};
        set_timeout(opts.delay,^void(dic_t d){
            if(d[@"o"]){
                view_t o = d[@"o"];
                [o animate:ms step:(anime_step_f)d[@"onStep"] end:d[@"onEnd"] opts:newOpt];
            }}, @{@"o":self, @"onStep":onStep, @"onEnd":onEnd, @"ms":@(ms)});
        return;
    }
    long long start = time_ms();
    anime_delta_t delta_name = opts.delta;
    anime_style_t style_name = opts.style;
    float interval = 16;
    int times = ms/interval;
    //cout << "times = " << times << endl;
    set_interval(interval, ^bool(dic_t d, int i){
        long long start = [d[@"start"] longLongValue];
        float duration = [d[@"duration"] floatValue];
        long long current = time_ms();
        long long passed = current - start;
        float progress = passed / duration;
        if (progress > 1) progress = 1;
        
        
        anime_delta_t deltaname = delta_name;//(anime_delta_t)numi(d[@"delta_func"]);
        delta_f* delta_func = delta_funcs[deltaname];
        
        float delta;
        
        if(numi(d[@"style_name"])!=0){
            anime_style_t stylename = style_name;//(anime_style_t)numi(d[@"style_func"]);
            style_f* style_func = style_funcs[stylename];
            delta = style_func(deltaname,progress);
        }else{
            delta = delta_func(progress);
        }

        view_t o = d[@"o"];
        
        //view_t o = d[@"o"];
        if(d[@"onStep"]){
            //((anime_step_f) d[@"onStep"])(*o.owner, delta);
            onStep(*o.owner, delta);
        }
        int times = numi(d[@"times"]);
        if(progress >= 1 || i>times){
            if(onEnd)onEnd(*o.owner);
            return NO;
        }else return YES;
        
    }, @{@"o":self,@"times":@(times), @"start":@(start), @"duration":@(ms), @"delta_name":@(delta_name), @"style_name":@(style_name), @"onStep":onStep, @"onEnd":onEnd});

}

-(void) animate:(float)ms style:(style_t)toStyle opts:(anime_t)opts{
    [self animate:ms style:toStyle svg:nil end:nil opts:opts];
}
-(void) animate:(float)ms style:(style_t)toStyle end:(anime_end_f)onEnd opts:(anime_t)opts{
    [self animate:ms style:toStyle svg:nil end:onEnd opts:opts];
}
-(void) animate:(float)ms style:(style_t)ss svg:(str_t)svgpath end:(anime_end_f)onEnd opts:(anime_t)opts{
    style_t org, tar;
    org = style_t::decode(_styles);
    tar = ss.clone();
//    [self set:@"orgStyle" value:_styles];
//    [self set:@"targetStyle" value:ss.encode()];
    
    if(svgpath){
        [self set:@"orgSvgPath" value:[self _getSvgPath:x orgY:y]];
        [self set:@"targetSvgPath" value:svgpath];
        _svg = svgpath;
    }
    
    [self animate:ms step:^($& n, float delta) {
        
        view_t v = n.view();
//        style_t org, tar;
//        org = style_t::decode([v get:@"orgStyle"]);
//        tar = style_t::decode([v get:@"targetStyle"]);
        //decode([v get:@"orgStyle"],&org);
        //decode([v get:@"targetStyle"],&tar);

        style_t s = {};
        //x, y, w, h
        if((tar.x||tar.x!=org.x) || (tar.y||tar.y!=org.y) || tar.w || tar.h){
            s.x = tar.x?@(numf(org.x)+(numf(tar.x)-numf(org.x))*delta):org.x;
            s.y = tar.y?@(numf(org.y)+(numf(tar.y)-numf(org.y))*delta):org.y;
            s.w = tar.w?@(numf(org.w)+(numf(tar.w)-numf(org.w))*delta):org.w;
            s.h = tar.h?@(numf(org.h)+(numf(tar.h)-numf(org.h))*delta):org.h;
            //cout << "x,y = " << s.x << "," << s.y << endl;
        }
        
        if(tar.alpha||tar.alpha!=org.alpha){
            s.alpha = @(numf(org.alpha)+(numf(tar.alpha)-numf(org.alpha))*delta);
        }
        
        if(tar.corner)s.corner = @(numf(org.corner)+(numf(tar.corner)-numf(org.corner))*delta);
        if(tar.rotate)s.rotate = @(numf(org.rotate)+(numf(tar.rotate)-numf(org.rotate))*delta);
        if(tar.rotate3d){
            rotate3d_t o3d = str2r3d(org.rotate3d?org.rotate3d:@"0,0,0,0,500,0.5,0.5");
            rotate3d_t t3d = str2r3d(tar.rotate3d);
            s.rotate3d = r3d2str(o3d.degree+(t3d.degree-o3d.degree)*delta, t3d.x, t3d.y,t3d.z,
                                 o3d.resp+(t3d.resp-o3d.resp)*delta,
                                 o3d.axisX+(t3d.axisX-o3d.axisX)*delta,
                                 o3d.axisX+(t3d.axisY-o3d.axisY)*delta,
                                 o3d.transX+(t3d.transX-o3d.transX)*delta,
                                 o3d.transY+(t3d.transY-o3d.transY)*delta);
        }
        if(tar.bgcolor)
            s.bgcolor = deltacolor(org.bgcolor, tar.bgcolor, delta);
        if(tar.color)
            s.color = deltacolor(org.color, tar.color, delta);
        
        if(tar.shadow){
            //TODO save shadows to improve speed
            shadow_t osd = org.shadow?str2shadow(org.shadow):shadow_init(false, 0, 0, 0, @"ffffff00");
            shadow_t tsd = str2shadow(tar.shadow);
            
            str_t clr = rgba_equals(color2rgba(osd.color), color2rgba(tsd.color))?color2str(tsd.color):deltacolor(color2str(osd.color), color2str(tsd.color), delta);
            s.shadow = shadow2str(shadow_init(tsd.inset,
                                              osd.x+(tsd.x-osd.x)*delta,
                                              osd.y+(tsd.y-osd.y)*delta,
                                              osd.radius+(tsd.radius-osd.radius)*delta, clr));
        }
        if(tar.border){
            border_t ob = org.border?str2border(org.border):border_init(0, @"ffffff00", 0);
            border_t tb = str2border(tar.border);
            
            str_t clr = rgba_equals(color2rgba(ob.color), color2rgba(tb.color))?
            color2str(tb.color):deltacolor(color2str(ob.color), color2str(tb.color), delta);
            s.border = border2str(border_init(ob.width+(tb.width-ob.width)*delta, clr,
                                              ob.radius+(tb.radius-ob.radius)*delta));
        }
        if(svgpath){
            str_t osv = [v get:@"orgSvgPath"];
            str_t tsv = [v get:@"targetSvgPath"];
            arr_t cmds = svg_tween(osv, tsv, @(delta));
            path_t path = arr2svgpath(cmds);
            s.path = svgpath;
            [v setStyles:s];
            [v _setMaskPath:path];
        }else
            [v setStyles:s];
    } end:onEnd  opts:opts];
}

#pragma mark - AppendTO

-(void) appendTo:(view_base_t)p asLayer:(bool)asLayer{
    //FIXME asLayer, slides
    if(p){
        if(_subLayers){
            BOOL hasSubHandler = NO;
            for (view_t v in _subLayers) {
                v.asSubLayer = true;
                [self.layer addSublayer:v.layer];
                if(v.gestures && v.gestures[@"tap"]){
                    hasSubHandler = YES;
                }
            }
            dic_t parentHit = _gestures&&_gestures[@"tap"]?@{@"parentHit":_gestures[@"tap"]}:@{};
            if(hasSubHandler){
                [self unbind:@"tap"];
                [self bind:@"tap" handler:^(ges_t g,$& n, dic_t p) {
                    CGPoint coords = [g locationInView:g.view];
                    //logPoint(@"click at", coords);
                    view_t o = self;
                    int size = o.subLayers?(int)[o.subLayers count]:0;
                    BOOL hitSub = NO;
                    for (int i=size-1; i>=0; i--) {
                        view_t sp = o.subLayers[i];
                        if(CGRectContainsPoint(sp.layer.frame, coords)){
                            if(sp.gestures[@"tap"]){
                                ges_f subHandler =sp.gestures[@"tap"];
                                subHandler(g,*sp.owner,@{});
                                hitSub = YES;
                                break;
                            }
                        }
                    }
                    if(!hitSub&&p[@"parentHit"]){
                        ges_f parentHandler =p[@"parentHit"];
                        parentHandler(g,n,@{});
                    }
                } opts:parentHit];
            }
        }
        
        [p addSubview:self];
        if(_src) [self setImage:_src];
        _parent = p;
        
        if(is_view(p)){
            view_t vp = (view_t)p;
            if(!vp.nodes)vp.nodes = marr(nil);
            marr_add(vp.nodes, self);
        }
        
        if(_slidable && _slideWithPages && _nodes){ // add pages
            int cnt = (int)[_nodes count];
            if(cnt){
                float w = self.bounds.size.width,
                h = self.bounds.size.height,
                pw = 16, ph = 20, cw = cnt * pw;
                if(cw<=w*0.6){ // show as dot
                    _pages = box({@((w-cw)/2.0f+self.frame.origin.x), @(h-ph+self.frame.origin.y), @(cw), @(ph), @1}).view();
                    style_t pstyle = {@0,@4,@8,@8,@0,@"#ffffff66",.corner=@4,.shadow=@"0 0 1 #00000099"};
                    for (int i = 0; i<cnt; i++)
                        box((style_t){@(i*pw)} > pstyle) >> _pages;
                    [(view_t)(_pages.nodes[0]) setStyles:{.bgcolor=@"#ffffffcc"}];
                    
                }else{ // show as label
                    _pages = label(sprintf(@"(1/%d)",cnt),
                                   (style_t){@((w-100)/2.0f+self.frame.origin.x), @(h-ph+self.frame.origin.y), @100, @(ph), @1,
                                       .color=@"#ffffff",.font=@"HelveticaNeue-CondensedBold,12",.align=@"center"}).view();
                }
                [p addSubview:_pages];
            }
        }
    }


}

-(view_t) root{
    view_base_t p = _parent;
    while (p && is_view(p) && ((view_t)p).parent) {
        p = ((view_t)p).parent;
    }
    return is_view(p)?p:nil;
}

-(void) _registerView{
    if(!__nodes) __nodes = mdic(nil);
    str_t cname = __controller ? __controller : @"__DEFAULT__";
    if(!__nodes[cname]) __nodes[cname] = mdic(nil);
    if(!_ID)_ID = sprintf(@"%@_%d",(_src?@"IMG":(_text?@"TXT":@"BOX")),__view_id);
    _NS = cname;
    if(_ID)
        __nodes[cname][_ID] = self;
    //NSLog(@"Register view : %@",_ID);
    if(!__idxmap) __idxmap = mdic(nil);
    __idxmap[@(_idx)] = self;
}


#pragma mark layer override
+ (Class) layerClass{
    return [LBLayer class];
}

#pragma mark delegate of textView

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if(!((textview_t)_textField).nowrap){
            ((UITextView*)_textField).text = sprintf(@"%@\r\n",((UITextView*)_textField).text);
            return YES;
        }else{
            [_textField resignFirstResponder];
            _textField.hidden = YES;
            _owner->text(((UITextView*)_textField).text);
            _owner->scrollBack();
            return NO;
        }
    }
    return YES;
}


#pragma mark delegate of uipickerviewdelegate

- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _textField.text = _textField.options[row];
    _owner->text(_textField.text);
    [_textField.picker resignFirstResponder];
    [_textField resignFirstResponder];
    _textField.hidden = YES;
    _owner->scrollBack();
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return  _textField.options?[_textField.options count]:0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _textField.options?_textField.options[row]:@"";
}

- (void)datePicked{
    UIDatePicker * picker = ((textview_t) _textField).datePicker;
    NSString * format = _owner->get(@"_dateFormat");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    ((textview_t) _textField).text = [formatter stringFromDate:picker.date];
}


@end

#pragma mark - Layer
@implementation LBLayer
@synthesize asSubLayer;
- (BOOL)containsPoint:(CGPoint)thePoint{
    return (asSubLayer)? NO:
    [super containsPoint:thePoint];
}

@end

@implementation LBShapeLayer
@synthesize type;
@end



#pragma mark - TextEdit

@implementation LBTextView
@synthesize inputView,inputAccessoryView,datePicker,picker,dateFormat,nowrap;
- (UIView *)inputView {
    return datePicker?datePicker:(picker?picker:inputView);
}
- (UIView *)inputAccessoryView {
    if (!inputAccessoryView && !picker && (datePicker || !nowrap)) {
        $&b = box({@0, @0, @320, @44, @0, @"#ECF0F1"})
        << (label(@"DONE", {@250, @0, @70, @44, @1, nil, @"#0088ff", .font=@"AvenirNextCondensed-DemiBold,18",.paddingTop=@10,.paddingLeft=@14})
            .bind(@"tap", ^(ges_t g, $& n, dic_t p) {
            $* owner = get_node(@"textEditViewOwner");
            if(owner){
                textview_t tv = owner->view().textField;
                NSString *value = tv.text;
                if(datePicker){
                    NSString * format = owner->get(@"_dateFormat");
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:format];
                    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
                    value = [formatter stringFromDate:datePicker.date];
                    [datePicker resignFirstResponder];
                }
                [tv resignFirstResponder];
                tv.hidden = YES;
                owner->text(value);
                remove_data(@"textEditViewOwner");
                owner->scrollBack();
            }
        }, @{}));
        inputAccessoryView = b.view();
    }
    return inputAccessoryView;
}
@end


@implementation LBBorder
+ (LBBorder *) border:(str_t)bd{
    LBBorder *def = [[LBBorder alloc] init];
    def.color = [@"FFFFFF00" colorValue];
    bd = str_regex_replace(bd, @"\\s+", @" ");
    arr_t parts = str_split(bd, @" ");
    int size = (int)[parts count];
    if(size==0)return def;
    
    if(str_matchs(parts[0],@"[0-9\\.]+"))
        def.width =str2f(parts[0]);
    
    for (int i=1; i<size; i++) {
        str_t p = parts[i];
        if(str_has(p, @"#") || str_has(p, @",")){
            def.color = [p colorValue];
        }else if(str_has(p, @".png")||str_has(p, @".jpg")){
            def.image = image_read(p);
            def.color = color_transparent();
        }else if(str_matchs(parts[i],@"[0-9\\.]+")){
            def.radius = str2f(parts[i]);
        }
    }
    return def;
}
+ (LBBorder *) border:(float)w color:(str_t)c radius:(float)r{
    LBBorder *def = [[LBBorder alloc] init];
    def.width = w;
    def.radius = r;
    if(str_has(c, @"#")){
        def.color = [c colorValue];
    }else{
        def.image = image_read(c);
        def.color = color_transparent();
    }
    return def;
}
- (str_t) toString{
    return sprintf(@"%f %@ %f",self.width,color2str(self.color),self.radius);
}
@end
@implementation LBShadow
+ (LBShadow *) shadow:(str_t)shd{
    LBShadow *def = [[LBShadow alloc] init];
    if(!shd)return def;
    str_t sd = str_has(shd, @",") ? str_split(shd,@",")[0]:shd;
    sd = str_regex_replace(sd, @"\\s+", @" ");
    arr_t p = str_split(sd, @" ");
    if (str_eq(p[0], @"inset")){
        def.inset = true;
        def.x = str2f(p[1]);
        def.y = str2f(p[2]);
        def.radius = str2f(p[3]);
        def.color = str2color(p[4]);
    }else{
        def.x = str2f(p[0]);
        def.y = str2f(p[1]);
        def.radius = str2f(p[2]);
        def.color = str2color(p[3]);
    }
    return def;
}
+ (LBShadow *) shadow:(bool)inset x:(float)x y:(float)y radius:(float)r color:(str_t)c{
    LBShadow *def = [[LBShadow alloc] init];
    def.inset = inset;
    def.x = x;
    def.y = y;
    def.radius = r;
    def.color = str2color(c);
    return def;
}
- (str_t) toString{
    return sprintf(@"%@%f %f %f %@",self.inset?@"inset ":@"",self.x,self.y,self.radius,color2str(self.color));
}
@end


@implementation HTTPRequest
- (id)init{
    self = [super init];
    self.raw = [[NSMutableData alloc] init];
    return self;
}
/**
 
 @example
 HTTPRequestHandler handler =^id (NSArray* res, NSDictionary* datas){
 NSLog(@"%@",res);
 return res;
 };
 [HTTPRequest call:@"GET" url:@"http://soyoes.com/seal/api/orders" params:nil handler:handler datas:nil];
 
 
 @example
 HTTPRequestHandler handler =^id (NSArray* res, NSDictionary* datas){
 NSLog(@"%@",res);
 return res;
 };
 [HTTPRequest call:@"POST" url:@"http://soyoes.com/seal/api/orders/test" params:@{
 @"firstname":@"YOUR_FIRST",
 @"lastname":@"YOUR_LAST",
 @"email":@"YOUR_MAIL@gmail.com",
 @"zipcode":@"200-3011",
 @"address":@"YOUR_ADDRESS_HERE",
 @"data":[UIImage imageNamed:@"ico_fb.png"]
 } handler:handler datas:nil];
 
 **/
+ (void)call:(str_t)method url:(str_t)url datas:(dic_t)datas handler:(HTTPRequestHandler)handler args:(dic_t)args{
    url = [HTTPRequest parseURL:url];
    HTTPRequest *req = [[HTTPRequest alloc] init];
    req.handler = handler;
    if(args)
        req.args = mdic(args);
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    if(!str_eq(@"GET", method)){
        [request setHTTPMethod: method];
        if(datas){
            NSData *postData;
            NSString *queryStr = [HTTPRequest makeQueryStr:datas];
            //NSLog(@"query = \n%@",queryStr);
            postData = [ NSData dataWithBytes:[queryStr UTF8String] length:strlen([queryStr UTF8String])];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            [request setHTTPBody: postData ];
        }
    }
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:req startImmediately:NO];
    [conn start];
}

#pragma mark -- private

+ (NSString *) makeQueryStr:(NSDictionary *)param{
    NSMutableString *query = [NSMutableString stringWithFormat:@""];
    for (NSString *key in param) {
        NSString *format = [query length] == 0 ? @"%@=%@":@"&%@=%@";
        NSObject *v = [param valueForKey:key];
        NSString *value = [v isKindOfClass:[NSDictionary class]] || [v isKindOfClass:[NSArray class]] || [v isKindOfClass:[NSData class]] ||[v isKindOfClass:[UIImage class]] ?
        [HTTPRequest pack:(NSArray *)v] : (NSString*)v;
        [query appendFormat:format, key, value];
    }
    return query;
}


+ (NSString *) pack:(NSObject *)data{
    if([data isKindOfClass:[UIImage class]]){
        //FIXME support JPG
        NSString *hex = [self packImage:(UIImage *)data];
        return hex;
    }else{
        NSData *byteData = nil;
        if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]]) {
            NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding ];
            byteData= [json dataUsingEncoding:NSUTF8StringEncoding];
        }else if([data isKindOfClass:[NSData class]]){
            byteData= (NSData *)data;
        }else{
            byteData= [(NSString*)data dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSMutableString *hex = [NSMutableString string];
        unsigned char *bytes = (unsigned char *)[byteData bytes];
        char temp[3];
        for (int i = 0; i < [byteData length]; i++) {
            temp[0] = temp[1] = temp[2] = 0;
            (void)sprintf(temp, "%02x", bytes[i]);
            [hex appendString:[NSString stringWithUTF8String: temp]];
        }
        return hex;
    }
}

+ (NSString *)packImage :(UIImage *)image{
    NSData * imageData = UIImagePNGRepresentation(image);
    NSString *hex = [[imageData base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return hex;
}

+ (NSString *)parseURL : (NSString*)url{
#ifdef API_SERVER
    return([url hasPrefix:@"http:"] || [url hasPrefix:@"https:"])?url:
        sprintf(@"%s%@",API_SERVER,url);
#else
    return url;
#endif
}

#pragma mark -- NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    [self.raw setLength:0];
    //NSLog(@"Response Code: %d", [response statusCode]);
    if (!([response statusCode] >= 200 && [response statusCode] < 300 && [response statusCode] != 204)) {
        NSLog(@"Failed to get Data.");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.raw appendData:data];
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
    //NSLog (@"HTTP Conn closed");
    NSError * err = nil;
    id res = [NSJSONSerialization JSONObjectWithData:self.raw options:NSJSONReadingMutableContainers error:&err];
    self.handler(res, self.args);
}

-(void) connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    //[activityIndicator stopAnimating];
    NSLog (@"Connection Failed with Error");
    self.handler(nil, self.args);
}



@end

