//
//  style_sheet.cpp
//  LiberObjcExample
//
//  Created by soyoes on 6/29/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#include "style_sheet.h"

#define FONT_DEFAULT "Futura-CondensedMedium,14"

Styles s_list={0,20,320,548,0,"#ECF0F1"};
Styles s_list_row={.w=320,.h=44,.bgcolor="#FFFFFF",.color="#333333",.font=FONT_DEFAULT,.paddingTop=10,.paddingLeft=10,};
Styles s_list_title={.w=320,.h=44,
    .textAlign="center",.bgcolor="#FFFFFF",
    .color="#FF0000",.font=FONT_DEFAULT,.paddingTop=10};
Styles s_list_title_btn={.w=80,.h=44,.z=1,.color="#333333",.font=FONT_DEFAULT,.paddingTop=12,.paddingLeft=10};


Styles s_panel={10,0,300,500};

Styles s_box={.w=80,.h=80,.color="#000000",.bgcolor="#ffffff",.font=FONT_DEFAULT};

Styles s_label={.w=300,.h=30,.paddingTop=5,.paddingLeft=10,.color="#000000",.bgcolor="#ffffff",.font=FONT_DEFAULT};

Styles s_layer={.x=10,.y=20,.w=60,.h=60,.bgcolor="#ffffff",.color="#000000",.font=FONT_DEFAULT,.paddingTop=16,.textAlign="center"};