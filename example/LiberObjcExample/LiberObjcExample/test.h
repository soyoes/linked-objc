//
//  test.h
//  LiberObjcExample
//
//  Created by soyoes on 8/17/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#ifndef TST_H
#define TST_H

struct TestStruct{
    int num ;
    const char * src1;
    const char * src2;
};

class TestCls{
    
public:
    TestStruct cls;
};

void run_test();

#endif