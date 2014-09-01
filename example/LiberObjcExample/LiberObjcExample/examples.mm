//
//  examples_t.mm
//  LiberObjcExample
//
//  Created by soyoes on 8/17/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#include "examples.h"
#include "style_sheet.h"
#include <iostream>

//Shapes with styles
void boxes_example($& target){
    NSLog(@"boxes");
    $& a = box(s_panel)
    //bgcolor
    <<box((style_t){@10,@10}>s_box)
    //transparent color RGBA
    <<box((style_t){@110,@10,.bgcolor=@"#00FFFF55"}>s_box)
    //gradient with positions
    <<box((style_t){@210,@10,.bgcolor=@"#00FFFF:0 #FF0000:0.5 #FFFF00:1"}>s_box)
    
    
    //shadow
    <<box((style_t){@10,@110,.bgcolor=@"#33CCFF",.shadow=@"2 2 3 #000000"}>s_box)
    //inner shadow
    <<box((style_t){@110,@110,.shadow=@"inset 2 2 3 #000000"}>s_box)
    //gradient with positions and degree
    <<box((style_t){@210,@110,.bgcolor=@"#00FFFF:0 #FF0000:0.5 #FFFF00:1 90"}>s_box)
    
    // BUG
    //border + shadow
    <<box((style_t){@10,@210,.border=@"4 #FF9933",.shadow=@"0 0 5 #000000"}>s_box)
    // BUG
    //corner radius with border
    <<box((style_t){@110,@210,.corner=@40,.border=@"1 #ff3399 15",.shadow=@"3 3 3 #333333"}>s_box)
    //corner radius
    <<box((style_t){@210,@210,.corner=@40,.shadow=@"1 1 3 #333333"}>s_box)
    
    //outline
    //<<box({.x=10,.y=310,.outline="1 #ff3399 5"},&s_box)
    //svg path triangle
    <<svgp(@"M 40 0 L80 80 L0 80 Z", (style_t){@110,@310,.bgcolor=@"#0000FF",.shadow=@"inset 1 1 3 #000000"} > s_box)
    //svg path fan & shadow
    <<svgp(@"M 40 0 L80 60 Q40 80 0 60 Z", (style_t){@210,@310,.bgcolor=@"#00FF00",.shadow=@"0 0 2 #333333"} > s_box)

    >>target;
   
}

//Image and content mode
void images_example($& target){
    NSLog(@"images");
    box(s_panel)
    //aspect ratio fit
    <<img(@"kodaru.jpg", (style_t){@10,@10,.contentMode=kModeFill}>s_box)
    //crop and fit the rect size
    <<img(@"kodaru.jpg", (style_t){@110,@10,.contentMode=kModeCropFit,.shadow=@"3 3 3 #000000ff"}>s_box)
    //aspect ratio fill
    <<img(@"kodaru.jpg", (style_t){@210,@10,.contentMode=kModeFit}>s_box)
    
    //show center with original size
    <<img(@"kodaru.jpg", (style_t){@10,@110,.contentMode=kModeOrg}>s_box)
    //img with round corner
    <<img(@"kodaru.jpg", (style_t){@110,@110,.contentMode=kModeCropFit,.corner=@40,.shadow=@"inset 3 3 3 #000000",.ID=@"OT"}>s_box)
    //svg path fan with image background
    <<svgp(@"M40 0 L80 80 L0 80 Z", (style_t){@210,@110,.shadow=@"3 3 3 #000000ff"}>s_box).image(@"kodaru.jpg")
    
    //rotate 3d
    <<img(@"kodaru.jpg", (style_t){@10,@210,.contentMode=kModeCropFit,.rotate3d=@"45,1,0,0,200,0.5,0.5"}>s_box)
    //rotate 2d
    <<img(@"kodaru.jpg", (style_t){@110,@210,.contentMode=kModeCropFit,.rotate=@45}>s_box)
    //rotate 3d
    <<img(@"kodaru.jpg", (style_t){@210,@210,.contentMode=kModeCropFit,.rotate3d=@"45,0,1,0,200,0.5,0.5"}>s_box)
    
    //flipH
    <<img(@"kodaru.jpg", (style_t){@10,@310,.contentMode=kModeCropFit,.flip=@"H"}>s_box)
    //flipV
    <<img(@"kodaru.jpg", (style_t){@110,@310,.contentMode=kModeCropFit,.flip=@"V"}>s_box)
    
    >>target;
    
    slide(@[@"sea.jpg",@"mountain.jpg",@"people.jpg",@"kodaru.jpg",
            @"sea.jpg",@"mountain.jpg",@"people.jpg",@"kodaru.jpg"],
          ^$& (obj_t item, int i) {
              return img(item,{@(300*i),@0,@300,@80,.contentMode=kModeCropFit});
          },
          {@10,@410,@300,@80})
    >> target;
}

//Label & text edit
void labels_example($& target){
    NSLog(@"labels");
    int i=0;
    $& b = box(s_panel)
    //normal label
    <<label(@"Label normal", (style_t){.y=@(10+35*(i++))} > s_label)
    //truncate
    <<label(@"Label truncate, Lorem ipsum dolor sit amet, consectetur adipisicing elit",
            (style_t){.y=@(10+35*(i++)),.nowrap=@YES,.truncate=@YES} > s_label)
    // .nowrap=true + setEditable = single line edit
    <<label(@"Label editable (single line)", (style_t){.y=@(10+35*(i++)),.nowrap=@YES} > s_label).setEditable(true)
    <<label(@"Label with other font", (style_t){.y=@(10+35*(i++)),.font=@"MarkerFelt-Thin,14",.color=@"#ff0000"} > s_label)
    
    <<(label(@"Date Picker",(style_t){.y=@(10+35*(i++)),.nowrap=@YES} > s_label).setPickable([NSDate date], @"yyyy-MM-dd"))
    
    <<(label(@"Picker", (style_t){.y=@(10+35*(i++))} > s_label).setPickable(@[@"one",@"two",@"three",@"four",@"five"]))
    
    <<label(@"Label multiline\nThe 2nd row", (style_t){.y=@(10+35*(i++)), .h=@60} > s_label)
    
    // .nowrap=false + setEditable = multi line edit
    <<(label(@"Label multiline\neditable", (style_t){.ID=@"textEdit",.y=@(10+35*(i++)+30), .h=@120} > s_label).setEditable(true)) //
    >>target;
}

//Lazy loading
void lazy_loading_example($& target){
    NSLog(@"lazy_loading");
    int i=0;
    box(s_panel)
    >>target
    //normal label
    <<glabel(@"http://ip.jsontest.com", ^str_t(obj_t res) {
        return res[@"ip"];                                                   //this will be set after loading
    },(style_t){.y=@(10+35*(i++))}>s_label).defaultText(@"Loading from remote ...")  //this will be shown as default/loading message.
    <<img(@"http://miriadna.com/desctopwalls/images/min/Walking-in-forest.jpg",(style_t){.y=@(10+35*(i++)),.h=@200}>s_label);
    
    
}

//Actions
void actions_example($& target){
    NSLog(@"actions");
    
    ges_f handler =^(ges_t g, $& v, dic_t p) {
        str_t act =NSStringFromClass([g class]);
        $id(@"RES").text(sprintf(@"Action:%@",act));
        NSLog(act);
    };
    
    $& panel = box(s_panel)
    .bind(@"tap",handler, @{})
    .bind(@"swipe",handler, @{})
    .bind(@"longPress", handler, @{})
    .bind(@"pinch",handler, @{})
    .bind(@"pan",handler, @{})
    .bind(@"rotation",handler, @{})
    .bind(@"screenEdge", handler,@{})
    >> target;
    
    label(@"Waiting for touch ...",(style_t){.y=@10,.align=@"center",.bgcolor=@"#00000000",.color=@"#ffffff"}>s_label)
    >>panel;
    
    label(@"",(style_t){.ID=@"RES",.y=@100,.align=@"center",.bgcolor=@"#00000000",.color=@"#ffffff"}>s_label)
    >>panel;
    
    label(@"Drop here",(style_t){@40,@300,@240,@120,@0,@"#ffffff00",@"#ffffff",.paddingTop=@30,.ID=@"DRP",.align=@"center",.border=@"1 #ffffff"}>s_box)
    >> panel;
    
    label(@"Drag me",(style_t){@120,@120,.ID=@"DRG",.bgcolor=@"#ffffff",.paddingTop=@30,.z=@1,.align=@"center"}>s_box)
    .dragable(^(ges_t g, $& v, dic_t p) {
        v.text(@"Dragging");
        view_t sv = g.view.superview;
        CGPoint lo = [g locationInView:sv];
        for (view_base_t v in sv.subviews) {
            if(is_view(v)&& ![@"DRG" isEqualToString:((view_t)v).owner->ID()]){
                if(CGRectContainsPoint(v.frame,lo)){
                    ((view_t)v).owner->setStyle({.bgcolor=@"#FFcccc88"});
                }else{
                    ((view_t)v).owner->setStyle({.bgcolor=@"#ffffff00"});
                }
            }
        }
    }, ^(ges_t g, $& v, dic_t p) {
        v.text(@"Drag me");
        $ drop =$id(@"DRP");
        rect_t f = drop.rect();
        view_t dv = drop.view();
        view_t vi = v.view();
        float cx = vi.center.x, cy = vi.center.y;
        if(cx>=f.x && cx<=f.x+f.w && cy>=f.y && cy>=f.y+f.h){
            v.set(@"x",@(vi.center.x));
            v.set(@"y",@(vi.center.y));
            v.animate(300, ^($ &vv, float delta) {
                float x = vv.getFloat(@"x");
                float y = vv.getFloat(@"y");
                view_t vi = vv.view();
                if(vi)
                    vi.center = {x+(dv.center.x-x)*delta, y+(dv.center.y-y)*delta};
            }, ^($&vv){
                $id(@"DRP").setStyle({.bgcolor=@"#ffffff00"});
            }, {.style=kEaseOut});
        }
    })>>panel;
    
}

//Manipulate
void manipulate_example($& target){
    NSLog(@"manipulate");
    int i = 0;
    box(s_panel)
    //yellow box
    <<box((style_t){@10,@10,.ID=@"YELLOW",.bgcolor=@"#ffff00"}>s_box)
    //red box
    <<box((style_t){@110,@10,.ID=@"RED",.bgcolor=@"#ff0000"}>s_box)
    //blue box
    <<box((style_t){@210,@10,.ID=@"BLUE",.bgcolor=@"#0000ff"}>s_box)
    
    //btn 1
    <<(label(@"Change YELLOW box to Purple", (style_t){.y=@(100+35*(i++))}>s_label)
       .bind(@"tap", ^(ges_t g, $& v, dic_t p) {
        $id(@"YELLOW").setStyle({.bgcolor=@"#FF00FF"});
    }, @{}))
    
    //btn 2
    <<(label(@"Hide RED box", (style_t){.y=@(100+35*(i++))}>s_label)
       .bind(@"tap", ^(ges_t g, $& v, dic_t p) {
        $id(@"RED").hide(0);
    }, @{}))
    
    //btn 3
    <<(label(@"Remove BLUE box", (style_t){.y=@(100+35*(i++))}>s_label)
       .bind(@"tap", ^(ges_t g, $& v, dic_t p) {
        $& blue = $id(@"BLUE");
        if(&blue) blue.remove();
    }, @{}))
    
    
    >>target;
    
}

//Layers
void layers_example($& target){
    NSLog(@"motion");
    ges_f layerHandler =^(ges_t g, $& v, dic_t p) {v.text(sprintf(@"Tapped\n%@",v.ID()));};
    
    label(@"Tap the white rectangles",(style_t){@10,@10,.align=@"center",.bgcolor=@"#00000000",.color=@"#ffffff"}>s_label) >> target;
    
    //if you want to insert $ as layer,
    //you will have to finish your layer operations first before you do other things like >> or bind
    $& b = box((style_t){.ID=@"test"}>s_panel)
    <(label(@"layer 1",(style_t){@10,@60,.ID=@"Layer1"}>s_layer).bind(@"tap", layerHandler, @{}))
    <(label(@"layer 2",(style_t){@110,@60,.ID=@"Layer2"}>s_layer).bind(@"tap", layerHandler, @{}))
    <(label(@"layer 3",(style_t){@210,@60,.ID=@"Layer3"}>s_layer).bind(@"tap", layerHandler, @{}));
    //insert layer 1~3 as sublayers but not subview to b, and bind a tap event to each layer.
    //while for this moment only @"tap" is supported for layers.
    b>>target;
    
    //rotate layers
    $& r = box({@-50,@200,@300,@100,@0,@"#ffffff88",.rotate3d=@"-45,0,1,0,300,0.5,0.5"})
    <(label(@"layer 1",(style_t){@20,@10,.ID=@"Layer1"}>s_layer).bind(@"tap", layerHandler, @{}))
    <(label(@"layer 2",(style_t){@120,@10,.ID=@"Layer2"}>s_layer).bind(@"tap", layerHandler, @{}))
    <(label(@"layer 3",(style_t){@220,@10,.ID=@"Layer3"}>s_layer).bind(@"tap", layerHandler, @{}));
    r>>b;
    
    
}

//Animations(Motions)
void image_editor_example($& target){
    NSLog(@"motion");
    
    arr_t imgs = @[@"kodaru.jpg",@"mountain.jpg",@"sea.jpg",@"people.jpg"];
    
    static image_t org = image_read(imgs[2]);
    image_t display = image_scale(org, {600,320}, 0);
    static image_t ef = display;
    
    $& im = img(org, {@0,@0,@320,@320,@0,@"#000000",.ID=@"img",.contentMode=kModeFit})>>target;
    value_t imp = im.encode();
    
    image_t thumb = image_scale(org, {120,120}, 1);
    
    struct Effects {
        float matrix[9]; //3*3
        float contrast;
        str_t blendColor;
        CGBlendMode mode;
        str_t blendImage;
        float imageAlpha;
    };
    
    static Effects efs[11]={
        {{0.5,0.25,0.25,   0.2,0.6,0.2 ,   0,0.0,1.0},1.3,@"#aaaa99",kCGBlendModeOverlay,@"radial.png",0.2},
        {{0.5,0.25,0.25,   0.0,1,0.0 ,     0.1,0.2,0.7},1.3,nil,kCGBlendModeOverlay,@"radial.png",0.5},
        {{0.6,0.2,0.2,     0,1,0 ,         0.2,.2,.6},1.2,@"#aa99aa66",kCGBlendModeOverlay,@"radial.png",0.6},
        {{0.8,0,0,         0.1,0.8,0.1 ,   0.2,0.2,0.6},1.2,@"#cccc9966",kCGBlendModeOverlay,@"radial.png",0.5},
        {{0.6,0.2,0.2,     0.2,.6,0.2 ,    0,0,1},1.1,@"#99ffff33",kCGBlendModeOverlay,@"radial.png",1},
        {{0.8,0,0,         0.2,0.6,0.2 ,   0.5,0.1,0.5},1.1,@"#ff886666",kCGBlendModeOverlay},
        {{0.6,0.2,0.15,    0.2,0.6,0.15 ,  0.15,0.1,0.65},1.1,@"#CC9988",kCGBlendModeOverlay},
        {{0.6,0.2,0.2,     0.2,0.6,0.2 ,   0.2,0.2,0.6},1.1,nil,kCGBlendModeOverlay,@"radial.png",1},
        {{0.8,0.1,0.1,     0.1,0.8,0.1 ,   0.1,0.1,0.8},0.9,@"#CC9999",kCGBlendModeOverlay},
        {{0.3,0.6,0.3,     0.3,0.6,0.3 ,   0.3,0.6,0.3},1.1,@"#996633",kCGBlendModeOverlay}, //sepia
        {{0.3,0.6,0.2,     0.3,0.6,0.2 ,   0.3,0.6,0.2},1.3} //monochrome
    };
    
    image_t (^EffectFunc)(Effects,image_t) = ^image_t(Effects e,image_t ig){
        @autoreleasepool {
            ef = image_color_mix(ig, e.matrix, e.contrast);
            if(e.blendColor)ef = image_blend_color(ef, str2color(e.blendColor), e.mode);
            if(e.blendImage)ef = image_blend_image(ef, e.blendImage, e.imageAlpha?MIN(e.imageAlpha,1):1);
            return ef;
        }
    };
    
    ges_f gh = ^(ges_t g, $& v, dic_t p){
        int i = numi(p[@"i"]);
        //$ im;
        //decode(p[@"im"], &im);
        if(i<0){
            im.image(display);
        }else{
            Effects e = efs[i];
            image_t ef = EffectFunc(e,display);
            im.image(ef);
            im.setStyle({.contentMode=kModeFit});
        }
    };
    
    //bar bg
    box({@0,@400,@320,@64,@0,@"#000000"})>>target;
    $& bar = box({@0,@400,@320,@64,@1}) >> target;
    img(thumb,{@2,@2,@60,@60,.contentMode=kModeCropFit}).bind(@"tap", gh, @{@"i":@(-1),@"im":imp}) >> bar;
    for (int i=0;i<11;i++) {
        Effects e = efs[i];
        image_t ef = EffectFunc(e,thumb);
        img(ef,{@((i+1)*64+2),@2,@60,@60,.contentMode=kModeCropFit}).bind(@"tap", gh, @{@"i":@(i),@"im":imp}) >> bar;
        ef = nil;
    }
    
    bar.scrollSize(12*64, 64);
}

//Animations(Transform)
void animation_example($& target){
    NSLog(@"animation");
    $& p = box(s_panel)
    <<box((style_t){@10,@10,.ID=@"YELLOW",.bgcolor=@"#FFFFFF"}>s_box)
    <<box((style_t){@110,@10,.ID=@"RED",.bgcolor=@"#FF0000"}>s_box)
    <<box((style_t){@210,@10,.ID=@"BLUE",.bgcolor=@"#0000FF"}>s_box)
    >>target;
    
    p[0]->animate(1000, ^($ &o, float delta) {
        o.setStyle({.bgcolor=rgba2str({1, 1, delta, 1})});
    }, ^($& o) {NSLog(@"finished");}, {});
   
    p[1]->animate(1000, ^($ &o, float delta) {
        o.setStyle({.h=@(80+delta*400)});
    }, ^($& o) {NSLog(@"finished");}, {.delta=kDeltaQuad});

    p[2]->animate(1000, ^($ &o, float delta) {
        o.setStyle({.y=@(10+delta*400)});
    }, ^($& o) {NSLog(@"finished");}, {.delta=kDeltaBounce,.style=kEaseInOut});
    
}

//Animations(rotate delay)
void animation_example2($& target){
    NSLog(@"example2");
    $& p = box(s_panel) >> target;
    for (int i=0; i<12; i++) {
        box((style_t){@(10+i%3*100),@600,.bgcolor=@"#FFFFFF"}>s_box)
        .animate(1000, {@(10+i%3*100),.y=@((float)floor(i/3)*100+20)}, ^($&o){
            o.animate(1000, {.rotate3d=@"360,0,1,0,300"},{});
        }, {.delta=kDeltaQuad,.style=kEaseOut,.delay=i*64+300})
        >> p;
    }
}

//with styles
void animation_example3($& target){
    NSLog(@"example3");
    $& a = box(s_panel)
    //bgcolor
    <<(box((style_t){@10,@10,.bgcolor=@"#ffff00"}>s_box)
       .animate(2000,{@60,@140,@200,@240,
        .bgcolor=@"#00FFFF",.rotate3d=@"360,1,1,0,300",//.rotate=360,
        .shadow=@"10 10 10 #000000ff",
        .border=@"5 solid #ffffff",
        .corner=@100
    },^($&v){},{.delta=kDeltaBounce, .style=kEaseOut}))
    >>target;
}


//svg example
void svg_example($& target){
    NSLog(@"svg");
    static str_t shapes[6] = {
        @"M 0 0 L200 0 L 200 200 L 0 200 Z",
        @"M 12 72.012 L 72.012 72.012 L 72.012 12 L 131.988 12 L 131.988 72.012 L 192 72.012 L 192 131.988 L 131.988 131.988 L 131.988 192 L 72.012 192 L 72.012 131.988 L 12 131.988 Z",
        @"M 102 12 L 122.11605 74.18847 L 187.21297 74.18847 L 134.548455 112.62306 L 154.66451 174.81153 L 102 136.37694 L 49.33549 174.81153 L 69.451545 112.62306 L 16.787034 74.18847 L 81.88395 74.18847 Z",
        @"M 102 57 C 78.6216 1.101 12.351 13.9332 12 78.6216 C 11.649 115.0086 43.6404 127.839 64.7346 142.2534 C 85.125 156.1404 99.8904 175.125 102 182.8596 C 104.1096 175.125 120.2808 155.4384 139.2654 141.5514 C 160.0086 126.2586 192.351 113.9538 192 78.6216 C 191.649 13.4058 124.149 3.036 102 57 Z",
        @"M 35.4666 111.6678 C 6.375 102 17.976 20.613 64.3836 34.5 C 68.6892 7.4298 122.655 11.8236 122.3022 34.5 C 156.1404 5.4966 199.3836 63.3288 170.3784 92.3322 C 205.1832 106.3938 169.9392 182.1558 141.375 169.5 C 139.089 190.5942 88.0248 197.976 83.5428 169.5 C 54.6276 199.911 -5.6652 153.1524 35.4666 111.6678 Z",
        @"M 162.66523 169.65428 C 155.17486 180.6263 147.42614 191.53232 135.19321 191.76032 C 123.15254 191.98832 119.2932 184.6163 105.55419 184.6163 C 91.801154 184.6163 87.4992 191.53232 76.131468 191.98832 C 64.321122 192.43232 55.340694 180.1383 47.788242 169.21428 C 32.358888 146.88024 20.58259 106.064166 36.42051 78.518117 C 44.263363 64.838093 58.316813 56.182078 73.54589 55.954077 C 85.14394 55.740077 96.101105 63.78609 103.18491 63.78609 C 110.28073 63.78609 123.57913 54.126074 137.56048 55.542077 C 143.41258 55.784077 159.83731 57.90408 170.38591 73.36611 C 169.55276 73.91611 150.78078 84.85613 151.009095 107.64817 C 151.23941 134.87422 174.82606 143.92423 175.10044 144.04623 C 174.88614 144.68623 171.32922 156.96626 162.66523 169.65428 M 111.30214 25.634024 C 117.7751 18.034011 128.71624 12.380001 137.74474 12 C 138.898334 22.558019 134.65847 33.130037 128.3958 40.74805 C 122.121115 48.354064 111.8489 54.278074 101.76895 53.486073 C 100.39905 43.156055 105.480085 32.384036 111.30214 25.634024",
    };
    int __block i=0;
    int len = 800;
    $& a = box(s_panel)
    
    <<(svgp(shapes[i++],(style_t){@50,@50,@200,@200}>s_box)
       .animate(len,{.bgcolor=@"#ff0000"},shapes[i++],^($&v){
        v.animate(len,{.bgcolor=@"#ffff00"},shapes[i++],^($&v){
            v.animate(len,{.bgcolor=@"#00ff00"},shapes[i++],^($&v){
                v.animate(len,{.bgcolor=@"#00ffff"},shapes[i++],^($&v){
                    v.animate(len,{.bgcolor=@"#cccccc",.shadow=@"3 3 5 #000000"},shapes[i++],^($&v){},{.delay=len+1});
                },{.delay=len+1});
            },{.delay=len+1});
        },{.delay=len+1});
    },{.delay=len+1}))
    >>target;
}