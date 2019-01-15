//
//  VPUPOrderedDictionary.h
//  VideoPlsCytronSDK
//
//  Created by Zard1096 on 16/7/11.
//  Copy & Modify from https://github.com/nicklockwood/OrderedDictionary
//  Copyright © 2016年 videopls.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPOrderedDictionary : NSDictionary

+ (instancetype)dictionaryWithContentsOfFile:(NSString *)path;
+ (instancetype)dictionaryWithContentsOfURL:(NSURL *)url;

+ (NSArray *)sortedDictionaryKeys:(NSArray *)keys;

/** Returns the nth key in the dictionary. */
- (id)keyAtIndex:(NSUInteger)index;
/** Returns the nth object in the dictionary. */
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
/** Returns the index of the specified key, or NSNotFound if key is not found. */
- (NSUInteger)indexOfKey:(id)key;
/** Returns an enumerator for backwards traversal of the dictionary keys. */
- (NSEnumerator *)reverseKeyEnumerator;
/** Returns an enumerator for backwards traversal of the dictionary objects. */
- (NSEnumerator *)reverseObjectEnumerator;
/** Enumerates keys ands objects with index using block. */
- (void)enumerateKeysAndObjectsWithIndexUsingBlock:(void (^)(id key, id obj, NSUInteger idx, BOOL *stop))block;


@end

/**
 * Mutable subclass of OrderedDictionary.
 * Supports all the same methods as NSMutableDictionary, plus a few
 * new methods for operating on entities by index rather than key.
 * Note that although it has the same interface, MutableOrderedDictionary
 * is not a subclass of NSMutableDictionary, and cannot be used as one
 * without generating compiler warnings (unless you cast it).
 */
@interface VPUPMutableOrderedDictionary : VPUPOrderedDictionary

+ (instancetype)dictionaryWithCapacity:(NSUInteger)count;
- (instancetype)initWithCapacity:(NSUInteger)count;

+ (instancetype)sortDictionaryWithDictionary:(NSDictionary *)dictionary;

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary;
- (void)removeAllObjects;
- (void)removeObjectForKey:(id)key;
- (void)removeObjectsForKeys:(NSArray *)keyArray;
- (void)setDictionary:(NSDictionary *)otherDictionary;
- (void)setObject:(id)object forKey:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key;

/** Inserts an object at a specific index in the dictionary. */
- (void)insertObject:(id)object forKey:(id)key atIndex:(NSUInteger)index;
/** Replace an object at a specific index in the dictionary. */
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object;
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index;
/** Swap the indexes of two key/value pairs in the dictionary. */
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
/** Removes the nth object in the dictionary. */
- (void)removeObjectAtIndex:(NSUInteger)index;

@end
