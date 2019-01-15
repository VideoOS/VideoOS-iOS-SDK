//
//  HexColor.m
//
//  Created by Marius Landwehr on 02.12.12.
//  The MIT License (MIT)
//  Copyright (c) 2013 Marius Landwehr marius.landwehr@gmail.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "VPUPHexColors.h"

@implementation VPUPHXColor

+ (UIColor *)vpup_colorWithHexString:(NSString *)hexString
{
    return [self vpup_colorWithHexString:hexString alpha:1.0];
}

+ (UIColor *)vpup_colorWithHexARGBString:(NSString *)hexString {
    if(hexString.length == 0) {
        return nil;
    }
    
    if('#' == [hexString characterAtIndex:0]) {
        hexString = [hexString substringFromIndex:1];
    }
    NSArray *validHexStringLengths = @[@3, @4, @6, @8];
    NSNumber *hexStringLengthNumber = [NSNumber numberWithUnsignedInteger:hexString.length];
    if ([validHexStringLengths indexOfObject:hexStringLengthNumber] == NSNotFound) {
        return nil;
    }
    if (4 == hexString.length || 8 == hexString.length) {
        NSString *alphaHex;
        NSString *rgbHex;
        if (4 == hexString.length) {
            alphaHex = [hexString substringWithRange:NSMakeRange(0, 1)];
            rgbHex = [hexString substringFromIndex:1];
        } else {
            alphaHex = [hexString substringWithRange:NSMakeRange(0, 2)];
            rgbHex = [hexString substringFromIndex:2];
        }
        
        hexString = [NSString stringWithFormat:@"#%@%@",rgbHex,alphaHex];
    }
    
    return [self vpup_colorWithHexRGBAString:hexString];
}

+ (UIColor *)vpup_colorWithHexRGBAString:(NSString *)hexString
{
    return [self vpup_colorWithHexRGBAString:hexString alpha:1.0];
}

+ (UIColor *)vpup_colorWithHexRGBAString:(NSString *)hexString alpha:(CGFloat)alpha
{
    // We found an empty string, we are returning nothing
    if (hexString.length == 0) {
        return nil;
    }
    
    // Check for hash and add the missing hash
    if('#' != [hexString characterAtIndex:0]) {
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    }
    
    // returning no object on wrong alpha values
    NSArray *validHexStringLengths = @[@4, @5, @7, @9];
    NSNumber *hexStringLengthNumber = [NSNumber numberWithUnsignedInteger:hexString.length];
    if ([validHexStringLengths indexOfObject:hexStringLengthNumber] == NSNotFound) {
        return nil;
    }
    
    // if the hex string is 5 or 9 we are ignoring the alpha value and we are using the value from the hex string instead
    CGFloat handedInAlpha = alpha;
    if (5 == hexString.length || 9 == hexString.length) {
        NSString *alphaHex;
        if (5 == hexString.length) {
            alphaHex = [hexString substringWithRange:NSMakeRange(4, 1)];
        } else {
            alphaHex = [hexString substringWithRange:NSMakeRange(7, 2)];
        }
        if (1 == alphaHex.length) alphaHex = [NSString stringWithFormat:@"%@%@", alphaHex, alphaHex];
        //hexString = [NSString stringWithFormat:@"#%@", [hexString substringFromIndex:9 == hexString.length ? 7 : 3]];
        hexString = [NSString stringWithFormat:@"#%@", [hexString substringWithRange:NSMakeRange(1, 9 == hexString.length ? 6 : 3)]];
        unsigned alpha_u = [self vpup_hexValueToUnsigned:alphaHex];
        handedInAlpha = ((CGFloat) alpha_u) / 255.0;
    }
    
    // check for 3 character HexStrings
    hexString = [self vpup_hexStringTransformFromThreeCharacters:hexString];
    
    NSString *redHex    = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(1, 2)]];
    unsigned redInt = [self vpup_hexValueToUnsigned:redHex];
    
    NSString *greenHex  = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(3, 2)]];
    unsigned greenInt = [self vpup_hexValueToUnsigned:greenHex];
    
    NSString *blueHex   = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(5, 2)]];
    unsigned blueInt = [self vpup_hexValueToUnsigned:blueHex];
    
    UIColor *color = [self vpup_hx_colorWith8BitRed:redInt green:greenInt blue:blueInt alpha:handedInAlpha];
    
    return color;
}

+ (UIColor *)vpup_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    // We found an empty string, we are returning nothing
    if (hexString.length == 0) {
        return nil;
    }
    
    // Check for hash and add the missing hash
    if('#' != [hexString characterAtIndex:0]) {
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    }
    
    // returning no object on wrong alpha values
    NSArray *validHexStringLengths = @[@4, @5, @7, @9];
    NSNumber *hexStringLengthNumber = [NSNumber numberWithUnsignedInteger:hexString.length];
    if ([validHexStringLengths indexOfObject:hexStringLengthNumber] == NSNotFound) {
        return nil;
    }
    
    // if the hex string is 5 or 9 we are ignoring the alpha value and we are using the value from the hex string instead
    CGFloat handedInAlpha = alpha;
    if (5 == hexString.length || 9 == hexString.length) {
        NSString * alphaHex = [hexString substringWithRange:NSMakeRange(1, 9 == hexString.length ? 2 : 1)];
        if (1 == alphaHex.length) alphaHex = [NSString stringWithFormat:@"%@%@", alphaHex, alphaHex];
        hexString = [NSString stringWithFormat:@"#%@", [hexString substringFromIndex:9 == hexString.length ? 3 : 2]];
        unsigned alpha_u = [[self class] vpup_hexValueToUnsigned:alphaHex];
        handedInAlpha = ((CGFloat) alpha_u) / 255.0;
    }
    
    // check for 3 character HexStrings
    hexString = [self vpup_hexStringTransformFromThreeCharacters:hexString];
    
    NSString *redHex    = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(1, 2)]];
    unsigned redInt = [[self class] vpup_hexValueToUnsigned:redHex];
    
    NSString *greenHex  = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(3, 2)]];
    unsigned greenInt = [[self class] vpup_hexValueToUnsigned:greenHex];
    
    NSString *blueHex   = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(5, 2)]];
    unsigned blueInt = [[self class] vpup_hexValueToUnsigned:blueHex];
    
    UIColor *color = [VPUPHXColor vpup_hx_colorWith8BitRed:redInt green:greenInt blue:blueInt alpha:handedInAlpha];
    
    return color;
}

+ (UIColor *)vpup_hx_colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue
{
    return [self vpup_hx_colorWith8BitRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)vpup_hx_colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha
{
    UIColor *color = nil;
    color = [UIColor colorWithRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
    
    return color;
}

+ (unsigned)vpup_hexValueToUnsigned:(NSString *)hexValue
{
    unsigned value = 0;
    
    NSScanner *hexValueScanner = [NSScanner scannerWithString:hexValue];
    [hexValueScanner scanHexInt:&value];
    
    return value;
}

+ (NSString *)vpup_hexStringTransformFromThreeCharacters:(NSString *)hex;
{
    if(hex.length == 4)
    {
        NSString * hexString = [NSString stringWithFormat:@"#%1$c%1$c%2$c%2$c%3$c%3$c",
                                [hex characterAtIndex:1],
                                [hex characterAtIndex:2],
                                [hex characterAtIndex:3]];
        return hexString;
    }
    
    return hex;
}

@end
