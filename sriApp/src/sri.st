program sri ( "X=X" )
#define SRI_VER 1.0
/* xray will not be considered ON until this value is reached */
#define XRAY_UA_DEADBAND 5

/*****************************************************************************************
 *	Program to monitor x-ray on time, get the exposure time, and mAs readbacks. 
 *	Implements a watchdog timer to kill the x-ray flux if it is on uninterrupted for more 
 *  than a specified amount of time.
 *  
 *	by Alireza Panna, NIH/NHLBI/IPL
 *	
 *	#  X  	= prefix for all of the PV's associated with main x-ray ioc
 * 
 *  Add xxx_SRCS += sri.st to ../src/Makefile
 *  Add registrar(sriRegistrar) to sriSupport.dbd
 *  To use this snl code add seq(&sri, "X=$(P)") to st.cmd after iocInit.
 *  
 *  __log__ = 2/10/2016: (AP) Version 1.0 created
 ******************************************************************************************/ 

/*====================Option statements===================*/
option +r; /* allows running more than one copy with different macros */
option +c; /* wait for channel connections*/
option -l; /* use C line numbers in error messages etc. */
option +w; /* Suppress snc compiler warnings */
option -s; /* dont run in safe mode */

/* Escape to C code for C includes using %% */
%% #include <string.h>
%% #include <epicsThread.h>
%% #include <epicsTime.h>
%% #include <time.h>
#include "seqPVmacros.h" /* for PV macro */

#ifndef NULL
#define NULL 0L
#endif

/*==================================assignments/declarations==================================================*/
PV (short,		xray_enable,			"{X}:ON", 							Monitor);	/* xray on/off monitor */
PV (double,		xray_ua_rbv,			"{X}:UA_RBV", 						Monitor);	/* xray flux readback (uA) */
PV (double,		xray_ms_rbv,			"{X}:MS_RBV", 						NoMon);		/* xray exposure time readback (ms) */
PV (double,		xray_mAs_rbv,			"{X}:MAS_RBV", 						NoMon);		/* xray flux rate readback (mAs) */
PV (double,		auto_kill_length,		"{X}:AUTOKILL_LENGTH", 				NoMon);		/* auto shut-off xray timer */
PV (double,		auto_kill_elapsed_rbv,	"{X}:AUTOKILL_ELAPSED_RBV", 		NoMon);		/* readback of time left before auto shut-off (countdown) */

/* for watch dog timer */
long	start;		
long	elapsed;
/* for calculating x-ray exposure time more accurately */
double 	start_time, ns_start_time;
double 	current_time, ns_current_time;
double 	exp_time, ns_exp_time;

/*====================State Sets====================*/
ss monitor_xray
{
	state init
	{
		/* initialize stuff here */
		when(1)
		{
		} state xray_on
	}

	state xray_on
  	{
    		when (xray_enable && xray_ua_rbv > XRAY_UA_DEADBAND) {
       			start_time  = pvTimeStamp(xray_enable).secPastEpoch;
    			start = time(NULL);
    			ns_start_time = pvTimeStamp(xray_enable).nsec;
    			pvGet(xray_ua_rbv);
    			pvGet(auto_kill_length);
			} state watchdog
   	} 

   	state watchdog
   	{
   		when (elapsed - start > auto_kill_length) {
   			PVPUT(xray_enable, 0);
   		} state xray_off

  		when (!xray_enable) {
  		} state xray_off

  		when (1) {
   			elapsed = time(NULL);
   			PVPUT(auto_kill_elapsed_rbv, elapsed - start);
   		} state watchdog
   	}

	state xray_off
	{
		when (1) {
			current_time = pvTimeStamp(xray_enable).secPastEpoch;
			ns_current_time = pvTimeStamp(xray_enable).nsec;
			exp_time = (ns_current_time - ns_start_time)/1000000000.;
			exp_time += current_time  - start_time;
			PVPUT(xray_ms_rbv, exp_time*1000);
			PVPUT(xray_mAs_rbv, exp_time*xray_ua_rbv*0.001);

		} state xray_on
	} 
}
