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


#import "NPColorPickerView.h"
#import <QuartzCore/QuartzCore.h>

#import "NPConicGradient.h"
#import "RGB-HSL.h"
#import "NPPickerIndicator.h"

#define M_PI_3    M_PI/3 

@interface NPHueDonutLayer : CALayer {
}
@property (nonatomic, readwrite, assign) CGFloat donutThickness;
@property (nonatomic, readwrite, retain) NPConicGradient * conicGradient;

@end

@implementation NPHueDonutLayer 

// the width of the donut 
@synthesize donutThickness = donutThickness_;
@synthesize conicGradient = conicGradient_; 

-(id)init {
   self = [super init];
   if (self) {
      [self setOpaque: NO];
   }
   return self;
}

-(void)drawInContext:(CGContextRef)context {
   CGRect frame = self.bounds;
   
   CGContextClearRect(context, frame);
   
   CGFloat maxRadius = MIN(frame.size.width, frame.size.height) / 2;
   CGFloat internalRadius = maxRadius - donutThickness_;
   CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
   
   conicGradient_.center = center;
   conicGradient_.radius = maxRadius;
   
   CGContextSaveGState(context);
   
   CGMutablePathRef path = CGPathCreateMutable();
   // the donut is reduced by 1 at both diameters because to clip op includes the path thickness
   CGPathAddRelativeArc(path, &CGAffineTransformIdentity, center.x, center.y, maxRadius - 1, 0, 2*M_PI);  
   CGPathMoveToPoint(path, &CGAffineTransformIdentity, center.x + internalRadius, center.y);
   CGPathAddRelativeArc(path, &CGAffineTransformIdentity, center.x, center.y, internalRadius + 1, 0, 2*M_PI);
   
   CGContextAddPath(context, path);
   CGPathRelease(path);
   
   CGContextEOClip(context);
   
   [conicGradient_ drawInContext:context];
   
   CGContextRestoreGState(context);
   
   CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.58 alpha:0.5] .CGColor);
   CGContextSetLineWidth(context, 3.0f);
   
   path = CGPathCreateMutable();
   CGPathAddRelativeArc(path, &CGAffineTransformIdentity, center.x, center.y, maxRadius, 0, 2*M_PI);
   CGPathMoveToPoint(path, &CGAffineTransformIdentity, center.x + internalRadius, center.y);
   CGPathAddRelativeArc(path, &CGAffineTransformIdentity, center.x, center.y, internalRadius, 0, 2*M_PI);
   CGContextAddPath(context, path);
   CGContextStrokePath(context);
   CGPathRelease(path);
}

@end


@implementation NPColorPickerView {
   NSMutableArray * hueIndicators_;
   NPPickerIndicator * hueIndicator_;
   NPPickerIndicator * svIndicator_;
   NPHueDonutLayer * donutLayer_;
}

// the chosen color
@synthesize color = color_;

// the margin around the palette 
@synthesize insets;

// the width of the donut 
@dynamic donutThickness;


//--------------------------------------------------------------------------------------------------------------------
//
// method:		   defaultInitializer_
// scope:			private
// description:	
//                
// parameters:		
// result:			
//
// notes:			
//
//--------------------------------------------------------------------------------------------------------------------

-(void) defaultInitializer_ {
   
   self.insets = UIEdgeInsetsMake(15,15, 15, 15);
   
   donutLayer_ = [NPHueDonutLayer layer];
   
   NPConicGradient * conicGradient = [[NPConicGradient alloc]init];
   conicGradient.startAngle = 0;
   conicGradient.endAngle = 2*M_PI;
   [conicGradient addColor:[UIColor colorWithHue:0.0001f saturation:1.0f brightness:1.0f alpha:1.0f] atPosition:0.0f ];
   [conicGradient addColor:[UIColor colorWithHue:0.9999f saturation:1.0f brightness:1.0f alpha:1.0f] atPosition:1.0f ]; 
   
   conicGradient.interpolater = ^void(CGFloat percent, CGFloat sourceComps[], CGFloat endComps[], CGFloat outCompts[], size_t s)  {
      
      CGFloat sh;
      CGFloat ss; 
      CGFloat sv;
      
      CGFloat eh;
      CGFloat es; 
      CGFloat ev;
      
      CGFloat ih;
      CGFloat is; 
      CGFloat iv;
      
      RGBtoHSV(sourceComps[0], sourceComps[1], sourceComps[2], &sh, &ss, &sv);
      RGBtoHSV(endComps[0], endComps[1], endComps[2], &eh, &es, &ev);
      
      ih = sh + ((eh - sh) * percent);
      is = ss + ((es - ss) * percent);
      iv = sv + ((ev - sv) * percent);
      outCompts[3] = sourceComps[3] + ((endComps[3] - sourceComps[3]) * percent);
      
      HSVtoRGB(&outCompts[0], &outCompts[1], &outCompts[2], ih, is, iv );
   };
   
   [donutLayer_ setConicGradient:conicGradient];
   
   self.donutThickness = 50;
   
   [[self layer] addSublayer: donutLayer_];
   
   hueIndicators_ = [[NSMutableArray alloc] initWithCapacity:3];
   
   hueIndicator_ = [[NPPickerIndicator alloc] initWithFrame:CGRectZero];
   hueIndicator_.insets = UIEdgeInsetsMake(5,5,5,5);
   hueIndicator_.borderWidth = 7;
   [hueIndicators_ addObject:hueIndicator_];
   [self addSubview:hueIndicator_];
   UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onMoveHueIndicator:)];
   [hueIndicator_ addGestureRecognizer:panGesture];
   
   svIndicator_ = [[NPPickerIndicator alloc] initWithFrame:CGRectZero];
   svIndicator_.insets = UIEdgeInsetsMake(5,5,5,5);
   svIndicator_.borderWidth = 7;
   [self addSubview:svIndicator_];
   
   panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onMoveSVIndicator:)];
   [svIndicator_ addGestureRecognizer:panGesture];
   
   self.color = [UIColor colorWithHue:1.00 saturation:1.0f brightness:0.001f alpha:1.0f];
   
   [donutLayer_ setNeedsDisplay];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       [self defaultInitializer_];
    }
    return self;
}

-(void)awakeFromNib {
   [self defaultInitializer_];
}

//--------------------------------------------------------------------------------------------------------------------
//
// method:		   haloThickness
// scope:			
// description:	 
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------


-(void)setDonutThickness:(CGFloat)donutThickness {
   [donutLayer_ setDonutThickness:donutThickness]; 
}

//--------------------------------------------------------------------------------------------------------------------
//
// method:		   haloThickness
// scope:			
// description:	 
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------


-(CGFloat) donutThickness {
   return [donutLayer_ donutThickness];
}

//--------------------------------------------------------------------------------------------------------------------
//
// method:		   layoutSubviews
// scope:			OS
// description:	places the subviews (indicators) where they should BE ! 
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void)layoutSubviews {
   [super layoutSubviews];
   
   donutLayer_.frame = [self donutFrameForRect:self.bounds];
   
   CGFloat hue, sat,brightness;
   [color_ getHue:&hue saturation:&sat brightness:&brightness alpha:NULL];
   
   CGPoint center = [self indicatorCenterForHue:hue];
   hueIndicator_ .frame = CGRectMake(floorf(0.5f + center.x - (self.donutThickness/2)),
                                     floorf(0.5f + center.y - (self.donutThickness/2)),
                                     self.donutThickness, self.donutThickness);
   
   center = [self indicatorCenterForSaturation:sat brightness:brightness];
   svIndicator_. frame = CGRectMake(floorf(0.5f + center.x - (self.donutThickness/2)),
                                    floorf(0.5f + center.y  - (self.donutThickness/2)), 
                                    self.donutThickness, self.donutThickness);
}


//--------------------------------------------------------------------------------------------------------------------
//
// method:		   set the color and trigger view refresh:
// scope:			private
// description:	
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void)setColor:(UIColor *)color {
   
   color_ = color;
   
   CGFloat hue, sat,brightness;
   [color_ getHue:&hue saturation:&sat brightness:&brightness alpha:NULL];
   
   hueIndicator_.fillColor = [UIColor colorWithHue:hue saturation:1.0f brightness:1.0f alpha:1.0f];
   svIndicator_.fillColor = color_;
   
   CGRect frame = [self donutFrameForRect:self.bounds];
   CGFloat maxRadius = MIN(frame.size.width, frame.size.height) / 2;
   CGFloat internalRadius = maxRadius - self.donutThickness;
   CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

   [self setNeedsLayout];
   [self setNeedsDisplayInRect:CGRectMake(center.x - internalRadius, center.y-internalRadius, internalRadius * 2, internalRadius * 2)];
   [hueIndicator_ setNeedsDisplay];
   [svIndicator_ setNeedsDisplay];
}


//--------------------------------------------------------------------------------------------------------------------
//
// method:		   set the color and trigger view refresh:
// scope:			private
// description:	
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(CGRect) donutFrameForRect:(CGRect) rect {
   return (CGRect) { rect.origin.x + self.insets.left, rect.origin.y+ self.insets.top,
      rect.size.width - self.insets.left - self.insets.right, rect.size.height - self.insets.top - self.insets.bottom};
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Drawing
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)drawRect:(CGRect)rect
{
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
   
   CGRect frame = [self donutFrameForRect:self.bounds];
   
   CGFloat maxRadius = MIN(frame.size.width, frame.size.height) / 2;
   CGFloat internalRadius = maxRadius - self.donutThickness;
   CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

   CGMutablePathRef path = NULL;
   // triangle
   CGPoint edges[3]; 
   edges[0] = (CGPoint) { center.x + cosf(0) * internalRadius, center.y + sinf(0) * internalRadius };   
   edges[1] = (CGPoint) { center.x + cosf(2*M_PI_3) * internalRadius, center.y + sinf(2*M_PI_3) * internalRadius };   
   edges[2] = (CGPoint) { center.x + cosf(4*M_PI_3) * internalRadius, center.y + sinf(4*M_PI_3) * internalRadius };   
   
   path = CGPathCreateMutable();
   CGPathAddLines(path, &CGAffineTransformIdentity, edges, 3);
   CGPathCloseSubpath(path);
   
   CGContextAddPath(context, path);
   CGContextStrokePath(context);
   
   CGContextAddPath(context, path);
   CGContextClip(context);
   
   CGFloat hue;
   [self.color getHue:&hue saturation:NULL brightness:NULL alpha:NULL];
   
   CGContextSetFillColorWithColor(context, [UIColor colorWithHue:hue saturation:1.0f brightness:1.0f alpha:1.0f].CGColor);
   CGContextFillRect(context, 
                     CGRectMake(center.x - internalRadius, center.y-internalRadius, internalRadius * 2, internalRadius * 2));
   
   CGFloat locations[]  = {0.0f, 1.0f};
   CGGradientRef gradient;
   
   NSArray * a = [NSArray arrayWithObjects:
        (id)[UIColor colorWithHue:0 saturation:1.0f brightness:0.0f alpha:1.0f].CGColor,
        (id)[UIColor colorWithHue:0 saturation:1.0f brightness:0.0f alpha:0.0f].CGColor,
        nil];
   
   gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)a, locations);
   
   CGContextDrawLinearGradient(context,gradient, edges[1], (CGPoint) { (edges[0].x + edges[2].x)/2,(edges[0].y + edges[2].y)/2}, kCGGradientDrawsBeforeStartLocation); 
   CGGradientRelease(gradient);
   a = [NSArray arrayWithObjects:
        (id)[UIColor colorWithHue:0 saturation:0.0f brightness:1.0f alpha:1.0f].CGColor,
        (id)[UIColor colorWithHue:0 saturation:0.0f brightness:1.0f alpha:0.0f].CGColor,
        nil];
   gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)a, locations);
   
   CGContextDrawLinearGradient(context,gradient, edges[2], (CGPoint) { (edges[0].x + edges[1].x)/2,(edges[0].y + edges[1].y)/2}, kCGGradientDrawsBeforeStartLocation); 
   CGGradientRelease(gradient);
   
   CGPathRelease(path);
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Projections from color HSV space to palette 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------------------------------------------------
//
// method:		   indicatorCenterForHue:
// scope:			private
// description:	return the a point on the donut that correspond to the given hue
//                
// parameters:		
// result:			
//
// notes:			
//
//--------------------------------------------------------------------------------------------------------------------

-(CGPoint)indicatorCenterForHue:(CGFloat) hue {

   CGRect frame = [self donutFrameForRect:self.bounds];
   
   CGFloat radius = ((MIN(frame.size.width, frame.size.height) - self.donutThickness ) / 2);
   CGFloat hueRad =  hue * 2 * M_PI;
   CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
   return (CGPoint) { center.x + (cosf(hueRad) * radius),  center.y + (sinf(hueRad) * radius) };
}

//--------------------------------------------------------------------------------------------------------------------
//
// method:		   indicatorCenterForHue:
// scope:			private
// description:	return the a point on the triangle that correspond to the given saturation and brightness
//                
// parameters:		
// result:			
//
// notes:			saturation is the angle between the triangle edge ( sat=0,bri=1  :  sat=1,bri=1) and a line 
//                going through (sat=1,bri=1) and the returned point
//                brightness is the distance between the point (sat=1,bri=1) and the returned point on the sat line
//--------------------------------------------------------------------------------------------------------------------

-(CGPoint)indicatorCenterForSaturation:(CGFloat) saturation brightness:(CGFloat) brightness {

   CGRect frame = [self donutFrameForRect:self.bounds];

   CGFloat internalRadius = (MIN(frame.size.width, frame.size.height) / 2) - self.donutThickness;
   CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

   CGFloat teta = M_PI_3 * saturation;

   CGFloat l = brightness * ( (sqrtf(3) / 2) / cosf(fabsf(teta - (M_PI/6))));
   CGPoint s = (CGPoint) { center.x + cosf(2*M_PI_3) * internalRadius, center.y + sinf(2*M_PI_3) * internalRadius };   
   CGPoint b = (CGPoint) { center.x + cosf(4*M_PI_3) * internalRadius, center.y + sinf(4*M_PI_3) * internalRadius };
   
   CGPoint v = (CGPoint) { l * ( b.x - s.x), l * (b.y - s.y)};
   CGPoint r = (CGPoint) { (v.x * cosf(teta)) - (v.y * sinf(teta)), (v.x * sinf(teta)) + (v.y * cosf(teta))};
   
   return CGPointMake(floorf(s.x + r.x), floorf(s.y + r.y));
}


//--------------------------------------------------------------------------------------------------------------------
//
// method:		   getSaturation:brightness:position:
// scope:			private
// description:	
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void)getSaturation:(CGFloat *) sat brightness:(CGFloat *) brightness position:(CGPoint) pos {

   CGRect viewFrame = self.bounds;
   viewFrame = (CGRect) { viewFrame.origin.x + self.insets.left, viewFrame.origin.y+ self.insets.top,
      viewFrame.size.width - self.insets.left - self.insets.right, viewFrame.size.height - self.insets.top - self.insets.bottom};
   CGFloat internalRadius = (MIN(viewFrame.size.width, viewFrame.size.height) / 2) - self.donutThickness;
   CGPoint center = CGPointMake(CGRectGetMidX(viewFrame), CGRectGetMidY(viewFrame));

   CGPoint s = (CGPoint) { cosf(2*M_PI_3) * internalRadius, sinf(2*M_PI_3) * internalRadius };   
   CGPoint b = (CGPoint) { cosf(4*M_PI_3) * internalRadius, sinf(4*M_PI_3) * internalRadius };
   pos.x -= center.x;
   pos.y -= center.y;
   
   CGPoint v1 = (CGPoint) { b.x - s.x , b.y - s.y  };
   CGPoint v2 = (CGPoint) { pos.x-s.x , pos.y - s.y };
   
   CGFloat teta = atan2f(v1.x,v1.y) - (atan2f(v2.x, v2.y));

   if (teta > M_PI) {
      teta = 0.00001;
   } else if (teta > M_PI / 3) {
      teta = M_PI / 3;
   };
   
   if (sat) {
      *sat = MAX(0.00001,(teta / (M_PI_3))) ;
   }
   
   if (brightness) {
      CGFloat v1l = sqrtf(v1.x*v1.x + v1.y*v1.y);
      CGFloat max = v1l  * ( (sqrtf(3) / 2) / cosf(fabsf(teta - (M_PI/6))));
      CGFloat l = sqrtf(v2.x*v2.x + MIN(v2.y,0)*MIN(v2.y,0));
      *brightness = MIN( l, max) / max ;
   }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gesture recognizer
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   onMoveHueIndicator:
// scope:			private - recognizer 
// description:	move the indicator that belongs to the donut
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void)onMoveHueIndicator:(UIPanGestureRecognizer *) recognizer {
   
   if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
      CGRect viewFrame = self.frame;
      viewFrame = (CGRect) { viewFrame.origin.x + self.insets.left, viewFrame.origin.y+ self.insets.top,
         viewFrame.size.width - self.insets.left - self.insets.right, viewFrame.size.height - self.insets.top - self.insets.bottom};
      CGPoint center = CGPointMake(CGRectGetMidX(viewFrame), CGRectGetMidY(viewFrame));
      CGPoint t = [recognizer locationOfTouch:0 inView:self];
      
      float sat, brigt, hue = (M_PI - atan2f(t.y-center.y,center.x-t.x)) / (2 * M_PI);
      [color_ getHue:NULL saturation:&sat brightness:&brigt alpha:NULL];
      [self setColor:[UIColor colorWithHue:hue saturation:sat brightness:brigt alpha:1.0f]];
   }
}



//--------------------------------------------------------------------------------------------------------------------
//
// method:		   onMoveSVIndicator:
// scope:			private - recognizer 
// description:	move the indicator that belongs to the triangle
//                
// parameters:		
// result:			
//
// notes:			
//--------------------------------------------------------------------------------------------------------------------

-(void)onMoveSVIndicator:(UIPanGestureRecognizer *) recognizer {
   if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
      CGPoint t = [recognizer locationOfTouch:0 inView:self];
      float sat, brigt, hue;
      [color_ getHue:&hue saturation:NULL brightness:NULL alpha:NULL];
      [self getSaturation:&sat brightness:&brigt position:CGPointMake(t.x,t.y)];
      [self setColor:[UIColor colorWithHue:hue saturation:sat brightness:brigt alpha:1.0f]];
   }
}

@end
