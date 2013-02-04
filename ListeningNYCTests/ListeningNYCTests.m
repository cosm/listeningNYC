#import "ListeningNYCTests.h"
#import "Utils.h"

@implementation ListeningNYCTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testTags {
    NSMutableArray *tags;
    tags = [Utils findTagsIn:@"tag 1, tag2, tag3, tag tag 3, tag 6 ,taht8,tag3,tah3, tga3  tgas2, tag 1"];
    STAssertEquals([tags count], 10u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@""];
    STAssertEquals([tags count], 0u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@" "];
    STAssertEquals([tags count], 0u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@", "];
    STAssertEquals([tags count], 0u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@" , "];
    STAssertEquals([tags count], 0u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@" ,"];
    STAssertEquals([tags count], 0u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@"t"];
    STAssertEquals([tags count], 1u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@"0"];
    STAssertEquals([tags count], 1u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@"0123"];
    STAssertEquals([tags count], 1u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@"tag"];
    STAssertEquals([tags count], 1u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@"tag,"];
    STAssertEquals([tags count], 1u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@",AFGH"];
    STAssertEquals([tags count], 1u, @"Utils findTagsIn:");
    tags = [Utils findTagsIn:@"GHKFGK$^%"];
    STAssertEquals([tags count], 1u, @"Utils findTagsIn:");
}

- (void)testTagsWithoutMachineTags {
    NSArray *tags = @[  @"tag",
                        @"tag",
                        @"Machine:Tag=123",
                        @"Tag",
                        @"Almost:tag",
                        @"COSM:GUID=123123-423432-25235432-234234"];
    NSMutableArray *withoutMachineTags = [Utils tagArrayWithoutMachineTags:tags];
    NSLog(@"%@",withoutMachineTags);
    STAssertEquals([withoutMachineTags count], 4u, @"Utils tagArrayWithoutMachineTags:");
}

// Modeled after the quintic y = (x - 1)^5 + 1
float QuinticEaseOut(float p)
{
	float f = (p - 1);
	return f * f * f * f * f + 1;
}

- (void)testQuinticEaseOut {
    NSLog(@"Quintic out");
    NSLog(@"%f", QuinticEaseOut(0.0));
    NSLog(@"%f", QuinticEaseOut(0.25));
    NSLog(@"%f", QuinticEaseOut(0.5));
    NSLog(@"%f", QuinticEaseOut(0.75));
    NSLog(@"%f", QuinticEaseOut(1.0));
}


@end
