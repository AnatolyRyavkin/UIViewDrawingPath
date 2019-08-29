//
//  ViewController.m
//  lesson24-UIViewDrawingPath
//
//  Created by Anatoly Ryavkin on 03/05/2019.
//  Copyright © 2019 AnatolyRyavkin. All rights reserved.
//
#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()
- (IBAction)era:(UIButton *)sender;
- (IBAction)redButton:(UIButton *)sender;
- (IBAction)orangeButton:(UIButton *)sender;
- (IBAction)yellowButton:(UIButton *)sender;
- (IBAction)greenButton:(UIButton *)sender;
- (IBAction)blueligthButton:(UIButton *)sender;
- (IBAction)blueButton:(UIButton *)sender;
- (IBAction)purpleButton:(UIButton *)sender;
- (IBAction)cleanButton:(UIButton *)sender;
- (IBAction)resetButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *areaDraw;
- (IBAction)litlle:(UIButton *)sender;
- (IBAction)midle:(UIButton *)sender;
- (IBAction)large:(UIButton *)sender;
@property CGPoint pointBegin;
@property CGPoint pointEnd;
@property CGFloat size;
@property UIColor* color;
@property CGMutablePathRef path;
@property CGContextRef context;
@property BOOL flagBegin;
@property NSMutableArray* arrayPath;
@property NSMutableArray* arrayColor;
@property NSMutableArray* arraySize;
@property UIImage* image;
@property BOOL clean;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.size=10;
    self.color=[UIColor blackColor];
    self.path=CGPathCreateMutable();
    UIGraphicsBeginImageContext(self.areaDraw.bounds.size);
    self.context = UIGraphicsGetCurrentContext();
    self.arrayPath = [[NSMutableArray alloc]init];
    self.arrayColor = [[NSMutableArray alloc]init];
    self.arraySize = [[NSMutableArray alloc]init];
    self.clean = NO;
}

#pragma mark - drawing

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.clean == YES){
        self.areaDraw.image=nil;
        CGContextClearRect(self.context, self.areaDraw.bounds);
        UIGraphicsBeginImageContext(self.areaDraw.bounds.size);
        self.context = UIGraphicsGetCurrentContext();
        self.clean=NO;
    }

    UITouch* touch = [touches anyObject];
    CGPoint pointCurent= [touch locationInView:self.areaDraw];
    if(CGRectContainsPoint(self.areaDraw.bounds,pointCurent)){
        self.pointBegin=pointCurent;
        self.pointEnd=pointCurent;
        self.flagBegin=YES;
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch=[touches anyObject];
    CGPoint pointCurent = [touch locationInView:self.areaDraw] ;
    if(CGRectContainsPoint(self.areaDraw.bounds, pointCurent)){
        self.pointEnd=pointCurent;
            CGPathMoveToPoint(self.path, NULL, self.pointBegin.x, self.pointBegin.y);
            CGPathAddLineToPoint(self.path, NULL, self.pointEnd.x, self.pointEnd.y);
                CGContextSetLineWidth(self.context, self.size);
                CGContextSetLineCap(self.context, kCGLineCapRound);
                CGContextSetStrokeColorWithColor(self.context, self.color.CGColor);
                CGContextAddPath(self.context, self.path);
                CGContextStrokePath(self.context);
        CGImageRef imageRef = CGBitmapContextCreateImage(self.context);
        self.image = [UIImage imageWithCGImage:imageRef];
        self.areaDraw.image = self.image;
        self.pointBegin=self.pointEnd;
    }
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGMutablePathRef path =  CGPathCreateMutableCopy(self.path);
    [self.arrayPath addObject: CFBridgingRelease(path)];
    [self.arrayColor addObject: [self.color copy]];
    [self.arraySize addObject: [NSNumber numberWithFloat:self.size]];
    self.path=CGPathCreateMutable();

}

- (IBAction)resetButton:(UIButton *)sender {
    self.areaDraw.image=nil;

    if(self.arrayPath.count>0){
    [self.arrayPath removeObjectAtIndex:self.arrayPath.count-1];
    [self.arraySize removeObjectAtIndex:self.arraySize.count-1];
    [self.arrayColor removeObjectAtIndex:self.arrayColor.count-1];
    }
    NSUInteger count = self.arrayPath.count;

    CGContextClearRect(self.context, self.areaDraw.bounds);
    UIGraphicsBeginImageContext(self.areaDraw.bounds.size);
    self.context = UIGraphicsGetCurrentContext();

    for(int i=0;i<count;i++){

            CGPathRef path = CFBridgingRetain([self.arrayPath objectAtIndex:i]);
            UIColor* color = [self.arrayColor objectAtIndex:i];
            float size =[[self.arraySize objectAtIndex:i] floatValue];

            CGContextSetLineWidth(self.context, size);
            CGContextSetLineCap(self.context, kCGLineCapRound);
            CGContextSetStrokeColorWithColor(self.context, color.CGColor);
            CGContextAddPath(self.context, path);
            CGContextStrokePath(self.context);
    }

    CGImageRef imageRef = CGBitmapContextCreateImage(self.context);
    self.image = [UIImage imageWithCGImage:imageRef];
    self.areaDraw.image = self.image;

    self.pointBegin=self.pointEnd;
    self.path=CGPathCreateMutable();
}

// !!!!!!!!!!!!!!! drawing text in function from a coreText : CTLineDraw(line, self.context) !!!!!!!!!!!!!!!!!!!! hear work
/*
- (IBAction)cleanButton:(UIButton *)sender {
    self.areaDraw.image=nil;
    UIGraphicsBeginImageContext(self.areaDraw.bounds.size);
    self.context = UIGraphicsGetCurrentContext();
    self.path=CGPathCreateMutable();
    [self.arrayPath removeAllObjects];
    [self.arraySize removeAllObjects];
    [self.arrayColor removeAllObjects];


    NSString *text = @"CLEAN!!!";
    NSShadow*shadow = [[NSShadow alloc]init];

    //this shadow dont wrok  !!!!!!

    shadow.shadowOffset = CGSizeMake(10, 10);
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowBlurRadius = 0.9;

    UIFont*font=[UIFont systemFontOfSize:100];

    NSDictionary*dictionary =
    [NSDictionary dictionaryWithObjectsAndKeys:
    shadow,                 NSShadowAttributeName,
    [[UIColor redColor] colorWithAlphaComponent:1],    NSForegroundColorAttributeName,
    [[UIColor grayColor] colorWithAlphaComponent:1],    NSBackgroundColorAttributeName,
    font,                    NSFontAttributeName,
    nil];

    CFAttributedStringRef textAttrStr = CFAttributedStringCreate(NULL, (CFStringRef) text, (CFDictionaryRef) dictionary);
    CTLineRef line = CTLineCreateWithAttributedString(textAttrStr);

    CGContextTranslateCTM(self.context, 0, self.areaDraw.bounds.size.height);
    CGContextScaleCTM(self.context, 1.0, -1.0);
    CGContextSetTextPosition(self.context, 200, 400);

    CTLineDraw(line, self.context);

    CGImageRef imageRef = CGBitmapContextCreateImage(self.context);
    self.image = [UIImage imageWithCGImage:imageRef];
    self.areaDraw.image = self.image;
    self.clean=YES;

}
*/

    // !!!!!!!!!!!!!!! drawing text in function from a : [text drawAtPoint:] !!!!!!!!!!!!!!!!!!!! hear work


- (IBAction)cleanButton:(UIButton *)sender {
    self.areaDraw.image=nil;
    UIGraphicsBeginImageContext(self.areaDraw.bounds.size);
    self.context = UIGraphicsGetCurrentContext();
    self.path=CGPathCreateMutable();
    [self.arrayPath removeAllObjects];
    [self.arraySize removeAllObjects];
    [self.arrayColor removeAllObjects];


    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!                         work with text - this is dont draw from set for contecst-text-papametrs             !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    //CGContextGetTextPosition(self.context);
    //CGContextSetTextPosition(self.context,300, 400);
    //CGContextSetTextDrawingMode(self.context,kCGTextFill);
    //CGContextSetFont(self.context, CGFontCreateWithFontName((CFStringRef)@"Helvetica"));
    //      CGFontRef font =  CTFontCreateWithName( (CFStringRef)@"Helvetica", 12.0f, NULL);
    //CGContextSetFontSize(self.context, 50);


   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    static int in =10;
    in=in+100;
    NSString *text = @"CLEAN!!!";
    UIFont*font=[UIFont systemFontOfSize:100];
    NSShadow*shadow = [[NSShadow alloc]init];

    shadow.shadowOffset = CGSizeMake(1, 1);
    shadow.shadowColor = [UIColor redColor];
    shadow.shadowBlurRadius = 0.9;
    NSDictionary*dictionary =
             [NSDictionary dictionaryWithObjectsAndKeys:
             [UIColor grayColor],    NSForegroundColorAttributeName,
             font,                    NSFontAttributeName,
             shadow,                 NSShadowAttributeName,
              nil];
    CGSize size = [text sizeWithAttributes:dictionary];

    NSAttributedString* atribString = [[NSAttributedString alloc] initWithString:text attributes:dictionary];
    [atribString drawAtPoint:CGPointMake(CGRectGetMidX(self.areaDraw.bounds)-size.width/2,CGRectGetMidY(self.areaDraw.bounds)-size.height/2)];

    //[text drawAtPoint:CGPointMake(CGRectGetMidX(self.areaDraw.bounds)-size.width/2,CGRectGetMidY(self.areaDraw.bounds)-size.height/2) withAttributes:dictionary];

    CGImageRef imageRef = CGBitmapContextCreateImage(self.context);
    self.image = [UIImage imageWithCGImage:imageRef];
    self.areaDraw.image = self.image;
    self.clean=YES;
}

#pragma mark - setup size and color

- (IBAction)era:(UIButton *)sender {
    self.color=[UIColor whiteColor];
}
- (IBAction)redButton:(UIButton *)sender{
    self.color=sender.backgroundColor;
}
- (IBAction)orangeButton:(UIButton *)sender {
    self.color=sender.backgroundColor;
}
- (IBAction)yellowButton:(UIButton *)sender {
    self.color=sender.backgroundColor;
}
- (IBAction)greenButton:(UIButton *)sender {
    self.color=sender.backgroundColor;
}
- (IBAction)blueligthButton:(UIButton *)sender {
    self.color=sender.backgroundColor;
}
- (IBAction)blueButton:(UIButton *)sender {
   self.color=sender.backgroundColor;
}
- (IBAction)purpleButton:(UIButton *)sender {
    self.color=sender.backgroundColor;
}
- (IBAction)litlle:(UIButton *)sender {
    self.size=5;
}
- (IBAction)midle:(UIButton *)sender {
    self.size=10;
}
- (IBAction)large:(UIButton *)sender {
    self.size=15;
}
@end
