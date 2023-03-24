/***************************************************************************
          %MULTNORM macro:  Mardia Tests of Multivariate Normality
                                Version 1.1

   DISCLAIMER:
     THIS INFORMATION IS PROVIDED BY SAS INSTITUTE INC. AS A SERVICE TO
     ITS USERS.  IT IS PROVIDED "AS IS".  THERE ARE NO WARRANTIES,
     EXPRESSED OR IMPLIED, AS TO MERCHANTABILITY OR FITNESS FOR A
     PARTICULAR PURPOSE REGARDING THE ACCURACY OF THE MATERIALS OR CODE
     CONTAINED HEREIN.

   REQUIRES:
     For multivariate normality tests:  Version 6.06 or later of SAS/IML
       Software or Version 6.09 TS450 or later (except Version 6.10) of
       SAS/ETS Software.  If neither is found, only univariate normality
       tests can be provided.

     For optional plot:  Version 6 or later SAS/STAT Software if SAS/IML
       is not available.  Version 6 or later SAS/GRAPH Software if
       high-resolution plot is desired.

   ABSTRACT:
     The %MULTNORM macro performs tests of multivariate normality based
     on multivariate skewness and kurtosis statistics (Mardia 1974).  A
     test of univariate normality is also given for each of the
     variables.  A chi-square quantile-quantile plot of the
     observations' squared Mahalanobis distances can be obtained
     allowing a visual assessment of multivariate normality.

   USAGE:
     The options and allowable values are:

        DATA=   SAS data set to be analyzed.  If the DATA= option is not
                supplied, the most recently created SAS data set is
                used.

        VAR=    REQUIRED.  The list of variables to use when testing for
                univariate and multivariate normality.  Individual
                variable names, separated by blanks, must be specified.
                Special variable lists may NOT be used (such as
                VAR1-VAR10, ABC--XYZ, _NUMERIC_).

        PLOT=   Requests a chi-square quantile-quantile (Q-Q) plot of
                the squared Mahalanobis distances of observations from
                the mean vector.  PLOT=yes (the default) requests the
                plot.  PLOT=no suppresses the plot.

        HIRES=  Ignored unless PLOT=yes.  HIRES=yes (the default)
                requests that high-resolution graphics (PROC GPLOT) be
                used when creating the plot.  You must set the graphics
                device (GOPTIONS DEVICE=) and any other graphics-related
                options before invoking the macro.  HIRES=no requests
                that the plot be drawn with low-resolution (PROC PLOT).

   PRINTED OUTPUT:
     If the IML procedure is found, a single table titled "Univariate
     and Multivariate Normality Tests" is printed.  If the MODEL
     procedure is found, a table titled "Normality Test" is printed and
     previous output can be ignored.  If neither procedure is found, a
     single table titled "Univariate Normality Tests" is printed.

     For p variables listed in the VAR= option, the first p rows of the
     printed table contain univariate tests of normality, including the
     name of the test (Shapiro-Wilk or Kolmogorov), the value of the
     test statistic and the corresponding p-value.  The next two lines
     of the table contain Mardia's tests of multivariate normality,
     including the name of the test (skewness or kurtosis), the values
     of the multivariate skewness and kurtosis statistics (when IML is 
     used), the values of the test statistics and their p-values.  When 
     the MODEL procedure is used, another test of multivariate normality 
     is performed -- the Henze-Zirkler test.  This test is discussed in 
     the SAS/ETS User's Guide and in the reference below.

     For multivariate normal data, Mardia (1974) shows that the expected
     value of the multivariate skewness statistic is

            p(p+2)[(n+1)(p+1)-6]
            --------------------
                 (n+1)(n+3)

     and the expected value of the multivariate kurtosis statistic is

            p(p+2)(n-1)/(n+1)  .

     If PLOT=yes is specified, a chi-square quantile-quantile plot is
     produced which plots the squared mahalanobis distances against
     corresponding quantiles of the limiting chi-square distribution.
     If the data are distributed as multivariate normal, then the points
     should fall on a straight line with slope one and intercept zero.
     See DETAILS for more information.

   DETAILS:
     If a set of variables is distributed as multivariate normal, then
     each variable must be normally distributed.  However, when all
     individual variables are normally distributed, the set of variables
     may not be distributed as multivariate normal.  Hence, testing each
     variable only for univariate normality is not sufficient.  Mardia
     (1974) proposed tests of multivariate normality based on sample
     measures of multivariate skewness and kurtosis.

     Univariate normality is tested by either the Shapiro-Wilk W test or
     the Kolmogorov-Smirnov test.  For details on the univariate tests
     of normality, refer to "Tests for Normality" in "The UNIVARIATE
     Procedure" chapter in the SAS Procedures Guide.

     If the p-value of any of the tests is small, then multivariate
     normality can be rejected.  However, it is important to note that
     the univariate Shapiro-Wilk W test is a very powerful test and is
     capable of detecting small departures from univariate normality
     with relatively small sample sizes.  This may cause you to reject
     univariate, and therefore multivariate, normality unnecessarily if
     the tests are being done to validate the use of methods that are
     robust to small departures from normality.

     When the data's covariance matrix is singular, the macro quits and
     the following message is issued:

        ERROR: Covariance matrix is singular.

     The PRINCOMP procedure in SAS/STAT Software is required for this
     check.  If it is not found, a message is printed, nonsinularity
     is assumed and the macro attempts to perform the tests.

     For p variables and a large sample size, the squared Mahalanobis
     distances of the observations to the mean vector are distributed as
     chi-square with p degrees of freedom.  However, the sample size
     must be quite large for the chi-square distribution to obtain
     unless p is very small.  Also, this plot is sensitive to the
     presence of outliers.  So, this plot should be cautiously used as a
     rough indicator of multivariate normality.

   MISSING VALUES:
     Observations with missing values are omitted from the analysis and
     plot.

   LIMITATIONS:
     LIMITED ERROR CHECKING is done.  If the DATA= option is specified,
     be sure the named data set exists.  If DATA= is not specified, a
     data set must have been created previously in the current SAS
     session.  Be sure that the variables specified in the VAR= option
     exist on that data set.  Running PROC CONTENTS on the data set
     prior to using this macro is recommended for verifying the data set
     name and the names of variables.  Use the full words 'yes' or 'no'
     on the PLOT= and HIRES= options.

     MEMORY USAGE for the multivariate tests is quadratically related to
     the number of observations.  Moderately large data sets (1000 is
     big) may cause "Unable to allocate sufficient memory" errors.

   REFERENCES:
     Henze, N. and Zirkler, B. (1990),"A Class of Invariant Consistant 
       tests for Multivariate Normality," Commun. Statist.-Theory Meth., 
       19(10), pp. 3595-3617.
     Mardia (1974),"Applications of some measures of multivariate skewness
       and kurtosis in testing normality and robustness studies", Sankhya B,
       36, pp 115-128.
     Mardia (1975),"Assessment of Multinormality and the Robustness of
       Hotelling's T-squared Test", Applied Statistics, 1975, 24(2).
     Mardia, Kent, Bibby (1979),"Multivariate Analysis", Academic Press
     Mardia (1980),"Measures of Multivariate Skewness and Kurtosis with
       Applications", Biometrika 57(3).
     Royston, J.P. (1982), "An Extension of Shapiro and Wilk's W Test
       for Normality to Large Samples," Applied Statistics, 31.
     Shapiro, S.S. and Wilk, M.B. (1965), "An Analysis of Variance Test
       for Normality (complete samples)," Biometrika, 52.

   EXAMPLE:
     The following example is from Mardia, Kent, Bibby (1979, pg 12).
     The multivariate skewness test statistic differs due to the use in
     %MULTNORM of an alternative approximation to the chi-square
     distribution given in Mardia (1974, pg 123).


         data cork;
           input n e s w @@;
           cards;
         72 66 76 77   91 79 100 75
         60 53 66 63   56 68 47 50
         56 57 64 58   79 65 70 61
         41 29 36 38   81 80 68 58
         32 32 35 36   78 55 67 60
         30 35 34 26   46 38 37 38
         39 39 31 27   39 35 34 37
         42 43 31 25   32 30 30 32
         37 40 31 25   60 50 67 54
         33 29 27 36   35 37 48 39
         32 30 34 28   39 36 39 31
         63 45 74 63   50 34 37 40
         54 46 60 52   43 37 39 50
         47 51 52 43   48 54 57 43
         ;

         %multnorm(data=cork,var=n e s w)

****************************************************************************/

%macro multnorm (
       data=_last_ ,    /*            input data set           */
       var=        ,    /* REQUIRED:  variables for test       */
                        /* May NOT be a list e.g. var1-var10   */
       plot=yes    ,    /*            create chi-square plot?  */
       hires=yes        /*            high resolution plot?    */
                );
options nonotes;
%let lastds=&syslast;

/* Verify that VAR= option is specified */
%if &var= %then %do;
    %put ERROR: Specify test variables in the VAR= argument;
    %goto exit;
%end;

/* Parse VAR= list */
%let _i=1;
%do %while (%scan(&var,&_i) ne %str() );
   %let arg&_i=%scan(&var,&_i);
   %let _i=%eval(&_i+1);
%end;
%let nvar=%eval(&_i-1);

/* Remove observations with missing values */
%put MULTNORM: Removing observations with missing values...;
data _nomiss;
  set &data;
  if nmiss(of &var )=0;
  run;

/* Quit if covariance matrix is singular */
%let singular=nonsingular;
%put MULTNORM: Checking for singularity of covariance matrix...;
proc princomp data=_nomiss outstat=_evals noprint;
  var &var ;
  run;
%if &syserr=3000 %then %do;
  %put MULTNORM: PROC PRINCOMP required for singularity check.;
  %put %str(          Covariance matrix not checked for singularity.);
  %goto findproc;
%end;
data _null_;
  set _evals;
  where _TYPE_='EIGENVAL';
  if round(min(of &var ),1e-8)<=0 then do;
    put 'ERROR: Covariance matrix is singular.';
    call symput('singular','singular');
  end;
  run;
%if &singular=singular %then %goto exit;

%findproc:
/* Is IML or MODEL available for analysis? */
%let mult=yes; %let multtext=%str( and Multivariate);
%put MULTNORM: Checking for necessary procedures...;
proc iml; quit;
%if &syserr=0 %then %goto iml;
proc model; quit;
%if &syserr=0 and
    (%substr(&sysvlong,1,9)>=6.09.0450 and %substr(&sysvlong,3,2) ne 10)
    %then %goto model;
%put MULTNORM: SAS/ETS PROC MODEL with NORMAL option or SAS/IML is required;
%put %str(          to perform tests of multivariate normality.  Univariate);
%put %str(          normality tests will be done.);
%let mult=no; %let multtext=;
%goto univar;


%iml:
proc iml;
  reset;
  use _nomiss;  read all var {&var} into _x;   /* input data */

  /* compute mahalanobis distances */
  _n=nrow(_x); _p=ncol(_x);
  _c=_x-j(_n,1)*_x[:,];         /* centered variables    */
  _s=(_c`*_c)/_n;               /* covariance matrix     */
  _rij=_c*inv(_s)*_c`;          /* mahalanobis angles    */

  /* get values for probability plot and output to data set */
  %if &plot=yes %then %do;
  _d=vecdiag(_rij#(_n-1)/_n);   /* squared mahalanobis distances */
  _rank=ranktie(_d);            /* ranks of distances    */
  _chi=cinv((_rank-.5)/_n,_p);  /* chi-square quantiles  */
  _chiplot=_d||_chi;
  create _chiplot from _chiplot [colname={'MAHDIST' 'CHISQ'}];
  append from _chiplot;
  %end;

  /* Mardia tests based on multivariate skewness and kurtosis */
  _b1p=(_rij##3)[+,+]/(_n##2);                    /* skewness */
  _b2p=trace(_rij##2)/_n;                         /* kurtosis */
  _k=(_p+1)#(_n+1)#(_n+3)/(_n#((_n+1)#(_p+1)-6)); /* small sample correction */
  _b1pchi=_b1p#_n#_k/6;                           /* skewness test statistic */
  _b1pdf=_p#(_p+1)#(_p+2)/6;                      /*   and df                */
  _b2pnorm=(_b2p-_p#(_p+2))/sqrt(8#_p#(_p+2)/_n); /* kurtosis test statistic */
  _probb1p=1-probchi(_b1pchi,_b1pdf);             /* skewness p-value */
  _probb2p=2*(1-probnorm(abs(_b2pnorm)));         /* kurtosis p-value */

  /* output results to data sets */
  _names={"Mardia Skewness","Mardia Kurtosis"};
  create _names from _names [colname='TEST'];
  append from _names;
  _probs=(_n||_b1p||_b1pchi||_probb1p) // (_n||_b2p||_b2pnorm||_probb2p);
  create _values from _probs [colname={'N' 'VALUE' 'STAT' 'PROB'}];
  append from _probs;
quit;

data _mult;
  merge _names _values;
  run;


%univar:
/* get univariate test results */
proc univariate data=_nomiss noprint;
  var &var;
  output out=_stat normal=&var ;
  output out=_prob  probn=&var ;
  output out=_n         n=&var ;
  run;

data _univ;
  set _stat _prob _n;
  run;

proc transpose data=_univ name=variable
               out=_tuniv(rename=(col1=stat col2=prob col3=n));
   var &var ;
   run;

data _both;
  length test $15.;
  set _tuniv
      %if &mult=yes %then _mult;;
  if test='' then if n<=2000 then test='Shapiro-Wilk';
                  else test='Kolmogorov';
  run;

proc print data=_both noobs split='/';
  var variable n test      %if &mult=yes %then value;
      stat prob;
  format prob pvalue.;
  title "MULTNORM macro: Univariate&multtext Normality Tests";
  label variable="Variable"
            test="Test"       %if &mult=yes %then
           value="Multivariate/Skewness &/Kurtosis";
            stat="Test/Statistic/Value"
            prob="p-value";
  run;
%if &plot=yes %then
   %if &mult=yes %then %goto plotstep;
   %else %goto plot;
%else %goto exit;


%model:
/* Multivariate and Univariate tests with MODEL */
proc model data=_nomiss;
  %do _i=1 %to &nvar;
    &&arg&_i = _a;
  %end;
  fit &var / normal;
  title "MULTNORM macro: Univariate&multtext Normality Tests";
  run;
%if &plot ne yes %then %goto exit;


%plot:
/* compute values for chi-square Q-Q plot */
proc princomp data=_nomiss std out=_chiplot noprint;
  var &var ;
  run;
%if &syserr=3000 %then %do;
  %put ERROR: PROC PRINCOMP in SAS/STAT needed to do plot.;
  %goto exit;
%end;
data _chiplot;
  set _chiplot;
  mahdist=uss(of prin1-prin&nvar );
  keep mahdist;
  run;
proc rank data=_chiplot out=_chiplot;
  var mahdist;
  ranks rdist;
  run;
data _chiplot;
  set _chiplot nobs=_n;
  chisq=cinv((rdist-.5)/_n,&nvar);
  keep mahdist chisq;
  run;


%plotstep:
/* Create a chi-square Q-Q plot
   NOTE: Very large sample size is required for chi-square asymptotics
   unless the number of variables is very small.
*/
%if &hires=yes %then proc gplot data=_chiplot;
%else                proc  plot data=_chiplot;;
   plot mahdist*chisq;
   label mahdist="Squared Distance"
           chisq="Chi-square quantile";
   title "MULTNORM macro: Chi-square Q-Q plot";
   run;
   quit;
%if &syserr=3000 %then %do;
   %put MULTNORM: PROC PLOT will be used instead.;
   %let hires=no;
   %goto plotstep;
%end;


%exit:
options notes _last_=&lastds;
title;
%mend;

