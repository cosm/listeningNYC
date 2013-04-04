#pragma once

// Weightings

typedef struct {
    float a;
    float c;
} DBWeighting;

DBWeighting CalculateDBWeighting(float frequency);

// Collections

typedef struct {
    float flatDB;
    float aWeightedDB;
    float cWeightedDB;
} DBCollection;

// Tools

float MapDB(float inputDB, float inputDBMin, float inputDBMax, float outputDBMin, float outputDBMax);
//DBCollection MapDBCollection(DBCollection collection, float inputDBMin, float inputDBMax, float outputDBMin, float outputDBMax);