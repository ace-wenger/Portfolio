****************************************************************************;
***** written by Aaron Wenger
***** written 12-7-21 last updated 12-14-21
*****	
*****	EMR6750 - Final Project
*****		Data Processing
****************************************************************************;
libname emr6750 "C:\Users\aw647\Documents\GSchoolCourses_GsCs\GsCs_21.9_MultivarStats_Mv\GsCsMv_Data";
****************************************************************************;
****	variable categories are indicated in data steps
****		ID and data limiters
****		student outcomes
****		institutional characteristics
****		additional descriptors for interpretation
****************************************************************************;
proc contents data=emr6750.Most_Recent_Cohorts_All_Data_El; run;
proc freq data=emr6750.Most_Recent_Cohorts_All_Data_El; 
	table ccbasic control main; run;
****Selecting variables and Observiations;
data temp; set emr6750.Most_Recent_Cohorts_All_Data_El (keep=
unitid 				instnm			control			ccbasic			main	
c150_4				count_nwne_3yr	count_wne_3yr	cntover150_3yr	grad_debt_mdn		
sat_avg				adm_rate		ug12mn			ugds_white		ugds_black		
	ugds_hisp		ugds_asian		ugds_men		costt4_a		ftftpctfloan		
stabbr				region			d150_4			comp_orig_yr6_rt);

if control=1;
if strip(upcase(ccbasic))="NULL" then ccbasic=".";
	carnegie=input(ccbasic,8.);
if 14<carnegie<18;
if main=1; run;
****Recoding;
data temp2; set temp;
if strip(upcase(c150_4))="NULL" then c150_4=".";
	comp=input(c150_4,8.);
if strip(upcase(cntover150_3yr))="NULL" then cntover150_3yr=".";
	earn_count=input(cntover150_3yr,8.);
if strip(upcase(count_nwne_3yr))="NULL" then count_nwne_3yr=".";
	unemp_raw=input(count_nwne_3yr,8.);
if strip(upcase(count_wne_3yr))="NULL" then count_wne_3yr=".";
	emp_raw=input(count_wne_3yr,8.);
if strip(upcase(grad_debt_mdn))="PRIVACYSUPPRESSED" then grad_debt_mdn=".";
if strip(upcase(grad_debt_mdn))="NULL" then grad_debt_mdn=".";
	debt=input(grad_debt_mdn,8.);

if strip(upcase(ugds))="NULL" then ugds=".";
	ugds=input(ugds,8.);
if strip(upcase(sat_avg))="NULL" then sat_avg=".";
	sat=input(sat_avg,8.);
if strip(upcase(adm_rate))="NULL" then adm_rate=".";
	adm=adm_rate;
if strip(upcase(ug12mn))="NULL" then ug12mn=".";
	size=input(ug12mn,8.);
if strip(upcase(ugds_white))="NULL" then ugds_white=".";
	race_wh=input(ugds_white,8.);
if strip(upcase(ugds_black))="NULL" then ugds_black=".";
	race_bl=input(ugds_black,8.);
if strip(upcase(ugds_hisp))="NULL" then ugds_hisp=".";
	race_hi=input(ugds_hisp,8.);
if strip(upcase(ugds_asian))="NULL" then ugds_asian=".";
	race_as=input(ugds_asian,8.);
if strip(upcase(ugds_men))="NULL" then ugds_men=".";
	gend=input(ugds_men,8.);
if strip(upcase(costt4_a))="NULL" then costt4_a=".";
	cost=input(costt4_a,8.);
if strip(upcase(ftftpctfloan))="NULL" then ftftpctfloan=".";
	aid=input(ftftpctfloan,8.);

if strip(upcase(comp_orig_yr6_rt))="NULL" then comp_orig_yr6_rt=".";
if strip(upcase(comp_orig_yr6_rt))="PRIVACYSUPPRESSED" then comp_orig_yr6_rt=".";
	des_corig=input(comp_orig_yr6_rt,8.);
if strip(upcase(d150_4))="NULL" then d150_4=".";
	des_cden=input(d150_4,8.);
run;
****Create New Variables;
data temp3; set temp2;
	minor=1-race_wh;
	emp=emp_raw/(emp_raw+unemp_raw);
	earn=earn_count/(emp_raw+unemp_raw);
run;
****Dropping original variables;
data temp4; set temp3 (drop=
control			ccbasic			main			
c150_4			count_nwne_3yr	count_wne_3yr	cntover150_3yr	grad_debt_mdn	
	emp_raw		unemp_raw		earn_count
sat_avg			adm_rate		ug12mn			ugds_white		ugds_black		
	ugds_hisp	ugds_asian		ugds_men		ugds			costt4_a		
	ftftpctfloan
d150_4			comp_orig_yr6_rt);
run;
****************************************************************************;
***** INSPECTING DATA;
***** Descriptives;
proc means data=temp4 maxdec=3 vardef=df
	n nmiss mean std median min max kurt skew;
	var comp earn emp debt sat adm size gend cost aid minor; run;
proc corr data=temp4 nosimple noprob plots=scatter; 
	var comp earn emp debt sat adm size gend cost aid minor; run;
proc univariate data=temp4;
	var comp earn emp debt sat adm size gend cost aid minor;
	histogram comp earn emp debt sat adm size gend cost aid minor /normal;
	title1 'Univariate Normality'; run;
***** Missing Data;
data temp4_miss; set temp4
	(keep=comp earn emp debt sat adm size gend cost aid minor);
	CaseVar_N=n(comp, earn, emp, debt, sat, adm, size, gend, cost, aid, minor);
	CaseVar_Nmiss=nmiss(comp, earn, emp, debt, sat, adm, size, gend, cost, aid, minor); run;
proc freq data=temp4_miss;
	tables comp earn emp debt sat adm size gend cost aid minor;
	title1 "look at each variable";
	run;
proc freq data=temp4_miss;
	tables CaseVar_N CaseVar_Nmiss;
	title1 "look at OVERALL Missingness summary";
	run;
proc means data=temp4_miss n nmiss;
	var comp earn emp debt sat adm size gend cost aid minor;
	run;
***** Delete out of population cases;
data emr6750.final; set temp4;
	if unitid=200697 then delete; 
	if unitid=190576 then delete; run;
