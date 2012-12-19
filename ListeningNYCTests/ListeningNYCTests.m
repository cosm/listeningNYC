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


@end
