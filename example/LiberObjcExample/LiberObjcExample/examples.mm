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
        <<box({.x=110,.y=210,.border="1 #ff3399 15"},&s_box)
        //corner radius
        <<box({.x=210,.y=210,.cornerRadius=10},&s_box)
    
        //outline
        <<box({.x=10,.y=310,.outline="1 5 #ff3399"},&s_box)
        //svg path triangle
        <<svgp(@"M40 0 L80 80 L0 80 Z", {.x=110,.y=310,.bgcolor="#0000FF"},&s_box)
        //svg path fan & shadow
        <<svgp(@"M40 0 L80 60 Q40 80 0 60 Z", {.x=210,.y=310,.bgcolor="#00FF00",.shadow="0 0 2 #333333"},&s_box)
    
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
}

//Label & text edit
void labels_example($& target){
    NSLog(@"labels");
    float i=0;
    
    box(&s_panel)
        //normal label
        <<label(@"Label normal", {.y=10+35*(i++)}, &s_label)
        //truncate
        <<label(@"Label truncate, Lorem ipsum dolor sit amet, consectetur adipisicing elit",
                {.y=10+35*(i++),.nowrap=true,.truncate=true}, &s_label)
        <<label(@"Label editable (single line)", {.y=10+35*(i++),.nowrap=true}, &s_label).setEditable(true,nil)
        <<label(@"Label with other font", {.y=10+35*(i++),.font="MarkerFelt-Thin,14",.color="#ff0000"}, &s_label)
        <<label(@"Label multiline\nThe 2nd row", {.y=10+35*(i++), .h=60}, &s_label)
        <<(label(@"Label multiline\neditable", {.ID=@"textEdit",.y=10+35*(i++)+30, .h=120}, &s_label)
           .setEditable(true,^($&v) {
            $* dbtn = $::getView(@"EDIT_DONE_BTN", @"ViewController");
            if(!dbtn){
                $* title_row = $::getView(@"LI_0", @"ViewController");
                //add back btn to title row
                *title_row << label(@"Done",{.ID=@"back_btn",.x=275,.color="#3366CC"},&s_list_title_btn)
                .bind(@"tap", ^(GR *gg, $& btn, Dic *pp) {
                    btn.remove();
                    $* te = $::getView(@"textEdit", @"ViewController");
                    if(te) [te->view switchEditingMode];
                }, @{});
            }
            }))
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
    UIImage * org = [UIImage imageNamed:@"kodaru.jpg"];
    UIImage * display = [org imageByScalingProportionallyToMinimumSize:{600,400}];
    static UIImage * ef = display;
    
    $& im = img(org, {.ID=@"img",.x=10,.y=20,.w=300,.h=200})>>target;
    NSValue *imp = [NSValue valueWithPointer:&im];
    
    UIImage * thumb = [org imageByScalingProportionallyToMinimumSize:{120,120}];
    
    struct Effects {
        float matrix[3][3];
        float contrast;
        char* blendColor;
        NSString* blendImage;
        float imageAlpha;
    };
    
    static Effects efs[11]={
        {{{1,0,0},{0,1,0.2},{.1,.1,1}},1.4},
        {{{1,0.1,0.1},{0.1,1,0.1},{.1,.1,.8}},1.4,NULL,@"radial.png",0.5},
        {{{0.8,.3,0.1},{0,.8,0.2},{0.1,.2,1}},1.2,NULL,@"radial.png",0.6},
        {{{0.7,0,0},{0.1,0.6,0},{0.2,0.2,0.5}},1.1,"#CCCC66",@"radial.png",0.5},
        {{{0.9,.3,0.2},{0.2,.7,0.3},{0.2,.3,.5}},1.1,NULL,@"radial.png",1},
        {{{0.7,0,0},{0.2,0.6,0.2},{0.2,0.2,0.6}},1.1,"#CC6666"},
        {{{0.6,0.2,0.15},{0.2,0.6,0.15},{0.15,0.1,0.65}},1.1,"#CC9988"},
        {{{0.6,0.2,0.2},{0.2,0.6,0.2},{0.2,0.2,0.6}},1.1,NULL,@"radial.png",1},
        {{{0.8,0.1,0.1},{0.1,0.8,0.1},{0.1,0.1,0.8}},0.9,"#CC9999"},
        //{{{.393,.769,.189},{.349,.686,.168},{.272,.534,.131}},1.1,"#666600FF"}, //sepia
        {{{0.3,0.6,0.3},{0.3,0.6,0.3},{0.3,0.6,0.3}},1.1,"#996633"}, //sepia
        {{{0.3,0.6,0.2},{0.3,0.6,0.2},{0.3,0.6,0.2}},1.3} //monochrome
    };
    
    UIImage* (^EffectFunc)(Effects,UIImage*) = ^UIImage*(Effects e,UIImage *img){
        @autoreleasepool {
            ef = [img colorMix:e.matrix contrast:e.contrast];
            if(e.blendColor)ef = [ef imageWithBlendColor:str2color(e.blendColor)];
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
        }
    };
    
    //bar bg
    box({0,400,320,64,0,"#000000"})>>target;
    $& bar = sbox({0,400,320,64,1}) >> target;
    img(thumb,{.x=2,.y=2,.h=60,.w=60,.contentMode=m_FIT}).bind(@"tap", gh, @{@"i":@(-1),@"im":imp}) >> bar;
    for (int i=0;i<11;i++) {
        Effects e = efs[i];
        UIImage *ef = EffectFunc(e,thumb);
        img(ef,{.x=(i+1)*64+2.0f,.y=2,.h=60,.w=60,.contentMode=m_FIT}).bind(@"tap", gh, @{@"i":@(i),@"im":imp}) >> bar;
        ef = nil;
    }

    bar.setContentSize(12*64, 64);
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
        $& cell = box({.x=10+i%3*100.0f,.y=600,.bgcolor="#FFFFFF"},&s_box) >> p;
        cell.set(@"y", @(floor(i/3)*100+20));
        cell.animate(1000, ^($ &o, float delta) {
            CGRect r = o.rect();
            float y = r.origin.y;
            float targetY = [o.get(@"y") floatValue];
            o.setStyle({.y=y+delta*(targetY-y)});
        }, ^($& o) {
            o.animate(1000, ^($& oo, float delta1) {
                int degree =delta1*360;
                NSString * rt = [NSString stringWithFormat:@"%d,0,1,0,300,0.5,0.5",degree];
                oo.setStyle({.rotate3d=cstr(rt)});
            }, ^($ &) {}, @{@"delta":@"linear"});
        }, @{@"delta":@"quad",@"style":@"easeOut",@"delay":@(i*64+300)});//
    }
}