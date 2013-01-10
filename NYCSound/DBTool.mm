#include "DBTool.h"
#include <stdio.h>
#include <math.h>


DBWeighting CalculateDBWeighting(float frequency) {
    DBWeighting result;
    float f2 = frequency*frequency;
    float n1 = 12200*12200;
    float n2 = 20.6*20.6;
    result.a = n1*f2*f2;
    result.a = result.a / ((f2+n2)*(f2+n1)*sqrt(f2+107.7*107.7)*sqrt(f2+737.9*737.9));
    result.a = result.a / 0.79434639580229505;
    result.a = 20.0*log10(result.a);
    if (fabs(result.a)<0.0001) result.a=0.0;
    result.c = n1*f2;
    result.c = result.c / ((f2+n1)*(f2+n2));
    result.c = result.c /0.9929048655202054;
    result.c = 20.0*log10(result.c);
    if (fabs(result.c)<0.0001) {
        result.c=0.0;
    }
    return result;
};

float MapDB(float inputDB, float inputDBMin, float inputDBMax, float outputDBMin, float outputDBMax) {
    
    float linearInputDB = exp(inputDB*log(20));
    float iinearInputDBMin = exp(inputDBMin*log(20));
    float iinearInputDBMax = exp(inputDBMax*log(20));
    float iinearOutputDBMin = exp(outputDBMin*log(20));
    float iinearOutputDBMax = exp(outputDBMax*log(20));
    
    printf("%f %f %f %f %f \n", linearInputDB, iinearInputDBMin, iinearInputDBMax, iinearOutputDBMin, iinearOutputDBMax);

    float outputDB = ((linearInputDB-iinearInputDBMin)/(iinearInputDBMax-iinearInputDBMin)*(iinearOutputDBMax-iinearOutputDBMin)+iinearOutputDBMin);
    if (iinearOutputDBMax < iinearOutputDBMin) {
        if (outputDB < iinearOutputDBMax) {
            outputDB = iinearOutputDBMax;
        }
        else if (outputDB > iinearOutputDBMin) {
            outputDB = iinearOutputDBMin;
        }
    } else {
        if (outputDB > iinearOutputDBMax) {
            outputDB = iinearOutputDBMax;
        }
        else if (outputDB < iinearOutputDBMin) {
            outputDB = iinearOutputDBMin;
        }
    }
    return 20 * log(outputDB);
};
//
//DBCollection MapDBCollection(DBCollection collection, float inputDBMin, float inputDBMax, float outputDBMin, float outputDBMax) {
//    collection.flatDB = MapDB(collection.flatDB, inputDBMin, inputDBMax, outputDBMin, outputDBMax);
//    collection.aWeightedDB = MapDB(collection.aWeightedDB, inputDBMin, inputDBMax, outputDBMin, outputDBMax);
//    collection.cWeightedDB = MapDB(collection.cWeightedDB, inputDBMin, inputDBMax, outputDBMin, outputDBMax);
//    return collection;
//};


