//
//  ViewController.m
//  LiberObjcExample
//
//  Created by soyoes on 6/29/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#import "ViewController.h"


#import "View.h"
#import "style_sheet.h"
#import <iostream>
#import "examples.h"

#define EXAMPLES @[@"Examples", \
    @"Shapes with styles",  \
    @"Image and content mode",  \
    @"Label & text edit",       \
    @"Lazy loading",            \
    @"Actions",                 \
    @"Manipulate",              \
    @"Layers",                  \
    @"Image Editor",     \
    @"Animations(Transform)",    \
    @"Animations(delay, rotation)",\
    @"Animations(styles animation)",\
    @"SVG Animation"]

$* _panel;
bool panel_presented;

void list_item_tapped(UIView * target, int i){
    
    if(panel_presented)return;
    
    //Up date title row.
    //get title row with ID, under namespace of @"ViewController"
    $* title_row = $::getView(@"LI_0", @"ViewController");
    //add back btn to title row
    *title_row << label(@"Back",{.ID=@"back_btn"},&s_list_title_btn).bind(@"tap", ^(GR *g, $& btn, Dic *p) {
        //release panel
        if(_panel)_panel->remove();
        //release this label btn
        btn.remove();
        panel_presented = false;
    }, @{});
    
    //add a panel to the screen
    $& panel = sbox({0,568,320,548,1,"#465866",.ID=@"panel"}) >> target;
    
    //add transition animation
    panel.addGravity(@{@"angle":@270, @"speed":@8})     //add gravity to top with power of 8*gravity.
         .addCollision(@{@"points":@[@0,@65,@320,@65]}) //add bounds to top
         .startMove();                                  //start the animation
    
    //add contents here
    static example_func* drawing_funcs[12] = {
        boxes_example,images_example,labels_example,lazy_loading_example,
        actions_example,manipulate_example,layers_example,image_editor_example,animation_example,
        animation_example2,animation_example3,svg_example
    };
    if(i<12)
        drawing_funcs[i](panel);
    
    _panel = &panel;
    panel_presented = true;

}

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    //set namespace of current controller, that all views will be rendered under this namespace.
    $::setControllerName(@"ViewController");
    
    list(EXAMPLES,^$& (id item, int i) {
        //Set unique ID for each row.
        Str * ID = [NSString stringWithFormat:@"LI_%d",i];
        return label((Str*)item, {.y=i==0?1:i*41.0f+5, .ID=ID}, i==0?&s_list_title:&s_list_row)
                .bind(@"tap", ^(GR *gesture, $& v, Dic *params) {
                    Str * item = params[@"item"];
                    int i = [params[@"i"] intValue];
                    if(i>0) list_item_tapped(self.view, i-1);
                }, @{@"i":@(i)});
    }, s_list) >> self.view;
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


