//
//  WVExpose.m
//  MotionControl
//
//  Created by Conrad Kramer on 3/12/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#include <objc/message.h>

#import "LeapObjectiveC.h"
#import "WVExpose.h"

extern LeapController *controller;

static __attribute__((constructor)) void constructor() {

}