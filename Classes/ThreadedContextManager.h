//
//  ThreadedContextManager.h
//
//
//  Created by Raphaël Pinto on 20/06/2014.
//
// The MIT License (MIT)
// Copyright (c) 2015 Raphael Pinto.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


static NSString * const ThreadedContextManager_Init         = @"ThreadedContextManagerInit";
static NSString * const ThreadedContextManager_Release      = @"ThreadedContextManagerRelease";


@interface ThreadedContextManager : NSObject


@property (nonatomic, retain) NSManagedObjectContext* mManagedObjectContext_;


#pragma mark - Object Life Cycle

- (id)initWithContext:(NSManagedObjectContext*)_Context;


#pragma mark - Public Management

- (NSManagedObjectContext*)managedObjectContext;

- (void)performBlockWaitUntilDone:(void (^)(NSManagedObjectContext* context))block
                          success:(void (^)())success
                          failure:(void (^)(NSError* error))failure;

- (void)performBlock:(void (^)(NSManagedObjectContext* context))block
             success:(void (^)())success
             failure:(void (^)(NSError* error))failure;


@end
