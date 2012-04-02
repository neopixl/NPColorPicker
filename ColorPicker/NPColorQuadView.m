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

#import "NPColorQuadView.h"

@implementation NPColorQuadView {
   NSMutableArray * colors_;
}

@dynamic selectedColor;
@synthesize selectedIndex = selectedIndex_;
@synthesize intercellSpace = intercellSpace_;
@synthesize insets = insets_;
@synthesize depht = depht_;



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   
// scope:			private 
// description:	make sure kvo is working properly
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
   NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
   if ([key compare:@"selectedColor"] == 0) {
      NSSet *affectingKeys = [NSSet setWithObjects:@"selectedIndex", nil];
      keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
   }
   return keyPaths;
}



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   
// scope:			private 
// description:	
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void) defaultInitializer_ {
   self.insets = UIEdgeInsetsMake(5,15, 5, 15);
   selectedIndex_ = 0;
   intercellSpace_ = CGSizeMake(5, 0);
   depht_ = 4;
   colors_ = [[NSMutableArray alloc] initWithCapacity:depht_];
   
   UITapGestureRecognizer * rec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
   [rec setNumberOfTapsRequired:1];
   [rec setNumberOfTouchesRequired:1];
   [self addGestureRecognizer:rec];
}



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   designed init
// scope:			
// description:	
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
   if (self) {
      [self defaultInitializer_];
   }
   return self;
}



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   
// scope:			 
// description:	
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void)awakeFromNib {
   [self defaultInitializer_];
}



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   
// scope:			 
// description:	
//                
// parameters:		
// result:			return the selected color or nil if nothign is selcted
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(UIColor *)selectedColor {
   if (selectedIndex_ != NSNotFound && selectedIndex_ < [colors_ count]) {
      return [colors_ objectAtIndex:selectedIndex_];
   } else {
      return nil;
   }
}



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   Used to push a new color on the view, the exitings colors are shifting (the selection is kept).
// scope:			public 
// description:	
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void)pushColor:(UIColor *)color {
   
   [colors_ insertObject:color atIndex:0];
   
   while ([colors_ count] > depht_) {
      [colors_ removeObjectAtIndex: [colors_ count]-1];
   }
   
   if (selectedIndex_ != NSNotFound) {
      selectedIndex_ = MIN(selectedIndex_ +1, depht_-1); 
   }
   
   [self setNeedsDisplay];
}



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   drawRect
// scope:			private 
// description:	
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void)drawRect:(CGRect)rect {
   
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
   CGRect b = self.bounds;
   
   if ([self backgroundColor]) {
      CGContextSetFillColorWithColor(context, [[self backgroundColor] CGColor]);
      CGContextFillRect(context, b);
   }
   
   CGPoint origin = CGPointMake(b.origin.x + insets_.left, b.origin.y + insets_.top);
   CGSize swatchSize;
   swatchSize.width = ((b.size.width - insets_.left - insets_.right) / depht_) - intercellSpace_.width;
   swatchSize.height = b.size.height - insets_.top - insets_.bottom;
   
   CGFloat hue, sat, bright, alpha;
   
   for (NSUInteger index= 0; index < depht_; index++) {
      UIColor * c = [UIColor colorWithWhite:0 alpha:1.0f];
      if (index < [colors_ count]) {
         c = [colors_ objectAtIndex:index];
      }

      [c getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
      UIColor * light = [UIColor colorWithHue:hue saturation:sat brightness:MIN(1.0f, 1.4f * bright) alpha:alpha];
      UIColor * dark = [UIColor colorWithHue:hue saturation:sat brightness:bright * 0.4f alpha:alpha];

      CGRect swatchRect = (CGRect) { origin, swatchSize };
      CGContextSetFillColorWithColor(context, [c CGColor]);
      CGContextFillRect(context, swatchRect);
      
      if (index == selectedIndex_) { 
         CGContextSetLineWidth(context, 2.0f);
         CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1.0f alpha:1.0f] CGColor]);
         CGContextMoveToPoint(context, CGRectGetMinX(swatchRect), CGRectGetMaxY(swatchRect));
         CGContextAddLineToPoint(context, CGRectGetMinX(swatchRect), CGRectGetMinY(swatchRect));
         CGContextAddLineToPoint(context, CGRectGetMaxX(swatchRect), CGRectGetMinY(swatchRect));
         CGContextAddLineToPoint(context, CGRectGetMaxX(swatchRect), CGRectGetMaxY(swatchRect));
         CGContextAddLineToPoint(context, CGRectGetMinX(swatchRect), CGRectGetMaxY(swatchRect));
         CGContextStrokePath(context);
      } else {
         CGContextSetLineWidth(context, 1.0f);
         CGContextMoveToPoint(context, CGRectGetMinX(swatchRect), CGRectGetMaxY(swatchRect));
         CGContextAddLineToPoint(context, CGRectGetMinX(swatchRect), CGRectGetMinY(swatchRect));
         CGContextAddLineToPoint(context, CGRectGetMaxX(swatchRect), CGRectGetMinY(swatchRect));
         CGContextSetStrokeColorWithColor(context, [light CGColor]);
         CGContextStrokePath(context);
         
         CGContextMoveToPoint(context, CGRectGetMaxX(swatchRect), CGRectGetMinY(swatchRect));
         CGContextAddLineToPoint(context, CGRectGetMaxX(swatchRect), CGRectGetMaxY(swatchRect));
         CGContextAddLineToPoint(context, CGRectGetMinX(swatchRect), CGRectGetMaxY(swatchRect));
         CGContextSetStrokeColorWithColor(context, [dark CGColor]);
         CGContextStrokePath(context);
      }

      origin.x += swatchSize.width + intercellSpace_.width;
   }
   
   CGColorSpaceRelease(colorspace);
}



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   onTap
// scope:			private 
// description:	gesture recognize, change selection
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void)onTap:(UITapGestureRecognizer *) recognizer {
   if ([recognizer state] == UIGestureRecognizerStateEnded) {
      CGPoint t = [recognizer locationOfTouch:0 inView:self];
      
      CGRect b = self.bounds;
      CGSize swatchSize;
      CGPoint origin = CGPointMake(b.origin.x + insets_.left, b.origin.y + insets_.top);
      swatchSize.width = ((b.size.width - insets_.left - insets_.right) / depht_);

      NSUInteger index = MIN((t.x - origin.x) / swatchSize.width, depht_);
      [self setSelectedIndex: index];
      [self setNeedsDisplay];
   }
}


@end
