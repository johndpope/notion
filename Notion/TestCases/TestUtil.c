/*
 *  TestUtil.c
 *  Señor Staff
 *
 *  Created by Konstantine Prevas on 1/30/07.
 *  Copyright 2007 Konstantine Prevas. All rights reserved.
 *
 */

#include "TestUtil.h"

inline float effDuration(int duration, int dotted){
	return (3.0 / (float)duration) * (dotted ? 1.5 : 1.0);
}