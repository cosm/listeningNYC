#import "Config.h"

// COSM
NSString *const kCOSM_API_KEY = @"Q6_-qsvMOJbrlZNz_0lmUW2mbGWSAKxkekxuRG5SaVRlOD0g";
NSString *const kCOSM_API_URL = @"https://listeningnyc.herokuapp.com/v2";
//NSString *const kCOSM_API_URL = @"https://localhost:60000/v2";
//NSString *const kCOSM_API_URL = @"https://api.cosm.com/v2";
NSString *const kCOSM_FEED_TITLE_PREPEND = @"Listening NYC";
NSString *const kCOSM_FEED_TAG_PREPEND = @"";
NSString *const kCOSM_FEED_WEBSITE = @"www.cosm.com";
NSString *const kCOSM_FEED_VERSION_FORMAT = @"%@ (build %@, iPhone)";

// Recording
double const kRECORD_FOR = 10.0f;
double const kRECORD_COUNTDOWN_FOR = 1.0;
bool const kSTORE_UNSYNCED = NO; // experimental

// Radar
bool const kRADAR_SHOW_DEBUG_UI = NO;
float const kMAX_DB_FOR_FULL_ALPHA = 2.0f;
float const kRADAR_DECAY_RATE = 0.992;
unsigned int const kRADAR_DELAY_FOR = 10;
bool const kRADAR_USE_PEAKS = NO;

// Circle bands
float const kCIRCLE_BANDS_HUE_MAX = -0.095324;
float const kCIRCLE_BANDS_HUE_MIN = 0.449640;

// Detail view
int const kDETAIL_MODAL_MAP_ZOOM = 18;

// Description
NSString *const kDESCRIPTION = @"{#FFFFFF|There was }{#F15A29|%@} {#FFFFFF|low frequency,} {#F15A29|%@} {#FFFFFF|mid-range and }{#F15A29|%@} {#FFFFFF|high frequency content in this sound capture, which was }{#F15A29|%@}";
