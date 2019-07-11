/****************************************************************************
**===========================================================================
**	SpeedTest.lsl by bayjoo
**	"25fae92c-d1a8-48fe-bacd-36c5539bb435"
**	Thu Jul 11 11:39:35 2019
**===========================================================================
**                         LSL Edi Plus v0.2
**===========================================================================
****************************************************************************/
key gKey;
key gOwner;
integer g_iSwitch;
integer iBNumb;
integer iANumb;
list g_lOverall;

TestA() {
	
}
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
		llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXT, "", <1,1,1>, 1]);
		llSetTimerEvent(0.001);
	}
	timer() {
		llSetTimerEvent(0);
		g_iSwitch = !g_iSwitch;
		
		float t0;
		float t1;
		float t2;
		
		float fTime;
		list lStats;
		
		integer iTestNumb;
		integer iTestIt;
		integer iMax = 1000;
		
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
		
		float fMean = llListStatistics(LIST_STAT_MEAN, lStats);
		if(fMean > 0) ++iBNumb;
		else ++iANumb;
		
		g_lOverall += fMean;
		integer iNumb = llGetListLength(g_lOverall);
		
		llSetLinkPrimitiveParamsFast(LINK_THIS, [ 
				PRIM_TEXT, ("A: " + (string)iANumb + ", B: " + (string)iBNumb + ", Number: " + (string)iNumb + 
				"\nLast test: " + Text(fMean) + 
				"\nOverall: " + Text(llListStatistics(LIST_STAT_MEAN, g_lOverall)))
				, <1,1,1>, 1 
		]);
		
		if(iNumb < 1000) fTime = 1;
		else fTime = 0;
		llSetTimerEvent(fTime);
	}
}
