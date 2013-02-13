#import "MeterTableBridge.h"
#import "MeterTable.h"

@implementation MeterTableBridge

+ (float)valueForDB:(float)db {
    static MeterTable *meterTable = nil;
    if (!meterTable) {
        meterTable = new MeterTable(-30.0f, 800, 8.0);
    }
    // step it back down 60db
    float outValue = meterTable->ValueAt(db - 30.0f);
    //NSLog(@"out %f", outValue);
    static float max = -600.0f;
    if (db > max) {
        //NSLog(@"new max %f", db);
        max = db;
    }
    return outValue;
}

@end
