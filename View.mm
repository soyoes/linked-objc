//
//  View.m
//  liberobjc
//
//  Created by soyoes on 6/14/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//
//

/*
 TODO
 dashed
 rotate2d
*/

#import "Styles.h"
#import <math.h>
#import <string>
#import <sstream>
#import <algorithm>
#import <cctype>
#import <regex>
#import <iostream>
#import <map>
#import "Categories.h"
#import "View.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#import "Lang.h"

using namespace std;

#pragma mark - $View

@implementation View

-(id) initWithOwner:($*)owner rect:(CGRect)rect{
    self = [super initWithFrame:rect];
    _data = [[NSMutableDictionary alloc] init];
    _gestures = [[NSMutableDictionary alloc] init];
    _owner = owner;
    self.userInteractionEnabled = YES;
    return self;
}

-(void) gestureHandler:(UIGestureRecognizer*)ges{
    NSString *className = [[ges class] description];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(UI|GestureRecognizer)"
                                                                           options:NSRegularExpressionCaseInsensitive error:nil];
    className = [[regex stringByReplacingMatchesInString:className options:0 range:NSMakeRange(0, [className length]) withTemplate:@""] lowercaseString];
    //NSLog(@"ges : %@", className);
    if(_gestures!=nil && _gestures[className]!=nil){
        GestureHandler handler = _gestures[className];
        if(handler){
            View * v = (View*)ges.view;
            handler(ges, *_owner, [v.data valueForKey:@"gestureData"]);
        }
    }
}

-(void) switchEditingMode{
    if(_textField!=nil){
        if(_textField.hidden){
            $setData(@"textEditViewOwner",_owner->value());
            [self addSubview:_textField];//FIXME
            ((TextView*)_textField).text = _owner->text;
            _textField.hidden = NO;
            _owner->textLayer.hidden = YES;
            [_textField becomeFirstResponder];
            _owner->scrollTop(10);
        }else{
            _textField.hidden = YES;
            _owner->setText(((TextView*)_textField).text);
            [_textField resignFirstResponder];
            _owner->scrollBack();
        }
    }
}


+ (Class) layerClass{
    return [Layer class];
}

- (void)datePicked{
    UIDatePicker * picker = ((TextView*) _textField).datePicker;
    NSString * format = _owner->get(@"_dateFormat");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    //_owner->setText([formatter stringFromDate:picker.date]);
    ((TextView*) _textField).text = [formatter stringFromDate:picker.date];
}


#pragma mark delegate of textView

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if(!((TextView*)_textField).nowrap){
            ((UITextView*)_textField).text = [NSString stringWithFormat:@"%@\r\n",((UITextView*)_textField).text ];
            return YES;
        }else{
            [_textField resignFirstResponder];
            _textField.hidden = YES;
            _owner->setText(((UITextView*)_textField).text);
            _owner->scrollBack();
            return NO;
        }
    }
    return YES;
}


#pragma mark delegate of uipickerviewdelegate

- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _textField.text = _textField.options[row];
    _owner->setText(_textField.text);
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


@end

#pragma mark - Layer
@implementation Layer
@synthesize asSubLayer;
- (BOOL)containsPoint:(CGPoint)thePoint{
    return (asSubLayer)? NO:
    [super containsPoint:thePoint];
}

@end

@implementation ShapeLayer
@synthesize type;
@end



#pragma mark - TextEdit

@implementation TextView
@synthesize inputView,inputAccessoryView,datePicker,picker,dateFormat,nowrap;
- (UIView *)inputView {
    return datePicker?datePicker:(picker?picker:inputView);
}
- (UIView *)inputAccessoryView {
    if (!inputAccessoryView && !picker && (datePicker || !nowrap)) {
        $&b = box({0.0, 0.0, 320, 44.0, 0, "#ECF0F1"})
        << (label(@"DONE", {250, 0, 70, 44, 1, NULL, "#0088ff", .font="AvenirNextCondensed-DemiBold,18",.paddingTop=10,.paddingLeft=14})
            .bind(@"tap", ^(GR *g, $ & v, Dic * p) {
            $* owner = ($*)[$getData(@"textEditViewOwner") pointerValue];
            if(owner){
                TextView * tv = owner->view.textField;
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
                owner->setText(value);
                $removeData(@"textEditViewOwner");
                owner->scrollBack();
            }
        }, @{}));
        inputAccessoryView = b.view;
    }
    return inputAccessoryView;
}
@end


#pragma mark - SVG

vector<SVGPathCmd> SVG::str2cmds(const char* pathcmd){
    string svgpath(pathcmd);
    
    svgpath = regex_replace(svgpath, regex("[\\s+,]"), " ");
    svgpath = regex_replace(svgpath, regex("([A-Z])\\s+"), "$1");
    smatch m;
    regex e("\\b[MLCSQTAZ]*[\\d\\.]*\\b");
    vector<SVGPathCmd> cmds;
    SVGPathCmd cmd=(SVGPathCmd){};
    int cidx = 0;
    while (regex_search(svgpath,m,e)) {
        string o = m[0];
        char pref = o.at(0);
        if(pref>='A' && pref<'Z'){//CMD
            if(cmd.cmd){
                cmds.push_back(cmd);
                cmd = {};
                cidx = 0;
            }
            cmd.cmd = pref;
            cmd.coords[cidx++]=atof(o.substr(1).c_str());
        }else if(pref=='Z'){//VALUE
            cmds.push_back(cmd);
            cmds.push_back({'Z'});
            break;
        }else{
            cmd.coords[cidx++]=atof(o.c_str());
        }
        svgpath = m.suffix().str();
    }
    return cmds;
}

/**
 get svg path from svg path string.
 don't forget to release : CGPathRelease(path), after using.
 */
__attribute__((overloadable)) CGPathRef SVG::path(const char* svgpathcmd){
    vector<SVGPathCmd> cmds = SVG::str2cmds(svgpathcmd);
    return SVG::path(cmds);
}
__attribute__((overloadable)) CGPathRef SVG::path(std::vector<SVGPathCmd> cmds){
    CGMutablePathRef path = CGPathCreateMutable();
    for (auto c : cmds) {
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

vector<SVGPathCmd> SVG::tween(const char* path1, const char* path2,  float delta){
    vector<SVGPathCmd> cs1 = SVG::str2cmds(path1);
    vector<SVGPathCmd> cs2 = SVG::str2cmds(path2);
    vector<SVGPathCmd> cs;
    int size_min = MIN(cs1.size(),cs2.size());
    int size_max = MAX(cs1.size(),cs2.size());
    for (int i=0; i<size_min; i++) {
        SVGPathCmd  c1=cs1.at(i),c2=cs2.at(i),c=c1;
        for (int j=0; j<6; j++) {
            float cf1 = c1.coords[j]?c1.coords[j]:0,
            cf2 = c2.coords[j]?c2.coords[j]:0;
            if(cf1!=cf2) c.coords[j] = cf1 + (cf2-cf1)*delta;
        }
        c.cmd = c2.cmd;
        cs.push_back(c);
    }
    if(size_max!=size_min){
        vector<SVGPathCmd> cx = cs1.size()>cs2.size()? cs1:cs2;
        for (int i=size_min; i<size_max; i++) {
            cs.push_back(cx[i]);
        }
    }
    return cs;
}

const char * SVG::pathFromStyle(StyleDef *s){
    return SVG::pathFromStyle(s, false, 0, 0);
}
const char * SVG::pathFromStyle(StyleDef *s, bool customOrigin, float left, float top){
    float x1=customOrigin?left:s.x, y1=customOrigin?top:s.y;
    float x2=x1+s.w, y2=y1+s.h, r=s.corner;
    NSString * ss = r>0?
    [NSString stringWithFormat:@"M%f %f L%f %f C%f,%f %f,%f L%f %f Q%f,%f %f,%f L%f %f Q%f,%f %f,%f L%f,%f Q%f,%f %f,%f Z",
     x1+r,  y1,     //left-up corner p2
     x2-r,  y1,     //right-up corner p1
     x2,    y1,     //right-up corner cp
     x2,    y1+r,   //right-up corner p2
     x2,    y2-r,   //right-down corner p1
     x2,    y2,     //right-down corner cp
     x2-r,  y2,     //right-down corner p2
     x1+r,  y2,     //left-down corner p1
     x1,    y2,     //left-down corner cp
     x1,    y2-r,   //left-down corner p2
     x1,    y1+r,   //left-up corner p1
     x1,    y1,     //left-up corner cp
     x1+r,  y1      //left-up corner p2 close
     ]:[NSString stringWithFormat:@"M%f %f L%f %f L%f %f L%f %f Z", x1,y1, x2,y1, x2,y2, x1,y2];
    return cstr(ss);
}


#pragma mark - $deltas
typedef float delta_f(float);
float delta_linear(float progress){return progress;}
float delta_quad(float progress){return pow(progress, 2);}
float delta_quad5(float progress){return pow(progress, 5);}
float delta_circ(float progress){return 1 - sin(acos(progress));}
float delta_back(float progress){float x=1.5;return pow(progress, 2) * ((x + 1) * progress - x);}
float delta_bounce(float progress){for(float a=0, b=1; 1; a+=b, b/=2) {if(progress >= (7-4*a)/11)return pow(b, 2)-pow((11-6*a-11*progress)/4,2);}}
float delta_elastic(float progress){float x = 0.1;return pow(2, 10 * (progress-1)) * cos(20*M_PI*x/3*progress);}

map<NSString*, delta_f*> delta_funcs = {
	{@"linear",delta_linear},
	//accelerator2x     :o > >> >>> >>>> >>>>>
	{@"quad",delta_quad},
	//accelerator5x     :o > >>> >>>>> >>>>>>> >>>>>>>>>>>
	{@"quad5",delta_quad5},
	//throwing          :o >> > ... > >> >>> >>>>
	{@"circ",delta_circ},
	//bow - arrow       :<< < o > >> >>> >>>>
	{@"back",delta_back},
	//bounce            :< > < > < > o > >> >>> >>>>
	{@"bounce",delta_bounce},
	//elastic           :< > << >> <<< >>> o > >> >>> >>>>
	{@"elastic",delta_elastic},
};

float style_easeOut(NSString* deltaname, float progress){
    delta_f* func = delta_funcs[deltaname];
    return 1-func(1-progress);
}
float style_easeInOut(NSString* deltaname, float progress){
    delta_f* func = delta_funcs[deltaname];
    return (progress<=0.5) ? func(2*progress)/2 : (2-func(2*(1-progress)))/2;
}
typedef float style_f(NSString*, float);
map<NSString*, style_f*> style_funcs = {
    // reverse
	{@"easeOut",style_easeOut},
    // repeat 0~50% and reverse.
	{@"easeInOut",style_easeInOut}
};




#pragma mark - $


__attribute__((overloadable)) $::$():slidable(false),released(false){}
__attribute__((overloadable)) $::$(id _src):src(_src),slidable(false),released(false){}
__attribute__((overloadable)) $::$(bool scroll):scrollable(scroll),slidable(false),released(false){}
__attribute__((overloadable)) $::$(const char* path):svg(str(path)),slidable(false),released(false){}
// Constructor
$::~$(){
    if(ID && !released){
        //NSLog(@"Free view : %@",ID);
        //if(pages) pages->remove();
//        nodes=nil;
//        src=nil;
//        svg=nil;
//        text=nil;
//        layer=nil;
//        textLayer=nil;
//        imageLayer=nil;
//        contentLayer=nil;
//        maskLayer=nil;
//        frameLayer=nil;
//        subLayers=nil;
//        animator =nil;
//        behaviors=nil;
//        view=nil;
//        dummys=nil;
//        ID=nil;
//        NS=nil;
        ID=nil;
        released=true;
    }
}

$* $::initView(Styles s){
    styles = [StyleDef style:s];
    if(!view){
        CGRect rect =CGRectMake(styles.x, styles.y, styles.w, styles.h);
        view = [[View alloc] initWithOwner:this rect:rect];
        //view.userInteractionEnabled = YES;
    }
    layer = view.layer;
    layer.zPosition = styles.z;

    frameLayer = [CALayer layer];
    frameLayer.frame = view.bounds;
    [layer addSublayer:frameLayer];
    
    contentLayer = [CALayer layer];
    contentLayer.frame = view.bounds;
    contentLayer.masksToBounds = YES;
    [frameLayer addSublayer:contentLayer];
    
    if(styles.ID)ID = styles.ID;
    registerView(this);
    
    return this;
}

__attribute__((overloadable))
$& $::setStyle(Styles s){
    
    bool inited = ID!=nil;

    /*
    if(s.padding){
        s.paddingLeft=s.padding;
        s.paddingTop=s.padding;
        s.paddingRight=s.padding;
        s.paddingBottom=s.padding;
    }*/
    
    if(!inited) initView(s);
    bool rendered = parent != nullptr;
    
    
    StyleDef* ss = rendered ? [StyleDef style:s] : styles;
    
    layer.opacity = (1-ss.alpha);
    
    bool need_redraw = !rendered || (rendered && (ss.x||ss.y||ss.w||ss.h||ss.corner)) || ss.path;
    if(need_redraw){
        float ww = ss.w ? ss.w : styles.w;
        float hh = ss.h ? ss.h : styles.h;
        float xx = ss.x ? ss.x : styles.x;
        float yy = ss.y ? ss.y : styles.y;
        view.frame = {{xx,yy},{ww,hh}};
        layer.bounds = view.bounds;
        frameLayer.frame = layer.bounds;
        contentLayer.frame = layer.bounds;
        textLayer.frame = layer.bounds;
        styles.x = xx;
        styles.y = yy;
        styles.w = ww;
        styles.h = hh;
        styles.corner = ss.corner;

        if(ss.path){
            svg = ss.path;
            setSvgPath(cstr(svg));
            styles.path = ss.path;
        }else{
            setMask([UIBezierPath bezierPathWithRoundedRect:contentLayer.bounds cornerRadius:ss.corner].CGPath);
            if(!src){
                //contentLayer.masksToBounds = YES;
                contentLayer.cornerRadius = ss.corner;
            }
        }
    }
    
    if(ss.bgcolor!=nil){
        const char* bgcolor = cstr(ss.bgcolor);
        if(strhas(bgcolor, ":")){//gradient
            setGradient(bgcolor);
        }else{
            setBgcolor(bgcolor);
        }
        styles.bgcolor = ss.bgcolor;
    }
    
    if(ss.shadows){
        clearShadows();
        //[styles setShadowStyle:s.shadow];
        for(ShadowDef*sd in ss.shadows){
            addShadow(sd);
        }
        styles.shadows = ss.shadows;
    }
    
    if(ss.borders){
        clearBorders();
        for(BorderDef*b in ss.borders){
            addBorder(b);
        }
        styles.borders = ss.borders;
    }
    
    /*
    if(ss.outline){
        setOutline(ss.outline);
    }*/
    
    CGAffineTransform transf;
    bool trasDefined=false;
    if(ss.scaleX!=1 || ss.scaleY!=1){
        trasDefined = true;
        transf = CGAffineTransformMakeScale(ss.scaleX, ss.scaleY);
        styles.scaleX = ss.scaleX;
        styles.scaleY = ss.scaleY;
    }
    
    if(ss.flip){
        CGAffineTransform flip;
        if (ss.flip == m_filpH) {
            flip =CGAffineTransformMake(view.transform.a * -1, 0, 0, 1, view.transform.tx, 0);
            transf = trasDefined? CGAffineTransformConcat(transf,flip):flip;
            trasDefined = true;
        }else if(ss.flip == m_filpV){
            flip = CGAffineTransformMake(1, 0, 0, view.transform.d * -1, 0, view.transform.ty);
            transf = trasDefined? CGAffineTransformConcat(transf,flip):flip;
            trasDefined = true;
        }
        styles.flip = ss.flip;
    }
    
    if(ss.rotate){
        CGAffineTransform rotate = CGAffineTransformMakeRotation(radians(ss.rotate));
        transf = trasDefined? CGAffineTransformConcat(transf,rotate):rotate;
        trasDefined = true;
        styles.rotate = ss.rotate;
    }
    
    if(trasDefined)
        view.transform = transf;
    
    if(ss.rotate3d){
        Rotate3DOpt o3 = r3dopt(cstr(ss.rotate3d));
        layer.anchorPoint = CGPointMake(o3.axisX, o3.axisY);
        CATransform3D rt = CATransform3DIdentity;
        rt.m34 = 1.0f / (-1*o3.resp);
        rt = CATransform3DRotate(rt, radians(o3.degree), o3.x, o3.y, o3.z);
        rt = CATransform3DTranslate(rt, o3.transX, o3.transY, o3.transZ);
        layer.transform = rt;//CATransform3DConcat
        styles.rotate3d = ss.rotate3d;
    }
    
    if(rendered && text){
        setTextstyle(ss);
    }
    //if(initedBeforeSetting) *&styles = style(&s, &styles);
    //if(initedBeforeSetting) [styles mergeStyle:styles];
    
    return *this;
}
__attribute__((overloadable))
$& $::setStyle(Styles st, Styles *ex){
    Styles o = style(&st,ex);
    return setStyle(o);
}
__attribute__((overloadable))
$& $::setStyle(Styles st, initializer_list<Styles *>ext){
    Styles o = st;
    for (Styles *ex  : ext) {
        style(&o,ex);
    }
    return setStyle(o);
}
$& $::bind(NSString* event, GestureHandler handler, NSDictionary * opts){
    if([_events indexOfObject:event]==NSNotFound || handler==NULL)
        return *this;
    view.gestures[event] = (id) handler;
    event = [event stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[event substringToIndex:1] uppercaseString]];
    NSString * className = [NSString stringWithFormat:@"UI%@GestureRecognizer",event];
    UIGestureRecognizer *gesture = [[NSClassFromString(className) alloc]
                                    initWithTarget:view action:@selector(gestureHandler:)];
    
    
    [view setUserInteractionEnabled:YES];
    /*
     TODO multipleTouchEnabled
     exclusiveTouch
     */
    if(opts!=nil && [[opts allKeys] count]>0){
        [view.data setValue:opts forKey:@"gestureData"];
    }
    
    if([event isEqualToString:@"swipe"]){
        UISwipeGestureRecognizer * gr = [[UISwipeGestureRecognizer alloc] initWithTarget:view action:@selector(gestureHandler:)];
        [gr setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [view addGestureRecognizer:gr];
        [(UISwipeGestureRecognizer*)gesture setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    }
    
    [view addGestureRecognizer:gesture];
    return *this;
}
$& $::unbind(NSString* event){
    if(view && view.gestures)
    [view.gestures removeObjectForKey:event];
    //mask removeGestureRecognizer:<#(UIGestureRecognizer *)#>
    //FIXME remove event
    return *this;
}

$& $::dragable(GestureHandler onDrag, GestureHandler onEnd){
    bind(@"pan",^(GR *ges,$& v, Dic *params) {
        UIPanGestureRecognizer * r = (UIPanGestureRecognizer *) ges;
        View *m = r.view;
        if(r.state == UIGestureRecognizerStateEnded){
            [m.data removeObjectForKey:@"diffX"];
            [m.data removeObjectForKey:@"diffY"];
            onEnd(r,v,params);
        }else{
            CGPoint trans = [r translationInView:view];
            if(![m.data valueForKey:@"diffX"]){
                [m.data setValue:@(trans.x-m.owner->view.center.x) forKey:@"diffX"];
                [m.data setValue:@(trans.y-m.owner->view.center.y) forKey:@"diffY"];
            }
            m.owner->view.center = CGPointMake(trans.x-[[m.data valueForKey:@"diffX"] floatValue], trans.y-[[m.data valueForKey:@"diffY"] floatValue]) ;
            onDrag(r,v,params);
        }
    },@{});
    return *this;
}

CGRect $::rect(){
    return CGRectMake(styles.x, styles.y, styles.w, styles.h);
}

void $::remove(){
    //if(view) [view removeFromSuperview];
    $::removeView(this);
    
    /*
    $setTimeout(1000,^void(Dic*d){
        if(d[@"o"]){
            $* o = ($*)[d[@"o"] pointerValue];
            if(!o->released && o->ID)
                delete o;
        }}, @{@"o":[NSValue valueWithPointer:this]});
     */
    if(this->ID && !this->released)  delete this;
}

NSValue* $::value(){
    return [NSValue valueWithPointer:this];
}

$* $::root(){
    if(!released && ID){
        View * v = view;
        while (v.superview) {
            if([v.superview isKindOfClass:[View class]]){
                v = v.superview;
            }else{
                return v.owner;
            }
        }
    }
    return nullptr;
    /*
    if(!released && parent!=nullptr && ID!=nil){
        cout << "go to parent :" << ID << endl;
        return parent->root();
    }else return ID?this:nullptr;
    */
}

#pragma mark $ animator

/**
 
 bounds : @[@left, @top, @right, @bottom], all of them are float
 */
$& $::startMove(){
    if(!behaviors || !view.superview)
        return *this;
    //you have to init animator out side.
    if(!animator)
        animator = [[UIDynamicAnimator alloc] initWithReferenceView:view.superview];
    for (id b in behaviors) {
        [animator addBehavior:b];
    }
    
    return *this;
}

/**
 Gravity animation
 opt.angle  -> _.angle in degree, float 0~360
 opt.speed  -> _.magnitude 1~N float
 opt.x      -> _.gravityDirection.x float
 opt.y      -> _.gravityDirection.y float
 */
$& $::addGravity(Dic *opt){
    if(!behaviors) behaviors = [[MArr alloc] init];
    UIGravityBehavior * b =[[UIGravityBehavior alloc] initWithItems:@[view]];
    if(opt){
        if(opt[@"angle"])
            b.angle = radians([opt[@"angle"] floatValue]);
        if(opt[@"speed"])
            b.magnitude = [opt[@"speed"] floatValue];
        if(opt[@"x"]&&opt[@"y"])
            b.gravityDirection = CGVectorMake([opt[@"x"] floatValue], [opt[@"y"] floatValue]);
    }
    [behaviors addObject:b];
    return *this;
}

/*
 opt.angle  -> (angle) in degree, float 0~360
 opt.speed  -> (magnitude) 1~N float
 opt.x : (pushDirection.x) direction targetX
 opt.y : (pushDirection.y) direction targetY
 opt.once : (mode), bool, default true
 */
$& $::addPush(Dic *opt){
    if(!behaviors) behaviors = [[MArr alloc] init];
    UIPushBehaviorMode mode = opt&&opt[@"once"]==@YES ?UIPushBehaviorModeInstantaneous:UIPushBehaviorModeContinuous;
    UIPushBehavior *b = [[UIPushBehavior alloc] initWithItems:@[view] mode:mode];
    if(opt[@"angle"])
        b.angle = radians([opt[@"angle"] floatValue]);
    if(opt[@"speed"])
        b.magnitude = [opt[@"speed"] floatValue];
    if(opt[@"x"]&&opt[@"y"])
        b.pushDirection = CGVectorMake([opt[@"x"] floatValue], [opt[@"y"] floatValue]);
    [behaviors addObject:b];
    return *this;
}

/*
 opt.x : transport target point.x
 opt.y : transport target point.y
 opt.damping : (damping) float 0~1, default 0.5
 */
$& $::addSnap(Dic *opt){
    if(!opt[@"x"] || !opt[@"y"])
        return *this;
    if(!behaviors) behaviors = [[MArr alloc] init];
    UISnapBehavior *b = [[UISnapBehavior alloc] initWithItem:view snapToPoint:CGPointMake([opt[@"x"] floatValue], [opt[@"y"] floatValue])];
    if(opt[@"damping"]) b.damping =[opt[@"damping"] floatValue];
    [behaviors addObject:b];
    return *this;
}

/*
 set collision bounds of animation
 opts.points : float array len>=2, @[point0.x,point0.y,point1.x,point1.y...]
 nil : use animator.target.bounds.
 len=2 : use p1~p2 rectangle
 len>2 : use p1~pN polygon
 opts.svg   : provide path by giving svg path cmd, e.g. "M100 100 L0 200..."
 opts.mode : (collisionMode) UICollisionBehaviorModeItems|UICollisionBehaviorModeBoundaries|UICollisionBehaviorModeEverything
 */
$& $::addCollision(Dic *opt){
    //if(!view.superview)return *this;
    if(!behaviors) behaviors = [[MArr alloc] init];
    
    UICollisionBehavior *b = [[UICollisionBehavior alloc] initWithItems:@[view]];
    if(opt){
        if(opt[@"points"]){
            int len = [opt[@"points"] count];
            if(len>4 && len%2==0){
                CGMutablePathRef path = CGPathCreateMutable();
                for(int i=0;i<len;i+=2){
                    CGPathAddLineToPoint(path, NULL, [opt[@"points"][i] floatValue], [opt[@"points"][i+1] floatValue]);
                }
                CGPathCloseSubpath(path);
                [b addBoundaryWithIdentifier:@"polygon" forPath:[UIBezierPath bezierPathWithCGPath:path]];
                CGPathRelease(path);
            }else if (len==4){
                [b addBoundaryWithIdentifier:@"rect"
                                   fromPoint:CGPointMake([opt[@"points"][0] floatValue], [opt[@"points"][1] floatValue])
                                     toPoint:CGPointMake([opt[@"points"][2] floatValue], [opt[@"points"][3] floatValue])];
            }
            else b.translatesReferenceBoundsIntoBoundary = YES;
            b.collisionMode = UICollisionBehaviorModeEverything;
        }else if(opt[@"svg"]){
            CGPathRef path = SVG::path(cstr(opt[@"svg"]));
            [b addBoundaryWithIdentifier:@"svg" forPath:[UIBezierPath bezierPathWithCGPath:path]];
            CGPathRelease(path);
        }
        if(opt[@"mode"]) b.collisionMode = (UICollisionBehaviorMode)[opt[@"mode"] intValue];
    }else{
        b.translatesReferenceBoundsIntoBoundary = YES;
    }
    [behaviors addObject:b];
    return *this;
}


char* deltacolor(const char* from, const char* to, float delta){
    RGBA o = rgba(from);
    RGBA t = rgba(to);
    return colorfstr((o.r+(t.r-o.r)*delta)/255.0f, (o.g+(t.g-o.g)*delta)/255.0f, (o.b+(t.b-o.b)*delta)/255.0f, (o.a+(t.a-o.a)*delta)/255.0f);
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
$& $::animate(float ms, Styles s){return animate(ms, s, ^($&v){}, @{});}
$& $::animate(float ms, Styles s, AnimateFinishedHandler onEnd){return animate(ms, s, ^($&v){}, @{});}
$& $::animate(float ms, Styles s, Dic* opts){return animate(ms, s, ^($&v){}, opts);}
$& $::animate(float ms, Styles s, AnimateFinishedHandler onEnd, Dic* opts){
    return animate(ms, s, nullptr, onEnd, opts);
}

$& $::animate(float ms, Styles s, const char* svgpath, AnimateFinishedHandler onEnd, Dic* opts){
    
    StyleDef *ss = [StyleDef style:s];
    set(@"orgStyle", [styles duplicate]);
    set(@"targetStyle", ss);
    
    //cout << "SET ORG" << endl;
    
    if(svgpath){
        set(@"orgSvgPath", svg?svg: str(SVG::pathFromStyle(styles)));
        NSString * svg_path = str(svgpath);
        set(@"targetSvgPath", svg_path);
        svg = svg_path;
    }
    
    animate(ms, ^($& v, float delta) {
        StyleDef *org = v.get(@"orgStyle");
        StyleDef *tar = v.get(@"targetStyle");
        Styles s = nos;
        //x, y, w, h
        if(tar.x || tar.y || tar.w || tar.h){
            s.x = tar.x?org.x+(tar.x-org.x)*delta:org.x,
            s.y = tar.y?org.y+(tar.y-org.y)*delta:org.y,
            s.w = tar.w?org.w+(tar.w-org.w)*delta:org.w,
            s.h = tar.h?org.h+(tar.h-org.h)*delta:org.h;
        }
        if(tar.alpha) s.alpha = org.alpha+(tar.alpha-org.alpha)*delta;
        if(tar.corner)s.cornerRadius = org.corner+(tar.corner-org.corner)*delta;
        if(tar.rotate)s.rotate = org.rotate+(tar.rotate-org.rotate)*delta;
        if(tar.rotate3d){
            Rotate3DOpt o3d = r3dopt(org.rotate3d?cstr(org.rotate3d):"0,0,0,0,500,0.5,0.5");
            Rotate3DOpt t3d = r3dopt(cstr(tar.rotate3d));
            s.rotate3d = r3dstr(o3d.degree+(t3d.degree-o3d.degree)*delta, t3d.x, t3d.y,
                                o3d.resp+(t3d.resp-o3d.resp)*delta,
                                o3d.axisX+(t3d.axisX-o3d.axisX)*delta,
                                o3d.axisX+(t3d.axisY-o3d.axisY)*delta,
                                o3d.transX+(t3d.transX-o3d.transX)*delta,
                                o3d.transY+(t3d.transY-o3d.transY)*delta);
        }
        if(tar.bgcolor)
            s.bgcolor = deltacolor(cstr(org.bgcolor), cstr(tar.bgcolor), delta);
        if(tar.color)
            s.color = deltacolor(cstr(org.color), cstr(tar.color), delta);
        
        if(tar.shadows && [tar.shadows count]){
            
            ShadowDef* osd = org.shadows?org.shadows[0]:[ShadowDef shadow:"0 0 0 #00000000"];
            ShadowDef* tsd = tar.shadows[0];
            const char* clr = rgba_equals(osd.color,tsd.color)?
                rgba2hex(tsd.color):deltacolor(rgba2hex(osd.color), rgba2hex(tsd.color), delta);
            s.shadow = [[ShadowDef shadow:tsd.inset
                                       x:osd.x+(tsd.x-osd.x)*delta
                                       y:osd.y+(tsd.y-osd.y)*delta
                                  radius:osd.radius+(tsd.radius-osd.radius)*delta color:clr] toString];
            /*
            s.shadow = shadstr(tsd.inset, osd.x+(tsd.x-osd.x)*delta,
                               osd.y+(tsd.y-osd.y)*delta,
                               osd.radius+(tsd.radius-osd.radius)*delta,
                               clr);
            */
        }
        if(tar.borders){
            BorderDef* ob = org.borders?org.borders[0]:[BorderDef border:"0 solid #00000000 0"];
            BorderDef* tb = tar.borders[0];
            const char* clr = rgba_equals(ob.color,tb.color)?
                rgba2hex(tb.color):deltacolor(rgba2hex(ob.color), rgba2hex(tb.color), delta);
            s.border = [[BorderDef border:ob.width+(tb.width-ob.width)*delta
                                     type:tb.type color:clr radius:ob.radius+(tb.radius-ob.radius)*delta] toString];
            /*
            s.border = bordstr(ob.w+(tb.w-ob.w)*delta, tb.style, clr, ob.radius+(tb.radius-ob.radius)*delta);
             */
        }
        if(svgpath){
            const char* osv = cstr(get(@"orgSvgPath"));
            const char* tsv = cstr(get(@"targetSvgPath"));
            vector<SVGPathCmd> cmds = SVG::tween(osv, tsv, delta);
            CGPathRef path = SVG::path(cmds);
            //styles = s;
            //v.svg = str(svgpath);
            s.path = svgpath;
            v.setStyle(s);
            setMask(path);
            //setStyle(s);
        }else
            v,setStyle(s);
        
        //cout << "trans : " << delta <<"|" << org.corner << "," << s.cornerRadius << "|" << s.w << "," << s.h << endl;
        
    }, onEnd, opts);
    return *this;
    
}

$& $::animate(float ms, AnimateStepHandler onStep, AnimateFinishedHandler onEnd){return animate(ms, onStep, onEnd, @{});}

$& $::animate(float ms, AnimateStepHandler onStep, AnimateFinishedHandler onEnd, Dic*opts){
    //var ele = this;
    if(opts[@"delay"]){
        float delay = [opts[@"delay"] floatValue];
        MDic * newOpt = [MDic dictionaryWithDictionary:opts];
        [newOpt removeObjectForKey:@"delay"];
        $setTimeout(delay,^void(Dic*d){
            if(d[@"o"]){
                $* o = ($*)[d[@"o"] pointerValue];
                o->animate(ms, d[@"onStep"], d[@"onEnd"], d[@"opts"]);
            }}, @{@"o":[NSValue valueWithPointer:this], @"opts":newOpt, @"onStep":onStep, @"onEnd":onEnd, @"ms":@(ms)});
        return *this;
    }
    long long start = milliseconds();
    NSString* delta_func_name = opts[@"delta"]?opts[@"delta"]:@"linear";
    NSString* style_func = opts[@"style"]?opts[@"style"]:@"easeIn";
    const float interval = 16;
    int times = ms/interval;
    cout << "times = " << times << endl;
    $setInterval(interval, ^BOOL(NSDictionary*d, int i){
        long long start = [d[@"start"] longLongValue];
        float duration = [d[@"duration"] floatValue];
        long long current = milliseconds();
        long passed = current - start;
        float progress = passed / duration;
        if (progress > 1) progress = 1;
        
        
        NSString* deltaname =d[@"delta_func"];
        
        delta_f* deltaf = delta_funcs[deltaname];
        
        float delta;
        
        if(![d[@"style_func"] isEqualToString:@"easeIn"]){
            style_f* stylef = style_funcs[d[@"style_func"]];
            delta = stylef(d[@"delta_func"],progress);
        }else{
            delta = deltaf(progress);
        }
        
        //NSLog(@"Delta: %@, %f  -  %f", deltaname, progress, delta);
        
        $* o = ($*) [d[@"o"] pointerValue];
        if(d[@"onStep"]){
            AnimateStepHandler onstep = d[@"onStep"];
            onStep(*o, delta);
        }
        int times = [d[@"times"] intValue];
        if(progress >= 1 || i>times){
            if(onEnd)onEnd(*o);
            return NO;
        }else return YES;
        
    }, @{@"o":[NSValue valueWithPointer:this],@"times":@(times), @"start":@(start), @"duration":@(ms), @"delta_func":delta_func_name, @"style_func":style_func, @"onStep":onStep, @"onEnd":onEnd});
    
    return *this;
}


#pragma mark $ operator

__attribute__((overloadable)) $& $::operator>>($& p){
    //    cout << [ID UTF8String] << " >> " << [p.ID UTF8String] << endl;
    if(&p){
        if(subLayers){
            BOOL hasSubHandler = NO;
            for (NSValue*v in subLayers) {
                $* vp =($*)[v pointerValue];
                ((Layer*)vp->layer).asSubLayer = YES;
                [layer addSublayer:vp->layer];
                if(vp->view.gestures && vp->view.gestures[@"tap"]){
                    hasSubHandler = YES;
                }
            }
            Dic * parentHit = view.gestures&&view.gestures[@"tap"]?@{@"parentHit":view.gestures[@"tap"]}:@{};
            if(hasSubHandler){
                unbind(@"tap").
                bind(@"tap", ^(GR *g,$& o, Dic *p) {
                    CGPoint coords = [g locationInView:g.view];
                    //logPoint(@"click at", coords);
                    int size = o.subLayers?[o.subLayers count]:0;
                    BOOL hitSub = NO;
                    for (int i=size-1; i>=0; i--) {
                        $* sp = ($*)[o.subLayers[i] pointerValue];
                        if(CGRectContainsPoint(sp->layer.frame, coords)){
                            //NSLog(@"id=%@",sp->ID);
                            if(sp->view.gestures[@"tap"]){
                                GestureHandler subHandler =sp->view.gestures[@"tap"];
                                subHandler(g,*sp,@{});
                                hitSub = YES;
                                break;
                            }
                        }
                    }
                    if(!hitSub&&p[@"parentHit"]){
                        GestureHandler parentHandler =p[@"parentHit"];
                        parentHandler(g,o,@{});
                    }
                }, parentHit);
            }
        }
        
        [p.view addSubview:view];
        if(src)setImage(src);
        parent = &p;
        if(!p.nodes)p.nodes = [[NSMutableArray alloc] init];
        [p.nodes addObject:[NSValue valueWithPointer:this]];
        if(slidable==true && nodes){ // add pages
            int cnt = [nodes count];
            if(cnt){
                float w = view.bounds.size.width,
                h = view.bounds.size.height,
                pw = 16, ph = 20, cw = cnt * pw;
                if(cw<=w*0.6){ // show as dot
                    pages = &box({static_cast<float>((w-cw)/2.0f+view.frame.origin.x), static_cast<float>(h-ph+view.frame.origin.y), cw, ph, 1});
                    Styles pstyle = {0,4,8,8,0,"#ffffff66",.cornerRadius=4,.shadow="0 0 1 #00000099"};
                    for (int i = 0; i<cnt; i++)
                        box({i*pw}, &pstyle) >> *pages;
                    (*pages)[0]->setStyle({.bgcolor="#ffffffcc"});
                    
                }else{ // show as label
                    pages = &label([NSString stringWithFormat:@"(1/%d)",cnt],
                                   {static_cast<float>((w-100)/2.0f+view.frame.origin.x), static_cast<float>(h-ph+view.frame.origin.y), 100, ph, 1,
                                       .color="#ffffff", .font="HelveticaNeue-CondensedBold,12",.textAlign="center"});
                }
                *pages >> p;
            }
        }
    }
    return *this;
}
__attribute__((overloadable)) $& $::operator>>(UIView*p){
    //FIXME solve sublayers
    if(p){[p addSubview:view];if(src)setImage(src);}
    return *this;
}
__attribute__((overloadable)) $& $::operator<<($& p){
    p >> *this;
    return *this;
}

$* $::operator[](int idx){
    if(nodes && [nodes count]>idx){
        return ($*)[[nodes objectAtIndex:idx] pointerValue];
    }
    return NULL;
}

//insert layer into super
$& $::operator>($&p){
    if(&p){
        //[p.layer addSublayer:layer];
        if(src)setImage(src);
        parent = &p;
        if(!p.subLayers)p.subLayers = [[NSMutableArray alloc] init];
        [p.subLayers addObject:[NSValue valueWithPointer:this]];
    }
    return *this;
}
//append layer
$& $::operator<($&p){
    p > *this;
    return *this;
}

#pragma mark $ data

id $::get(NSString* key){
    if(view){return [view.data valueForKey:key];}
    return nil;
}
float $::getFloat(NSString*key){id r = get(key); return r? [r floatValue]:0;}
int $::getInt(NSString*key){id r = get(key); return r? [r intValue]:0;}
__attribute__((overloadable)) $& $::set(NSString*key, id value){
    if(view){[view.data setValue:value forKey:key];}
    return *this;
}
__attribute__((overloadable)) $& $::set(Dic * p){
    if(view&&p){for (id k in p) {view.data[k] = p[k];}}
    return *this;
}

$& $::del(id key){
    if(view){
        if([key isKindOfClass:[NSString class]])
            [view.data removeObjectForKey:key];
        else if([key isKindOfClass:[NSArray class]]){
            for (NSString *k in (NSArray*)key) {
                [view.data removeObjectForKey:k];
            }
        }
    }
    return *this;
}

#pragma mark $ drawing
/*
void $::setBorder(const char*border){
    if(!border)return;
    
    BorderlineOpt bo = bordopt(border);
    styles.borderWidth = bo.w;
    if(bo.color) styles.borderColor = bo.color;
    if(bo.radius) styles.cornerRadius = bo.radius;
    styles.borderStyle = bo.style;
    //cout << "border.color" << styles.borderColor << endl;
    
    ShapeLayer * borderLayer = [ShapeLayer layer];
    borderLayer.type = @"border";
    borderLayer.path = maskLayer.path;
    //string bc(styles.borderColor);
    //const char* bc =styles.borderColor;
    cout <<  "border.color" << bo.color << endl;
    borderLayer.strokeColor=(strhas(styles.borderColor, "#")||strhas(styles.borderColor, ","))?
        //bc.find("#")!=string::npos || bc.find(",")!=string::npos ?
        str2color(styles.borderColor).CGColor:[UIColor colorWithPatternImage:[UIImage imageNamed:str(styles.borderColor)]].CGColor;
    borderLayer.lineWidth=styles.borderWidth;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    NSLog(@"border= %s, %@, %f", styles.borderColor, borderLayer.strokeColor,borderLayer.lineWidth);
    borderLayer.lineCap = kCALineCapSquare;
    borderLayer.lineJoin = kCALineJoinRound;
    [frameLayer addSublayer:borderLayer];
}*/

void $::addBorder(BorderDef*bo){
    if(!bo)return;
    ShapeLayer * borderLayer = [ShapeLayer layer];
    borderLayer.type = @"border";
    borderLayer.path = maskLayer.path;
    borderLayer.strokeColor = rgba_empty(bo.color)==true?
        (bo.image?[UIColor colorWithPatternImage:bo.image].CGColor:
         [UIColor clearColor].CGColor) : rgba_color(bo.color).CGColor;
    borderLayer.lineWidth=bo.width;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.lineCap = kCALineCapSquare;
    borderLayer.lineJoin = kCALineJoinRound;
    [frameLayer addSublayer:borderLayer];
}
void $::clearBorders(){
    NSEnumerator *enumerator = [frameLayer.sublayers reverseObjectEnumerator];
    for (CALayer *la in enumerator){
        if([la isKindOfClass:[ShapeLayer class]]
           && [@"border" isEqualToString:((ShapeLayer*)la).type]){
            [la removeFromSuperlayer];
        }
    }
}



void $::setBgcolor(const char* color){
    contentLayer.backgroundColor=str2color(color).CGColor;
}

/**
 format :[inset] x y radius [color]
 */
/*
void $::setShadow(const char* shadow){
    if(shadow){
        ShadowOpt opt = shadopt(shadow);
        UIColor * cl = opt.color?str2color(opt.color):[UIColor darkGrayColor];
        view.clipsToBounds = NO;
        if(opt.inset){
            ShapeLayer * shad = [ShapeLayer layer];
            shad.type = @"shadow";
            shad.zPosition = 8;
            shad.path = maskLayer.path;
            shad.strokeColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            shad.fillColor = [UIColor clearColor].CGColor;
            shad.lineWidth = MAX(opt.x, opt.y);
            shad.shadowOffset = CGSizeMake(opt.x/2, opt.y/2);
            shad.shadowRadius = opt.radius;
            shad.shadowOpacity = 1.0;
            shad.shadowColor = cl.CGColor;
            CGRect fr = CGPathGetPathBoundingBox(maskLayer.path);
            float w = fr.size.width,h = fr.size.height;
            shad.transform = CATransform3DMakeScale((2.0f+w)/w, (2.0f+h)/h, 1);
            shad.position = (CGPoint){-1,-1};
            [contentLayer addSublayer:shad];
            shad = nil;
        }else{
            ShapeLayer *shad = [ShapeLayer layer];
            shad.type = @"shadow";
            shad.path=maskLayer.path;
            shad.shadowOffset = CGSizeMake(opt.x, opt.y);
            shad.shadowRadius = opt.radius;
            shad.shadowColor = cl.CGColor;
            shad.shadowOpacity = 1.0;
            [frameLayer insertSublayer:shad atIndex:0];
            shad = nil;
        }
        cl = nil;
    }else{
        clearShadows();
    }
}
 */

void $::addShadow(ShadowDef* opt){
    if(opt){
        UIColor * cl = rgba_empty(opt.color)?[UIColor darkGrayColor]:rgba_color(opt.color);
        view.clipsToBounds = NO;
        if(opt.inset){
            ShapeLayer * shad = [ShapeLayer layer];
            shad.type = @"shadow";
            shad.zPosition = 8;
            shad.path = maskLayer.path;
            shad.strokeColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            shad.fillColor = [UIColor clearColor].CGColor;
            shad.lineWidth = MAX(opt.x, opt.y);
            shad.shadowOffset = CGSizeMake(opt.x/2, opt.y/2);
            shad.shadowRadius = opt.radius;
            shad.shadowOpacity = 1.0;
            shad.shadowColor = cl.CGColor;
            CGRect fr = CGPathGetPathBoundingBox(maskLayer.path);
            float w = fr.size.width,h = fr.size.height;
            shad.transform = CATransform3DMakeScale((4.0f+w)/w, (4.0f+h)/h, 1);
            shad.position = (CGPoint){-2,-2};
            [contentLayer addSublayer:shad];
            shad = nil;
        }else{
            ShapeLayer *shad = [ShapeLayer layer];
            shad.type = @"shadow";
            shad.path=maskLayer.path;
//            shad.fillColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            shad.shadowOffset = CGSizeMake(opt.x, opt.y);
            shad.shadowRadius = opt.radius;
            shad.shadowColor = cl.CGColor;
            shad.shadowOpacity = 1.0;
            [frameLayer insertSublayer:shad atIndex:0];
            shad = nil;
        }
        cl = nil;
    }
}

void $::clearShadows(){
    NSEnumerator *enumerator = [frameLayer.sublayers reverseObjectEnumerator];
    for (CALayer *la in enumerator){
        if([la isKindOfClass:[ShapeLayer class]]
           && [@"shadow" isEqualToString:((ShapeLayer*)la).type]){
            [la removeFromSuperlayer];
        }
    }
}

void $::setGradient(const char* value){
    CAGradientLayer *gradient = [CAGradientLayer layer];
    //CALayer *layer = shapeLayer?shapeLayer:contentLayer;
    CALayer *layer = contentLayer;
    gradient.frame = layer.bounds;
    gradient.cornerRadius = styles.corner;
    
    string grad(value);
    grad = regex_replace(grad,regex("\\s+")," ");
    vector<string> parts=splitx(grad, regex("\\s"));
    
    int size = parts.size();
    
    NSMutableArray *colors=[NSMutableArray array];
    NSMutableArray *locations=[NSMutableArray array];
    int degree = 0;
    for (int i=0;i<size;i++) {
        string v = parts[i];
        if(strhas(v.c_str(), ":")){
            int sidx = (int)v.find(':',0);
            string cpart = v.substr(0, sidx);
            [colors addObject:(id)(str2color(cpart.c_str()).CGColor)];
            cpart = v.substr(sidx+1,v.length()-sidx-1);
            [locations addObject:@(stof(cpart))];
        }else{
            if(i==size-1 && !strhas(v.c_str(), "#")){
                degree = stof(v);
            }else{
                [colors addObject:(id)(str2color(v.c_str()).CGColor)];
                [locations addObject:[NSNumber numberWithFloat:((float)i/(float)(size-1))]];
            }
        }
    }
    gradient.colors = colors;
    gradient.locations = locations;
    if(degree)
        gradient.affineTransform = CGAffineTransformMakeRotation(radians(degree));
    [layer insertSublayer:gradient atIndex:0];
}

void $::setOutline(const char * s){
    /*
    OutlineOpt op = olopt(s);
    styles.outlineWidth = op.w;
    styles.outlineColor = op.color;
    styles.outlineSpace = op.space;
    
    NSString *cl = str(styles.outlineColor);
    UIColor *oColor;
    if([cl contains:@","]||[cl contains:@"#"]){//color
        oColor = [cl colorValue];
    }else{//image
        oColor= [UIColor colorWithPatternImage:[UIImage imageNamed:cl]];
    }
    view.clipsToBounds = NO;
    
    float w = styles.outlineWidth + styles.outlineSpace;
    
    CALayer *olayer = [CALayer layer];
    olayer.frame = CGRectMake(-1*w, -1*w,
                              contentLayer.frame.size.width+2*w, contentLayer.frame.size.height+2*w);
    
    olayer.borderWidth = styles.outlineWidth;
    olayer.borderColor = oColor.CGColor;
    olayer.cornerRadius = styles.cornerRadius>0? styles.cornerRadius+styles.outlineSpace : 0;
    
    [contentLayer addSublayer:olayer];
    olayer = nil;oColor = nil;
     */
}


#pragma mark $ svg

/*
 draw svg path to view.
 H V S T are unsupported
 */
void $::setSvgPath (const char* svgpathcmd){
    svg = str(svgpathcmd);
    CGPathRef path = SVG::path(svgpathcmd);
    return setMask(path);
}

void $::setMask (CGPathRef path){
    if(!maskLayer){
        maskLayer = [CAShapeLayer layer];
    }
    maskLayer.frame = contentLayer.bounds;
    maskLayer.path = path;
    if(src || svg)
        contentLayer.mask = maskLayer;
    //CGPathRelease(path);
}


#pragma mark $ scroll
$& $::setContentSize(float x, float y){
    if(scrollable)
        ((UIScrollView*)view).contentSize = CGSizeMake(x, y);
    else
        NSLog(@"LiberOBJC ERROR: You can not specify contentSize to UIView, use sbox instead");
    return *this;
}

$& $::scrollTo(float x, float y){
    if(scrollable){
        [((UIScrollView*)view) setContentOffset:{x,y} animated:YES];
    }else
        NSLog(@"LiberOBJC ERROR: You can not specify make UIView scroll, use sbox instead");
    return *this;
}
$& $::scrollTop(float topMargin){
    $* ro = root();
    if(ro != NULL)
        ro->set(@"orgContentOffset", @(ro->view.contentOffset.y)).scrollTo(0,view.frame.origin.y-topMargin);
    return *this;
}
$& $::scrollBack(){
    $* ro = root();
    if(ro != NULL){
        id off = ro->get(@"orgContentOffset");
        if(off)
            ro->scrollTo(0,[off floatValue]).del(@"orgContentOffset");
    }
    return *this;
}

#pragma mark $ image

$& $::setImage(id _src){
    if(!ID||!_src || ([_src isKindOfClass:[NSString class]]&&[_src length]==0))
        return *this;//much init with img()
    UIImage* img;
    if([_src isKindOfClass:[NSString class]]){
        if([_src hasPrefix:@"http:"]||[_src hasPrefix:@"https:"]||[_src hasPrefix:@"ftp:"]){//URL
            src = _src;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSError* error = nil;
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:src] options:NSDataReadingUncached error:&error];
                if(data&&!error){
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        setImage([UIImage imageWithData:data]);
                    });
                }else{
                    //NSLog(@"Failed To Load Image From URL:%@",src);
                }
                src = nil;
            });
        }else if([_src hasPrefix:@"assets-library:"]){//asset
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                src = _src;
                @autoreleasepool {
                    [UIImage loadImageFromAssetURL:[NSURL URLWithString:src] handler:^(UIImage *im,NSDictionary *p) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            setImage(im);
                        });
                        im = nil;
                    } params:@{}];
                }
            });
        }else if([_src length]>0)
            img = [UIImage imageNamed:_src];
    }else if([_src isKindOfClass:[UIImage class]])
        img = _src;
    if(img){
        if(!imageLayer){
            imageLayer=[CALayer layer];
            [contentLayer addSublayer:imageLayer];
        }
        CGFloat imgW = CGImageGetWidth(img.CGImage);
        CGFloat imgH = CGImageGetHeight(img.CGImage);
        if(imgW && imgH){
            CGFloat cw = contentLayer.bounds.size.width;
            CGFloat ch = contentLayer.bounds.size.height;
            CGFloat wScale = cw / imgW;
            CGFloat hScale = ch / imgH;
            CGFloat w,h;
            switch (styles.contentMode) {
                case m_FIT:
                    w = wScale>hScale?imgW*hScale:cw;
                    h = wScale>hScale?ch:imgH*wScale;
                    imageLayer.frame = {{wScale>hScale?(cw-w)/2:0,wScale>hScale?0:(ch-h)/2},{w,h}};
                    break;
                case m_CROP_FIT:
                    w = wScale>hScale?cw:imgW*hScale;
                    h = wScale>hScale?imgH*wScale:ch;
                    imageLayer.frame = {{wScale>hScale?0:(cw-w)/2,wScale>hScale?(ch-h)/2:0},{w,h}};
                    break;
                case m_ORG:
                    imageLayer.frame = {{(cw-imgW)/2,(ch-imgH)/2},{imgW,imgH}};
                    break;
                default://m_FILL
                    imageLayer.frame = {{0,0},{cw,ch}};
                    break;
            }
            imageLayer.contents =(__bridge id)img.CGImage;
            /*
            else{
                shapeLayer = [CAShapeLayer layer];
                shapeLayer.path  = [UIBezierPath bezierPathWithRoundedRect:{{
                    -imageLayer.frame.origin.x,-imageLayer.frame.origin.y,
                    },contentLayer.bounds.size} cornerRadius:styles.cornerRadius].CGPath;
                //[imageMask setFillRule : kCAFillRuleEvenOdd];
                shapeLayer.fillColor = [[UIColor blackColor] CGColor];
                imageLayer.mask = shapeLayer;
            }*/
        }
        src = nil;
    }
    img = nil;
    return *this;
}
UIImage * $::getImage(){
    if(imageLayer)
        return [UIImage imageWithCGImage:(CGImageRef)imageLayer.contents];
    return nil;
}

#pragma mark $ text

$& $::setText(NSString * _text){
    text = _text;
    // TODO
    // - (CGSize)sizeThatFits:(CGSize)size //calculate a size to make the superview to fit its all subviews
    // - (void)sizeToFit //auto adjust super view to fit its all subviews
    //logRect(@"txt",rect);
    if(textLayer==nil){
        textLayer= [[CATextLayer alloc] init];
        [contentLayer addSublayer:textLayer];
    }else
        textLayer.hidden = NO;
    if ([textLayer respondsToSelector:@selector(setContentsScale:)]){
        textLayer.contentsScale = [[UIScreen mainScreen] scale];
    }
    
    [textLayer setString:text];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    
    textLayer.wrapped = !styles.nowrap;
    textLayer.truncationMode = styles.truncate ? kCATruncationEnd:kCATruncationNone;
    
    setTextstyle(styles);
    return *this;
}

$& $::setDefaultText(NSString * _text){
    if(!text){
        setText(_text);
        text = nil;
    }
    return *this;
}
void $::setTextstyle(StyleDef *s){
    if(!textLayer)return;
    if(s.paddingLeft) styles.paddingLeft = s.paddingLeft;
    if(s.paddingRight) styles.paddingRight = s.paddingRight;
    if(s.paddingTop) styles.paddingTop = s.paddingTop;
    if(s.paddingBottom) styles.paddingBottom = s.paddingBottom;
    CGRect rect = CGRectMake(styles.paddingLeft, styles.paddingTop, contentLayer.bounds.size.width-styles.paddingLeft-styles.paddingRight, contentLayer.bounds.size.height-styles.paddingTop-styles.paddingBottom);
    [textLayer setFrame:rect];
    
    if(s.font)
        setFont(s.font);
    //    if(styles.fontSize>0)
    //        setFontSize(styles.fontSize);
    if(s.color){
        styles.color = s.color;
        setColor(s.color);
    }
    if(s.align){
        styles.align = s.align;
        setTextAlign(s.align);
    }
}
__attribute__((overloadable)) void $::setTextAlign(const char* align){
    if(!align)
        align = "left";
    static std::map<const char*, NSString*> def = {
        {"center",kCAAlignmentCenter},
        {"left",kCAAlignmentLeft},
        {"right",kCAAlignmentRight},
        {"justified",kCAAlignmentJustified},
        {"natural",kCAAlignmentNatural}
    };
    if(textLayer!=nil){
        [textLayer setAlignmentMode:def[align]];
    }
}

__attribute__((overloadable)) void $::setTextAlign(NSString *align){
    if(textLayer!=nil){
        [textLayer setAlignmentMode:align];
    }
}

__attribute__((overloadable)) void $::setFont(const char* font){
    if(textLayer==nil) return;
    UIFont *f = ftopt(font);
    setFont(f);
}
__attribute__((overloadable)) void $::setFont(UIFont* font){
    if(textLayer==nil) return;
    styles.font = font;
    [textLayer setFont:CGFontCreateWithFontName((CFStringRef)font.fontName)];
    [textLayer setFontSize:font.pointSize];
}

void $::setFontSize(float s){
    if(textLayer==nil)
        return;
    if(s>0)
        [textLayer setFontSize:s];
    else{
        CGRect rect = CGRectMake(styles.paddingLeft, styles.paddingTop, contentLayer.bounds.size.width-styles.paddingLeft-styles.paddingRight, contentLayer.bounds.size.height-styles.paddingTop-styles.paddingBottom);
        //NSString *fontName = styles.fontName? str(styles.fontName):@"Helvetica";
        NSString *fontName = styles.font.familyName;
        float fontSize = ![text isEqual:[NSNull null]] ? [text sizeToFit:rect.size font:fontName] : 14;
        [textLayer setFontSize:fontSize];
    }
}



__attribute__((overloadable)) void $::setColor(id color){
    if(textLayer==nil)return;
    if(color!=nil){
        UIColor * cl = ([color isKindOfClass:[UIColor class]])? (UIColor *)color:
        ([color isKindOfClass:[NSString class]]? [color colorValue]:[UIColor blackColor]);
        [textLayer setForegroundColor:[cl CGColor]];
    }else{
        NSDictionary *defaultStyle = @{};//FIXME : check styles.mm
        NSString *cl = defaultStyle!=nil && defaultStyle[@"color"]!=nil ? defaultStyle[@"color"]:@"#000000";
        [textLayer setForegroundColor:[cl colorValue].CGColor];
    }
}

__attribute__((overloadable)) void $::setColor(const char* color){
    if(textLayer==nil)
        textLayer= [[CATextLayer alloc] init];
    if(color){
        UIColor * cl = str2color(color);
        [textLayer setForegroundColor:[cl CGColor]];
    }
}

__attribute__((overloadable)) $& $::setPickable(Arr* opts){
    if(!text){
        NSLog(@"ERR: setPickable requires label()");
        return *this;
    }
    setEditable(true);
    UIPickerView * pv = [[UIPickerView alloc] init];
    pv.delegate = view;
    view.textField.picker = pv;
    view.textField.options = opts;
    //pv.showsSelectionIndicator = YES;
    return *this;
}
__attribute__((overloadable)) $& $::setPickable(NSDate *date, const char* labelFormat){
    if(!text){
        NSLog(@"ERR: setPickable requires label()");
        return *this;
    }
    setEditable(true);

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString * format =str(labelFormat);
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString * val = [formatter stringFromDate:date?date:[NSDate date]];
    set(@"_dateFormat", format);
    setText(val);

    UIDatePicker * picker = [[UIDatePicker alloc]init];
    UIDatePickerMode mode = UIDatePickerModeDate;
    
    if([format contains:@"ss"]||[format contains:@"mm"]||[format contains:@"HH"]||[format contains:@"hh"]){
        mode = ([format contains:@"yy"]||[format contains:@"MM"]||[format contains:@"dd"])
        ? UIDatePickerModeDateAndTime : UIDatePickerModeTime;
    }
    [picker setDatePickerMode:mode];
    ((TextView *) view.textField).datePicker = picker;
    [picker addTarget:view action:@selector(datePicked) forControlEvents:UIControlEventValueChanged];
    return *this;
}

__attribute__((overloadable)) $& $::setEditable(BOOL editable){return setEditable(editable, ^($&v){});}
__attribute__((overloadable)) $& $::setEditable(BOOL editable, TextEditOnInitHandler startHandler){
    styles.editable = editable;
    if(view.textField==nil){

        const NSArray * aligns = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?
        @[@"left",@"center",@"right", @"justified", @"natrual"]:@[@"left",@"right",@"center", @"justified", @"natrual"];
        NSString *align = styles.align?styles.align:@"left";
        
        TextView* t = [[TextView alloc] initWithFrame:textLayer.frame];
        t.delegate = view;
        t.textContainer.lineFragmentPadding = 0;
        t.textContainerInset = UIEdgeInsetsZero;
        t.textAlignment = (NSTextAlignment)[aligns indexOfObject:align];
        t.font = styles.font;
        t.editable = YES;
        t.nowrap = styles.nowrap;
        view.textField = t;

        view.textField.hidden = YES;
        set(@"initHandler", (id)startHandler);
    }
    bind(@"tap", ^void (UIGestureRecognizer*ges, $& o, NSDictionary*params){
        View *v = (View *)ges.view;
        [v switchEditingMode];
        TextEditOnInitHandler sh = o.get(@"initHandler");
        if(sh){sh(o);}
    },nil);
    return *this;
}

#pragma mark - Static
NSMutableDictionary * $::s_views = nil;
NSMutableDictionary * $::s_trash = nil;
NSString * $::s_controllerName = nil;
int $::s_views_idx = 0;
/*
 get view by ID
 */
__attribute__((overloadable)) $* const $::getView(NSString * _ID, NSString *ctrlerName){
    //NSString * cName = __controllerName?__controllerName:@"__DEFAULT__";
    if(s_views && s_views[ctrlerName] && s_views[ctrlerName][_ID])
        return ($*)[s_views[ctrlerName][_ID] pointerValue];
    return nullptr;
}
__attribute__((overloadable)) $& $::getView(NSString * _ID){
    $* vp = $::getView(_ID, s_controllerName);
    return *vp;
}
/*
 remove all views from memory.
 be careful to use this.
 */
void $::clearAll(NSString *ctrlerName){
    if(s_views && s_views[ctrlerName]){
        for (NSString *va in s_views[ctrlerName]) {
            $* v = ($*)[s_views[ctrlerName][va] pointerValue];
            if(v && v->ID && !v->released)delete(v);
        }
        [s_views[ctrlerName] removeAllObjects];
    }
}

void $::setControllerName(NSString *controllerName){
    s_controllerName = controllerName;
}

/*
 private static
 
 */
void $::removeView($* vp){
    if(!vp || !vp->ID || !vp->NS || vp->released)
        return;
    if(vp->view)
       [vp->view removeFromSuperview];
    if(s_views && s_views[vp->NS]){
        [s_views[vp->NS] removeObjectForKey:(NSString*)(vp->ID)];
    }
    
}

/*
 private static
 
 */
void $::registerView($* vp){
    if(!s_views){
        s_views = [[NSMutableDictionary alloc] init];
    }
    NSString * cName = s_controllerName?s_controllerName:@"__DEFAULT__";
    if(!s_views[cName])
        s_views[cName] = [[NSMutableDictionary alloc] init];
    s_views_idx++;
    if(!vp->ID)vp->ID = [NSString stringWithFormat:@"%@_%d",(vp->src?@"IMG":@"BOX"),s_views_idx];
    vp->NS = cName;
    s_views[cName][vp->ID] = [NSValue valueWithPointer:vp];
    //NSLog(@"Register view : %@",vp->ID);
}



#pragma mark - CPP wrapper
__attribute__((overloadable)) $& box(){return (new $())->setStyle(dfs);}
__attribute__((overloadable)) $& box(Styles s){return (new $())->setStyle(s);}
__attribute__((overloadable)) $& box(Styles *sp){return (new $())->setStyle(*sp);}
__attribute__((overloadable)) $& box(Styles s, Styles *sp){return (new $())->setStyle(style(&s,sp));}

__attribute__((overloadable)) $& box(initializer_list<Styles *>ext){return (new $())->setStyle(nos,ext);}
__attribute__((overloadable)) $& box(Styles s, initializer_list<Styles *>ext){return (new $())->setStyle(s,ext);}
__attribute__((overloadable)) $& sbox(){return (new $(true))->setStyle(dfs);}
__attribute__((overloadable)) $& sbox(Styles s){return (new $(true))->setStyle(s);}
__attribute__((overloadable)) $& sbox(Styles *sp){return (new $(true))->setStyle(*sp);}
__attribute__((overloadable)) $& sbox(Styles s,Styles *sp){return (new $(true))->setStyle(style(&s,sp));}

__attribute__((overloadable)) $& sbox(initializer_list<Styles *>ext){return (new $(true))->setStyle(nos,ext);}
__attribute__((overloadable)) $& sbox(Styles s, initializer_list<Styles *>ext){return (new $(true))->setStyle(s,ext);}


__attribute__((overloadable)) $& label(NSString*txt){return (new $())->setStyle(dfs).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles s){return (new $())->setStyle(s).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles *sp){return (new $())->setStyle(*sp).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles s,Styles *sp){return (new $())->setStyle(style(&s,sp)).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, std::initializer_list<Styles *>ext){return (new $())->setStyle(nos,ext).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles s, std::initializer_list<Styles *>ext){return (new $())->setStyle(s,ext).setText(txt);}


__attribute__((overloadable)) $& glabel(NSString*url,LabelContentHandler handler,Styles s){
    $* v = new $;
    v->setStyle(s);
    if(url){
        dispatch_async(dispatch_get_main_queue(), ^{
            [HTTPRequest get:url handler:^id(id res, NSDictionary *params) {
                NSString * str = handler(res);
                $* v = ($*) [params[@"view"] pointerValue];
                v->setText(str);
                return res;
            } datas:@{@"view":[NSValue valueWithPointer:v]}];
        });
    }else{
        v->setText(handler(nil));
    }
    return *v;
}
__attribute__((overloadable)) $& glabel(NSString*url,LabelContentHandler handler,Styles *sp){return glabel(url, handler, *sp);}
__attribute__((overloadable)) $& glabel(NSString*url,LabelContentHandler handler,Styles s, Styles *sp){return glabel(url, handler, style(&s, sp));}


__attribute__((overloadable)) $& img(id src){return (new $(src))->setStyle(dfs);}
__attribute__((overloadable)) $& img(id src, Styles s){return (new $(src))->setStyle(s);};
__attribute__((overloadable)) $& img(id src, Styles *sp){return (new $(src))->setStyle(*sp);};
__attribute__((overloadable)) $& img(id src, Styles s,Styles *sp){return (new $(src))->setStyle(style(&s,sp));};
__attribute__((overloadable)) $& img(id src, std::initializer_list<Styles *>ext){return (new $(src))->setStyle(nos,ext);};
__attribute__((overloadable)) $& img(id src, Styles s, std::initializer_list<Styles *>ext){return (new $(src))->setStyle(s,ext);};


__attribute__((overloadable)) $& svgp(NSString* cmds, Styles s){
    //$* o=(new $())->initView(s);o->svg = cmds;return o->setStyle(s);//o->setSvgPath(cstr(cmds));return *o;
    s.path = cstr(cmds);return (new $())->setStyle(s);
}
__attribute__((overloadable)) $& svgp(NSString* cmds, Styles *sp){
    //$& o=(new $())->setStyle(*sp);o.setSvgPath(cstr(cmds));return o;
    //$* o=(new $())->initView(*sp);o->svg = cmds;return *o;
    return (new $())->setStyle({.path=cstr(cmds)},sp);
}
__attribute__((overloadable)) $& svgp(NSString* cmds, Styles s, Styles *sp){
    //$& o=(new $())->setStyle(style(&s,sp));o.setSvgPath(cstr(cmds));return o;
    //$* o=(new $())->initView(s);o->svg = cmds;return o->setStyle(style(&s,sp));
    s.path = cstr(cmds);return (new $())->setStyle(style(&s,sp));
}
__attribute__((overloadable)) $& svgp(NSString* cmds, std::initializer_list<Styles *>ext){
    //$& o=(new $())->setStyle({},ext);o.setSvgPath(cstr(cmds));return o;
    //$* o=(new $())->initView(dfs);o->svg = cmds;return o->setStyle(nos,ext);
    return (new $())->setStyle({.path=cstr(cmds)},ext);
}
__attribute__((overloadable)) $& svgp(NSString* cmds, Styles s, std::initializer_list<Styles *>ext){
    //$& o=(new $())->setStyle(s,ext);o.setSvgPath(cstr(cmds));return o;
    //$* o=(new $())->initView(s);o->svg = cmds;return o->setStyle(s,ext);
    s.path = cstr(cmds);return (new $())->setStyle(s,ext);
}


__attribute__((overloadable)) $& list(NSArray*data, ListHandler handler, Styles listStyle){
    return list(data, handler, listStyle, {});
}
__attribute__((overloadable)) $& list(NSArray*data, ListHandler handler, Styles listStyle, std::initializer_list<Styles *>ext){
    if(data && handler){
        int i = 0;
        $& ul = sbox(listStyle, ext);
        ul.view.clipsToBounds = YES;
        float maxX = 0, maxY = 0;
        for (id item in data){
            $& it = handler(item, i++) >> ul;
            CGRect re = it.rect();
            maxX = MAX(maxX, (re.origin.x+re.size.width));
            maxY = MAX(maxY, (re.origin.y+re.size.height));
        }
        ul.setContentSize(maxX, maxY);
        return ul;
    }
    return sbox(listStyle, ext);
}


__attribute__((overloadable)) $& slide(NSArray*data, ListHandler handler, Styles slideStyle){return slide(data, handler, slideStyle,{});}
__attribute__((overloadable)) $& slide(NSArray*data, ListHandler handler, Styles slideStyle, std::initializer_list<Styles *>ext){
   
    //b.view.backgroundColor = [UIColor blackColor];
    if(!data || !handler)return sbox();
    
    int i = 0;
    $& b = sbox(slideStyle,ext);
    b.slidable = true;
    b.view.clipsToBounds = YES;
    for (id item in data){
        handler(item, i++) >> b;
    }
    
    //add scroll event
    b.bind(@"pan", ^(GR *g, $ & v, Dic *p) {
        if(v.getInt(@"_sliding"))return;
        CGPoint coords = [g locationInView:v.view.superview];
        float orgX = v.getFloat(@"_slideOrgX");
        int   lastPage = v.getInt(@"_slideLastPage");
        float w = v.view.bounds.size.width;
        float factor = 2.0f;
        if(g.state == UIGestureRecognizerStateEnded){
            float dis = orgX>coords.x?orgX-coords.x:coords.x-orgX;
            int page = lastPage;
            float diss;
            int speed=100;
            AnimateStepHandler sh = ^($ & vv, float d) {
                float start = vv.getFloat(@"_slideStart");
                float ds = vv.getFloat(@"_slideDis");
                vv.view.contentOffset ={start+ds*d,0};
            };
            AnimateFinishedHandler se =^($ & vv) {
                float start = vv.getFloat(@"_slideStart");
                float ds = vv.getFloat(@"_slideDis");
                vv.view.contentOffset ={static_cast<CGFloat>((int)(start+ds)),0};
                vv.del(@[@"_sliding",@"_slideDis",@"_slideStart",@"_slideOrgX"]);
                int p = vv.getInt(@"_slideLastPage");
                if(vv.pages){
                    if(vv.pages->text){
                        vv.pages->setText([NSString stringWithFormat:@"(%d/%d)",p+1,[vv.nodes count]]);
                    }else{
                        for (int i=0; i<[vv.nodes count]; i++)
                            (*vv.pages)[i]->setStyle({.bgcolor="#ffffff66"});
                        (*vv.pages)[p]->setStyle({.bgcolor="#ffffffcc"});
                    }
                }
            };
            
            if(dis*factor>w/4){ //move to the next page.
                page += orgX>coords.x? 1:-1;
                page = MIN([v.nodes count]-1,MAX(page, 0));
                diss =page*w-v.view.contentOffset.x;
            }else{//move to the previous page.
                if(!page) page = 0;
                diss =dis*((orgX>coords.x)?-1:1)*factor;
            }
            
            v.set(@"_sliding", @(1))
            .set(@"_slideStart",@(v.view.contentOffset.x))
            .set(@"_slideDis",@(diss))
            .set(@"_slideLastPage", @(page))
            .animate(speed, sh, se, @{});
            
        }else{
            if(!orgX){
                v.set(@"_slideOrgX", @(coords.x));
            }else{
                v.view.contentOffset ={lastPage*w-(coords.x-orgX)*factor,0};
            }
        }
    }, @{});
    return b;
}

__attribute__((overloadable)) $& grids(NSArray*data, int cols, GridHandler handler, Styles gridsStyle){
    return grids(data, cols, handler, gridsStyle, {});
}
__attribute__((overloadable)) $& grids(NSArray*data, int cols, GridHandler handler, Styles gridsStyle, std::initializer_list<Styles *>ext){
    if(data && handler){
        int i = 0;
        $& ul = sbox(gridsStyle, ext);
        for (id item in data){
            int row = floor(i/cols);
            int col = i%cols;
            //TODO dispatch async
            ul << handler(item, row, col);
            i++;
        }
        return ul;
    }
    return sbox(gridsStyle, ext);
}


/*
 build shadow option string with parameters
 
char* shadstr(bool inset, float x, float y, float blur, const char*color){
    return cstr([NSString stringWithFormat:@"%@%f %f %f %@",inset?@"inset ":@"",x,y,blur,str(color)]);
}

ShadowOpt shadopt(const char*s){
    if(!s)return {false, 0, 0, 0, NULL};
    string shad(s);
    
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
    
    return (p[0].compare("inset")==0) ?
    (ShadowOpt){true,stof(p[1]),stof(p[2]),stof(p[3]),const_cast<char*>(p[4].c_str())} :
    (ShadowOpt){false,stof(p[0]),stof(p[1]),stof(p[2]),const_cast<char*>(p[3].c_str())};
    
}


//styles : border
char* bordstr(float w, int style, const char*color, float radius){
    const char* snames[3] = {"solid","dashed","dotted"};
    const char* ststr = snames[(int)style];
    return cstr([NSString stringWithFormat:@"%f %@ %@ %f",w,str(ststr),str(color),radius]);
}
BorderlineOpt& bordopt(const char*s){
    string border(s);
    border = regex_replace(border,regex("\\s+")," ");
    vector<string> parts = splitx(border, regex("\\s+"));
    BorderlineOpt bo = {0,"#00000000",m_SOLID,0};
    int size = parts.size();
    if(size==0)return bo;
    if(regex_match(parts[0],regex("[0-9\\.]+")))
        bo.w =stof(parts[0]);
    
    for (int i=1; i<size; i++) {
        const char * cst = parts[i].c_str();
        if(strhas(cst, "#")){
            bo.color = const_cast<char*>(cst);
        }else if(parts[i].compare("solid")==0){
            bo.style = m_SOLID;
        }else if(parts[i].compare("dashed")==0){
            bo.style = m_DASHED;
        }else if(parts[i].compare("dotted")==0){
            bo.style = m_DOTTED;
        }else if(regex_match(parts[i],regex("[0-9\\.]+"))){
            bo.radius = stof(parts[i]);
        }
    }
    return bo;
}
/*
//styles : outline
char* olstr(float w, int style, const char*color, float space){
    return bordstr(w, style, color, space);
}
OutlineOpt olopt(const char*s){
    BorderlineOpt bo = bordopt(s);
    return {.w=bo.w,.style=bo.style,.color=bo.color,.space=bo.radius};
}


*/




#pragma mark - opengl
