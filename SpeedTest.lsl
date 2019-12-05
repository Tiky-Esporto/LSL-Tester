/****************************************************************************
**===========================================================================
**	SpeedTest.lsl by bayjoo
**	"25fae92c-d1a8-48fe-bacd-36c5539bb435"
**	Thu Dec 5 00:55:43 2019
**===========================================================================
**                         LSL Edi Plus v0.2
**===========================================================================
This is a tool to reveal how fast a code is, not only at start-up, 
but over time and with variation in sim lag.

****************************************************************************/

key gKey;
key gOwner;
integer giSwitch;
float gfAvg;
list g_lOverall;
TestA() {
	
}
TestB() {
	
}
default {
	state_entry() {
		gfAvg = 0.047;
		gKey = llGetKey();
		gOwner = llGetOwner();
		llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXT, "", <1,1,1>, 1]);
		llSetTimerEvent(1);
	}
	timer() {
		if(llGetEnv("region_idle") == "1") return;
		llSetTimerEvent(0);
		integer iTestNumb;
		integer iTestIt;
		list lA;
		list lB;
		float t0;
		float t1;
		float t2;
		for(iTestNumb = 0; iTestNumb < 100; ++iTestNumb) {
			for(iTestIt = 0; iTestIt < 1000; ++iTestIt){;}
			
			if(giSwitch = !giSwitch) {
				t0 = llGetTime();
				for(iTestIt = 0; iTestIt < 1000; ++iTestIt) TestA();
				t1 = llGetTime();
				for(iTestIt = 0; iTestIt < 1000; ++iTestIt) TestB();
				t2 = llGetTime();
				lA += (t1 - t0);
				lB += (t2 - t1);
			} else {
				t0 = llGetTime();
				for(iTestIt = 0; iTestIt < 1000; ++iTestIt) TestB();
				t1 = llGetTime();
				for(iTestIt = 0; iTestIt < 1000; ++iTestIt) TestA();
				t2 = llGetTime();
				lB += (t1 - t0);
				lA += (t2 - t1);
			}
		}
		float fa = llListStatistics(LIST_STAT_MEAN, ((lA=[])+lA));
		float fb = llListStatistics(LIST_STAT_MEAN, ((lB=[])+lB));
		float fr = llListStatistics(LIST_STAT_RANGE, [fa, fb]);
		if(fr) {
			if(fa > fb) fr = -fr;
			g_lOverall += fr;
		}
		integer iNumb = llGetListLength(g_lOverall);
		if(iNumb > 999) return;
		string sText;
		fa = llListStatistics(LIST_STAT_MEAN, g_lOverall);
		if(fa) {
			if(fa > 0.0) sText += "A";
			else sText += "B";
			while(iNumb) {
				fb = llList2Float(g_lOverall, --iNumb);
				if(fa > 0.0) lA += fb;
				else lA += -fb;
			}
			sText ="Numb: "+ (string)llGetListLength(g_lOverall) +"\n"+ sText +" is faster by: "+ (string)llListStatistics(LIST_STAT_MEAN, lA);
		}
		llSetLinkPrimitiveParamsFast(LINK_THIS, [ PRIM_TEXT, sText, <1,1,1>, 1]);
		llSetTimerEvent(1.0/45.0);
	}
}
