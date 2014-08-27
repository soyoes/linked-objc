//
//  AppDelegate.m
//  LiberObjcExample
//
//  Created by soyoes on 6/29/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#import "AppDelegate.h"
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


bool panel_presented;

$* _panel;

void list_item_tapped(view_base_t target, int i){
    
    if(panel_presented)return;
    
    //Up date title row.
    //get title row with ID, under namespace of @"ViewController"
    $& title_row = $id(@"LI_0");
    //add back btn to title row
    title_row << label(@"Back",(style_t){.ID=@"back_btn"}>s_list_title_btn).bind(@"tap", ^(ges_t g, $& btn, dic_t p) {
        //release panel
        if(_panel)_panel->remove();
        //release this label btn
        btn.remove();
        panel_presented = false;
    }, @{});
    
    //add a panel to the screen
    $& panel = box({@0,@568,@320,@548,@1,@"#465866",.ID=@"panel"}) >> target;
    
    //add transition animation
    panel.animate(400, {.y=@60}, {.delta=kDeltaBounce,.style=kEaseInOut});
    
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

@interface TView : UIScrollView


@end
@implementation TView


@end


@implementation AppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor greenColor];
    window.rootViewController = self;
    //root = self.view;
    NSLog(@"app load");
    [window makeKeyAndVisible];
    return YES;
}

#pragma mark - controller delegates

-(void) respondToTapGesture:(UITapGestureRecognizer*)ges{
    NSLog(@"taps");
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

     NSLog(@"view appear");
//    $ d = label(@"test", {@0,@30,@320,@200,.bgcolor=@"#ffffff",.font=@"AvenirNextCondensed-DemiBold,18"})
//    .bind(@"tap", ^(ges_t g, $ & n, dic_t p) {
//        n.text(@"hoho");
//    }, @{})
//    >> self.view;

    
    list(EXAMPLES,^$& (obj_t item, int i) {
        //Set unique ID for each row.
        str_t ID = sprintf(@"LI_%d",i);
        return label((str_t)item, (style_t){.y=(i==0?@1:@(i*41+5)), .ID=ID} > (i==0?s_list_title:s_list_row))
            .bind(@"tap", ^(ges_t gesture, $& n, dic_t params) {
                int i = numi(params[@"i"]);
                if(i>0) list_item_tapped(self.view, i-1);
            }, @{@"i":@(i)});
    }, s_list) >> self.view;
}

#pragma mark - other app delegates

- (void)applicationWillResignActive:(UIApplication *)application{//will go to background
}

- (void)applicationDidEnterBackground:(UIApplication *)application{//free some shared resource, or exec bacgkround program
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
}

- (void)applicationDidBecomeActive:(UIApplication *)application{//refresh UI
}

- (void)applicationWillTerminate:(UIApplication *)application{//save datas
}

@end
