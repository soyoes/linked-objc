//
//  style_sheet.cpp
//  LiberObjcExample
//
//  Created by soyoes on 6/29/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#include "style_sheet.h"

#define FONT_DEFAULT @"Futura-CondensedMedium,14"

style_t s_list={@0,@20,@320,@548,@0,@"#ECF0F1"};
style_t s_list_row={.w=@320,.h=@40,.bgcolor=@"#FFFFFF",.color=@"#333333",.font=FONT_DEFAULT,.paddingTop=@8,.paddingLeft=@10};
style_t s_list_title={@0,@0,@320,@44,@0,@"#FFFFFF",@"#FF0000",.align=@"center",.font=FONT_DEFAULT,.paddingTop=@10};
style_t s_list_title_btn={.w=@80,.h=@44,.z=@1,.color=@"#333333",.font=FONT_DEFAULT,.paddingTop=@12,.paddingLeft=@10};
style_t s_panel={@10,@0,@300,@500};

style_t s_box={.w=@80,.h=@80,@0,@"#ffffff",@"#000000",.font=FONT_DEFAULT};

style_t s_label={.w=@300,.h=@30,@0,@"#ffffff",@"#000000",.paddingTop=@5,.paddingLeft=@10,.font=FONT_DEFAULT};

style_t s_layer={@10,@20,@60,@60,@0,@"#ffffff",@"#000000",.font=FONT_DEFAULT,.paddingTop=@16,.align=@"center"};