//
//  test.cpp
//  LiberObjcExample
//
//  Created by soyoes on 8/17/14.
//  Copyright (c) 2014 Liberhood ltd. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "test.h"
using namespace std;

void print_tst (TestCls t){
    cout << t.cls.num << " - "<< t.cls.src1 << " - "<< t.cls.src2<< endl;
}

void run_test(){
    //test_cls t1 = {.src1="v1",.src2="v2",.src_pr="v3"};
    TestStruct t1 = {1, "v1-1","v2-1"};
    
    TestStruct t2 = *new TestStruct();
    t2.num = 2;
    t2.src1 = "v1-2";
    t2.src2 = "v2-2";
    
    TestStruct t3 = *(TestStruct*)malloc(sizeof(TestStruct*));
    t3.num = 3;
    t3.src1 = "v1-3";
    t3.src2 = "v2-3";
    
    TestCls a={t1};
    TestCls b=*new TestCls();
    b.cls = t2;
    TestCls c=*(TestCls*)malloc(sizeof(TestCls*));
    c.cls = t3;
    
    for (int i=0; i<10; i++) {
        print_tst(a);
        print_tst(b);
        print_tst(c);
    }
}





