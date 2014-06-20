linked-objc 
=========

Rock your OBJC like script language
(Another version of liberobjc)

# Goals
* Simplify View rendering
* Write OBJC code like script languages.
* Use Style sheets to define styles of views.
* Make it easy to define styles like
    * borderLeft, borderRight ... with different styles
    * inner shadow.
    * cornerRadius > borderLeft...
* Simplify some works, so you can define styles like this way
    * .border = "1 #33333399"       #width=1, color=#333333, alpha=99/255
    * .bgcolor = "#333333:0 #888888:1"  #gradient %0=#333, %100=#888
    * .shadow = "5 8 10 #666666"    #shadow offset=5,8 radius=10 color=#666666
    * .shadow = "inset 5 5 5"       #inset shadow with offset & radius, color=darkgray
    * .font = "Arial,18"            #font name=Arail, size=18
    * .outline = "1 2 #555555"
    * .scaleX = 2.0                  #transform width to 200%
    * .scaleY = 2.0                  #transform height to 200%
    * .flip = "H"                   # or "V", horizontal/vertical flip
    * .rotate = 90|180|270 ...   
    * .rotate3d = 45,1,0,0,500,0.5,1
    * text editing | display features: .nowrap ,.truncate, .editable
* Support SVG path drawing
* maker animation easier with UIDynamicAnimator


# Configuration

Be sure you have these in your xcode -> build settings

* Apple LLVM 5.1 - Language
  * C Language Dialect = gnu11 or c11

* Apple LLVM 5.1 - Language - C ++
  * C++ Language Dialect = gnu++11 or c++11

If there is too many warnings 
you can add this also.
* Apple LLVM 5.1 - Custom Compiler Flags
  * Other Warning Flags = -w
  
* Be sure your controller file which using this library is .mm file but not .m file

## View Rendering
```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];

    /* add 2 labels to a box and insert this box to self.view */
    View b = box({.z=10,.x=60,.y=100,.w=200,.h=200,.bgcolor="#ffffff"})
        << label(@"test1", {.x=50,.y=50,.w=100,.h=30,.color="#ff0000",.bgcolor="#000000"})
        << label(@"test2", {.x=50,.y=100,.w=100,.h=30,.color="#0000ff",.bgcolor="#000000"})
        >> self.view;
        
    /* alternatively you can do the same thing with the following way*/
    $ b = box({60,100,200,200,10,"#ffffff"})
        << label(@"test1", {50,50,100,30,0,"#000000","#FF0000"})
        << label(@"test2", {50,100,100,30,0,"#000000","#FF0000"})
        >> self.view;
}

```

## Use Style sheet

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];

    /*
    You can define style sheet to make organize your code
    This is just an example, you should put these style defination in some header file outside.
    */    
    Styles box_style = {0,0,200,200,10,"#ffffff"};   
    Styles label_style = {0,0,100,30,0,"#00000"};
    
    
    $ b = box({60,100},&box_style)
        << label(@"test1", {.y=50,.color="#FF0000"}, &label_style)
        << label(@"test2", {.y=100,.color="#0000FF"}, &label_style)
        >> self.view;
}
```

## Gradient, Border, Shadow, Opacity ...
```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];

    /*Gradient : 10%:red, 80%:yellow, 100%:white*/
    box({.w=60,.h=100,.bgcolor="#ff0000:10 #ffff00:80 #ffffff:100"}) >> self.view;
    
    /*Shadow : xOffset=1, yOffset=1, radius=5, color=RGBA(#00000099)*/
    box({.w=60,.h=100,.shadow="1 1 5 #00000099"}) >> self.view;
    
    /*Inter Shadow : innerXOffset=3, innerYOffset=3, radius=2, color=RGBA(#00000044)*/
    box({.w=60,.h=100,.shadow="3 3 2 #00000044"}) >> self.view;
    
    /*Opacity/alpha : alpha=0.9 means opacity=0.1 !!! */
    box({.w=60,.h=100,.alpha=0.9}) >> self.view;
    
    /*Border: borderWidth=1 borderColor=#ff0000 cornerRadius=3 */
    box({.w=60,.h=100,.border="1 #FF0000 3"}) >> self.view;
        
}
```

## Handle Gesture Event

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];    
    /* 
      handle guesture events 
      add a label to self.view
      when this label is tapped, "Your Param is value1" will be printed out in the console.
      also you can use other gestures like @"pan",@"pinch",@"rotation",@"swipe",@"longPress",@"screenEdgePan",
    */
    label(@"Click Me", {0,200,200,50})
      .bind(@"tap",^(UIGestureRecognizer *r, NSDictionary *p) {
        NSLog(@"Your Param is %@",p[@"param1"]);
        Mask* m = r.view;    // get gesture mask
        m.owner->unbind(@"tap"); // remove event.
      }, @{@"param1":@"value1"})
      >> self.view;
}
```


## Draw Label and text

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];  
    /* draw label or text */
    label(@"my text ...",{
         .w=300,.h=40,     //required, you can specify these with stylesheet 
         .font="Arial,15", //format : fontName,fontSize
         .color="#ffff00", 
         .paddingLeft=5,   // optional,padding,paddingRight,paddingBottom,paddingTop are also ok
         .textAlign="left" // optional,left | right | center
         .nowrap=YES       // optional,whether wrap text to multiple row , default=true
         .truncate=NO      // optional,truncate text to ..., default = NO truncate
         .placeHolder="input your text here ..."   //optional,symilar with html placeholder
         .editable=YES     //optional,with this option use can edit the text inside.
         }) 
         >> self.view;
}

```

## Draw Image

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];  
    /* draw an image and flip horizontal (flip will be changed later)*/
    img(@"myimg.png",{.w=300,.h=200,.flip="H"}) >> self.view;
}

```

## Draw SVG Path

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];  
    /*  
      Draw a rectangle which's top-right-corner-radius=10 with svg path .
      and set background color to red.
    */
    svgp(@"M0 0 L90 0 Q100,0 100,10 L100 100 L0 100 Z", {0,0,100,100,0,"#ff0000"}) >> self.view;
}

```

## Drag & Drop

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];  
   
    /*
    GR = shortcut of UIGestureRecognizer, defines in Styles.h
    Dic = shortcut of NSDictionary, defines in Styles.h
   
    */
    box({0,0,100,100,0,"#ff0000"})
      .dragable(
            ^(GR *g, Dic *p){},                    //on drag callback
            ^(GR *g, Dic *p){NSLog(@"finished");}  //on finish callback
      )
      >> self.view;
}

```


## Animation (transition with UIDynamicAnimator)

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];  

    $& car = img(@"mycar.png",{0,0,200,60}) >> self.view;
    
    //add 2 x gravity towards (320,0) and make it move.
    car.addGravity(@{@"speed":@2,@"x":@320,@"y":@0}).startMove();
    
    //add a one time force to car towards (320,0) and make it move.
    car.addPush(@{@"speed":@2,@"x":@320,@"y":@0}).startMove();
    
    //add snap (quick move with shaking effect) to car towards (320,400)
    car.addSnap(@{@"x":@320,@"y":@400}).startMove();
    
    
    car.addGravity(@{@"x":@320,@"y":@568})   //add gravity towards (320,568)
      .addCollision(nil)                     //also add a collision area with the default option 
                                             //(the frame of its superview = self.view)
      .startMove();                          //execute all the animations.
      
}

```


## Usage 

In your FooViewController.mm
```objective-c
#import "FooViewController.h"
#import "View.h"

- (void)viewDidLoad{
   [super viewDidLoad];
   
   //draw a black rectangle
   box({60,100,200,200,0,"#000000"}) >> self.view;   

}

```



