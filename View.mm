//
//  View.m
//  liberobjc
//
//  Created by soyoes on 6/14/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#import "Styles.h"
#include <math.h>
#include <vector>
#include <string>
#include <sstream>
#include <algorithm>
#include <cctype>
#include <regex>
#include <iostream>
#import "Categories.h"
#import "View.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
using namespace std;

#pragma mark - Mask

@implementation Mask

-(id) initWithOwner:($*)owner{
    self = [super initWithFrame:owner->view.bounds];
    _data = [[NSMutableDictionary alloc] init];
    _gestures = [[NSMutableDictionary alloc] init];
    _owner = owner;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    [owner->view addSubview:self];
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
            Mask * v = (Mask*)ges.view;
            NSDictionary *params = [v.data valueForKey:@"gestureData"];
            handler(ges, params);
            [v.data removeObjectForKey:@"gestureData"];
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

#pragma mark - $


__attribute__((overloadable)) $::$(){nodes=*new std::vector<$*>();view=nil;}
__attribute__((overloadable)) $::$(id _src){$();src = _src;}
__attribute__((overloadable)) $::$(bool scroll){$();scrollable=scroll;}

// Constructor
$::~$(){view=nil;mask=nil;nodes.clear();src=nil;text=nil;textLayer=nil;}

__attribute__((overloadable))
$& $::setStyle(Styles s){
    //TODO
    styles = s;
    if(!view){
        CGRect rect =CGRectMake(s.x, s.y, s.w, s.h);
        if(src!=nil){
            view = [[UIImageView alloc] initWithFrame:rect];
            setImage(src);
        }else{
            view = scrollable?[[UIScrollView alloc] initWithFrame:rect]:[[UIView alloc] initWithFrame:rect];
        }
    }
    
    view.layer.zPosition = styles.z;
    
    if(styles.padding){
        styles.paddingLeft=styles.padding;
        styles.paddingTop=styles.padding;
        styles.paddingRight=styles.padding;
        styles.paddingBottom=styles.padding;
    }
    
    if(styles.border) this->drawBorder(str(styles.border));
    
    if(styles.bgcolor){
        if(strhas(styles.bgcolor, ":")){//gradient
            this->drawGradient(str(styles.bgcolor));
        }else
            view.backgroundColor=str2color(styles.bgcolor);
    }

    if(styles.shadow){
        NSString *shadow = [str(styles.shadow) regexpReplace:@"  +" replace:@" "];
        if([shadow contains:@","]){
            NSArray *shadows = [shadow componentsSeparatedByString:@","];
            for(NSString *sha in shadows)
                this->drawShadow(sha);
        }else{
            this->drawShadow(shadow);
        }
    }

    if(styles.outline){
        this->drawOutline(str(styles.outline));
    }
    
    CGAffineTransform transf;
    bool trasDefined=false;
    if(styles.scaleX>0 && styles.scaleY>0){
        trasDefined = true;
        transf = CGAffineTransformMakeScale(styles.scaleX, styles.scaleY);
    }
    
    if(styles.flip){
        CGAffineTransform flip;
        if (styles.flip[0] == 'H') {
            flip =CGAffineTransformMake(view.transform.a * -1, 0, 0, 1, view.transform.tx, 0);
            transf = trasDefined? CGAffineTransformConcat(transf,flip):flip;
            trasDefined = true;
        }else if(styles.flip[0] == 'V'){
            flip = CGAffineTransformMake(1, 0, 0, view.transform.d * -1, 0, view.transform.ty);
            transf = trasDefined? CGAffineTransformConcat(transf,flip):flip;
            trasDefined = true;
        }
    }
    
    if(styles.rotate){
        CGAffineTransform rotate = CGAffineTransformMakeRotation(radians(styles.rotate));
        transf = trasDefined? CGAffineTransformConcat(transf,rotate):rotate;
        trasDefined = true;
    }
    
    if(trasDefined)
        view.transform = transf;
    
    if(styles.rotate3d){
        string rotate(styles.rotate3d);
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
        
        CALayer *layer = view.layer;
        layer.anchorPoint = CGPointMake(parts[5], parts[6]);
        CATransform3D rt = CATransform3DIdentity;
        rt.m34 = 1.0f / (-1*parts[4]);
        rt = CATransform3DRotate(rt, radians(parts[0]), parts[1], parts[2], parts[3]);
        rt = CATransform3DTranslate(rt, parts[7], parts[8], parts[9]);
        layer.transform = rt;//CATransform3DConcat
    }
    
    
    //self.alpha = styles.alpha;
    view.layer.opacity = (1-styles.alpha);
    
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
    if(!mask)
        mask = [[Mask alloc] initWithOwner:this];
    mask.gestures[event] = (id) handler;
    event = [event stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[event substringToIndex:1] uppercaseString]];
    NSString * className = [NSString stringWithFormat:@"UI%@GestureRecognizer",event];
    UIGestureRecognizer *gesture = [[NSClassFromString(className) alloc]
                                    initWithTarget:mask action:@selector(gestureHandler:)];
    //[mask setUserInteractionEnabled:YES];
    [view setUserInteractionEnabled:YES];
    /*
     TODO multipleTouchEnabled
     exclusiveTouch
     */
    if(opts!=nil && [[opts allKeys] count]>0){
        //this->set(@"gestureData", opts);
        [mask.data setValue:opts forKey:@"gestureData"];
    }
    [mask addGestureRecognizer:gesture];
    return *this;
}
$& $::unbind(NSString* event){
    if(!mask) return *this;
    [mask.gestures removeObjectForKey:event];
    //FIXME remove event
    return *this;
}
__attribute__((overloadable)) $& $::operator>>($& p){
    if(&p){[p.view addSubview:this->view];parent = &p;p.nodes.push_back(this);}
    return *this;
}
__attribute__((overloadable)) $& $::operator>>(UIView*p){
    if(p){[p addSubview:this->view];}
    return *this;
}
__attribute__((overloadable)) $& $::operator<<($& p){
    if(&p){[view addSubview:p.view];p.parent = this;nodes.push_back(&p);}
    return *this;
}


#pragma mark $ data

id $::get(NSString* key){
    if(mask){return [mask.data valueForKey:key];}
    return nil;
}
void $::set(NSString*key, id value){
    if(mask){[mask.data setValue:value forKey:key];}
}
void $::del(NSString*key){
    if(mask){[mask.data removeObjectForKey:key];}
}

#pragma mark $ drawing

void $::drawBorder(NSString *border){
    border = [border regexpReplace:@"  +" replace:@" "];
    NSArray *parts = [border componentsSeparatedByString:@" "];
    styles.borderWidth =[parts[0] floatValue];
    view.layer.borderWidth =styles.borderWidth;
    if([parts count]>1){
        NSString *cl = parts[1];
        if([cl contains:@","]||[cl contains:@"#"]){//color
            view.layer.borderColor = [cl colorValue].CGColor;
        }else{//image
            view.layer.borderColor = [UIColor colorWithPatternImage:[UIImage imageNamed:cl]].CGColor;
        }
        //radius
        if([parts count]>2){
            int rd = [parts[2] intValue];
            if(rd>0) {
                styles.cornerRadius = rd;
                view.layer.cornerRadius = rd;
                view.layer.masksToBounds=YES;
            }
        }
    }

}


/**
 format :[inset] x y radius [color]
 */

void $::drawShadow(NSString* shadow){
    if(!shadow || [shadow length]==0)return;
    
    NSArray *parts = [shadow componentsSeparatedByString:@" "];
    int psize =(int)[parts count];
    
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
            float o = styles.outlineWidth+styles.outlineSpace;
            /*
            float left = view.borderLeft!=nil? view.borderLeft.width+o : o;
            float top = view.borderTop!=nil? view.borderTop.width+o : o;
            float right = view.borderRight!=nil? view.borderRight.width+o : o;
            float bottom = view.borderBottom!=nil? view.borderBottom.width+o : o;
            float mx = MAX(MAX(left, right),MAX(top, bottom));
            s.frame = CGRectMake(left-x, top-y, view.bounds.size.width-left-right+2*x, view.bounds.size.height-top-bottom+2*y);
            s.cornerRadius = styles.cornerRadius>mx ? styles.cornerRadius-mx : 0;
            */
            
            float ww = styles.borderWidth?styles.borderWidth+o:o;
            s.frame = CGRectMake(ww-x, ww-y, view.bounds.size.width-2*ww+2*x, view.bounds.size.height-2*ww+2*y);
            s.cornerRadius = styles.cornerRadius>ww ? styles.cornerRadius-ww : 0;
            s.borderWidth = MAX(x, y);
            s.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            s.shadowOffset = CGSizeMake(x/2, y/2);
            s.shadowRadius = r;
            s.shadowOpacity = 0.7;
            s.shadowColor = cl.CGColor;
            s.masksToBounds = YES;
            [view.layer addSublayer:s];
            s = nil;
        }else{
            view.layer.shadowOffset = CGSizeMake(x, y);
            view.layer.shadowRadius = r;
            view.layer.shadowColor = cl.CGColor;
            //!!! layer.shadowOpacity is very slow sometime and use much more memory
            //self.layer.shadowOpacity = [parts count]>4? [parts[5] floatValue]:0.7;
            view.layer.shadowOpacity = 0.7;
        }
        cl = nil;
    }else{
        view.layer.shadowOffset = CGSizeZero;
        view.layer.shadowRadius = 0;
        view.layer.shadowColor = [UIColor clearColor].CGColor;
        view.layer.shadowOpacity = 0;
    }
    parts = nil;
    
}

void $::drawGradient(NSString *value){
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.cornerRadius = styles.cornerRadius;
    
    value = [value regexpReplace:@"  +" replace:@" "];
    NSArray *parts = [value componentsSeparatedByString:@" "];
    int size =(int)[parts count];
    
    NSMutableArray *colors=[NSMutableArray array];
    NSMutableArray *locations=[NSMutableArray array];
    for (int i=0;i<size; i++) {
        NSString *v = parts[i];
        if([v contains:@":"]){
            NSArray *vps = [v componentsSeparatedByString:@":"];
            [colors addObject:(id)[vps[0] colorValue].CGColor];
            [locations addObject:[NSNumber numberWithFloat:[vps[1] floatValue]]];
        }else{
            [colors addObject:(id)[v colorValue].CGColor];
            [locations addObject:[NSNumber numberWithFloat:((float)i/(float)(size-1))]];
        }
    }
    gradient.colors = colors;
    gradient.locations = locations;
    [view.layer insertSublayer:gradient atIndex:0];
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
                              view.frame.size.width+2*w, view.frame.size.height+2*w);
    
    olayer.borderWidth = styles.outlineWidth;
    olayer.borderColor = oColor.CGColor;
    olayer.cornerRadius = styles.cornerRadius>0? styles.cornerRadius+styles.outlineSpace : 0;
    
    [view.layer addSublayer:olayer];
    olayer = nil;oColor = nil;
}

#pragma mark $ scroll
void $::setContentSize(float x, float y){
    if(scrollable)
        ((UIScrollView*)view).contentSize = CGSizeMake(x, y);
    else
        NSLog(@"LiberOBJC ERROR: You can not specify contentSize to UIView, use sbox instead");
}

#pragma mark $ image

$& $::setImage(id _src){
    if(!src || !_src)return *this;//much init with img()
    src=_src;
    UIImage* img;
    if([src isKindOfClass:[NSString class]])
        img = [UIImage imageNamed:src];
    else if([src isKindOfClass:[UIImage class]])
        img = src;
    if(img)
        [((UIImageView*)view) setImage:img];
    return *this;
}
UIImage * $::getImage(){
    if(src){
        return ((UIImageView*)view).image;
    }
    return nil;
}

#pragma mark $ text

$& $::setText(NSString * _text){
    text = _text;
    
    if(!mask)
        mask = [[Mask alloc] initWithOwner:this];
    
    // TODO
    // - (CGSize)sizeThatFits:(CGSize)size //calculate a size to make the superview to fit its all subviews
    // - (void)sizeToFit //auto adjust super view to fit its all subviews
    
    
    CGRect rect = CGRectMake(styles.paddingLeft, styles.paddingTop, view.bounds.size.width-styles.paddingLeft-styles.paddingRight, view.bounds.size.height-styles.paddingTop-styles.paddingBottom);
    
    //logRect(@"txt",rect);
    if(textLayer==nil)
        textLayer= [[CATextLayer alloc] init];
        else
            textLayer.hidden = NO;
            if ([textLayer respondsToSelector:@selector(setContentsScale:)]){
                textLayer.contentsScale = [[UIScreen mainScreen] scale];
            }
    
    [textLayer setFrame:rect];
    [textLayer setString:text];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    
    this->setFont(styles.font);
    
    if(styles.fontSize>0)
        this->setFontSize(styles.fontSize);

    if(styles.color)
        this->setColor(styles.color);
    
    this->setTextAlign(str(styles.textAlign));
    
    [view.layer addSublayer:textLayer];
    return *this;
}

void $::setTextAlign(NSString* align){
    if(align==nil)
        align = @"left";
    const NSDictionary * def = @{@"center":kCAAlignmentCenter,@"left":kCAAlignmentLeft,
                                     @"right":kCAAlignmentRight,@"justified":kCAAlignmentJustified};
    if(align!=nil)
        styles.textAlign = cstr(align);
    
    NSString *a = (align!=nil && def[align]!=nil) ? def[align]:kCAAlignmentNatural;
    if(textLayer!=nil){
        [textLayer setAlignmentMode:a];
    }
    textLayer.wrapped = !styles.nowrap;
    textLayer.truncationMode = styles.truncate ? kCATruncationEnd:kCATruncationNone;
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
        CGRect rect = CGRectMake(styles.paddingLeft, styles.paddingTop, view.bounds.size.width-styles.paddingLeft-styles.paddingRight, view.bounds.size.height-styles.paddingTop-styles.paddingBottom);
        NSString *fontName = styles.fontName? str(styles.fontName):@"Helvetica";
        int fontSize = ![text isEqual:[NSNull null]] ? [text sizeToFit:rect.size font:fontName] : 14;
        [textLayer setFontSize:fontSize];
    }
}

void $::setEditable(BOOL editable){
    styles.editable = editable;
    if(mask.textField==nil){
        CGRect rect = CGRectMake(styles.paddingLeft, styles.paddingTop, view.bounds.size.width-styles.paddingLeft-styles.paddingRight, view.bounds.size.height-styles.paddingTop-styles.paddingBottom);
        
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
            t.delegate = mask;
            t.textAlignment = (NSTextAlignment)[aligns indexOfObject:align];
            t.font = [UIFont fontWithName:fontName size:fontSize];
            t.editable = YES;
            mask.textField = t;
        }else{
            UITextField* t = [[UITextField alloc] initWithFrame:rect];
            t.delegate = mask;
            if(styles.placeHolder!=nil)
                t.placeholder = str(styles.placeHolder);
            t.textAlignment = (NSTextAlignment)[aligns indexOfObject:align];
            t.font = [UIFont fontWithName:fontName size:fontSize];
            mask.textField = t;
        }
        mask.textField.hidden = YES;
    }
    this->bind(@"tap", ^void (UIGestureRecognizer*ges, NSDictionary*params){
        Mask *v = (Mask *)ges.view;
        [v switchEditingMode];
    },nil);
}


#pragma mark - CPP wrapper
__attribute__((overloadable)) $& box(){return *(new $());}
__attribute__((overloadable)) $& box(Styles s){return (new $())->setStyle(s);}
__attribute__((overloadable)) $& box(Styles *sp){return (new $())->setStyle(*sp);}
__attribute__((overloadable)) $& box(Styles s, Styles *sp){return (new $())->setStyle(style(&s,sp));}

__attribute__((overloadable)) $& box(initializer_list<Styles *>ext){return (new $())->setStyle({},ext);}
__attribute__((overloadable)) $& box(Styles s, initializer_list<Styles *>ext){return (new $())->setStyle(s,ext);}
__attribute__((overloadable)) $& sbox(){return *(new $(true));}
__attribute__((overloadable)) $& sbox(Styles s){return (new $(true))->setStyle(s);}
__attribute__((overloadable)) $& sbox(Styles *sp){return (new $(true))->setStyle(*sp);}
__attribute__((overloadable)) $& sbox(Styles s,Styles *sp){return (new $(true))->setStyle(style(&s,sp));}

__attribute__((overloadable)) $& sbox(initializer_list<Styles *>ext){return (new $(true))->setStyle({},ext);}
__attribute__((overloadable)) $& sbox(Styles s, initializer_list<Styles *>ext){return (new $(true))->setStyle(s,ext);}

__attribute__((overloadable)) $& label(NSString*txt){return (new $())->setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles s){return (new $())->setStyle(s).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles *sp){return (new $())->setStyle(*sp).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles s,Styles *sp){return (new $())->setStyle(style(&s,sp)).setText(txt);}

__attribute__((overloadable)) $& label(NSString*txt, std::initializer_list<Styles *>ext){return (new $())->setStyle({},ext).setText(txt);}
__attribute__((overloadable)) $& label(NSString*txt, Styles s, std::initializer_list<Styles *>ext){return (new $())->setStyle(s,ext).setText(txt);}
__attribute__((overloadable)) $& img(id src){return *(new $(src));}
__attribute__((overloadable)) $& img(id src, Styles s){return (new $(src))->setStyle(s);};
__attribute__((overloadable)) $& img(id src, Styles *sp){return (new $(src))->setStyle(*sp);};
__attribute__((overloadable)) $& img(id src, Styles s,Styles *sp){return (new $(src))->setStyle(style(&s,sp));};

__attribute__((overloadable)) $& img(id src, std::initializer_list<Styles *>ext){return (new $(src))->setStyle({},ext);};
__attribute__((overloadable)) $& img(id src, Styles s, std::initializer_list<Styles *>ext){return (new $(src))->setStyle(s,ext);};

__attribute__((overloadable)) $& list(NSArray*data, ListHandler handler, Styles listStyle){
    return list(data, handler, listStyle, {});
}
__attribute__((overloadable)) $& list(NSArray*data, ListHandler handler, Styles listStyle, std::initializer_list<Styles *>ext){
    if(data && handler){
        int i = 0;
        $& ul = sbox(listStyle, ext);
        for (id item in data)
            ul << handler(item, i++); //TODO dispatch async
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

NSString * str(char * cs){return cs!=nil?[NSString stringWithFormat:@"%s",cs]:nil;}

char * cstr(NSString * cs){
    return (char*)[cs UTF8String];
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

Styles style(Styles *custom, Styles *ext){
    
    if(!ext) return *custom;
    
    Styles ss = *ext;
    Styles sc = *custom;
    if(sc.x) ss.x = sc.x;
    if(sc.y) ss.y = sc.y;
    if(sc.z) ss.z = sc.z;
    if(sc.w) ss.w = sc.w;
    if(sc.h) ss.h = sc.h;
    
    if(sc.border) ss.border = sc.border;
    if(sc.borderWidth) ss.borderWidth = sc.borderWidth;
    if(sc.cornerRadius) ss.cornerRadius = sc.cornerRadius;
    
    if(sc.outlineColor) ss.outlineColor = sc.outlineColor;
    if(sc.outline) ss.outline = sc.outline;
    if(sc.outlineSpace) ss.outlineSpace = sc.outlineSpace;
    if(sc.outlineWidth) ss.outlineWidth = sc.outlineWidth;
    
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
            
            if(k=="cornerRadius") s0.cornerRadius = atoi(v);
            if(k=="outlineColor") s0.outlineColor = v;
            if(k=="outline") s0.outline = v;
            if(k=="outlineSpace") s0.outlineSpace = atoi(v);
            if(k=="outlineWidth") s0.outlineWidth = atoi(v);
            
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
