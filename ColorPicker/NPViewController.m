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


#import "NPViewController.h"

@interface NPViewController ()

@end

@implementation NPViewController
@synthesize colorPickerView;
@synthesize colorQuadView;

- (void)viewDidLoad
{
   [super viewDidLoad];

   [[self colorQuadView] setBackgroundColor: [UIColor colorWithWhite:0 alpha:1.0f]];
   [[self colorPickerView] setBackgroundColor: [UIColor colorWithWhite:0 alpha:1.0f]];
   [[self colorPickerView] setDelegate:self];
}

- (void)viewDidUnload
{
   [self setColorPickerView:nil];
   [self setColorQuadView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NPColorPickerViewDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)NPColorPickerView:(NPColorPickerView *)view didSelectColor:(UIColor *)color {
   [[self colorQuadView] pushColor:color];
}

@end
