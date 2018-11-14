//
//  ARObjectView.m
//  Santander
//
//  Created by Carlos on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//https://medium.com/ios-os-x-development/swift-and-objective-c-interoperability-2add8e6d6887

#import "ARObjectView.h"
//#import "ARKitEngine.h"
#import "Golfication-Swift.h"

@interface ARObjectView (){

}

@end
@implementation ARObjectView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.userInteractionEnabled = YES;
        self.opaque = YES;
        _displayed = YES;
        
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // TODO fix touch on objectviews at half side right
    
    [_controller viewTouched:self];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}


@end
