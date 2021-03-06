//
//  SGGCDSingleton.h
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#define GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(classname)\
\
+(classname *)shared##classname {\
\
static classname *sharedInstance = nil;\
\
static dispatch_once_t predicate;\
\
dispatch_once(&predicate, ^{\
\
sharedInstance = [[self alloc] init];\
\
});\
\
return sharedInstance;\
}