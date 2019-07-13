/****************************************************************************
**===========================================================================
**	SpeedTest.lsl by bayjoo
**	"25fae92c-d1a8-48fe-bacd-36c5539bb435"
**	Thu Jul 11 11:39:35 2019
**===========================================================================
**                         LSL Edi Plus v0.2
**===========================================================================
This is a tool to reveal how fast a code is, not only at start-up, 
but over time and with variation in sim lag.

This Script measured in milliseconds, but those times are irreverent,
we only need to measure everything on the same scale.

Also, each "test time" and "overall time" have different meaning.

This script will only tell what is faster not "by how much".

****************************************************************************/

integer g_iSwitch; // Switch between 1 and 0, do to the test in different order.

integer iANumb; // Number of time TestA() was faster then TestB()
integer iBNumb; // Number of time TestB() was faster then TestA()

list g_lOverall; // Store results of all tests.

// Got tired to add and remove those values between all tests so I let them there.
key gKey; // The object key the script is in.
key gOwner; // The object owner key.

// Write in "TestA()" the code you want to measure again "TestB()"
TestA() {
	
}

// Write in "TestB()" the code you want to measure again "TestA()"
// or let it empty to only measure how fast is TestA().
TestB() {
	
}

string Text(float in_fTime) {
	if(in_fTime) {
		string sOut = "Snippet \"";
		if(in_fTime > 0) sOut += "b";
		else {
			sOut += "a";
			in_fTime = -in_fTime;
		}
		return sOut + "\" is faster by " + (string)in_fTime + "Ms.";
	}
	return "\"a\" and \"b\" are the same.";
}

default {
	state_entry() {
		gKey = llGetKey();
		gOwner = llGetOwner();
		
		// Clean previous result
		llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXT, "", <1,1,1>, 1]);
		
		// Using Timer to let the script "Sleep" between each test.
		// Start timer.
		llSetTimerEvent(0.023);
	}
	timer() {
		
		// Stop timer cause each test is longer than the timer.
		llSetTimerEvent(0);
		
		// Flip the test order
		g_iSwitch = !g_iSwitch;
		
		float t0;
		float t1;
		float t2;
		
		float fTime;
		list lStats;
		
		integer iTestNumb;
		integer iTestIt;
		integer iMax = 1000;
		
		// testing "ABAB" and "BABA" So each test are in every possible position.
		// each test must use identical code.
		// Nothing else then the test between each "llGetTime()"
		for(iTestNumb = 0; iTestNumb < 2; ++iTestNumb) {
			if(g_iSwitch) {
				t0 = llGetTime();
				for(iTestIt = 0; iTestIt < iMax; ++iTestIt) TestA();
				t1 = llGetTime();
				for(iTestIt = 0; iTestIt < iMax; ++iTestIt) TestB();
				t2 = llGetTime();
				fTime = (1000.0 * (((t1 - t0) - (t2 - t1)) / iMax));
				
			} else {
				t0 = llGetTime();
				for(iTestIt = 0; iTestIt < iMax; ++iTestIt) TestB();
				t1 = llGetTime();
				for(iTestIt = 0; iTestIt < iMax; ++iTestIt) TestA();
				t2 = llGetTime();
				fTime = -(1000.0 * (((t1 - t0) - (t2 - t1)) / iMax));
				
			}
			lStats += fTime;
			
		}
		
		// I A is faster time is positive and if B is faster the time is negative.
		// So the average of all test will tell witch test performed better in this iteration.
		float fMean = llListStatistics(LIST_STAT_MEAN, lStats);
		
		// Increase the score for the over text.
		if(fMean > 0) ++iBNumb;
		else ++iANumb;
		
		// Store the average time in the overall list.
		// The overall result only has meaning over time and if the difference between A and B 
		// is more then half the total number of tests.
		g_lOverall += fMean;
		integer iNumb = llGetListLength(g_lOverall);
		
		// Show the result in over text.
		llSetLinkPrimitiveParamsFast(LINK_THIS, [ 
				PRIM_TEXT, ("A: " + (string)iANumb + ", B: " + (string)iBNumb + ", Number: " + (string)iNumb + 
				"\nLast test: " + Text(fMean) + 
				"\nOverall: " + Text(llListStatistics(LIST_STAT_MEAN, g_lOverall)))
				, <1,1,1>, 1 
		]);
		
		if(iNumb < 1000) fTime = 1;
		else fTime = 0;
		
		
		// just to not make the script calculate big numbers for nothing.
		llResetTime();
		llSetTimerEvent(fTime);
	}
}
