//
//  View.m
//  liberobjc
//
//  Created by soyoes on 6/14/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#import "Styles.h"
#include <math.h>
#include <string>
#include <sstream>
#include <algorithm>
#include <cctype>
#include <regex>
#include <iostream>
#include <map>
#import "Categories.h"
#import "View.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#include <stdlib.h>

using namespace std;

NSMutableDictionary * __datas=nil;

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
    if(_gestures!=nil && _gestures[className]!=nil){
        GestureHandler handler = _gestures[className];
        if(handler){
            View * v = (View*)ges.view;
            NSDictionary *params = [v.data valueForKey:@"gestureData"];
            handler(ges, *_owner, params);
            //[v.data removeObjectForKey:@"gestureData"];
            params=nil;
        }
    }
}

-(void) switchEditingMode{
    if(_textField!=nil){
        if(_textField.hidden){
            [self addSubview:_textField];//FIXME
            if(_owner->textLayer.wrapped){
                ((UITextView*)_textField).text = _owner->text;
            }else{
                ((UITextField*)_textField).text = _owner->text;
            }
            _textField.hidden = NO;
            _owner->textLayer.hidden = YES;
            [_textField becomeFirstResponder];
            /*
            View *root = [self root];
            if(root){
                [root set:@"orgContentOffset" value:[NSNumber numberWithFloat:root.contentOffset.y]];
                [root setContentOffset:CGPointMake(0, self.frame.origin.y) animated:YES];
                //FIXME , change self.frame.origin.y to height in root
            }*/
        }else{
            _textField.hidden = YES;
            if(_owner->textLayer.wrapped){
                _owner->setText(((UITextView*)_textField).text);
            }else{
                _owner->setText(((UITextField*)_textField).text);
            }
            [_textField resignFirstResponder];
            /*
            View *root = [self root];
            if(root){
                float orgOffset = [root get:@"orgContentOffset"]!=nil?[[root get:@"orgContentOffset"] floatValue]:0;
                [root setContentOffset:CGPointMake(0, orgOffset) animated:YES];
            }*/
        }
    }
}

+ (Class) layerClass{
    return [Layer class];
}

#pragma mark delegate of textField
// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"textFieldDidEndEditing");
    _textField.hidden = YES;
    _owner->setText(((UITextField*)_textField).text);
    /*
    View *root = [self root];
    if(root){
        float orgOffset = [root get:@"orgContentOffset"]!=nil?[[root get:@"orgContentOffset"] floatValue]:0;
        [root setContentOffset:CGPointMake(0, orgOffset) animated:YES];
    }*/
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(_owner->textLayer.wrapped){
        ((UITextField*)_textField).text = [NSString stringWithFormat:@"%@\r\n",((UITextField*)_textField).text ];
        return NO;
    }else{
        [textField resignFirstResponder];
        return YES;
    }
    
}

#pragma mark delegate of textView

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

@end

#pragma mark - Layer
@implementation Layer
@synthesize asSubLayer;
- (BOOL)containsPoint:(CGPoint)thePoint{
    return (asSubLayer)? NO:
        [super containsPoint:thePoint];
}
/*
- (void)layoutSublayers{
    //cout << "resize layer" << endl;
    for(CALayer *l in self.sublayers){
        if(l.frame.origin.x==0 && l.frame.origin.y==0
           && l.frame.size.width==self.bounds.size.width && l.frame.size.height==self.bounds.size.height){
            l.frame=self.bounds;
        }
    }
}*/

@end

#pragma mark - SVG

/**
 get svg path from svg path string.
 don't forget to release : CGPathRelease(path), after using.
 */
CGPathRef SVG::path(const char* svgpathcmd){
    string svgpath(svgpathcmd);
    
    //svgpath = regex_replace(svgpath, regex("\\s*,\\s*"), ",");
    //svgpath = regex_replace(svgpath, regex("\\s+"), " ");
    svgpath = regex_replace(svgpath, regex("[\\s+,]"), " ");
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


__attribute__((overloadable)) $::$(){}
__attribute__((overloadable)) $::$(id _src):src(_src){}
__attribute__((overloadable)) $::$(bool scroll):scrollable(scroll){}
__attribute__((overloadable)) $::$(const char* path):svgPath(path){}
// Constructor
$::~$(){
    if(ID && !released){
        //NSLog(@"Free view : %@",ID);
        nodes=nil;
        view=nil;
        src=nil;
        text=nil;
        
        layer=nil;
        transLayer=nil;
        contentLayer=nil;
        textLayer=nil;
        shapeLayer=nil;
        subLayers=nil;
        
        animator =nil;
        behaviors=nil;
        dummys=nil;
        ID=nil;
        NS=nil;
        released=true;
    }
}

$* $::initView(Styles s){
    styles = s;
    if(!view){
        CGRect rect =CGRectMake(styles.x, styles.y, styles.w, styles.h);
        view = [[View alloc] initWithOwner:this rect:rect];
        //view.userInteractionEnabled = YES;
    }
    layer = view.layer;
    layer.zPosition = styles.z;
    
    /*
    transLayer = [CATransformLayer layer];
    transLayer.frame = view.bounds;
    [layer addSublayer:transLayer];
    */
    
    contentLayer = [CALayer layer];
    contentLayer.frame = view.bounds;
    //[transLayer addSublayer:contentLayer];
    [layer addSublayer:contentLayer];
    
    if(styles.ID)ID = styles.ID;
    registerView(this);
    
    return this;
}

__attribute__((overloadable))
$& $::setStyle(Styles s){
    
    bool initedBeforeSetting = ID!=nil;
    
    if(ID==nil)
        initView(s);
    
    Styles ss = initedBeforeSetting? s: styles;
    
    if(ss.padding){
        ss.paddingLeft=ss.padding;
        ss.paddingTop=ss.padding;
        ss.paddingRight=ss.padding;
        ss.paddingBottom=ss.padding;
    }

    //CALayer *_layer = shapeLayer?shapeLayer:contentLayer;
    layer.opacity = (1-ss.alpha);
    
    if(initedBeforeSetting && (s.x||s.y||s.w||s.h)){
        float ww = s.w ? s.w : styles.w;
        float hh = s.h ? s.h : styles.h;
        float xx = s.x ? s.x : styles.x;
        float yy = s.y ? s.y : styles.y;
        view.frame = {{xx,yy},{ww,hh}};
        layer.frame = {{xx,yy},{ww,hh}};
        contentLayer.frame = layer.bounds;
        
        /*
        if((s.x&&s.x!=styles.x) || (s.y&&s.y!=styles.y) ){
            view.center=CGPointMake(xx+ww/2, yy+hh/2);
        }
        
        if(s.w||s.h){
            cout << "RESIZING:" << ww<<","<<hh << endl;
            view.bounds = CGRectMake(0, 0, ww, hh);
            view.backgroundColor = [UIColor blackColor];
            layer.bounds = view.bounds;
            layer.backgroundColor = [UIColor redColor].CGColor;
            //transLayer.bounds = view.bounds;
            contentLayer.bounds = view.bounds;
            contentLayer.backgroundColor = [UIColor purpleColor].CGColor;
            
            /*
            transLayer.bounds = view.bounds;
            contentLayer.bounds = view.bounds;
            if(shapeLayer)shapeLayer.bounds = view.bounds;
            if(textLayer)textLayer.bounds = {{ss.paddingLeft,ss.paddingTop},{ww-ss.paddingLeft-ss.paddingRight, hh-ss.paddingTop-ss.paddingBottom}};
         
        }*/
    }
    
    if(ss.bgcolor){
        if(strhas(ss.bgcolor, ":")){//gradient
            this->drawGradient(str(ss.bgcolor));
        }else{
            if(shapeLayer){
                shapeLayer.fillColor =str2color(ss.bgcolor).CGColor;
                contentLayer.backgroundColor = [UIColor clearColor].CGColor;
            }else
                contentLayer.backgroundColor=str2color(ss.bgcolor).CGColor;

        }
    }
    
    if(ss.shadow){
        NSString *shadow = [str(ss.shadow) regexpReplace:@"  +" replace:@" "];
        if([shadow contains:@","]){
            NSArray *shadows = [shadow componentsSeparatedByString:@","];
            for(NSString *sha in shadows)
                this->drawShadow(sha);
        }else{
            this->drawShadow(shadow);
        }
    }

    if(ss.border) this->drawBorder(str(ss.border));
    if(styles.cornerRadius>0) { //radius
        contentLayer.cornerRadius = styles.cornerRadius;
        contentLayer.masksToBounds=YES;
    }
    
    if(ss.outline){
        this->drawOutline(str(ss.outline));
    }
    
    CGAffineTransform transf;
    bool trasDefined=false;
    if(ss.scaleX>0 && ss.scaleY>0){
        trasDefined = true;
        transf = CGAffineTransformMakeScale(ss.scaleX, ss.scaleY);
    }
    
    if(ss.flip){
        CGAffineTransform flip;
        if (ss.flip[0] == 'H') {
            flip =CGAffineTransformMake(view.transform.a * -1, 0, 0, 1, view.transform.tx, 0);
            transf = trasDefined? CGAffineTransformConcat(transf,flip):flip;
            trasDefined = true;
        }else if(ss.flip[0] == 'V'){
            flip = CGAffineTransformMake(1, 0, 0, view.transform.d * -1, 0, view.transform.ty);
            transf = trasDefined? CGAffineTransformConcat(transf,flip):flip;
            trasDefined = true;
        }
    }
    
    if(ss.rotate){
        CGAffineTransform rotate = CGAffineTransformMakeRotation(radians(ss.rotate));
        transf = trasDefined? CGAffineTransformConcat(transf,rotate):rotate;
        trasDefined = true;
    }
    
    if(trasDefined)
        view.transform = transf;
    
    if(ss.rotate3d){
        string rotate(ss.rotate3d);
        //degree, rotateX, rotateY, rotateZ, respective, anchorX, anchorY, translateX, translateY, translateZ
        float parts[] = {0,0,0,0,500,0.5,0.5,0,0,0};
        rotate = regex_replace(rotate, regex("\\s*,\\s*"), ",");
        int start = 0, end = 0, i=0;
        do {
            end = (int)rotate.find(',', start);
            if(end<0)break;
            string sc =rotate.substr(start, end - start);
            parts[i] = stof(sc);
            start = end + 1;
            i++;
        }while(end != string::npos);
        
        layer.anchorPoint = CGPointMake(parts[5], parts[6]);
        CATransform3D rt = CATransform3DIdentity;
        rt.m34 = 1.0f / (-1*parts[4]);
        rt = CATransform3DRotate(rt, radians(parts[0]), parts[1], parts[2], parts[3]);
        rt = CATransform3DTranslate(rt, parts[7], parts[8], parts[9]);
        layer.transform = rt;//CATransform3DConcat
    }
    
    if(initedBeforeSetting) *&styles = style(&s, &styles);
    
    return *this;
}
__attribute__((overloadable))
$& $::setStyle(Styles st, initializer_list<Styles *>ext){
    Styles o = st;
    for (Styles *ex  : ext) {
        style(&o,ex);
    }
    return this->setStyle(o);
}
$& $::bind(NSString* event, GestureHandler handler, NSDictionary * opts){
    if([_events indexOfObject:event]==NSNotFound || handler==NULL)
        return *this;
    view.gestures[event] = (id) handler;
    event = [event stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[event substringToIndex:1] uppercaseString]];
    NSString * className = [NSString stringWithFormat:@"UI%@GestureRecognizer",event];
    UIGestureRecognizer *gesture = [[NSClassFromString(className) alloc]
                                    initWithTarget:view action:@selector(gestureHandler:)];
    //[mask setUserInteractionEnabled:YES];
    [view setUserInteractionEnabled:YES];
    /*
     TODO multipleTouchEnabled
     exclusiveTouch
     */
    if(opts!=nil && [[opts allKeys] count]>0){
        //this->set(@"gestureData", opts);
        [view.data setValue:opts forKey:@"gestureData"];
    }
    [view addGestureRecognizer:gesture];
    return *this;
}
$& $::unbind(NSString* event){
    [view.gestures removeObjectForKey:event];
    //mask removeGestureRecognizer:<#(UIGestureRecognizer *)#>
    //FIXME remove event
    return *this;
}

$& $::dragable(GestureHandler onDrag, GestureHandler onEnd){
    this->bind(@"pan",^(GR *ges,$& v, Dic *params) {
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
    if(view)[view removeFromSuperview];
    $::removeView(this);
    delete this;
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
    /*
    for (Str *k in opts) {
        Str *type = [k stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[k substringToIndex:1] uppercaseString]];
        NSString * className = [NSString stringWithFormat:@"UI%@Behavior",type];
        UIDynamicBehavior *behavior = [[NSClassFromString(className) alloc] initWithItems:@[view]];
        [animator addBehavior:behavior];
    }*/
    /*
    if(bounds){
        if(!dummys) dummys=[[MArr alloc] init];
        float hh = view.superview.bounds.size.height;
        float ww = view.superview.bounds.size.width;
        for (int i=0; i<4; i++) {
            CGRect wall;
            float v = [bounds[i] floatValue];
            switch (i) {
                case 0:wall = CGRectMake(v, 0, 1, hh);break;
                case 1:wall = CGRectMake(0, v, ww, 1);break;
                case 2:wall = CGRectMake(ww-v, 0, 1, hh);break;
                case 3:wall = CGRectMake(0, hh-v, ww, 1);break;
            }
            UIView *dummy = [[UIView alloc] initWithFrame:wall];
            [dummys addObject:dummy];
            dummy.backgroundColor = [UIColor redColor];
            [view.superview addSubview:dummy];
        }
    }*/
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
            CGPathRef path = SVG::path([opt[@"svg"] UTF8String]);
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


$& $::animate(float ms, Styles s){return *this;}
$& $::animate(float ms, Styles s, AnimateFinishedHandler onEnd){return *this;}
$& $::animate(float ms, AnimateStepHandler onStep, AnimateFinishedHandler onEnd){return *this;}
$& $::animate(float ms, Styles s, Dic* opts){return *this;}
$& $::animate(float ms, Styles s, AnimateFinishedHandler onEnd, Dic* opts){return *this;}
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
        
        $* o = ($*) [d[@"o"] pointerValue];
        
        if(d[@"onStep"]){
            AnimateStepHandler onstep = d[@"onStep"];
            onStep(*o, delta);
        }
        int times = [d[@"times"] intValue];
        if(progress >= 1 || i>times){
            onEnd(*o);
            return NO;
        }else return YES;
                
    }, @{@"o":[NSValue valueWithPointer:this],@"times":@(times), @"start":@(start), @"duration":@(ms), @"delta_func":delta_func_name, @"style_func":style_func, @"onStep":onStep, @"onEnd":onEnd});
    
    return *this;
}


#pragma mark $ operator

__attribute__((overloadable)) $& $::operator>>($& p){
    cout << [ID UTF8String] << " >> " << [p.ID UTF8String] << endl;
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
                            NSLog(@"id=%@",sp->ID);
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
    }
    return *this;
}
__attribute__((overloadable)) $& $::operator>>(UIView*p){
    cout << [ID UTF8String] << " >> UIVIEW" << endl;
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
void $::set(NSString*key, id value){
    if(view){[view.data setValue:value forKey:key];}
}
void $::del(NSString*key){
    if(view){[view.data removeObjectForKey:key];}
}

#pragma mark $ drawing

void $::drawBorder(NSString *border){
    if(border){
        border = [border regexpReplace:@"  +" replace:@" "];
        NSArray *parts = [border componentsSeparatedByString:@" "];
        styles.borderWidth =[parts[0] floatValue];
        if([parts count]>1){
            styles.borderColor = cstr(parts[1]);
            //radius
            if([parts count]>2){
                styles.cornerRadius = [parts[2] intValue];
            }
        }
    }
    if(!shapeLayer){ //drawing
        contentLayer.borderWidth =styles.borderWidth;
        if(strhas(styles.borderColor, "#")||strhas(styles.borderColor, ",")){//color
            contentLayer.borderColor = str2color(styles.borderColor).CGColor;
        }else{//image
            contentLayer.borderColor = [UIColor colorWithPatternImage:[UIImage imageNamed:str(styles.borderColor)]].CGColor;
        }
    }else{
        shapeLayer.strokeColor=str2color(styles.borderColor).CGColor;
        shapeLayer.lineWidth=styles.borderWidth;
    }

}


/**
 format :[inset] x y radius [color]
 */

void $::drawShadow(NSString* shadow){
    if(!shadow || [shadow length]==0)return;
    
    NSArray *parts = [shadow componentsSeparatedByString:@" "];
    int psize =(int)[parts count];
    CALayer *layer = shapeLayer?shapeLayer:contentLayer;
    if(psize>=4){
        BOOL isInner = [parts[0] isEqualToString:@"inset"];
        
        int offset = isInner ? 1:0;
        float x = [parts[0+offset] floatValue];
        float y = [parts[1+offset] floatValue];
        float r = [parts[2+offset] floatValue];
        UIColor * cl = ([parts count] >= 4+offset)? [parts[3+offset] colorValue]:[UIColor darkGrayColor];
        
        view.clipsToBounds = NO;
       

        if(isInner){
            //_innerShadow = [[InnerShadow alloc] initWithTarget:self x:x y:y r:r];
            CALayer * s = [CALayer layer];
            s.zPosition = 8;
            
            /*
            float o = styles.outlineWidth+styles.outlineSpace;
            float left = view.borderLeft!=nil? view.borderLeft.width+o : o;
            float top = view.borderTop!=nil? view.borderTop.width+o : o;
            float right = view.borderRight!=nil? view.borderRight.width+o : o;
            float bottom = view.borderBottom!=nil? view.borderBottom.width+o : o;
            float mx = MAX(MAX(left, right),MAX(top, bottom));
            s.frame = CGRectMake(left-x, top-y, view.bounds.size.width-left-right+2*x, view.bounds.size.height-top-bottom+2*y);
            s.cornerRadius = styles.cornerRadius>mx ? styles.cornerRadius-mx : 0;
            float ww = styles.borderWidth?styles.borderWidth+o:o;
            */
            
            float ww = styles.borderWidth?styles.borderWidth:0;
            s.frame = CGRectMake(ww-x, ww-y, contentLayer.bounds.size.width-2*ww+2*x, contentLayer.bounds.size.height-2*ww+2*y);
            s.cornerRadius = styles.cornerRadius>ww ? styles.cornerRadius-ww : 0;
            s.borderWidth = MAX(x, y);
            s.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            s.shadowOffset = CGSizeMake(x/2, y/2);
            s.shadowRadius = r;
            s.shadowOpacity = 1.0;
            s.shadowColor = cl.CGColor;
            s.masksToBounds = YES;
            [layer addSublayer:s];
            layer.masksToBounds = YES;
            s = nil;
        }else{
            layer.shadowOffset = CGSizeMake(x, y);
            layer.shadowRadius = r;
            layer.shadowColor = cl.CGColor;
            //!!! layer.shadowOpacity is very slow sometime and use much more memory
            //self.layer.shadowOpacity = [parts count]>4? [parts[5] floatValue]:0.7;
            layer.shadowOpacity = 0.7;
        }
        cl = nil;
    }else{
        layer.shadowOffset = CGSizeZero;
        layer.shadowRadius = 0;
        layer.shadowColor = [UIColor clearColor].CGColor;
        layer.shadowOpacity = 0;
    }
    parts = nil;
    
}

void $::drawGradient(NSString *value){
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CALayer *layer = shapeLayer?shapeLayer:contentLayer;
    gradient.frame = layer.bounds;
    gradient.cornerRadius = styles.cornerRadius;
    
    value = [value regexpReplace:@"  +" replace:@" "];
    NSArray *parts = [value componentsSeparatedByString:@" "];
    int size =(int)[parts count];
    
    NSMutableArray *colors=[NSMutableArray array];
    NSMutableArray *locations=[NSMutableArray array];
    int degree = 0;
    for (int i=0;i<size; i++) {
        NSString *v = parts[i];
        if(i<size-1){
            if([v contains:@":"]){
                NSArray *vps = [v componentsSeparatedByString:@":"];
                [colors addObject:(id)[vps[0] colorValue].CGColor];
                [locations addObject:[NSNumber numberWithFloat:[vps[1] floatValue]]];
            }else{
                [colors addObject:(id)[v colorValue].CGColor];
                [locations addObject:[NSNumber numberWithFloat:((float)i/(float)(size-1))]];
            }
        }else{
            degree = [v intValue];
        }
    }
    gradient.colors = colors;
    gradient.locations = locations;
    if(degree)
        gradient.affineTransform = CGAffineTransformMakeRotation(radians(degree));
    [layer insertSublayer:gradient atIndex:0];
}

void $::drawOutline(NSString * outline){
    outline = [outline regexpReplace:@"  +" replace:@" "];
    NSArray *parts = [outline componentsSeparatedByString:@" "];
    if([parts count]==3){
        styles.outlineWidth = [parts[0] floatValue];
        styles.outlineSpace = [parts[1] floatValue];
        styles.outlineColor = cstr(parts[2]);
    }
    NSString *cl = [NSString stringWithUTF8String:styles.outlineColor];
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
}


#pragma mark $ svg

/*
 draw svg path to view.
 H V S T are unsupported
 */
void $::drawSvgPath (const char* svgpathcmd){
    using namespace std;
    CGPathRef path = SVG::path(svgpathcmd);
    
    if(shapeLayer){
        [shapeLayer removeFromSuperlayer];
        shapeLayer=nil;
    }
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = CGRectMake(0, 0, contentLayer.frame.size.width,contentLayer.frame.size.height);
    shapeLayer.path = path;
    
    CGPathRelease(path);
    
    this->setStyle(this->styles);
    [contentLayer addSublayer:shapeLayer];
}


#pragma mark $ scroll
$& $::setContentSize(float x, float y){
    if(scrollable)
        ((UIScrollView*)view).contentSize = CGSizeMake(x, y);
    else
        NSLog(@"LiberOBJC ERROR: You can not specify contentSize to UIView, use sbox instead");
    return *this;
}

#pragma mark $ image

$& $::setImage(id _src){
    if(!_src || ([_src isKindOfClass:[NSString class]]&&[_src length]==0))
        return *this;//much init with img()
    UIImage* img;
    if([_src isKindOfClass:[NSString class]]){
        if([_src hasPrefix:@"http:"]||[_src hasPrefix:@"https:"]||[_src hasPrefix:@"ftp:"]){//URL
            src = _src;
            cout << "set url" << endl;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                cout << "fetch url" << endl;
                NSError* error = nil;
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:src] options:NSDataReadingUncached error:&error];
                if(data&&!error){
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        this->setImage([UIImage imageWithData:data]);
                    });
                }else{
                    NSLog(@"Failed To Load Image From URL:%@",src);
                }
                src = nil;
            });
        }else if([_src hasPrefix:@"assets-library:"]){//asset
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                src = _src;
                @autoreleasepool {
                    [UIImage loadImageFromAssetURL:[NSURL URLWithString:src] handler:^(UIImage *im,NSDictionary *p) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            //this->setImage([UIImage imageWithData:data]);
                            this->setImage(im);
                        });
                        //this->setImage(im);
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
            [contentLayer insertSublayer:imageLayer atIndex:0];
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
                    imageLayer.frame = {{0,0},{styles.w,styles.h}};
                    break;
            }
            imageLayer.contents =(__bridge id)img.CGImage;
            if(shapeLayer)
                imageLayer.mask = shapeLayer;
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
    
    CGRect rect = CGRectMake(styles.paddingLeft, styles.paddingTop, contentLayer.bounds.size.width-styles.paddingLeft-styles.paddingRight, contentLayer.bounds.size.height-styles.paddingTop-styles.paddingBottom);
    
    //logRect(@"txt",rect);
    if(textLayer==nil){
        textLayer= [[CATextLayer alloc] init];
        [contentLayer addSublayer:textLayer];
    }else
        textLayer.hidden = NO;
    if ([textLayer respondsToSelector:@selector(setContentsScale:)]){
        textLayer.contentsScale = [[UIScreen mainScreen] scale];
    }
    
    [textLayer setFrame:rect];
    [textLayer setString:text];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    
    if(styles.font)
        this->setFont(styles.font);
    
    if(styles.fontSize>0)
        this->setFontSize(styles.fontSize);

    if(styles.color)
        this->setColor(styles.color);
    
    this->setTextAlign(styles.textAlign);
    
    textLayer.wrapped = !styles.nowrap;
    textLayer.truncationMode = styles.truncate ? kCATruncationEnd:kCATruncationNone;
    
    return *this;
}

$& $::setDefaultText(NSString * _text){
    if(!text){
        setText(_text);
        text = nil;
    }
    return *this;
}

void $::setTextAlign(const char* align){
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

void $::setFont(char* font){
    NSString *f = [NSString stringWithFormat:@"%s",font];
    if(textLayer==nil)
        textLayer= [[CATextLayer alloc] init];
        NSDictionary *defaultStyle = @{};//FIXME : check styles.mm
        if(defaultStyle!=nil && f==nil){
            f = defaultStyle[@"font"];
        }
    if(f!=nil && ![f isEqualToString:@"default"]){//FIXME
        float fontSize = styles.fontSize>0?styles.fontSize:14;
        if([f contains:@","]){//@"monaco,12"
            NSArray *fs = [f componentsSeparatedByString:@","];
            f = (NSString*)fs[0];
            NSString *fsize = [(NSString*)fs[1] stringByReplacingOccurrencesOfString:@" " withString:@""];
            fontSize = [fsize floatValue];
        }
        styles.fontName = cstr(f);
        [textLayer setFont:(__bridge CFTypeRef)(f)];
        [textLayer setFontSize:fontSize];
    }else{
        this->setFontSize(-1);//adjust size auto;
    }
}


__attribute__((overloadable)) void $::setColor(id color){
    if(textLayer==nil)
        textLayer= [[CATextLayer alloc] init];
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

__attribute__((overloadable)) void $::setColor(char* color){
    if(textLayer==nil)
        textLayer= [[CATextLayer alloc] init];
    if(color){
        UIColor * cl = str2color(color);
        [textLayer setForegroundColor:[cl CGColor]];
    }
}


void $::setFontSize(float s){
    if(textLayer==nil)
        textLayer= [[CATextLayer alloc] init];
    if(s>0)
        [textLayer setFontSize:s];
    else{
        CGRect rect = CGRectMake(styles.paddingLeft, styles.paddingTop, contentLayer.bounds.size.width-styles.paddingLeft-styles.paddingRight, contentLayer.bounds.size.height-styles.paddingTop-styles.paddingBottom);
        NSString *fontName = styles.fontName? str(styles.fontName):@"Helvetica";
        int fontSize = ![text isEqual:[NSNull null]] ? [text sizeToFit:rect.size font:fontName] : 14;
        [textLayer setFontSize:fontSize];
    }
}

$& $::setEditable(BOOL editable){
    styles.editable = editable;
    if(view.textField==nil){
        CGRect rect = CGRectMake(styles.paddingLeft, styles.paddingTop, contentLayer.bounds.size.width-styles.paddingLeft-styles.paddingRight, contentLayer.bounds.size.height-styles.paddingTop-styles.paddingBottom);
        
        NSDictionary * orgs = @{};//FIXME : check styles.mm
        
        NSString *fontName = //_opts[@"fontName"]!=nil? _opts[@"fontName"]:@"Helvetica";
        styles.fontName!=NULL ? str(styles.fontName):@"Helvetica";
        
        float fontSize =// _opts[@"fontSize"]?[_opts[@"fontSize"] floatValue]:
        styles.fontSize>0 ? styles.fontSize:
        (orgs!=nil && orgs[@"fontSize"]!=nil? [orgs[@"fontSize"] floatValue]:14);
        
        const NSArray * aligns = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?
        @[@"left",@"center",@"right", @"justified", @"natrual"]:@[@"left",@"right",@"center", @"justified", @"natrual"];
        //NSString *align = _opts[@"textAlign"]!=nil?_opts[@"textAlign"]:@"left";
        NSString *align = styles.textAlign?str(styles.textAlign):@"left";
        
        if(textLayer.wrapped ||!styles.nowrap){
            UITextView* t = [[UITextView alloc] initWithFrame:rect];
            t.delegate = view;
            t.textAlignment = (NSTextAlignment)[aligns indexOfObject:align];
            t.font = [UIFont fontWithName:fontName size:fontSize];
            t.editable = YES;
            view.textField = t;
        }else{
            UITextField* t = [[UITextField alloc] initWithFrame:rect];
            t.delegate = view;
            if(styles.placeHolder!=nil)
                t.placeholder = str(styles.placeHolder);
            t.textAlignment = (NSTextAlignment)[aligns indexOfObject:align];
            t.font = [UIFont fontWithName:fontName size:fontSize];
            view.textField = t;
        }
        view.textField.hidden = YES;
    }
    this->bind(@"tap", ^void (UIGestureRecognizer*ges, $& o, NSDictionary*params){
        View *v = (View *)ges.view;
        [v switchEditingMode];
    },nil);
    return *this;
}

#pragma mark - Static
NSMutableDictionary * $::s_views = nil;
NSString * $::s_controllerName = nil;
int $::s_views_idx = 0;
/*
 get view by ID
 */
$* $::getView(NSString * _ID, NSString *ctrlerName){
    //NSString * cName = __controllerName?__controllerName:@"__DEFAULT__";
    if(s_views && s_views[ctrlerName] && s_views[ctrlerName][_ID])
        return ($*)[s_views[ctrlerName][_ID] pointerValue];
    return nullptr;
}
/*
 remove all views from memory.
 be careful to use this.
 */
void $::clearAll(NSString *ctrlerName){
    if(s_views && s_views[ctrlerName]){
        for (NSValue *va in s_views[ctrlerName]) {
            $* v = ($*)[va pointerValue];
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
    if(!vp || !vp->ID || !vp->NS)
        return;
    if(s_views && s_views[vp->NS])
       [s_views[vp->NS] removeObjectForKey:(NSString*)(vp->ID)];
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
__attribute__((overloadable)) $& box(){return (new $())->setStyle({});}
__attribute__((overloadable)) $& box(Styles s){return (new $())->setStyle(s);}
__attribute__((overloadable)) $& box(Styles *sp){return (new $())->setStyle(*sp);}
__attribute__((overloadable)) $& box(Styles s, Styles *sp){return (new $())->setStyle(style(&s,sp));}

__attribute__((overloadable)) $& box(initializer_list<Styles *>ext){return (new $())->setStyle({},ext);}
__attribute__((overloadable)) $& box(Styles s, initializer_list<Styles *>ext){return (new $())->setStyle(s,ext);}
__attribute__((overloadable)) $& sbox(){return (new $(true))->setStyle({});}
__attribute__((overloadable)) $& sbox(Styles s){return (new $(true))->setStyle(s);}
__attribute__((overloadable)) $& sbox(Styles *sp){return (new $(true))->setStyle(*sp);}
__attribute__((overloadable)) $& sbox(Styles s,Styles *sp){return (new $(true))->setStyle(style(&s,sp));}

__attribute__((overloadable)) $& sbox(initializer_list<Styles *>ext){return (new $(true))->setStyle({},ext);}
__attribute__((overloadable)) $& sbox(Styles s, initializer_list<Styles *>ext){return (new $(true))->setStyle(s,ext);}

__attribute__((overloadable)) $& label(NSString*txt){return (new $())->setStyle({}).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles s){return (new $())->setStyle(s).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles *sp){return (new $())->setStyle(*sp).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles s,Styles *sp){return (new $())->setStyle(style(&s,sp)).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, std::initializer_list<Styles *>ext){return (new $())->setStyle({},ext).setText(txt);}
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


__attribute__((overloadable)) $& img(id src){return (new $(src))->setStyle({});}
__attribute__((overloadable)) $& img(id src, Styles s){return (new $(src))->setStyle(s);};
__attribute__((overloadable)) $& img(id src, Styles *sp){return (new $(src))->setStyle(*sp);};
__attribute__((overloadable)) $& img(id src, Styles s,Styles *sp){return (new $(src))->setStyle(style(&s,sp));};
__attribute__((overloadable)) $& img(id src, std::initializer_list<Styles *>ext){return (new $(src))->setStyle({},ext);};
__attribute__((overloadable)) $& img(id src, Styles s, std::initializer_list<Styles *>ext){return (new $(src))->setStyle(s,ext);};


__attribute__((overloadable)) $& svgp(NSString* cmds, Styles s){
    $* o=(new $())->initView(s);o->drawSvgPath([cmds UTF8String]);return *o;
}
__attribute__((overloadable)) $& svgp(NSString* cmds, Styles *sp){$& o=(new $())->setStyle(*sp);o.drawSvgPath([cmds UTF8String]);return o;}
__attribute__((overloadable)) $& svgp(NSString* cmds, Styles s, Styles *sp){$& o=(new $())->setStyle(style(&s,sp));o.drawSvgPath([cmds UTF8String]);return o;}
__attribute__((overloadable)) $& svgp(NSString* cmds, std::initializer_list<Styles *>ext){$& o=(new $())->setStyle({},ext);o.drawSvgPath([cmds UTF8String]);return o;}
__attribute__((overloadable)) $& svgp(NSString* cmds, Styles s, std::initializer_list<Styles *>ext){$& o=(new $())->setStyle(s,ext);o.drawSvgPath([cmds UTF8String]);return o;}


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


#pragma mark - CPP

void memuse(const char* msg) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),TASK_BASIC_INFO,(task_info_t)&info,&size);
    NSLog(@"MEM : %@ %u KB",[NSString stringWithUTF8String:msg],info.resident_size/1024);
}

NSString * str(char * cs){return cs!=nil?[NSString stringWithCString:cs encoding:NSASCIIStringEncoding]:nil;}

char * cstr(NSString * cs){
    return const_cast<char*>([cs UTF8String]);
}

UIColor * str2color(char * s){
    string cs(s);
    if(strstarts(s, "#")){
        int red, green, blue, alpha=255;
        sscanf(cs.substr(1,2).c_str(), "%x", &red);
        sscanf(cs.substr(3,2).c_str(), "%x", &green);
        sscanf(cs.substr(5,2).c_str(), "%x", &blue);
        if(cs.size()==9) sscanf(cs.substr(7,2).c_str(), "%x", &alpha);
        return [UIColor colorWithRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:(float)alpha/255];
    }else if(strhas(s,",")==true){
        //cs.erase(remove_if(cs.begin(), cs.end(), [](char x){return std::isspace(x);}), cs.end());
        cs = regex_replace(cs, regex("\\s"), "");
        float clr []= {0,0,0,1};
        int start = 0, end = 0, i=0;
        do {
            end = (int)cs.find(',', start);
            string sc =cs.substr(start, end - start);
            clr[i] = ((float)std::stoi(sc))/255;
            start = end + 1;
            i++;
        }while(end != string::npos);
        return [UIColor colorWithRed:clr[0] green:clr[1] blue:clr[2] alpha:clr[3]];
    }
    return [UIColor colorWithWhite:0 alpha:0];
}

char* dec2hex(int dec, int bits){
    ostringstream ss;
    ss<< std::hex << dec;
    string st = ss.str();
    while(st.length()<bits)
        st = "0"+st;
    char *cstr = new char[bits+1];
    strcpy(cstr, st.c_str());
    return const_cast<char*>(cstr);
}

char * colorstr(int r, int g, int b, int a){
    char * ar=dec2hex(MIN(r,255),2), *ag=dec2hex(MIN(g,255),2), *ab=dec2hex(MIN(b,255),2), *aa=dec2hex(MIN(a,255),2);
    NSString *s = [NSString stringWithFormat:@"#%@%@%@%@",str(ar),str(ag),str(ab),str(aa)];
    return cstr(s);
}
char * colorfstr(float r, float g, float b, float a){
    return colorstr(r*255, g*255, b*255, a*255);
}

/*
 char** split(char *s, const char* delim){
 char * pch;
 char * arr[]={};
 char ss[] = "- This, a sample string.";
 pch = strtok (ss, delim);
 int i = 0;
 while (pch != NULL){
 arr[i++] = pch;
 pch = strtok (NULL, delim);
 }
 return arr;
 }*/

bool strstarts(char* s1, const char* s2){
    string ss1(s1), ss2(s2);
    return ss2.size() <= ss1.size() && ss1.compare(0, ss2.size(), ss2) == 0;
}

bool strends(char* s1, const char* s2){
    string ss1(s1), ss2(s2);
    return ss2.size() <= ss1.size() && ss1.compare(ss1.size()-ss2.size(), ss2.size(), ss2) == 0;
}

bool strhas(char* s1, const char* s2){
    if(!s1 || !s2) return false;
    string ss1(s1), ss2(s2);
    return (ss1.find(ss2) != string::npos);
}

char * f2str(float f){
    ostringstream ss;
    ss << f;
    string st = ss.str();
    char *cstr = new char[st.length() + 1];
    strcpy(cstr, st.c_str());
    return cstr;
    //return const_cast<char *>(ss.str().c_str());
}


char * strs(int num, char* s ,...){
    va_list ap;
    va_start(ap, s);
    string st(s);
    for(int i = 0; i < num-1; i++) {
        char * ss =va_arg(ap, char*);
        if(ss) st = st + string(ss);
    }
    va_end(ap);
    //char * r= const_cast<char *>(st.c_str());
    char *cstr = new char[st.length() + 1];
    strcpy(cstr, st.c_str());
    return cstr;
}

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
    if(sc.borderWidth) ss.borderWidth = sc.borderWidth;
    if(sc.borderColor) ss.borderColor = sc.borderColor;
    if(sc.cornerRadius) ss.cornerRadius = sc.cornerRadius;
    
    if(sc.outlineColor) ss.outlineColor = sc.outlineColor;
    if(sc.outline) ss.outline = sc.outline;
    if(sc.outlineSpace) ss.outlineSpace = sc.outlineSpace;
    if(sc.outlineWidth) ss.outlineWidth = sc.outlineWidth;
    
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

Styles str2style(char * s){
    string cs(s);
    regex_replace(cs, regex("\\s*;\\s*"), "");
    Styles s0 = {};
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
            if(k=="borderWidth") s0.borderWidth = atof(v);
            if(k=="borderColor") s0.borderColor = v;
            
            if(k=="cornerRadius") s0.cornerRadius = atoi(v);
            if(k=="outlineColor") s0.outlineColor = v;
            if(k=="outline") s0.outline = v;
            if(k=="outlineSpace") s0.outlineSpace = atoi(v);
            if(k=="outlineWidth") s0.outlineWidth = atoi(v);
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

//milliseconds
long long milliseconds(){
    return (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
}

MDic* __counters;

#pragma mark time
void $setTimeout(float millisec, TimeoutHandler block, NSDictionary*dic){
    dispatch_time_t span = dispatch_time(DISPATCH_TIME_NOW, millisec*0.001f * NSEC_PER_SEC);
    dispatch_after(span, dispatch_get_main_queue(), ^(void){
        block(dic);
    });
}

/**
 @exmample
 $& __block ico = $ico(@"train",{0,30}) >> self.view;
 $setInterval(40, ^BOOL(NSDictionary*d, int i){
 ico.view.center = CGPointMake(i*10, 30);   //move this ico
 return (i>100) ? NO:YES; // exec for 100 times.
 }, @{});
 
 */
void $setInterval(float millisec, TimeIntervalHandler block, NSDictionary*dic){
    if(!__counters) __counters=[[MDic alloc] init];
    id vp =block;
    if(!__counters[vp])
        __counters[vp]=@0;

    dispatch_time_t span = dispatch_time(DISPATCH_TIME_NOW, millisec*0.001f * NSEC_PER_SEC);
    dispatch_after(span, dispatch_get_main_queue(), ^(void){
        int counter = [__counters[vp] intValue];
        if(block(dic, counter++)) {
            $setInterval(millisec, block, dic);
            __counters[vp] = @(counter);
        }else {
            [__counters removeObjectForKey:vp];
        }
        
    });
}

#pragma mark data

void $setData(NSString *keyPath, id value){
    //AppDelegate *casya = $app();
    if(__datas==nil) $loadData();
    [__datas setValue:value forKeyPath:keyPath];
}
id $getData(NSString *keyPath){
    //AppDelegate *casya = $app();
    if(__datas==nil) $loadData();
    return [__datas valueForKeyPath:keyPath];
}
NSString* $getStr(NSString *keyPath){
    id v =$getData(keyPath);
    return (NSString*)v;
}
int $getInt(NSString *keyPath){
    id v =$getData(keyPath);
    return v!=nil? [(NSNumber*)v integerValue]:0;
}
long $getLong(NSString *keyPath){
    id v =$getData(keyPath);
    return v!=nil? [(NSNumber*)v longValue]:0;
}
float $getFloat(NSString *keyPath){
    id v =$getData(keyPath);
    return v!=nil? [(NSNumber*)v floatValue]:0;
}
NSArray* $getArr(NSString *keyPath){
    id v =$getData(keyPath);
    return (NSArray*)v;
}
NSDictionary* $getHash(NSString *keyPath){
    id v =$getData(keyPath);
    return (NSDictionary*)v;
}

void $removeData(NSString * key){
    if(__datas==nil)return;
    [__datas removeObjectForKey:key];
}
void $clearData(){
    if(__datas==nil)return;
    [__datas removeAllObjects];
}

void $saveData(){
#ifdef DATA_FILE_NAME
    if(__datas!=nil)
        [__datas writeToFile:[NSString stringWithUTF8String:DATA_FILE_NAME] atomically:YES];
#endif
}

void $loadData(){
#ifdef DATA_FILE_NAME
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString * fpath = [docDir stringByAppendingPathComponent:[NSString stringWithUTF8String:DATA_FILE_NAME]];
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


#pragma mark - opengl
