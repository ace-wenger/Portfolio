****************************************************************************;
***** written by Aaron Wenger
***** written 12-7-21 last updated 12-14-21
*****	
*****	EMR6750 - Final Project
*****		Data Processing
****************************************************************************;
options nodate nocenter nofmterr ls=78;
libname emr6750 "C:\Users\aw647\Documents\GSchoolCourses_GsCs\GsCs_21.9_MultivarStats_Mv\GsCsMv_Data";
%include "C:\Users\aw647\Documents\GSchoolCourses_GsCs\GsCs_21.9_MultivarStats_Mv\GsCsMv_Macros\M_multnorm.sas";
title1; title2;
****************************************************************************;
****************************************************************************;
***** DESCRIPTIVES;
proc means data=emr6750.final maxdec=3 vardef=df
	n nmiss mean std median min max kurt skew;
	var comp earn emp debt sat adm size gend cost aid minor; run;
proc corr data=emr6750.final nosimple noprob plots=scatter; 
	var comp earn emp debt sat adm size gend cost aid minor; run;
proc univariate data=emr6750.final;
	var comp earn emp debt sat adm size gend cost aid minor;
	histogram comp earn emp debt sat adm size gend cost aid minor /normal;
	title1 'Univariate Normality'; run;
****************************************************************************;
***** MISSING DATA ANALYSIS;
***** Description and impact of pairwise deletion;
data emr6750.final_miss; set emr6750.final
	(keep=comp earn emp debt sat adm size gend cost aid minor);
	CaseVar_N=n(comp, earn, emp, debt, sat, adm, size, gend, cost, aid, minor);
	CaseVar_Nmiss=nmiss(comp, earn, emp, debt, sat, adm, size, gend, cost, aid, minor); run;
proc freq data=emr6750.final_miss;
	tables CaseVar_N CaseVar_Nmiss;
	title1 "look at OVERALL Missingness summary";
	run;
proc means data=emr6750.final_miss n nmiss;
	var comp earn emp debt sat adm size gend cost aid minor;
	run;																				
***** Missingness MCAR/MAR or MNAR?;
%include "C:\Users\aw647\Documents\GSchoolCourses_GsCs\GsCs_21.9_MultivarStats_Mv\GsCsMv_Macros\P2_Little_MCAR_testv3.sas";
***** Missingness MCAR or MAR? Programming a MISSINGNESS INDICATOR;
data finalMCAR;
	set emr6750.final_miss;
array v comp earn emp debt sat adm size gend cost aid minor;
array i Mcomp Mearn Memp Mdebt Msat Madm Msize Mgend Mcost Maid Mminor;
do over v;
	i=0;
	if v=. then i=1;
end; run;
proc print data=finalMCAR(obs=10);
	var Mcomp Mearn Memp Mdebt Msat Madm Msize Mgend Mcost Maid Mminor;
	title1 "checking indicator logic"; run;	
***** Missingnss MCAR or MAR? Predicting Missingness (logistic regression);	
***** Msat;
proc logistic data=finalMCAR;
	model Msat=comp;
	ods output ParameterEstimates=M1;
	title1 "IV=comp"; title2 "DV=Msat"; run;
proc logistic data=finalMCAR;
	model Msat=earn;
	ods output ParameterEstimates=M2;
	title1 "IV=earn"; run;
proc logistic data=finalMCAR;
	model Msat=emp;
	ods output ParameterEstimates=M3;
	title1 "IV=emp"; run;
proc logistic data=finalMCAR;
	model Msat=debt;
	ods output ParameterEstimates=M4;
	title1 "IV=debt"; run;
***** Madm;
proc logistic data=finalMCAR;
	model Madm=comp;
	ods output ParameterEstimates=M5;
	title1 "IV=comp"; title2 "DV=Madm"; run;
proc logistic data=finalMCAR;
	model Madm=earn;
	ods output ParameterEstimates=M6;
	title1 "IV=earn"; run;
proc logistic data=finalMCAR;
	model Madm=emp;
	ods output ParameterEstimates=M7;
	title1 "IV=emp"; run;
proc logistic data=finalMCAR;
	model Madm=debt;
	ods output ParameterEstimates=M8;
	title1 "IV=debt"; run;
title1; title2;	
data summ;
	set m1(firstobs=2)
		m2(firstobs=2)
		m3(firstobs=2)
		m4(firstobs=2)
		m5(firstobs=2)
		m6(firstobs=2)
		m7(firstobs=2)
		m8(firstobs=2); run;
proc print data=summ; run;
***** Looking for Monotone Missing Pattern;
proc mi data=emr6750.final_miss;
	var comp earn emp debt sat adm size gend cost aid minor;
	ods output misspattern=MissPat;
	run;
proc sort data=MissPat out=MissPatOrdered;
	by freq;
	run;
proc print data=MissPatOrdered;
	var freq comp_miss earn_miss emp_miss debt_miss sat_miss adm_miss size_miss gend_miss cost_miss aid_miss minor_miss;
	run;
****************************************************************************;
***** TRANSFORMATION for UNIVARIATE NORMALITY;
data finalT; set emr6750.final;
	Learn=log10(1.947-earn);
	Ladm=log10(2-adm);
	SQsize=sqrt(size);
	SQminor=sqrt(minor); run;
***** Check Results;
proc means data=finalT maxdec=3 vardef=DF
	n nmiss mean std median min max kurt skew;
	var comp Learn emp debt sat Ladm SQsize gend cost aid SQminor; run;
proc univariate data=finalT;
	var comp Learn emp debt sat Ladm SQsize gend cost aid SQminor;
	histogram comp Learn emp debt sat Ladm SQsize gend cost aid SQminor /normal;
	title1 'Univariate Normality'; run;
***** Checking multivariate normality, linearity, and homoscedasticity;
proc cancorr data=finalT
	out=prelim
	sing=1e-8;
	var comp Learn emp debt; 
	with sat Ladm SQsize gend cost aid SQminor; run;
proc plot data=prelim;
	plot w1*v1;
	plot w2*v2; run; quit;
****************************************************************************;
***** DETECTING OUTLIERS;
***** Univariate;
proc standard data=finalT out=finalT_std vardef=df mean=0 std=1;
	var comp Learn emp debt sat Ladm SQsize gend cost aid SQminor; run;
proc means data=finalT_std vardef=df N Min Max;
	var comp Learn emp debt sat Ladm SQsize gend cost aid SQminor; run;
data finalT_v2; set finalT;
	if unitid=243221 then delete; run;
***** Check results (debt, emp, and earn were signficantly changed);
proc standard data=finalT_v2 out=finalT_v2std vardef=df mean=0 std=1;
	var comp Learn emp debt sat Ladm SQsize gend cost aid SQminor; run;
proc means data=finalT_v2std vardef=df N Min Max;
	var comp Learn emp debt sat Ladm SQsize gend cost aid SQminor; run;
***** Multivariate;
proc reg data=finalT_v2;
	model unitid=comp Learn emp debt;
	output out=finalT_v2H H=h; run; quit;
proc sort data=finalT_v2H out=sort1;
	by h; run;
proc reg data=finalT_v2;
	model unitid=sat Ladm SQsize gend cost aid SQminor;
	output out=finalT_v2H2 H=h; run; quit;
proc sort data=finalT_v2H2 out=sort2;
	by h; run;
data finalT_v3; set finalT_v2;
	if unitid=230728 then delete; 
	if unitid=141565 then delete;
	if unitid=231624 then delete; 
	if unitid=185828 then delete;
	if unitid=178411 then delete;
	if unitid=229179 then delete;
	if unitid=163453 then delete; run;
****************************************************************************;
***** EVALUATING NORMALITY;
proc univariate data=finalT_v3;
	var comp Learn emp debt sat Ladm SQsize gend cost aid SQminor;
	histogram comp Learn emp debt sat Ladm SQsize gend cost aid SQminor /normal;
	title1 'Univariate Normality'; run;
%multnorm(data=finalT_v3,
		  var=comp Learn emp debt sat Ladm SQsize gend cost aid SQminor,
		  plot=no);
****************************************************************************;
***** Listwise Deletion;
data emr6750.final_analysis; set finalT_v3;
	if unitid=105330 then delete;
	if unitid=142276 then delete;
	if unitid=150136 then delete;
	if unitid=151324 then delete;
	if unitid=155399 then delete;
	if unitid=156082 then delete;
	if unitid=166638 then delete;
	if unitid=174020 then delete;
	if unitid=216339 then delete;
	if unitid=221838 then delete;
	if unitid=228796 then delete; run;
proc means data=emr6750.final_analysis maxdec=3 vardef=df
	n nmiss mean std median min max kurt skew;
	var comp earn emp debt sat adm size gend cost aid minor; run;
***** Prelim Canonical Analysis and Visualization;
title1; title2;
proc cancorr data=emr6750.final_analysis red
		vprefix=Student vname='Student Outcomes'
		wprefix=Institution wname='Institutional Factors';
	var comp Learn emp debt; 
	with sat Ladm SQsize gend cost aid SQminor; run;
