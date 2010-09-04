// 
// Copyright 2010 MICHAL VASICEK
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 

#define USE_APPLICATION_UNIT_TEST 0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "MVIOCFactoryInjectionType.h"


@interface IOCFactoryInjectionTypeTest : SenTestCase {
    MVIOCFactoryInjectionType *_injectionType;
}

@property(nonatomic, retain) MVIOCFactoryInjectionType *injectionType;

#if USE_APPLICATION_UNIT_TEST

#else

#endif

- (id)createInstance;

@end
