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

#import "NPPickerIndicator.h"
#import "NPColorPickerView.h"
#import <QuartzCore/QuartzCore.h>
@implementation NPPickerIndicator

@synthesize insets;
@synthesize borderWidth;
@synthesize fillColor = fillColor_;
@synthesize pickerView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       borderWidth = 10;
       self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGRect viewFrame = self.bounds;
   
   viewFrame = (CGRect) { viewFrame.origin.x + self.insets.left, viewFrame.origin.y+ self.insets.top,
      viewFrame.size.width - self.insets.left - self.insets.right, viewFrame.size.height - self.insets.top - self.insets.bottom};
   
   CGFloat maxRadius = MIN(viewFrame.size.width, viewFrame.size.height) / 2;
   CGFloat internalRadius = maxRadius - borderWidth;
   CGPoint center = CGPointMake(CGRectGetMidX(viewFrame), CGRectGetMidY(viewFrame));

   CGMutablePathRef path = CGPathCreateMutable();
   CGPathAddRelativeArc(path, &CGAffineTransformIdentity, center.x, center.y, internalRadius, 0, 2*M_PI);
   CGContextSaveGState(context);
   
   // internal color
   CGContextAddPath(context, path);
   CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
   CGContextDrawPath(context, kCGPathFill);

   // outline
   CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
   CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
   CGPathMoveToPoint(path, &CGAffineTransformIdentity, center.x + maxRadius, center.y);
   CGPathAddRelativeArc(path, &CGAffineTransformIdentity, center.x, center.y, maxRadius, 0, 2*M_PI);
   CGContextAddPath(context, path);
   CGContextDrawPath(context, kCGPathEOFillStroke);
   CGContextRestoreGState(context);
   CGPathRelease(path);
}

@end
