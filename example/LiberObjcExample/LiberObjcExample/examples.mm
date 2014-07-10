//
//  examples.cpp
//  LiberObjcExample
//
//  Created by soyoes on 6/29/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#include "examples.h"
#include "style_sheet.h"
#include <iostream>

//Shapes with styles
void boxes_example($& target){
    NSLog(@"boxes");
    $& a = box(&s_panel)
        //bgcolor
        <<box({.x=10,.y=10},&s_box)
        //transparent color RGBA
        <<box({.x=110,.y=10,.bgcolor="#FFFFFF55"},&s_box)
        //gradient with positions
        <<box({.x=210,.y=10,.bgcolor="#00FFFF:0 #FF0000:0.5 #FFFF00:1"},&s_box)
    
    
        //shadow
        <<box({.x=10,.y=110,.shadow="2 2 3 #000000"},&s_box)
        //inner shadow
        <<box({.x=110,.y=110,.shadow="inset 2 2 3 #000000"},&s_box)
        //gradient with positions and degree
        <<box({.x=210,.y=110,.bgcolor="#00FFFF:0 #FF0000:0.5 #FFFF00:1 90"},&s_box)

    
        //border + shadow
        <<box({.x=10,.y=210,.border="4 #FF9933",.shadow="0 0 5 #000000"},&s_box)
        //corner radius with border
        <<box({.x=110,.y=210,.cornerRadius=10,.border="1 #ff3399 15"},&s_box)
        //corner radius
        <<box({.x=210,.y=210,.cornerRadius=10,.shadow="1 1 3 #333333"},&s_box)
    
        //outline
        <<box({.x=10,.y=310,.outline="1 #ff3399 5"},&s_box)
        //svg path triangle
        <<svgp(@"M 40 0 L80 80 L0 80 Z", {.x=110,.y=310,.bgcolor="#0000FF"},&s_box)
        //svg path fan & shadow
        <<svgp(@"M 40 0 L80 60 Q40 80 0 60 Z", {.x=210,.y=310,.bgcolor="#00FF00",.shadow="0 0 2 #333333"},&s_box)
    
        >>target;
}

//Image and content mode
void images_example($& target){
    NSLog(@"images");
    box(&s_panel)
        //aspect ratio fit
        <<img(@"kodaru.jpg", {.x=10,.y=10,.contentMode=m_FIT},&s_box)
        //crop and fit the rect size
        <<img(@"kodaru.jpg", {.x=110,.y=10,.contentMode=m_CROP_FIT},&s_box)
        //aspect ratio fill
        <<img(@"kodaru.jpg", {.x=210,.y=10,.contentMode=m_FILL},&s_box)
    
        //show center with original size
        <<img(@"kodaru.jpg", {.x=10,.y=110,.contentMode=m_ORG},&s_box)
        //img with round corner
        <<img(@"kodaru.jpg", {.x=110,.y=110,.contentMode=m_CROP_FIT,.cornerRadius=40},&s_box)
        //svg path fan with image background
        <<svgp(@"M40 0 L80 80 L0 80 Z", {.x=210,.y=110},&s_box).setImage(@"kodaru.jpg")
    
        //rotate 3d
        <<img(@"kodaru.jpg", {.x=10,.y=210,.contentMode=m_CROP_FIT,.rotate3d="45,1,0,0,200,0.5,1"},&s_box)
        //rotate 2d
        <<img(@"kodaru.jpg", {.x=110,.y=210,.contentMode=m_CROP_FIT,.rotate=45},&s_box)
        //rotate 3d
        <<img(@"kodaru.jpg", {.x=210,.y=210,.contentMode=m_CROP_FIT,.rotate3d="45,0,1,0,200,0.5,1"},&s_box)
    
        //flipH
        <<img(@"kodaru.jpg", {.x=10,.y=310,.contentMode=m_CROP_FIT,.flip="H"},&s_box)
        //flipV
        <<img(@"kodaru.jpg", {.x=110,.y=310,.contentMode=m_CROP_FIT,.flip="V"},&s_box)
    
        >>target;
    
    slide(@[@"sea.jpg",@"mountain.jpg",@"people.jpg",@"kodaru.jpg",
            @"sea.jpg",@"mountain.jpg",@"people.jpg",@"kodaru.jpg"],
          ^$& (id item, int i) {
              return img(item,{300.0f*i,0,300,80,.contentMode=m_CROP_FIT});
          },
          {10,410,300,80})
        >> target;
}

//Label & text edit
void labels_example($& target){
    NSLog(@"labels");
    float i=0;
    $& b = box(&s_panel)
        //normal label
        <<label(@"Label normal", {.y=10+35*(i++)}, &s_label)
        //truncate
        <<label(@"Label truncate, Lorem ipsum dolor sit amet, consectetur adipisicing elit",
                {.y=10+35*(i++),.nowrap=true,.truncate=true}, &s_label)
        // .nowrap=true + setEditable = single line edit
        <<label(@"Label editable (single line)", {.y=10+35*(i++),.nowrap=true}, &s_label).setEditable(true)
        <<label(@"Label with other font", {.y=10+35*(i++),.font="MarkerFelt-Thin,14",.color="#ff0000"}, &s_label)
        <<label(@"Label multiline\nThe 2nd row", {.y=10+35*(i++), .h=60}, &s_label)
        // .nowrap=false + setEditable = multi line edit
        <<(label(@"Label multiline\neditable", {.ID=@"textEdit",.y=10+35*(i++)+30, .h=120}, &s_label).setEditable(true)) //
        >>target;
}

//Lazy loading
void lazy_loading_example($& target){
    NSLog(@"lazy_loading");
    float i=0;
    box(&s_panel)
        >>target
        //normal label
        <<glabel(@"http://ip.jsontest.com", ^NSString*(id res) {
            return res[@"ip"];                                                   //this will be set after loading
        },{.y=10+35*(i++)},&s_label).setDefaultText(@"Loading from remote ...")  //this will be shown as default/loading message.
        <<img(@"http://miriadna.com/desctopwalls/images/min/Walking-in-forest.jpg",{.y=10+35*(i++),.h=200},&s_label);
    

}

//Actions
void actions_example($& target){
    NSLog(@"actions");
    
    GestureHandler handler =^(GR *g, $& v, Dic *p) {
        NSString *act =NSStringFromClass([g class]);
        $::getView(@"RES", @"ViewController")->setText([NSString stringWithFormat:@"Action:%@",act]);
        NSLog(act);
    };
    
    $& panel = box(&s_panel)
        .bind(@"tap",handler, @{})
        .bind(@"swipe",handler, @{})
        .bind(@"longPress", handler, @{})
        .bind(@"pinch",handler, @{})
        .bind(@"pan",handler, @{})
        .bind(@"rotation",handler, @{})
        .bind(@"screenEdge", handler,@{})
        >> target;
    
    label(@"Waiting for touch ...",{.y=10,.textAlign="center",.bgcolor="#00000000",.color="#ffffff"},&s_label)
        >>panel;
    
    label(@"",{.ID=@"RES",.y=100,.textAlign="center",.bgcolor="#00000000",.color="#ffffff"},&s_label)
        >>panel;
    
    
    label(@"Drop here",{.ID=@"DRP",.x=40,.y=300,.w=240,.h=120,.bgcolor="#ffffff00",.paddingTop=30,.color="#ffffff",.textAlign="center",.border="1 #ffffff"},&s_box)
        >> panel;
    
    label(@"Drag me",{.ID=@"DRG",.x=120,.y=120,.bgcolor="#ffffff",.paddingTop=30,.z=1,.textAlign="center"},&s_box)
        .dragable(^(GR *g, $& v, Dic *p) {
            v.setText(@"Dragging");
            View * sv = g.view.superview;
            CGPoint lo = [g locationInView:sv];
            for (UIView * v in sv.subviews) {
                if([v isKindOfClass:[View class]] && ![@"DRG" isEqualToString:((View*)v).owner->ID]){
                    if(CGRectContainsPoint(v.frame,lo)){
                        ((View*)v).owner->setStyle({.bgcolor="#FFcccc88"});
                    }else{
                        ((View*)v).owner->setStyle({.bgcolor="#ffffff00"});
                    }
                }
            }
        }, ^(GR *g, $& v, Dic *p) {
            v.setText(@"Drag me");
            $* drop =$::getView(@"DRP", @"ViewController");
            if(CGRectContainsPoint(drop->rect(), v.view.center)){
                v.set(@"x",@(v.view.center.x));
                v.set(@"y",@(v.view.center.y));
                v.animate(300, ^($ &v, float delta) {
                    float x = [v.get(@"x") floatValue];
                    float y = [v.get(@"y") floatValue];
                    v.view.center = {x+(drop->view.center.x-x)*delta, y+(drop->view.center.y-y)*delta};
                }, ^($&v){
                    drop->setStyle({.bgcolor="#ffffff00"});
                }, @{@"style":@"easeOut"});
            }
        })>>panel;
    
}

//Manipulate
void manipulate_example($& target){
    NSLog(@"manipulate");
    float i = 0;
    box(&s_panel)
        //yellow box
        <<box({.ID=@"YELLOW",.x=10,.y=10,.bgcolor="#ffff00"},&s_box)
        //red box
        <<box({.ID=@"RED",.x=110,.y=10,.bgcolor="#ff0000"},&s_box)
        //blue box
        <<box({.ID=@"BLUE",.x=210,.y=10,.bgcolor="#0000ff"},&s_box)
        
        //btn 1
        <<(label(@"Change YELLOW box to Purple", {.y=100+35*(i++)}, &s_label)
           .bind(@"tap", ^(GR *, $& v, Dic *) {
            $::getView(@"YELLOW", @"ViewController")->setStyle({.bgcolor="#FF00FF"});
        }, @{}))
        
        //btn 2
        <<(label(@"Hide RED box", {.y=100+35*(i++)}, &s_label)
           .bind(@"tap", ^(GR *, $& v, Dic *) {
            $::getView(@"RED", @"ViewController")->setStyle({.alpha=100});
        }, @{}))
    
        //btn 3
        <<(label(@"Remove BLUE box", {.y=100+35*(i++)}, &s_label)
           .bind(@"tap", ^(GR *, $& v, Dic *) {
            $* blue = $::getView(@"BLUE", @"ViewController");
            if(blue)blue->remove();
        }, @{}))

    
        >>target;
    
}

//Layers
void layers_example($& target){
    NSLog(@"motion");
    GestureHandler layerHandler =^(GR *g, $& o, Dic *p) {o.setText([NSString stringWithFormat:@"Tapped\n%@",o.ID]);};
    
    label(@"Tap the white rectangles",{.x=10,.y=10,.textAlign="center",.bgcolor="#00000000",.color="#ffffff"},&s_label) >> target;
    
    //if you want to insert $ as layer,
    //you will have to finish your layer operations first before you do other things like >> or bind
    $& b = box({.ID=@"test"},&s_panel)
    <(label(@"layer 1",{.x=10,.y=60,.ID=@"Layer1"},&s_layer).bind(@"tap", layerHandler, @{}))
    <(label(@"layer 2",{.x=110,.y=60,.ID=@"Layer2"},&s_layer).bind(@"tap", layerHandler, @{}))
    <(label(@"layer 3",{.x=210,.y=60,.ID=@"Layer3"},&s_layer).bind(@"tap", layerHandler, @{}));
    //insert layer 1~3 as sublayers but not subview to b, and bind a tap event to each layer.
    //while for this moment only @"tap" is supported for layers.
    b>>target;
    
    //rotate layers
    $& r = box({.x=-50,.y=200,.w=300,.h=100,.bgcolor="#ffffff88",.rotate3d="-45,0,1,0,300,0.5,0.5"})
    <(label(@"layer 1",{.x=20,.y=10,.ID=@"Layer1"},&s_layer).bind(@"tap", layerHandler, @{}))
    <(label(@"layer 2",{.x=120,.y=10,.ID=@"Layer2"},&s_layer).bind(@"tap", layerHandler, @{}))
    <(label(@"layer 3",{.x=220,.y=10,.ID=@"Layer3"},&s_layer).bind(@"tap", layerHandler, @{}));
    r>>b;
    
    
}

//Animations(Motions)
void image_editor_example($& target){
    NSLog(@"motion");
    
    Arr* imgs = @[@"kodaru.jpg",@"mountain.jpg",@"sea.jpg",@"people.jpg"];
    
    static UIImage * org = [UIImage imageNamed:imgs[2]];
    UIImage * display = [org imageByScale:{600,320} style:0];
    static UIImage * ef = display;
    
    $& im = img(org, {.ID=@"img",.x=0,.y=0,.w=320,.h=320,.bgcolor="#000000",.contentMode=m_FIT})>>target;
    NSValue *imp = [NSValue valueWithPointer:&im];
    
    UIImage * thumb = [org imageByScale:{120,120} style:1];
    
    struct Effects {
        float matrix[3][3];
        float contrast;
        char* blendColor;
        CGBlendMode mode;
        NSString* blendImage;
        float imageAlpha;
    };
    
    static Effects efs[11]={
        {{{0.5,0.25,0.25},{0.2,0.6,0.2},{0,0.0,1.0}},1.3,"#aaaa99",kCGBlendModeOverlay,@"radial.png",0.2},
        {{{0.5,0.25,0.25},{0.0,1,0.0},{.1,.2,.7}},1.3,NULL,kCGBlendModeOverlay,@"radial.png",0.5},
        {{{0.6,0.2,0.2},{0,1,0},{0.2,.2,.6}},1.2,"#aa99aa66",kCGBlendModeOverlay,@"radial.png",0.6},
        {{{0.8,0,0},{0.1,0.8,0.1},{0.2,0.2,0.6}},1.2,"#cccc9966",kCGBlendModeOverlay,@"radial.png",0.5},
        {{{0.6,0.2,0.2},{0.2,.6,0.2},{0,0,1}},1.1,"#99ffff33",kCGBlendModeOverlay,@"radial.png",1},
        {{{0.8,0,0},{0.2,0.6,0.2},{0.5,0.1,0.5}},1.1,"#ff886666",kCGBlendModeOverlay},
        {{{0.6,0.2,0.15},{0.2,0.6,0.15},{0.15,0.1,0.65}},1.1,"#CC9988",kCGBlendModeOverlay},
        {{{0.6,0.2,0.2},{0.2,0.6,0.2},{0.2,0.2,0.6}},1.1,NULL,kCGBlendModeOverlay,@"radial.png",1},
        {{{0.8,0.1,0.1},{0.1,0.8,0.1},{0.1,0.1,0.8}},0.9,"#CC9999",kCGBlendModeOverlay},
        //{{{.393,.769,.189},{.349,.686,.168},{.272,.534,.131}},1.1,"#666600FF"}, //sepia
        {{{0.3,0.6,0.3},{0.3,0.6,0.3},{0.3,0.6,0.3}},1.1,"#996633",kCGBlendModeOverlay}, //sepia
        {{{0.3,0.6,0.2},{0.3,0.6,0.2},{0.3,0.6,0.2}},1.3} //monochrome
    };
    
    UIImage* (^EffectFunc)(Effects,UIImage*) = ^UIImage*(Effects e,UIImage *img){
        @autoreleasepool {
            
            ef = [img colorMix:e.matrix contrast:e.contrast];
            if(e.blendColor)ef = [ef imageWithBlendColor:str2color(e.blendColor) mode:e.mode];
            if(e.blendImage)ef = [ef imageWithBlendImage:e.blendImage alpha:e.imageAlpha?MIN(e.imageAlpha,1):1];
            return ef;
        }
    };
    
    GestureHandler gh = ^(GR *g, $&v, Dic*p){
        int i = [p[@"i"] intValue];
        $* im = ($*)[p[@"im"] pointerValue];
        if(i<0){
            im->setImage(display);
        }else{
            Effects e = efs[i];
            UIImage * ef = EffectFunc(e,display);
            im->setImage(ef);
            im->setStyle({.contentMode=m_FIT});
        }
    };
    
    //bar bg
    box({0,400,320,64,0,"#000000"})>>target;
    $& bar = sbox({0,400,320,64,1}) >> target;
    img(thumb,{.x=2,.y=2,.h=60,.w=60,.contentMode=m_CROP_FIT}).bind(@"tap", gh, @{@"i":@(-1),@"im":imp}) >> bar;
    for (int i=0;i<11;i++) {
        Effects e = efs[i];
        UIImage *ef = EffectFunc(e,thumb);
        img(ef,{.x=(i+1)*64+2.0f,.y=2,.h=60,.w=60,.contentMode=m_CROP_FIT}).bind(@"tap", gh, @{@"i":@(i),@"im":imp}) >> bar;
        ef = nil;
    }

    bar.setContentSize(12*64, 64);
}


void image_editor_example_mixor($& target){
    NSLog(@"motion");
    
    Arr* imgs = @[@"kodaru.jpg",@"mountain.jpg",@"sea.jpg",@"people.jpg"];
    
    static UIImage * org = [UIImage imageNamed:imgs[1]];
    UIImage * display = [org imageByScale:{600,320} style:0];
    static UIImage * ef = display;
    
    $& im = img(org, {.ID=@"img",.x=0,.y=0,.w=320,.h=320,.bgcolor="#000000",.contentMode=m_FIT})>>target;
    NSValue *imp = [NSValue valueWithPointer:&im];

    struct Effects {
        float matrix[3][3];
        float contrast;
        char* blendColor;
        NSString* blendImage;
        float imageAlpha;
    };

    
    UIImage* (^EffectFunc)(Effects,UIImage*) = ^UIImage*(Effects e,UIImage *img){
        @autoreleasepool {
            ef = [img colorMix:e.matrix contrast:e.contrast];
            if(e.blendColor)ef = [ef imageWithBlendColor:str2color(e.blendColor) mode:kCGBlendModeMultiply];
            if(e.blendImage)ef = [ef imageWithBlendImage:e.blendImage alpha:e.imageAlpha?MIN(e.imageAlpha,1):1];
            return ef;
        }
    };

    //static Effects eff = {{{0.6,0.2,0.2},{0.2,0.6,0.2},{0.2,0.2,0.6}},1};
    static Effects eff = {{{1,0,0},{0,1,0},{0,0,1}},1};
    static float masks[3]={1,1,1};

    $& bs = box({.y=320,.w=320,.h=220,.bgcolor="#000000"})>>target;
    for (int i=0; i<13; i++) {
        float x = i%3*100+i%3*10;
        float y = floorf(i/3)*30+15;
        int row = floor(i/3);
        int col = i%3;
        NSString*lbid = [NSString stringWithFormat:@"label_%d", i];
        float v =i>9?1:eff.matrix[row][col];
        
        Arr* lbs= @[@"R",@"G",@"B",@"Mask",@"Contrast"];
        
        Dic * btnValues = @{@"y":@(y+2.5f),@"x":@(x),@"i":@(i),@"label_id":lbid,@"v":@(v)};
        
        label(i<12?[NSString stringWithFormat:@"(%@_%d):%.2f",lbs[row],col+1,v]:[NSString stringWithFormat:@"(%@):%.2f",lbs[row],v],
              {.ID=lbid,.x=x,.y=y-15,.w=100,.h=20,.font="ArialMT,10",.color="#ffffff",.textAlign="center"}) >> bs;
        
        box({.x=x,.y=y,.w=100,.h=5,.cornerRadius=2,.border="1 #ffffff"})>> bs;
        $& btn = box({.x=x+v*50,.y=y-2.5f,.w=10,.h=10,.bgcolor="#ffffff"})
            .set(btnValues)
            .dragable(^(GR *g, $ & v, Dic *p) {
                CGPoint pt = [g locationInView:bs.view];
                float ox = [v.get(@"x")  floatValue];
                float oy = [v.get(@"y")  floatValue];
                float x = pt.x>ox+100?ox+100:(pt.x<ox?ox:pt.x);
                v.view.center=CGPointMake(x, oy);
                float nv =(x-ox)/50;
                
                v.set(@"v",@(nv));
                int i = [v.get(@"i")  intValue];
                if(i>=9&&i<12){
                    masks[i-9]=nv;
                    $::getView(v.get(@"label_id"), @"ViewController")->setText([NSString stringWithFormat:@"%@",str(dec2hex(nv*255/2, 2))]);
                }else{
                    $::getView(v.get(@"label_id"), @"ViewController")->setText([NSString stringWithFormat:@"%.2f",nv]);
                }
            }, ^(GR *g, $ & v, Dic *p) {
                float nv =[v.get(@"v")  floatValue];
                int i = [v.get(@"i")  intValue];
                if(i==12){//contrast
                    eff.contrast = nv;
                }else if(i>=9){
                    eff.blendColor = const_cast<char*>(colorfstr(masks[0]/2, masks[1]/2, masks[2]/2, 0.3)) ;
                }else{
                    int row = floor(i/3);
                    int col = i%3;
                    eff.matrix[row][col] = nv;
                }
                UIImage * em = EffectFunc(eff, org);
                im.setImage(em);
                em=nil;
            })
            >> bs;
    }
    
}


//Animations(Transform)
void animation_example($& target){
    NSLog(@"animation");
    $& p = box(&s_panel)
    <<box({.ID=@"YELLOW",.x=10,.y=10,.bgcolor="#FFFFFF"},&s_box)
    <<box({.ID=@"RED",.x=110,.y=10,.bgcolor="#FF0000"},&s_box)
    <<box({.ID=@"BLUE",.x=210,.y=10,.bgcolor="#0000FF"},&s_box)
    >>target;
    
    p[0]->animate(1000, ^($ &o, float delta) {
        o.setStyle({.bgcolor=colorfstr(1, 1, delta, 1)});
    }, ^($& o) {NSLog(@"finished");}, @{});
    
    p[1]->animate(1000, ^($ &o, float delta) {
        o.setStyle({.h=80+delta*400.0f});
    }, ^($& o) {NSLog(@"finished");}, @{@"delta":@"quad"});
    //return;
    p[2]->animate(1000, ^($ &o, float delta) {
        o.setStyle({.y=10+delta*400.0f});
    }, ^($& o) {NSLog(@"finished");}, @{@"delta":@"bounce",@"style":@"easeInOut"});

    
}

//Animations(rotate delay)
void animation_example2($& target){
    NSLog(@"example2");
    $& p = box(&s_panel) >> target;
    for (int i=0; i<12; i++) {
        box({.x=10+i%3*100.0f,.y=600,.bgcolor="#FFFFFF"},&s_box)
            .animate(1000, {.y=(float)floor(i/3)*100.0f+20.0f}, ^($&o){
                o.animate(1000, {.rotate3d="360,0,1,0,300"});
            }, @{@"delta":@"quad",@"style":@"easeOut",@"delay":@(i*64+300)})
            >> p;
    }
    
    //another way to do this
    /*
     for (int i=0; i<12; i++) {
         $& cell = box({.x=10+i%3*100.0f,.y=600,.bgcolor="#FFFFFF"},&s_box) >> p;
         cell.set(@"y", @(floor(i/3)*100+20));
         cell.animate(1000, ^($ &o, float delta) {  //step function
             CGRect r = o.rect();
             float y = r.origin.y;
             float targetY = [o.get(@"y") floatValue];
             o.setStyle({.y=y+delta*(targetY-y)});
         }, ^($& o) {   //end function
             o.animate(1000, ^($& oo, float delta1) {
             int degree =delta1*360;
             NSString * rt = [NSString stringWithFormat:@"%d,0,1,0,300,0.5,0.5",degree];
             oo.setStyle({.rotate3d=cstr(rt)});
            }, ^($ &) {}, @{@"delta":@"linear"});
         }, 
         @{@"delta":@"quad",@"style":@"easeOut",@"delay":@(i*64+300)});
     }
     */
    
}

//with styles
void animation_example3($& target){
    NSLog(@"example3");
    $& a = box(&s_panel)
    //bgcolor
    <<(box({.x=10,.y=10,.bgcolor="#ffff00"},&s_box)
       .animate(2000,{.x=60,.y=140,.w=200,.h=240,
            .bgcolor="#00FFFF",.rotate3d="360,1,1,0,300",//.rotate=360,
            .shadow="10 10 10 #000000ff",
            .border="5 solid #ffffff",
            .cornerRadius=100
            },^($&v){},@{@"delta":@"bounce", @"style":@"easeOut"}))
    >>target;
}


//svg example
void svg_example($& target){
    NSLog(@"svg");
    static const char* shapes[6] = {
        "M 0 0 L200 0 L 200 200 L 0 200 Z",
        "M 12 72.012 L 72.012 72.012 L 72.012 12 L 131.988 12 L 131.988 72.012 L 192 72.012 L 192 131.988 L 131.988 131.988 L 131.988 192 L 72.012 192 L 72.012 131.988 L 12 131.988 Z",
        "M 102 12 L 122.11605 74.18847 L 187.21297 74.18847 L 134.548455 112.62306 L 154.66451 174.81153 L 102 136.37694 L 49.33549 174.81153 L 69.451545 112.62306 L 16.787034 74.18847 L 81.88395 74.18847 Z",
        "M 102 57 C 78.6216 1.101 12.351 13.9332 12 78.6216 C 11.649 115.0086 43.6404 127.839 64.7346 142.2534 C 85.125 156.1404 99.8904 175.125 102 182.8596 C 104.1096 175.125 120.2808 155.4384 139.2654 141.5514 C 160.0086 126.2586 192.351 113.9538 192 78.6216 C 191.649 13.4058 124.149 3.036 102 57 Z",
        "M 35.4666 111.6678 C 6.375 102 17.976 20.613 64.3836 34.5 C 68.6892 7.4298 122.655 11.8236 122.3022 34.5 C 156.1404 5.4966 199.3836 63.3288 170.3784 92.3322 C 205.1832 106.3938 169.9392 182.1558 141.375 169.5 C 139.089 190.5942 88.0248 197.976 83.5428 169.5 C 54.6276 199.911 -5.6652 153.1524 35.4666 111.6678 Z",
        "M 162.66523 169.65428 C 155.17486 180.6263 147.42614 191.53232 135.19321 191.76032 C 123.15254 191.98832 119.2932 184.6163 105.55419 184.6163 C 91.801154 184.6163 87.4992 191.53232 76.131468 191.98832 C 64.321122 192.43232 55.340694 180.1383 47.788242 169.21428 C 32.358888 146.88024 20.58259 106.064166 36.42051 78.518117 C 44.263363 64.838093 58.316813 56.182078 73.54589 55.954077 C 85.14394 55.740077 96.101105 63.78609 103.18491 63.78609 C 110.28073 63.78609 123.57913 54.126074 137.56048 55.542077 C 143.41258 55.784077 159.83731 57.90408 170.38591 73.36611 C 169.55276 73.91611 150.78078 84.85613 151.009095 107.64817 C 151.23941 134.87422 174.82606 143.92423 175.10044 144.04623 C 174.88614 144.68623 171.32922 156.96626 162.66523 169.65428 M 111.30214 25.634024 C 117.7751 18.034011 128.71624 12.380001 137.74474 12 C 138.898334 22.558019 134.65847 33.130037 128.3958 40.74805 C 122.121115 48.354064 111.8489 54.278074 101.76895 53.486073 C 100.39905 43.156055 105.480085 32.384036 111.30214 25.634024",
    };
    int __block i=0;
    int len = 800;
    $& a = box(&s_panel)
    <<(svgp(str(shapes[i++]), {50,50,200,200},&s_box)
       .animate(len,{.bgcolor="#ff0000"},shapes[i++],^($&v){
        v.animate(len,{.bgcolor="#ffff00"},shapes[i++],^($&v){
            v.animate(len,{.bgcolor="#00ff00"},shapes[i++],^($&v){
                v.animate(len,{.bgcolor="#00ffff"},shapes[i++],^($&v){
                    v.animate(len,{.bgcolor="#cccccc",.shadow="3 3 5 #000000"},shapes[i++],^($&v){},@{@"delay":@(len+1)});
                },@{@"delay":@(len+1)});
            },@{@"delay":@(len+1)});
        },@{@"delay":@(len+1)});
    },@{@"delay":@(len+1)}))
    >>target;
}

