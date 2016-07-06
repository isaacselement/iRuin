#import "IRUserDefaults.h"
#import <objc/runtime.h>

@implementation IRUserDefaults


+ (void)invoke_in_load_for_subclass: (NSArray*)skip_sel_names
{
    IMP hookerIMP = class_getMethodImplementation([self class], @selector(__hooker__:));
    unsigned int count;
    Method* methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        const char* sel_name = sel_getName(method_getName(method));
        NSString* name = [NSString stringWithCString:sel_name encoding:NSUTF8StringEncoding];
        if ([skip_sel_names containsObject:name]) {
            continue;
        }
        if ([name hasPrefix:@"."]||[name hasPrefix:@"__hook"] ) {        // .cxx_destruct  and  __hooker__:
            continue;
        }
        method_setImplementation(method, hookerIMP);
    }
}

- (void *)__hooker__:(void *)value
{
    SEL selector = _cmd;
    const char* sel_name = sel_getName(selector);
    const char* ivar_name = sel_name;
    NSString* name = [NSString stringWithCString:sel_name encoding:NSUTF8StringEncoding];
    BOOL isSetter = [name hasPrefix:@"set"];
    
    // get the key
    NSString* key = name;
    if (isSetter) {
        key = [key substringFromIndex:3];                   // delete "set"
        key = [key substringToIndex: [key length] - 1];     // delete ":"
        key = [[[key substringToIndex:1] lowercaseString] stringByAppendingString:[key substringFromIndex:1]];
        ivar_name = [key cStringUsingEncoding:NSUTF8StringEncoding];
    }
    key = [key uppercaseString];
    
    // get the type, and check if C primitive type
    Ivar ivar = class_getInstanceVariable([self class], ivar_name);     // with @synthesize
    if (ivar == NULL) {
        NSString* dash_name = [@"_" stringByAppendingString: [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding]];
        const char* dash_ivar_name = [dash_name cStringUsingEncoding:NSUTF8StringEncoding];
        ivar = class_getInstanceVariable([self class], dash_ivar_name); // without @synthesize
    }
    const char* type = ivar_getTypeEncoding(ivar);
    
    // get or set the value
    if (isSetter) {
        
        if (strcmp(type, "i") == 0) {
            value = (__bridge void *)(@((int)value));
        } else if (strcmp(type, "B") == 0) {
            value = (__bridge void *)(@((BOOL)value));
        }
        
        [self setObject:(__bridge id)value forKey:key];
        return nil;
        
    } else {
        value = (__bridge void *)([self objectForKey:key]);
        
        if (strcmp(type, "i") == 0) {
            value = (void *)[((__bridge NSNumber*)value) integerValue];
        } else if (strcmp(type, "B") == 0) {
            value = (void *)[((__bridge NSNumber*)value) boolValue];
        }
        
        return value;
    }
}

#pragma mark -

- (nullable id)objectForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setObject:(nullable id)value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeObjectForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
