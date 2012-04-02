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

#import "CGColor+Additions.h"

@interface GradientPosition : NSObject 

@property (nonatomic, readonly) UIColor * color;
@property (nonatomic, readonly) CGFloat position;
-(id)initWithColor:(UIColor *) color atPosition:(CGFloat) position;

@end

@implementation GradientPosition 

@synthesize color = color_;
@synthesize position = position_;



-(id)initWithColor:(UIColor *)color atPosition:(CGFloat)position {
   self = [super init];
   if (self) {
      color_  = color;
      position_ = position;
   }
   return self;
}


@end

#import "NPConicGradient.h"



//--------------------------------------------------------------------------------------------------------------------
// a class to draw conic gradient. The class uses a interpolater to compute color between two positions. 
//
//--------------------------------------------------------------------------------------------------------------------


@implementation NPConicGradient

// the center of the conic drawing
@synthesize center = center_;
// the radius
@synthesize radius = radius_;

// the starting angle 
@synthesize startAngle = startAngle_;

// the ending angle
@synthesize endAngle = endAngle_;

// the interpolater 
@synthesize interpolater = interpolater_;

// the number of interval drawn between start and end angle
@synthesize interstices = interstices_;


-(id)init {
   self = [super init];
   if (self) {
      positions_ = [[NSMutableArray alloc]initWithCapacity:2];
      interstices_ = 300;
   }
   return self;
}


//--------------------------------------------------------------------------------------------------------------------
//
// method:		   addColor: atPosition:
// scope:			public
// description:	Add a color at a specific normalized position of the gradient. 
//                
// parameters:		position, between 0.0 and 1.0f  represent a percentage of the angular distance between start and 
//                end angle values
// result:			
//
// notes:			
//
//--------------------------------------------------------------------------------------------------------------------

-(void)addColor:(UIColor *)color atPosition:(CGFloat) position {
   [positions_ addObject:[[GradientPosition alloc]initWithColor:color atPosition:position]];
   [positions_ sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      if ([obj1 position] < [obj2 position]) {
         return NSOrderedAscending;
      }
      if ([obj1 position] == [obj2 position]) {
         return NSOrderedSame;
      }
      return NSOrderedDescending;
   }];
}


//--------------------------------------------------------------------------------------------------------------------
//
// method:		   drawInContext: 
// scope:			public
// description:	Will draw the gradient in the given context 
//                
// parameters:		
// result:			
//
// notes:			
//
//--------------------------------------------------------------------------------------------------------------------

-(void)drawInContext:(CGContextRef) context {
   CGContextSetAllowsAntialiasing(context, false);
   CGFloat sc[4];
   CGFloat ec[4];
   CGFloat c[4];
   
   NSParameterAssert([positions_ count]>1);
   GradientPosition * spos = [positions_ objectAtIndex:0];
   CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
   CGContextSetFillColorSpace(context, cs);

   CGFloat startAngle = startAngle_ + ((endAngle_ - startAngle_) * spos.position);
   CGPoint prev =  CGPointMake(center_.x + cosf(startAngle) * radius_, center_.y + sinf(startAngle) * radius_);
   CGPoint part[3]; 
   CGPoint dest;
   
   for (NSInteger index = 1, len = [positions_ count];index < len;index++) {

      GradientPosition * epos = [positions_ objectAtIndex:index];
      
      CGFloat endAngle = startAngle_ + ((endAngle_ - startAngle_) * epos.position);
      [spos.color getRed:&sc[0] green:&sc[1] blue:&sc[2] alpha:&sc[3]];
      [epos.color getRed:&ec[0] green:&ec[1] blue:&ec[2] alpha:&ec[3]];

      CGFloat angle;
   
      for (angle = startAngle; angle <= endAngle; angle += (endAngle - startAngle) / interstices_ ) {
         
         dest = CGPointMake(center_.x + cosf(angle) * radius_, center_.y + sinf(angle)*radius_);

         interpolater_((angle - startAngle) / (endAngle - startAngle), sc, ec, c, 4);
         CGContextSetFillColor(context,c);
         CGContextSetStrokeColor(context,c);
         
         part[0] = center_;
         part[1] = prev;
         part[2] = dest;
         
         CGContextAddLines(context, part, 3);
         CGContextFillPath(context);
         prev = dest;
      }
      
      startAngle = angle;
      spos = epos;
   }
   
   // finish interval
   
   dest = CGPointMake(center_.x + cosf(startAngle_) * radius_, center_.y + sinf(startAngle_)*radius_);
   part[0] = center_;
   part[1] = prev;
   part[2] = dest;
   CGContextAddLines(context, part, 3);
   CGContextFillPath(context);
   
   CGColorSpaceRelease(cs);
   
   CGContextSetAllowsAntialiasing(context, true);
}


@end
