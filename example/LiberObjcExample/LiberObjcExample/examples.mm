//
//  examples.cpp
//  LiberObjcExample
//
//  Created by soyoes on 6/29/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#include "examples.h"
#include "style_sheet.h"

//Shapes with styles
void boxes_example($& target){
    NSLog(@"boxes");
    box(&s_panel)
        //bgcolor
        <<box({.x=10,.y=10},&s_box)
        //transparent color RGBA
        <<box({.x=110,.y=10,.bgcolor="#FFFFFF55"},&s_box)
        //gradient with positions
        <<box({.x=210,.y=10,.bgcolor="#00FFFF:0 #FF0000:0.7 #FFFF00:1"},&s_box)
    
        //shadow
        <<box({.x=10,.y=110,.shadow="2 2 3 #000000"},&s_box)
        //inner shadow
        <<box({.x=110,.y=110,.shadow="inset 2 2 3 #000000"},&s_box)
        //corner radius
        <<box({.x=210,.y=110,.cornerRadius=10},&s_box)
    
        //border
        <<box({.x=10,.y=210,.border="2 #ff3399"},&s_box)
        //corner radius with border
        <<box({.x=110,.y=210,.border="1 #ff3399 15"},&s_box)
        //outline
        <<box({.x=210,.y=210,.outline="1 5 #ff3399"},&s_box)
    
        //svg path triangle
        <<svgp(@"M40 0 L80 80 L0 80 Z", {.x=10,.y=310,.bgcolor="#0000FF"},&s_box)
        //svg path fan
        <<svgp(@"M40 0 L80 60 Q40 80 0 60 Z", {.x=110,.y=310,.bgcolor="#00FF00"},&s_box)
    
        >>target;
}

//Image and content mode
void images_example($& target){
    NSLog(@"images");
    box(&s_panel)
        //aspect ratio fit
        <<img(@"banff.jpg", {.x=10,.y=10,.contentMode=m_FIT},&s_box)
        //crop and fit the rect size
        <<img(@"banff.jpg", {.x=110,.y=10,.contentMode=m_CROP_FIT},&s_box)
        //aspect ratio fill
        <<img(@"banff.jpg", {.x=210,.y=10,.contentMode=m_FILL},&s_box)
    
        //show center with original size
        <<img(@"banff.jpg", {.x=10,.y=110,.contentMode=m_ORG},&s_box)
        //img with round corner
        <<img(@"banff.jpg", {.x=110,.y=110,.contentMode=m_CROP_FIT,.cornerRadius=40},&s_box)
        //svg path fan with image background
        <<svgp(@"M40 0 L80 80 L0 80 Z", {.x=210,.y=110},&s_box).setImage(@"banff.jpg")
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
        <<label(@"Label editable (single line)", {.y=10+35*(i++),.nowrap=true}, &s_label).setEditable(true)
        <<label(@"Label with other font", {.y=10+35*(i++),.font="MarkerFelt-Thin,14",.color="#ff0000"}, &s_label)
        <<label(@"Label multiline\nThe 2nd row", {.y=10+35*(i++), .h=60}, &s_label)
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
        
        <<img(@"http://miriadna.com/desctopwalls/images/min/Walking-in-forest.jpg",{.y=10+35*(i++),.h=200},&s_label)

        <<img(@"http://miriadna.com/desctopwalls/images/min/Walking-in-forest.jpg",{.y=10+35*(i++),.h=200},&s_label);
    

}

//Actions
void actions_example($& target){
    NSLog(@"actions");
    
    GestureHandler handler =^(GR *g, Dic *p) {
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
    
    label(@"Drag me",{.ID=@"DRG",.x=120,.y=200,.bgcolor="#ffffff",.paddingTop=30,.textAlign="center"},&s_box)
        .dragable(^(GR *g, Dic *p) {
            $::getView(@"DRG", @"ViewController")->setText(@"Dragging");
        }, ^(GR *g, Dic *p) {
            $::getView(@"DRG", @"ViewController")->setText(@"Drag me");
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
           .bind(@"tap", ^(GR *, Dic *) {
            $::getView(@"YELLOW", @"ViewController")->setStyle({.bgcolor="#FF00FF"});
        }, @{}))
        
        //btn 2
        <<(label(@"Hide RED box", {.y=100+35*(i++)}, &s_label)
           .bind(@"tap", ^(GR *, Dic *) {
            $::getView(@"RED", @"ViewController")->setStyle({.alpha=100});
        }, @{}))
    
        //btn 3
        //BUG : remove twice
        <<(label(@"Remove BLUE box", {.y=100+35*(i++)}, &s_label)
           .bind(@"tap", ^(GR *, Dic *) {
            $* blue = $::getView(@"BLUE", @"ViewController");
            if(blue)blue->remove();
        }, @{}))

    
        >>target;
    
}

//Animations(Motions)
void motion_example($& target){
    NSLog(@"motion");
}

//Animations(Transform)
void animation_example($& target){
    NSLog(@"animation");
    box(&s_panel)
    //aspect ratio fit
    <<label(@"Preparing", {0,0,300,60})
    >>target;
}
