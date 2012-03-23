/*
 Copyright 2012 NEOPIXL S.A. 
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

@interface NPConicGradient : NSObject {
   NSMutableArray * positions_;
}

typedef void (^Interpolater)(CGFloat percent, CGFloat sourceComps[], CGFloat endComps[], CGFloat outCompts[], size_t s) ;

@property (nonatomic, readwrite, assign) CGPoint center;
@property (nonatomic, readwrite, assign) CGFloat radius;
@property (nonatomic, readwrite, assign) CGFloat startAngle;
@property (nonatomic, readwrite, assign) CGFloat endAngle;
@property (nonatomic, readwrite, copy) Interpolater interpolater;
@property (nonatomic, readwrite, assign) NSUInteger interstices;


-(void)addColor:(UIColor *)color atPosition:(CGFloat) position;
-(void)drawInContext:(CGContextRef) context;

@end
