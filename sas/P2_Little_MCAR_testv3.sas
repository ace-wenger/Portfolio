/******************************************************************************************************************/
*                                                                                                                  *
*  This SAS macro implements the chi-square test for a missing completely at random (MCAR) mechanism, as           *
*  outlined in Little's (1998) JASA article.  Note that the macro requires SAS version 8.2 (or higher) because     * 
*  PROC MI is used to obtain ML estimates of the covariance matrix and mean vector.                                *                                       *
*                                                                                                                  *
/******************************************************************************************************************/;

%macro mcartest;
*libname emr6750 "Z:\applegab\Documents\MYFiles\Courses\EMR6750\Data";

%let testvars = comp earn emp debt sat adm size gend cost aid minor;


/* SPECIFY THE MISSING VALUE CODE */
%let misscode = .;						                       
		   				      				   
/*******************************/
/* DO NOT ALTER THE CODE BELOW */
/*******************************/

data one;
	set emr6750.final_miss;

%let numvars = %sysfunc(countw(&testvars));

array m[&numvars] &testvars ;
array r[&numvars] r1 - r&numvars ;

do i = 1 to &numvars;
	if m[i] = &misscode then m[i] = .;
end;
drop i;

do i = 1 to &numvars;
	r[i] = 1;
	if m[i] = . then r[i] = 0;
end;
drop i;

proc sort;
	by r1-r&numvars;

proc mi data = one nimpute = 0 noprint;
   	var &testvars;
	em outem = emcov;

proc iml;

use one;
read all var {&testvars} into y;
read all var {%do i = 1 %to &numvars; r&i %end;} into r;
use emcov;
read all var {&testvars} into em;

mu = em[1,];
sigma = em[2:nrow(em),];

/* ASSIGN AN INDEX VARIABLE DENOTING EACH CASE'S PATTERN */

jcol = j(nrow(y), 1 , 1);

do i = 2 to nrow(y);
	rdiff = r[i,] - r[i - 1,];
	if max(rdiff) = 0 & min(rdiff) = 0 then jcol[i,] = jcol[i - 1,];
	else jcol[i,] = jcol[i - 1,] + 1;
end;

/* NUMBER OF DISTINCT MISSING DATA PATTERNS */

j = max(jcol);

/* PUT THE NUMBER OF CASES IN EACH PATTERN IN A COL VECTOR M */
/* PUT THE MISSING DATA INDICATORS FOR EACH PATTERN IN A MATRIX RJ */

m = j(j, 1, 0);
rj = j(j, ncol(r), 0);

do i = 1 to j;									
	count = 0;
		do k = 1 to nrow(y);
			if jcol[k,] = i then do;
				count = count + 1;
			end;
			if jcol[k,] = i & count = 1 then rj[i,] = r[k,];
			m[i,] = count;
		end;
end;

/* COMPUTE D^2 STATISTIC FOR EACH J PATTERN */

d2j = j(j, 1, 0);

do i = 1 to j;

/* OBSERVED VALUES FOR PATTERN J */

yj = y[loc(jcol = i),loc(rj[i,] = 1)];

/* VARIABLE MEANS FOR PATTERN J */

ybarobsj = yj[+,]/nrow(yj);

/* D = P X Pj MATRIX OF INDICATORS (SEE P. 1199) */

Dj = j(ncol(y), rj[i,+], 0);

count = 1;
do k = 1 to ncol(rj);
	if rj[i,k] = 1 then do;
		Dj[k, count] = 1;
		count = count + 1;
	end;
end;

/* REDUCE EM ESTIMATES TO CONTAIN OBSERVED ELEMENTS */

muobsj = mu * Dj;
sigmaobsj = t(Dj) * sigma * Dj;

/* THE CONTRIBUTION TO THE D^2 STATISTIC FOR EACH OF THE J PATTERNS */

d2j[i,] = m[i,] * (ybarobsj - muobsj) * inv(sigmaobsj) * t(ybarobsj - muobsj);

end;

/* THE D^2 STATISTIC */

d2 = d2j[+,];

/* DF FOR D^2 */

df = rj[+,+] - ncol(rj);
p = 1 - probchi(d2,df);

/* PRINT ANALYSIS RESULTS */

file print;
put "Number of Observed Variables = " (ncol(rj)) 3.0;
put "Number of Missing Data Patterns = " (j) 3.0; put;
put "Summary of Missing Data Patterns (0 = Missing, 1 = Observed)"; put;
put "Frequency | Pattern | d2j"; put;
do i = 1 to nrow(rj);
  put (m[i,]) 6.0 "    | " @;
    do j = 1 to ncol(rj);
      put (rj[i,j]) 2.0 @;
  end;
    put " | " (d2j[i,]) 8.6;
end;
put;
put "Sum of the Number of Observed Variables Across Patterns (Sigma psubj) = " (rj[+,+]) 5.0; put;
put "Little's (1988) Chi-Square Test of MCAR"; put;
put "Chi-Square (d2)      = " (d2) 10.3;
put "df (Sigma psubj - p) =    " (df) 7.0;
put "p-value              = " (p) 10.3;

%mend mcartest;
%mcartest;

run;
quit;
