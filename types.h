//
//  types.h
//  LiberObjcExample
//
//  Created by soyoes on 8/23/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

struct rgba_t{
    float r;
    float g;
    float b;
    float a;
};

struct vec2{
    float x,y;
};
struct vec3{
    float x,y,z;
};
struct vec4{
    float x,y,z,w;
};
struct rect_t{
    float x,y,w,h;
};

typedef enum {
    kEaseIn,
    kEaseOut,
    kEaseInOut
} anime_style_t;

typedef enum {
    kDeltaLinear,
    kDeltaQuad,
    kDeltaQuad5,
    kDeltaCirc,
    kDeltaBounce,
    kDeltaArrow,
    kDeltaBack,
    kDeltaElastic,
} anime_delta_t;

typedef enum {
    kFill,
    kFit,
    kCropFit,
    kOrg,
    kCustom
} fill_mode_t;

typedef enum {
    kFadeIn,
    kLeftIn,
    kTopIn,
    kRightIn,
    kBottomIn,
} effect_in_t;

typedef enum {
    kFadeOut,
    kLeftOut,
    kTopOut,
    kRightOut,
    kBottomOut,
} effect_out_t;

typedef enum {
    kTopLeft,
    kTopCenter,
    kTopRight,
    kCenterLeft,
    kCenter,
    kCenterRight,
    kBottomLeft,
    kBottomCenter,
    kBottomRight,
    kJustified
} align_t;

struct rotate3d_t{
    float degree;
    float x;
    float y;
    float z;
    float resp; // respective
    float axisX;
    float axisY;
    float transX;
    float transY;
    float transZ;
};

struct anime_t{
    anime_delta_t delta;
    anime_style_t style;
    int delay;
    //    value_t encode();
};

struct svg_cmd_t{
    char cmd;
    float coords[6];
    //    value_t encode();
};


class $;
class style_t;
