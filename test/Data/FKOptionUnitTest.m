#import <SenTestingKit/SenTestingKit.h>
#import "FK/FKOption.h"
#import "FK/FKMacros.h"
#import "FK/FKFunction.h"

@interface FKOptionUnitTest : SenTestCase {
    NSObject *object;
}
@end

@implementation FKOptionUnitTest

- (void)setUp {
    object = [[[NSObject alloc] init] autorelease];
}

- (void)testANoneIsNone {
    STAssertTrue([[FKOption none] isNone], nil);
    STAssertFalse([[FKOption none] isSome], nil);
}

- (void)testASomeIsSome {
    STAssertTrue([[FKOption some:object] isSome], nil);
    STAssertFalse([[FKOption some:object] isNone], nil);
}

- (void)testCanPullTheSomeValueOutOfASome {
    STAssertEqualObjects(object, [[FKOption some:object] some], nil);
}

- (void)testTransformsNilsIntoNones {
    STAssertTrue([[FKOption fromNil:nil] isNone], nil);
    STAssertTrue([[FKOption fromNil:object] isSome], nil);
}

- (void)testMaps {
	STAssertTrue([[[FKOption none] map:functionS(description)] isNone], nil);
	NSString *description = [object description];
	FKOption *r = [[FKOption some:object] map:functionS(description)];
	STAssertTrue([r isSome], nil);	
	STAssertEqualObjects([r some], description, nil);
}

- (void)testTypes {
	STAssertTrue([[FKOption fromNil:@"54" ofType:[NSString class]] isSome], nil);
	STAssertTrue([[FKOption fromNil:nil ofType:[NSString class]] isNone], nil);
	STAssertTrue([[FKOption fromNil:@"54" ofType:[NSArray class]] isNone], nil);
}

- (void)testBindingAcrossANoneGivesANone {
    id result = [[FKOption none] bind:functionTS(self, givesANone:)];
    STAssertTrue([result isKindOfClass:[FKOption class]], nil);
    STAssertTrue([result isNone], nil);
}

- (void)testBindingAcrossASomeWithANoneGivesANone {
    id result = [[FKOption some:@"foo"] bind:functionTS(self, givesANone:)];
    STAssertTrue([result isKindOfClass:[FKOption class]], nil);
    STAssertTrue([result isNone], nil);
}

- (void)testBindingAcrossASomeWithASomeGivesANone {
    id result = [[FKOption some:@"foo"] bind:functionTS(self, givesASome:)];
    STAssertTrue([result isKindOfClass:[FKOption class]], nil);
    STAssertTrue([result isSome], nil);
    STAssertEqualObjects(@"foo", [result some], nil);
}

- (void)testSomes {
	NSArray *options = NSARRAY([FKOption some:@"54"], [FKOption none]);
	NSArray *somes = [FKOption somes:options];
	STAssertEqualObjects(NSARRAY(@"54"), somes, nil);
}

- (BOOL)isString:(id)arg {
    return [arg isKindOfClass:[NSString class]];
}

- (void)testFilter {
    FKOption *o1 = [FKOption some:[NSNumber numberWithInt:5]];
    FKOption *o2 = [FKOption some:@"Okay"];
    
    STAssertTrue([[[FKOption none] filter:functionTS(self, isString:)] isNone], nil);
    STAssertTrue([[o1 filter:functionTS(self, isString:)] isNone], nil);
    STAssertTrue([[o2 filter:functionTS(self, isString:)] isSome], nil);
    
}

- (void)testOrSome {
    FKOption *o1 = [FKOption some:@5];
    
    STAssertEqualObjects(@5, [o1 orSomeBlock:(id)^{ return @200; }],nil);
    STAssertEqualObjects(@2, [[FKOption none] orSomeBlock:(id)^{ return @2; }], nil);
}

- (void)testBindBlockGivesSome {
    FKOption *o1 = [FKOption some:@5];
    FKOption *o2 = nil;
    
    o2 = [o1 bindBlock:^FKOption *(id some) {
        return [FKOption some: @([(NSNumber *)some intValue] + 5)];
    }];
    STAssertEqualObjects(@10, o2.some, nil);
}

- (void)testBindBlockGivesNone {
    FKOption *o1 = nil;
    o1 = [[FKOption none] bindBlock:^FKOption *(id some) {
        STFail(@"This block shouldn't be evaluated");
        return [FKOption some: @([(NSNumber *)some intValue] + 5)];
    }];
    
    STAssertEqualObjects([FKOption none], o1, nil);
}


- (void)testMapBlockGivesSome {
    FKOption *o1 = [FKOption some:@5];
    FKOption *o2 = nil;
    
    o2 = [o1 bindBlock:^FKOption *(id some) {
        return [FKOption some: @([(NSNumber *)some intValue] + 5)];
    }];
    STAssertEqualObjects(@10, o2.some, nil);
}

- (void)testMapBlockGivesNone {
    FKOption *o1 = nil;
    o1 = [[FKOption none] bindBlock:^FKOption *(id some) {
        STFail(@"This block shouldn't be evaluated");
        return [FKOption some: @([(NSNumber *)some intValue] + 5)];
    }];
    STAssertEqualObjects([FKOption none], o1, nil);
}


- (FKOption *)givesANone:(NSString *)str {
    return [FKOption none];
}

- (FKOption *)givesASome:(NSString *)str {
    return [FKOption some:str];
}

@end
