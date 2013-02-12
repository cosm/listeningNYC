#import "Config.h"

// COSM
NSString *const kCOSM_API_KEY = @"Q6_-qsvMOJbrlZNz_0lmUW2mbGWSAKxkekxuRG5SaVRlOD0g";
NSString *const kCOSM_API_URL = @"https://warm-sands-4383.herokuapp.com/v2";
//NSString *const kCOSM_API_URL = @"https://localhost:60000/v2";
NSString *const kCOSM_FEED_TITLE_PREPEND = @"Listening NYC";
NSString *const kCOSM_FEED_TAG_PREPEND = @"";
NSString *const kCOSM_FEED_WEBSITE = @"www.cosm.com";
NSString *const kCOSM_FEED_VERSION_FORMAT = @"%@ (build %@, iPhone)";

// Recording
bool const kRADAR_SHOW_DEBUG_UI = NO;
double const kRECORD_FOR = 10.0f;
double const kRECORD_COUNTDOWN_FOR = 1.0;
bool const kSTORE_UNSYNCED = NO; // experimental

// Radar
float const kMAX_DB_FOR_FULL_ALPHA = 2.0f;
float const kRADAR_DECAY_RATE = 0.993;
unsigned int const kRADAR_DELAY_FOR = 107;
bool const kRADAR_USE_PEAKS = NO;

// Circle bands
float const kCIRCLE_BANDS_HUE_MAX = -0.095324;
float const kCIRCLE_BANDS_HUE_MIN = 0.449640;

// Detail view
int const kDETAIL_MODAL_MAP_ZOOM = 18;