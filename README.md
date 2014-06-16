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
# Examples

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
    
    /*Also you can define style sheet to make organize your code*/    
    Styles box_style = {0,0,200,200,10,"#ffffff"};   
    Styles label_style = {0,0,100,30,0,"#00000"};
    
    $ b = box({60,100},&box_style)
        << label(@"test1", {.y=50,.color="#FF0000"}, &label_style)
        << label(@"test2", {.y=100,.color="#0000FF"}, &label_style)
        >> self.view;
    
    /* 
      handle guesture events 
      add a label to self.view
      when this label is tapped, "Your Param is value1" will be printed out in the console.
    */
    label(@"Click Me", {0,200,200,50})
      .bind(@"tap",^(UIGestureRecognizer *r, NSDictionary *p) {
        NSLog(@"Your Param is %@",p[@"param1"]);
      }, @{@"param1":@"value1"})
      >> self.view;
    
    /* Image */
    img(@"myimg.png") >> self.view;
    
    
}

```

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

# Usage 

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
 

