clear
clear matrix 
clear mata
cap log close 
set maxvar 6000
set matsize 6000

if c(username)=="samanthacohen"	{		//	Sam working directory
gl PML "/Users/samanthacohen/2016_2017_KU_Leuven/Thesis/Tanzania/Data"	
gl latex "/Users/samanthacohen/2016_2017_KU_Leuven/Thesis/Tanzania/Writing/Paper Latex/graphs"	
	version 13.1
	}	
	
cd "$PML"

log using results.log, replace




**************************************************************************
*****************************Data Exploration*****************************
**************************************************************************


**********************************************
***** Counting number of migrants tables ******
***********************************************
use "$PML/TNPS Data/Panel_long.dta"
tab migrate2008_

**SURVEY TOTAL
**rural-urban migrants count
sum migrate2008_ if migrate2008==2


**rural-rural migrants count
sum migrate2008_ if migrate2008==1

**urban non-migrants
sum migrate2008_ if migrate2008_==4

**rural non-migrants
sum migrate2008_ if migrate2008_==3 //same rural

**counting for HHFE / ANALYTICAL SAMPLE
use "$PML/TNPS Data/Panel_longHHFE.dta", clear

drop if expPHHlog__D==.
drop if BMIadult_D==.
drop if satisf_health__D==.
drop if satisf_fin__D==.
drop if satisf_hous__D==.
drop if satisf_job__D==.
drop if satisf_life__D==.

**rural-urban migrants count
sum rural_urbanHHFE if rural_urbanHHFE==1

**rural-rural migrants count
sum rural_ruralHHFE if rural_ruralHHFE==1

sum same_ruralHHFE if same_ruralHHFE==1


clear

*****************************
/* differences in means for consumption
*/
*****************************
use "$PML/TNPS Data/Panel_longHHFE.dta", clear

drop if expPHHlog__D==.
drop if BMIadult_D==.
drop if satisf_health__D==.
drop if satisf_fin__D==.
drop if satisf_hous__D==.
drop if satisf_job__D==.
drop if satisf_life__D==.

**Rural urban
summarize expPHH if rural_urbanHHFE == 0
summarize expPHH if same_ruralHHFE == 1
ttest expPHH, by(rural_urbanHHFE) unequal
ttest expPHH, by (same_ruralHHFE) unequal
ttest expPHH, by (rural_ruralHHFE) unequal


*****************************
/* differences in means for health
*/
*****************************
summarize BMIadult if rural_urbanHHFE == 0
summarize BMIadult if rural_urbanHHFE == 1
ttest BMIadult, by(rural_urbanHHFE) unequal
ttest BMIadult, by(rural_ruralHHFE) unequal
ttest BMIadult, by(same_ruralHHFE) unequal

*****************************
/* differences in means for happiness
*/
*****************************

summarize satisf_life_ if rural_urbanHHFE == 0
summarize satisf_life_ if rural_urbanHHFE == 1
ttest satisf_life_, by(rural_urbanHHFE) unequal
ttest satisf_life_, by(rural_rural) unequal
ttest satisf_life_, by(same_ruralHHFE) unequal


**and other four happiness measures for appendix**

*health
summarize satisf_health_ if rural_urbanHHFE == 0
summarize satisf_health_ if rural_urbanHHFE == 1
ttest satisf_health_, by(rural_urbanHHFE) unequal
ttest satisf_health_, by(rural_ruralHHFE) unequal
ttest satisf_health_, by(same_ruralHHFE) unequal

*Finance
summarize satisf_fin_ if rural_urbanHHFE == 0
summarize satisf_fin_ if rural_urbanHHFE == 1
ttest satisf_fin_, by(rural_urbanHHFE) unequal
ttest satisf_fin_, by(rural_ruralHHFE) unequal
ttest satisf_fin_, by(same_ruralHHFE) unequal


**house
summarize satisf_hous_ if rural_urbanHHFE == 0
summarize satisf_hous_ if rural_urbanHHFE == 1
ttest satisf_hous_, by(rural_urbanHHFE) unequal
ttest satisf_hous_, by(rural_ruralHHFE) unequal
ttest satisf_hous_, by(same_ruralHHFE) unequal


**job
summarize satisf_job_ if rural_urbanHHFE == 0
summarize satisf_job_ if rural_urbanHHFE == 1
ttest satisf_job_, by(rural_urbanHHFE) unequal
ttest satisf_job_, by(rural_ruralHHFE) unequal
ttest satisf_job_, by(same_ruralHHFE) unequal

*****************************
/* differences in means for BASELINE control variables
*/
*****************************

gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008 "
gl migrvars "rural_urbanHHFE rural_ruralHHFE same_ruralHHFE"

foreach x in $con_varsHHFE {
ttest `x', by(rural_urbanHHFE) unequal
	
}

foreach x in $con_varsHHFE {
ttest `x', by(rural_ruralHHFE) unequal
	
}

foreach x in $con_varsHHFE {
ttest `x', by(same_ruralHHFE) unequal
	
}


clear

**************************************************************************
*******************************Analysis********************
**************************************************************************
*********************************
/*Diff in Diff w FE
*/	
*********************************

use "$PML/TNPS Data/Panel_longHHFE.dta", clear

**FOR attrition analysis
gen sample_at=1
** replace the variable by zero if an observation of a dependent variable is missing
replace sample_at=0 if expPHHlog_==.
replace sample_at=0 if BMIadult==.
replace sample_at=0 if satisf_life_==.
replace sample_at=0 if satisf_job_==.
replace sample_at=0 if satisf_hous_==.
replace sample_at=0 if satisf_health_==.
replace sample_at=0 if satisf_fin_==.

**generate sample_at to be 2 if the individual was recorded for both years and 0 otherwise
bysort UPI3 : egen nsample = sum(sample_at)
replace sample_at=0 if nsample!=2

** model the probability of being in the sample
probit sample_at sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008, vce(robust) //, if year==2008
predict double score 
**calculate the probability of dropping out (attrition)
gen weight=1/score
bysort UPI3 : egen attritionweight = max(weight)

**use only those individuals for whom you have observations for all dependent variables.
drop if expPHHlog__D==.
drop if BMIadult_D==.
drop if satisf_health__D==.
drop if satisf_fin__D==.
drop if satisf_hous__D==.
drop if satisf_job__D==.
drop if satisf_life__D==.

****************************************************
**not including attrition weights

**calculate the baseline averages for dependent vars**
gl dep_varsBaseline "expPHH_2008 expPHHlog__2008 BMIadult_2008 satisf_life__2008 satisf_health__2008 satisf_fin__2008 satisf_hous__2008 satisf_job__2008" 

foreach x in $dep_varsBaseline {
	summarize `x'
}


**diff in diff**
gl dep_varsHHFE "expPHHlog__D BMIadult_D satisf_life__D satisf_health__D satisf_fin__D satisf_hous__D satisf_job__D" 
//gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs MaternalEdu__2008 married unemployed_2008 employagr_2008"
gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008 "
//gl con_varsHHFE "age__2008 agesqr_2008 edu_yrs_2008 married_2008 employagr_2008 HHhead_child_2008"

eststo clear


foreach x in $dep_varsHHFE {
areg `x' rural_ruralHHFE rural_urbanHHFE $con_varsHHFE, vce(robust) absorb(y1_hhid)
	est sto DiD_`x'
	test rural_ruralHHFE rural_urbanHHFE
}


esttab DiD_satisf_life__D DiD_satisf_health__D DiD_satisf_fin__D DiD_satisf_hous__D DiD_satisf_job__D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))
esttab DiD_expPHHlog__D DiD_BMIadult_D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))


*******************************
********ROBUSTNESS CHECK*******
*******************************

****************************************************
**Regression including attrition weights
gl dep_varsHHFE "expPHHlog__D BMIadult_D satisf_life__D satisf_health__D satisf_fin__D satisf_hous__D satisf_job__D" 
//gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs MaternalEdu__2008 married unemployed_2008 employagr_2008"
gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008 "
//gl con_varsHHFE "age__2008 agesqr_2008 edu_yrs_2008 married_2008 employagr_2008 HHhead_child_2008"

eststo clear

foreach x in $dep_varsHHFE {
areg `x' rural_ruralHHFE rural_urbanHHFE $con_varsHHFE [pw=attritionweight], vce(robust) absorb(y1_hhid)
	est sto DiD_`x'
	test rural_ruralHHFE rural_urbanHHFE
}

esttab DiD_satisf_life__D DiD_satisf_health__D DiD_satisf_fin__D DiD_satisf_hous__D DiD_satisf_job__D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))
esttab DiD_expPHHlog__D DiD_BMIadult_D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))
clear
****************************************************
**Comparing migrants who have BASELINE lower happiness levels those w/ baseline higher levels**
use "$PML/TNPS Data/Panel_longHHFE.dta", clear

**FOR attrition analysis
gen sample_at=1
** replace the variable by zero if an observation of a dependent variable is missing
replace sample_at=0 if expPHHlog_==.
replace sample_at=0 if BMIadult==.
replace sample_at=0 if satisf_life_==.
replace sample_at=0 if satisf_job_==.
replace sample_at=0 if satisf_hous_==.
replace sample_at=0 if satisf_health_==.
replace sample_at=0 if satisf_fin_==.

**generate sample_at to be 2 if the individual was recorded for both years and 0 otherwise
bysort UPI3 : egen nsample = sum(sample_at)
replace sample_at=0 if nsample!=2

** model the probability of being in the sample
probit sample_at sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008, vce(robust) //, if year==2008
predict double score 
**calculate the probability of dropping out (attrition)
gen weight=1/score
bysort UPI3 : egen attritionweight = max(weight)

**use only those individuals for whom you have observations for all dependent variables.
drop if expPHHlog__D==.
drop if BMIadult_D==.
drop if satisf_health__D==.
drop if satisf_fin__D==.
drop if satisf_hous__D==.
drop if satisf_job__D==.
drop if satisf_life__D==.

**baseline satisfaction High sample

*drop if they are satisfaction low ppl
drop if satisf_life_LH_2008==0

**baseline averages for dependent vars**

gl dep_varsBaseline "expPHH_2008 expPHHlog__2008 BMIadult_2008 satisf_life__2008 satisf_health__2008 satisf_fin__2008 satisf_hous__2008 satisf_job__2008" 


foreach x in $dep_varsBaseline {
	summarize `x'
}

**
gl dep_varsHHFE "expPHHlog__D BMIadult_D satisf_life__D satisf_health__D satisf_fin__D satisf_hous__D satisf_job__D" 
//gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs MaternalEdu__2008 married unemployed_2008 employagr_2008"
gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008"
//gl con_varsHHFE "age__2008 agesqr_2008 edu_yrs_2008 married_2008 employagr_2008 HHhead_child_2008"

eststo clear

foreach x in $dep_varsHHFE {
areg `x' rural_ruralHHFE rural_urbanHHFE $con_varsHHFE [pw=attritionweight], vce(robust) absorb(y1_hhid)
	est sto DiD_`x'
	test rural_ruralHHFE rural_urbanHHFE
}

esttab DiD_satisf_life__D DiD_satisf_health__D DiD_satisf_fin__D DiD_satisf_hous__D DiD_satisf_job__D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))
esttab DiD_expPHHlog__D DiD_BMIadult_D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))

clear
**baseline satisfaction low sample
use "$PML/TNPS Data/Panel_longHHFE.dta", clear

**FOR attrition analysis
gen sample_at=1
** replace the variable by zero if an observation of a dependent variable is missing
replace sample_at=0 if expPHHlog_==.
replace sample_at=0 if BMIadult==.
replace sample_at=0 if satisf_life_==.
replace sample_at=0 if satisf_job_==.
replace sample_at=0 if satisf_hous_==.
replace sample_at=0 if satisf_health_==.
replace sample_at=0 if satisf_fin_==.

**generate sample_at to be 2 if the individual was recorded for both years and 0 otherwise
bysort UPI3 : egen nsample = sum(sample_at)
replace sample_at=0 if nsample!=2

** model the probability of being in the sample
probit sample_at sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008, vce(robust) //, if year==2008
predict double score 
**calculate the probability of dropping out (attrition)
gen weight=1/score
bysort UPI3 : egen attritionweight = max(weight)

**use only those individuals for whom you have observations for all dependent variables.
drop if expPHHlog__D==.
drop if BMIadult_D==.
drop if satisf_health__D==.
drop if satisf_fin__D==.
drop if satisf_hous__D==.
drop if satisf_job__D==.
drop if satisf_life__D==.

**drop if they are satifaction low people
drop if satisf_life_LH_2008==1

**baseline means for dep vars
gl dep_varsBaseline "expPHH_2008 expPHHlog__2008 BMIadult_2008 satisf_life__2008 satisf_health__2008 satisf_fin__2008 satisf_hous__2008 satisf_job__2008" 


foreach x in $dep_varsBaseline {
	summarize `x'
}

**
gl dep_varsHHFE "expPHHlog__D BMIadult_D satisf_life__D satisf_health__D satisf_fin__D satisf_hous__D satisf_job__D" 
//gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs MaternalEdu__2008 married unemployed_2008 employagr_2008"
gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008"
//gl con_varsHHFE "age__2008 agesqr_2008 edu_yrs_2008 married_2008 employagr_2008 HHhead_child_2008"

eststo clear

foreach x in $dep_varsHHFE {
areg `x' rural_ruralHHFE rural_urbanHHFE $con_varsHHFE [pw=attritionweight], vce(robust) absorb(y1_hhid)
	est sto DiD_`x'
	test rural_ruralHHFE rural_urbanHHFE
}

esttab DiD_satisf_life__D DiD_satisf_health__D DiD_satisf_fin__D DiD_satisf_hous__D DiD_satisf_job__D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))
esttab DiD_expPHHlog__D DiD_BMIadult_D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))



****************************************************
**Differentiating between secondary and big cities**
clear

use "$PML/TNPS Data/Panel_longHHFE.dta", clear

**FOR attrition analysis
gen sample_at=1
** replace the variable by zero if an observation of a dependent variable is missing
replace sample_at=0 if expPHHlog_==.
replace sample_at=0 if BMIadult==.
replace sample_at=0 if satisf_life_==.
replace sample_at=0 if satisf_job_==.
replace sample_at=0 if satisf_hous_==.
replace sample_at=0 if satisf_health_==.
replace sample_at=0 if satisf_fin_==.

**generate sample_at to be 2 if the individual was recorded for both years and 0 otherwise
bysort UPI3 : egen nsample = sum(sample_at)
replace sample_at=0 if nsample!=2

** model the probability of being in the sample
probit sample_at sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008, vce(robust) //, if year==2008
predict double score 
**calculate the probability of dropping out (attrition)
gen weight=1/score
bysort UPI3 : egen attritionweight = max(weight)

**use only those individuals for whom you have observations for all dependent variables.
drop if expPHHlog__D==.
drop if BMIadult_D==.
drop if satisf_health__D==.
drop if satisf_fin__D==.
drop if satisf_hous__D==.
drop if satisf_job__D==.
drop if satisf_life__D==.

**Baseline means for outcome vars
gl dep_varsBaseline "expPHH_2008 expPHHlog__2008 BMIadult_2008 satisf_life__2008 satisf_health__2008 satisf_fin__2008 satisf_hous__2008 satisf_job__2008" 

foreach x in $dep_varsBaseline {
	summarize `x'
}


**diff in diff
gl dep_varsHHFE "expPHHlog__D BMIadult_D satisf_life__D satisf_health__D satisf_fin__D satisf_hous__D satisf_job__D" 
//gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs MaternalEdu__2008 married unemployed_2008 employagr_2008"
gl con_varsHHFE "sex_2008 age__2008 agesqr_2008 edu_yrs_2008 married_2008 unemployed_2008 employagr_2008 HHhead_child_2008 HHhead_spouse_2008 "
//gl con_varsHHFE "age__2008 agesqr_2008 edu_yrs_2008 married_2008 employagr_2008 HHhead_child_2008"

eststo clear

foreach x in $dep_varsHHFE {
areg `x' rural_rurHHFE rural_urb1HHFE rural_urb2HHFE $con_varsHHFE [pw=attritionweight], vce(robust) absorb(y1_hhid)
	est sto DiD_`x'
	test rural_rurHHFE rural_urb1HHFE 
	test rural_rurHHFE rural_urb2HHFE
	test rural_urb1HHFE rural_urb2HHFE
}

esttab DiD_satisf_life__D DiD_satisf_health__D DiD_satisf_fin__D DiD_satisf_hous__D DiD_satisf_job__D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))
esttab DiD_expPHHlog__D DiD_BMIadult_D, cells(b(star fmt(2) label(Coef.)) ///
se(par fmt(2) label(std.errors)))starlevels( + 0.15 * 0.10 ** 0.05 *** 0.010 ) stats(N r2 ar2, labels ("No. of Obs.""R-Squared") fmt(2))







