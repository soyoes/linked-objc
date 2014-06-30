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

#import "examples.h"

#define EXAMPLES @[@"Examples", \
    @"Shapes with styles",  \
    @"Image and content mode",  \
    @"Label & text edit",       \
    @"Lazy loading",            \
    @"Actions",                 \
    @"Manipulate",              \
    @"Animations(Motions)",     \
    @"Animations(Transform)"]

$* _panel;

void list_item_tapped(UIView * target, int i){
    
    //Up date title row.
    //get title row with ID, under namespace of @"ViewController"
    $* title_row = $::getView(@"LI_0", @"ViewController");
    //add back btn to title row
    *title_row << label(@"Back",{.ID=@"back_btn"},&s_list_title_btn).bind(@"tap", ^(GR *g, Dic *p) {
        //release panel
        if(_panel)_panel->remove();
        //get View object from UIGestureRecogonizor
        View * btn = g.view;
        //release this label btn
        btn.owner->remove();
    }, @{});
    
    //add a panel to the screen
    $& panel = sbox({0,568,320,548,1,"#465866"}) >> target;
    
    //add transition animation
    panel.addGravity(@{@"angle":@270, @"speed":@8})     //add gravity to top with power of 8*gravity.
         .addCollision(@{@"points":@[@0,@65,@320,@65]}) //add bounds to top
         .startMove();                                  //start the animation
    
    //add contents here
    static example_func* drawing_funcs[8] = {
        boxes_example,images_example,labels_example,lazy_loading_example,
        actions_example,manipulate_example,motion_example,animation_example
    };
    if(i<8)
        drawing_funcs[i](panel);
    
    _panel = &panel;

}

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    //set namespace of current controller, that all views will be rendered under this namespace.
    $::setControllerName(@"ViewController");
    
    list(EXAMPLES,^$& (id item, int i) {
        //Set unique ID for each row.
        Str * ID = [NSString stringWithFormat:@"LI_%d",i];
        return label((Str*)item, {.y=i*45.0f+1, .ID=ID}, i==0?&s_list_title:&s_list_row)
                .bind(@"tap", ^(GR *gesture, Dic *params) {
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


