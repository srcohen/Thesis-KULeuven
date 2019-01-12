********************************************************************************
clear 
set more off 
set matsize 11000
		
if c(username)=="samanthacohen"	{		//	Sam working directory
gl PML "/Users/samanthacohen/2016_2017_KU_Leuven/Thesis/Tanzania/Data"		
	version 13.1
	}	
	
cd "$PML"

**first: create cleaned data of "$PML/TNPS Data/2010-2011/HH_SEC_G.dta" with dropped duplicate**

use "$PML/TNPS Data/2010-2011/HH_SEC_G.dta", clear
//isid y2_hhid
//isid indidy2
duplicates list
drop if _n == 15195
save "$PML/2010-2011_HH_SEC_G_clean.dta", replace //i did not edit the original document, just saved it in a different folder, but i now updated the name to include "clean"  so that there is no question. 


use "$PML/TNPS Data/2012-2013/NPSY3.PANEL.KEY.dta", clear //we are using the already given file
														// that allows you to connect individuals
														//and hh throughout the different rounds.


*******************************2012/13 HH Information***************************
//Here, we merge the HH_SEC_A data with the y3_hhid from the initial file 'NPSY3'
merge m:1 y3_hhid using "$PML/TNPS Data/2012-2013/HH_SEC_A.dta" // merge m:1 = Many-to-one merge on specified key variables
//using many to one because $PML/TNPS Data/2012-2013/HH_SEC_A.dta is at the household level and 
//$PML/TNPS Data/2012-2013/NPSY3.PANEL.KEY.dta is at the individual level (m:1, m is the file that we 
//are using ($PML/TNPS Data/2012-2013/NPSY3.PANEL.KEY.dta) and 1 is the file that we are merging to 
//the first one. 

/*HH_SEC_A data has Household location variables, unique within panel round household
identification variables, date and time of interview, analytic weights, cluster identification,
sampling strata identification, enumerator identification,
supervisor identification, and data entry clerk identification. */

// Clean up 13 households in 12 EAs with urban/rural discreprancies
replace y3_rural=0 if y3_hhid=="1625-001" 
replace y3_rural=1 if y3_hhid=="2092-001"
replace y3_rural=1 if y3_hhid=="2845-001"
replace y3_rural=1 if y3_hhid=="2925-001"
replace y3_rural=1 if y3_hhid=="3477-003"
replace y3_rural=0 if y3_hhid=="3490-004"
replace y3_rural=0 if y3_hhid=="3488-004"
replace y3_rural=1 if y3_hhid=="3552-001"
replace y3_rural=1 if y3_hhid=="0785-001"
replace y3_rural=0 if y3_hhid=="3723-004"
replace y3_rural=1 if y3_hhid=="3688-001"
replace y3_rural=1 if y3_hhid=="3863-003"
replace y3_rural=1 if y3_hhid=="3902-110"

rename hh_a01_1 region2012 
rename hh_a02_1 district2012
rename hh_a03_1 ward2012
rename hh_a04_1 ea2012
rename hh_a10 Original2012

gen location2012 = "In same/closeby (-1h) location" if hh_a11==1 | hh_a11==2 //if household 
//location is in "the same location=1" or "local tracking=2"

replace location2012 = "In different location" if hh_a11==3 //if household location is in
// "distance tracking=3"

encode location2012, gen(Location2012) //transform string variable to numeric variable 
drop location2012 hh_a11

gen rural = "rural" if y3_rural==1 & !missing(y3_rural) //generate a new variable with name
// rural if the individual is 'rural=1' and if the observation is NOT missing --> missing 
//observations stay unchanged (unobserved)

replace rural = "urban" if y3_rural== 0  & !missing(y3_rural) //generate a new variable with
// name urban the individual is 'urban=0' and if the observation is NOT missing

encode rural, gen(rural2012) //transform string variable to numeric variable

keep UPI3 y1_hhid indidy1 y2_hhid indidy2 y3_hhid indidy3 region2012 district2012 ward2012 ea2012 Original2012 Location2012 rural2012
//keep the variables of interest and drop the others. 

*****************************2010/11 HH Information**************************
merge m:1 y2_hhid using "$PML/TNPS Data/2010-2011/HH_SEC_A.dta" //merge with the y2_hhid from 
//the initial file 'NPSY3' 
/*This file includes variables describing: household identifier variables, weights, 
cluster identification, strata identification, 2008/2009 household id, enumerator, supervisor, 
data entry clerk identifiers, and date and time of interview */


rename ea ea2010
rename district district2010
rename ward ward2010
rename region region2010

gen original2010 = "Splitoff Household" if hh_a11==3 //if household location is 
//in "distance tracking=3" --> before 2012;13, the migrant had already moved once
/*Recall, hh_a11 is a value 1, 2, or 3. 1=same location, 2=local tracking, 
3= distance tracking. */

replace original2010="Original Household" if hh_a11==1 | hh_a11==2 //if household location
// is in "the same location=1" or "local tracking=2" --> make a variable that 
//tells us if the migrant had moved before 2012;13, 

encode original2010, gen(Original2010) //transform string variable to numeric variable
drop original2010

gen location2010 = "In same location" if hh_a11==1  //variable for non-migrants (at the HH level)
replace location2010 = "In different location" if hh_a11==2 //variable for migrants (@ HH level)
encode location2010, gen(Location2010) //transform string variable to numeric variable

gen rural = "rural" if y2_rural==1 & !missing(y2_rural) //generate a new variable with name
// rural if the individual is 'rural=1' and if the observation is NOT missing --> missing 
//observations stay unchanged (unobserved)
replace rural = "urban" if y2_rural== 0  & !missing(y2_rural) //generate a new variable with
// name urban the individual is 'urban=0' and if the observation is NOT missing
encode rural, gen(rural2010) //transorm string variable to numeric variable
drop rural //CELINE SHOWED ME THAT IF WE DON'T DROP RURAL HERE THEN IN THE NEXT SECTION WHEN WE TRY TO GENERATE RURAL 2008 IT WILL BE THE SAME AS RURAL 2010 BECAUSE RURAL WILL REFER TO THE 2010 VALUES
keep UPI3 y1_hhid indidy1 y2_hhid indidy2 y3_hhid indidy3 region* district* ward* ea* Original* Location* rural* //Keep all variables that we want and drop the others 

*****************************2008/09 HH Information****************************
rename y1_hhid hhid //Need to rename because not same name in the 2008;09 file
merge m:1 hhid using "$PML/TNPS Data/2008-2009/SEC_A_T.dta" //merge with the y1_hhid from the initial file 'NPSY3'
rename hhid y1_hhid 

encode rural, gen(rural2008) //not same because only the 2008;09 file is not a numeric variable
drop rural

rename ea ea2008
rename region region2008
rename district district2008
rename ward ward2008
label var thhmem "Household size 2008"

keep UPI3 y1_hhid indidy1 y2_hhid indidy2 y3_hhid indidy3 region* district* ward* ea* Original* Location* rural* thhmem


******************************************************************************************************
***************************** Migration Variable (rural/urban/DSM)************************************

//recall Location2012 is describing whether or not the observation is in the same location (=2) or different location (=1)
gen str Migrate2008_2012= "Same-Urban" if Location2012==2 & Location2010!=1 &!missing(indidy1) & rural2008==2
 //if the observation is in the same/local tracking location in 2012, in the same location in 2010, his value is not missing and is the same urban location in 2008
 
replace Migrate2008_2012= "Same-Rural" if Location2012==2 & Location2010!=1 &!missing(indidy1) & rural2008==1 
//if the observation is in the same/local tracking location in 2012, in the same location in 2010, his value is not missing and is rural in 2008

replace Migrate2008_2012="Urban-urban" if Location2012==1 &!missing(indidy1) & rural2008==2 & rural2012==2 | Location2012==2 & Location2010==1 &!missing(indidy1) & rural2008==2 & rural2012==2  
//if the observation is in a different location in 2012 and is not missing, the observation was urban in 2008, the observation was urban in 2012, 
//OR the observation was in the same location in 2012, different location in 2010 and not missing, and was urban in 2008 and urban 2012
//So basically, the observation is a migrant but the observation migrated between urban areas. 

replace Migrate2008_2012="Urban-rural" if Location2012==1 &!missing(indidy1) & rural2008==2 & rural2012==1 | Location2012==2 & Location2010==1 &!missing(indidy1) & rural2008==2 & rural2012==1 
// if the observation is in a different location in 2012 and is not missing, the observation was urban in 2008, the observation was rural in 2012
//OR if the observation is in the same location in 2012, a different location in 2010, is not a missing observation, was urban in 2008, and now is rural in 2012
//So basically, the observation migrated from an urban location to a rural location

replace Migrate2008_2012="Rural-rural" if Location2012==1 &!missing(indidy1) & rural2008==1 & rural2012==1 | Location2012==2 & Location2010==1 &!missing(indidy1) & rural2008==1 & rural2012==1 
// if the observation is in a different location in 2012, if the observation is not missing, if the observation is rural in 2008, observation is rural in 2012
// OR the observation is in the same location in 2012, a different location in 2010, is not missing, is rural in 2008, and is rural in 2012
//So basically, the observation migrated but migrated from a rural location to another rural location. 


replace Migrate2008_2012="Rural-urban" if Location2012==1 &!missing(indidy1) & rural2008==1 & rural2012==2 | Location2012==2 & Location2010==1 &!missing(indidy1) & rural2008==1 & rural2012==2 
//If the individual is in a different location in 2012, is not missing, is rural in 2008, is not rural in 2012
//OR if the individual is in the same location in 2012, a different location in 2010, not missing, in a rural location in 2008, and an urban location in 2012

encode Migrate2008_2012, gen(migrate2008_2012) //***might have to put zeros in for if it's right now missing values 2008
drop Migrate2008_2012

******************************************************************************************************
**NOT CORRECT
***************************** RETURN Migration Variable (rural/urban/DSM)************************************
gen str Return2008_2012 ="UrbS_Urb_UrbS" if rural2008==2 & region2008==region2012 & Location2010==1 &!missing(indidy1) & rural2010==2
//If the observation in in an urban location in 2008, is in the same region in 2008 and 2012, in a different location in 2010, is a nonmissing value, and is in an urban location in 2010

replace Return2008_2012="UrbS_Rur_UrbS" if rural2008==2 & region2008==region2012 & Location2010==1 &!missing(indidy1) & rural2010==1
//If the observation is in an urban location in 2008 in the same region in 2008 and 2012, in a different location in 2010, is a nonmissing value, and is in a rural location in 2010

replace Return2008_2012="RurS_Rur_RurS" if rural2008==1 & region2008==region2012 & Location2010==1 &!missing(indidy1) & rural2010==1
//if the observation is in a rural location in 2008, in the same region in 2008 and 2012, in a different location in 2010 and was rural in 2010

replace Return2008_2012="RurS_Urb_Rurs" if rural2008==1 & region2008==region2012 & Location2010==1 &!missing(indidy1) & rural2010==2
//if the observation is in a rural location in 2008, in the same region in 2008 and in 2012, in a different location in 2010, is a non-missing value, and in an urban location in 2010

encode Return2008_2012, gen(return2008_2012)
drop Return2008_2012

******************************************************************************************************
******************* 2008/12, 2nd option for Migration Variable*********************
****** (rural/urban/DSM + Mwanza (ilemela and nyamanga) primary) ********

*********************
**2008-2009**
*********************

**Defining whether or not the observations in 2008 were rural, from secondary towns, or from DSM + Mwanza:
gen ruralUrban2008 = "1rural" if rural2008==1 & !missing(rural2008)
 //if the observation is rural in 2008 and his value is not missing
 
replace ruralUrban2008 = "2secondary towns" if rural2008==2 & !missing(rural2008)
 //if the observation is urban in 2008 and his value is not missing,
 
replace ruralUrban2008 = "3Cities" if rural2008==2 & !missing(rural2008) & region2008==7 | rural2008==2 & !missing(rural2008) & region2008==19 & district2008==8 | rural2008==2 & !missing(rural2008) & region2008==19 & district2008==3 
//if the observation is urban in 2008, is a nonmissing value, is region DSM
//OR the observation is urban in 2008, is a nonmissing value, is region Mwanza, is district 8
//OR the observation is urban in 2008, is a nonmissing value, is region Mwanza, and is district 3

encode ruralUrban2008, gen(RuralUrban2008) //transform string variable to numeric variable

*********************
******2010-2011******
*********************

gen ruralUrban2010 = "1rural" if rural2010==1 & !missing(rural2010) 
//if the observation is rural in 2010 and not missing

replace ruralUrban2010 = "2secondary towns" if rural2010==2 & !missing(rural2010) 
//if the observation is urban in 2010 and value not missing

replace ruralUrban2010 = "3Cities" if rural2010==2 & !missing(rural2010) & region2010==7 | rural2010==2 & !missing(rural2010) & region2010==19 & district2010==8 | rural2010==2 & !missing(rural2010) & region2010==19 & district2010==3 
//If the observation is urban in 2010, not a missing value, is region DSM
//OR if the observation is urban in 2010, not a missing value, and is region Mwanza, district 8
//OR if the observation is urban in 2010, not a missing value, is region Mwanza, and district 3

encode ruralUrban2010, gen(RuralUrban2010)  //transform string variable to numeric variable 

*********************
******2012-2013******
*********************

gen ruralUrban2012 = "1rural" if rural2012==1 & !missing(rural2012)
//if the observation is rural in 2012 and not a missing value

replace ruralUrban2012 = "2secondary towns" if rural2012==2 & !missing(rural2012) 
// If the observation is urban in 2012 and not a missing value

replace ruralUrban2012 = "3Cities" if rural2012==2 & !missing(rural2012) & region2012==7 | rural2012==2 & !missing(rural2012) & region2012==19 & district2012==8 | rural2012==2 & !missing(rural2012) & region2012==19 & district2012==3
//if the observation is urban in 2012, not a missing value and region DSM
//OR the observation is urban in 2012, not a missing value, region Mwanza and district 8
//OR the observation is urban in 2012 not a missing value, region Mqwanza and district 3

encode ruralUrban2012, gen(RuralUrban2012) //transform string variable to numeric variable

gen str Migr2008_2012= "Same-Urban1" if Location2012==2 & Location2010!=1 &!missing(indidy1) & RuralUrban2008==3
//if the observation is in the same/local tracking location in 2012, in the same location in 2010, his value is not missing and is in a big city in 2008
//So basically this observation is NOT a migrant but a big city urban resident

replace Migr2008_2012= "Same-Urban2" if Location2012==2 & Location2010!=1 &!missing(indidy1) & RuralUrban2008==2
//if the observation is in the same/local tracking location in 2012, in the same location in 2010, his value is not missing and is urban in 2008 in a secondary town
//so basically this observation is NOT a migrant but a secondary city urban resident

replace Migr2008_2012= "Same-Rural" if Location2012==2 & Location2010!=1 &!missing(indidy1) & RuralUrban2008==1  
//if the observation is in the same/local tracking location in 2012, in the same location in 2010, his value is not missing and is rural in 2008
//so basically this observation is NOT a migrant but a rural urban resident

replace Migr2008_2012="Urban1-urban1" if Location2012==1 &!missing(indidy1) & RuralUrban2008==3  & RuralUrban2012==3 | Location2012==2 & Location2010==1 &!missing(indidy1) & RuralUrban2008==3 & RuralUrban2012==3
//if the observation is in a different tracking location in 2012, not a missing value, and a 3 cities urban resident 2008 and 20012,
//OR the observation is in the same local tracking location in 2012, a different location in 2010, not a missing value, and in 3 cities in 2008 and in 3 cities in 2012
//So the observation is a migrant from a big city to another big city and migrated in either 2010 OR 2012
			
replace Migr2008_2012="Urban1-urban2" if Location2012==1 &!missing(indidy1) & RuralUrban2008==3  & RuralUrban2012== 2| Location2012==2 & Location2010==1 &!missing(indidy1) & RuralUrban2008==3 & RuralUrban2012==2 
//if the observation is in a different tracking location in 2012, not a missing value, is in a big city in 2008, a secondary town in 2012
// OR the observation is in the same local tracking location in 2012, in a different location in 2010, a non-missing value, and in a 3 big city in 2008 and a secondary town in 2012
//So the observation is a migrant from a big city to a secondary city and either moved in 2012 (first line) or 2010 (second line)

replace Migr2008_2012="Urban2-urban1" if Location2012==1 &!missing(indidy1) & RuralUrban2008==2 & RuralUrban2012==3 | Location2012==2 & Location2010==1 &!missing(indidy1) & RuralUrban2008==2 & RuralUrban2012==3
//If the observation is in a different tracking location in 2012, not a missing value, is in a secondary town in 2008, and a big city in 2012
//OR the observation is in the same local tracking location in 2012, a different tracking location in 2010, not a missing value, was in a secondary city in 2008 and a 3 big city urban resident in 2012
//So the observation is a migrant from a secondary city to a big city and either moved in 2012 (first line) or 2010 (second line)

replace Migr2008_2012="Urban2-urban2" if Location2012==1 &!missing(indidy1) & RuralUrban2008==2 & RuralUrban2012==2 | Location2012==2 & Location2010==1 &!missing(indidy1) & RuralUrban2008==2 & RuralUrban2012==2 //added "RuralUrban2012==2" because i think it was missing but i'm not sure
//If the observation is in a different tracking location in 2012, not a missing value, is in a secondary town in 2008 and a secondary town in 2012
//OR If the observation is in the same tracking location in 2012, a different tracking location in 2010, not a missing value, and in a secondary city in 2008, and in a secondary city in 2012
//So the observation is a migrant from a secondary city to another secondary city and either moved in 2012 or 2010. 

replace Migr2008_2012="Urban1-rural" if Location2012==1 &!missing(indidy1) & RuralUrban2008==3 & RuralUrban2012==1 | Location2012==2 & Location2010==1 &!missing(indidy1) & RuralUrban2008==3 & RuralUrban2012==1 
//If the observation is in a different tracking location in 2012, not a missing value, is in a big city in 2008, and a rural location in 2012
//OR the observation is in the same tracking location in 2012, a different tracking locatoin in 2010, a non-missing value, a big city in 2008 and a rural location in 2012
//So the observation is a migrant from a big city to a rural location and either moved in 2012 or 2010. 

replace Migr2008_2012="Urban2-rural" if Location2012==1 &!missing(indidy1) & RuralUrban2008==2 & RuralUrban2012==1 | Location2012==2 & Location2010==1 &!missing(indidy1) & RuralUrban2008==2 & RuralUrban2012==1 
//If the observation is in a different tracking location in 2012, a non-missing value, a secondary city in 2008 and a rural location in 2012
//OR the obseravtion is in the same tracking location in 2012, a different tracking location in 2010, a non-missing value, a secondary city resident in 2008, and a rural resident in 2012
//So the observation is a migrant from a secondary city to a rural location and either moved in 2012 or 2010

replace Migr2008_2012="Rural-rural" if Location2012==1 &!missing(indidy1) & RuralUrban2008==1 & RuralUrban2012==1 | Location2012==2 & Location2010==1 &!missing(indidy1) & RuralUrban2008==1 & RuralUrban2012==1 
//If the observation is in a different tracking location in 2012, a nonmissing value, in a rural location in 2008 and a rural location in 2012
//OR if the observation is in the same location in 2012, a different location in 2010, is a non-missing value, is in a rural location in 2008 and a rural location in 2012
//So the observation is a migrant from a rural location to another rural location and either moved in 2012 or 2010

replace Migr2008_2012="Rural-urban1" if Location2012==1 &!missing(indidy1) & RuralUrban2008==1 & RuralUrban2012==3 | Location2012==2 & Location2010==1 &!missing(indidy1) & RuralUrban2008==1 & RuralUrban2012==3 
//If the observation is in a different tracking location in 2012, a nonmissing value, was in a rural location in 2008 and a big city location in 2012
//OR the observation is in the same tracking location in 2012, a different tracking location in 2010, a non-missing value, was in a rural location in 2008 and is in a big city in 2012
//So the observation is a migrant from a rural location to a big city and either moved in 2012 or 2010

replace Migr2008_2012="Rural-urban2" if Location2012==1 &!missing(indidy1) & RuralUrban2008==1 & RuralUrban2012==2 | Location2012==2 & Location2010==1 &!missing(indidy1) & RuralUrban2008==1 & RuralUrban2012==2 
//If the observation is in a different tracking location in 2012, a non-missing value, was in a rural location in 2008, and a secondary city location in 2012
//OR the observation is in the same tracking location in 2012, a different tracking location in 2010, is a nonmissing value, was in a rural location in 2008 and is in a secondary city location in 2012

encode Migr2008_2012, gen(migr2008_2012) //transform into numeric
drop Migr2008_2012 ruralUrban* RuralUrban*


save "$PML/migration.dta", replace

********************************************************************************
** COVARIATES
********************************************************************************

*****************************Income*****************************************

use "$PML/TNPS Data/2012-2013/ConsumptionNPS3.dta", replace

keep y3_hhid expmR fisherb3c3
//y3_hhid is hh identifier for 2012/2013
//expmR is total consumption annual, real
//fisherb3c3 is a price indice: Fisher price indices based only on food items were employed to adjust the nominal consumption
//aggregate for spatial and temporal price differences.

rename fisherb3c3 fisher_2012
gen Expenditures_2012 = expmR		// Adjust for inflation between rounds (based on indices in Basic Information Document)
//note: expmR=total consumption, annual, nominal


merge 1:m y3_hhid using "$PML/TNPS Data/2012-2013/NPSY3.PANEL.KEY.dta" //merge with data set we made throughout the earlier part of this do file
drop _merge

merge m:m y2_hhid using "$PML/TNPS Data/2010-2011/TZY2.HH.Consumption.dta"
drop _merge

rename fisherb2c2 fisher_2010
gen Expenditures_2010 = expmR*1.34
//note: expmR=total consumption, annual, nominal

keep y3_hhid Expenditures_2012 fisher_2012 UPI3 y1_hhid y2_hhid Expenditures_2010 fisher_2010
rename y1_hhid hhid

merge m:m hhid using "$PML/TNPS Data/2008-2009/TZY1.HH.Consumption.dta" //this is okay here LC but normally you do not to m:m
drop _merge

rename hhid y1_hhid
rename fisherb1c1 fisher_2008
gen Expenditures_2008 = expmR*1.21*1.34 //note: expmR=total consumption, annual, nominal
rename intmonth intmonth_2008
rename intyear intyear_2008

keep y3_hhid Expenditures_* UPI3 y1_hhid y2_hhid fisher* intmonth_2008 intyear_2008

save "$PML/TNPS Data/Expenditures.dta", replace //save the data on income/expenditure in the file 'Expenditures'

** *********************** *********************** *********************** *********************
** *********************Individual characteristics 2008/09*********************

use "$PML/TNPS Data/2008-2009/SEC_B_C_D_E1_F_G1_U.dta", clear


**renaming happiness variables
rename seq49_1 satisf_health2008 //how satisfied are you with your health
rename seq49_2 satisf_fin2008 //how satisfied are you with your financial situation
rename seq49_3 satisf_hous2008 //how satisfied are you with your housing
rename seq49_4 satisf_marie2008 // how satisfied are you with Your husband/ wife? 
rename seq49_5 satisf_job2008 //how satisfied are you with your job
rename seq49_6 satisf_life2008 //how satisfied are you with your life as a whole


rename sbmemno indidy1 //renaming the individual indicator vairable to match later rounds
rename seq46_hr agrihours_2008 //renaming hrs worked in agriculture to match later rounds

replace agrihours_2008 = . if agrihours_2008==999 //replace 999 by missing value
replace agrihours_2008 = 168 if !missing(agrihours_2008) & agrihours_2008> 168 //put at maximum the # of hours worked in agriculture to 168
rename sbq5 rel_2008 //relationship to head of HH
rename sbq4 age_2008 //age
rename sbq3yr BirthYear_2008 //year observation was born
rename sbq3mnth BirthMonth_2008 //
rename sbq2 sex_2008 //
rename sbq10 occupation_2008 // different occupations
rename scq6 education_2008 //highest grade completed 
replace education_2008 = 0 if scq2==2 //whether or not observation ever went to school
replace education_2008 = scq7 if missing(education_2008) & !missing(scq7) //if person is still in school what grade are they in now is told by education_2008
rename sbq26 MigrMotivation_2008 //why did you move here?
rename sbq24 LivedYears_2008 //for how many years have you lived in this community
rename scq2 schooling_2008 //have you ever gone to school
rename sbq16 MaternalEdu_2008 //how many years of school the mother had
rename sbq18 Marital_2008 //marital status
rename suq2 measured_2008 //was that observation measured
rename suq3 why_2008 //why not
rename suq4 weight_2008 //weight
rename suq5 height_2008 //height
rename hhid y1_hhid
gen str measure_2008 = "L" if suq6==2 //measured lying down
replace measure_2008 = "S" if suq6==1 //measured standing

* Panel
merge 1:m y1_hhid indidy1 using "$PML/TNPS Data/2012-2013/NPSY3.PANEL.KEY.dta" //merge into panel data
drop _merge

********************************************************************************************
******************** Individual Characteristics 2010/2011******************************

merge m:1 y2_hhid indidy2 using "$PML/TNPS Data/2010-2011/HH_SEC_B.dta"
drop _merge
merge m:1 y2_hhid indidy2 using "$PML/TNPS Data/2010-2011/HH_SEC_C.dta"
drop _merge
merge m:1 y2_hhid indidy2 using "$PML/TNPS Data/2010-2011/HH_SEC_U.dta"
drop _merge

rename hh_b05 rel_2010 //relationship to household
rename hh_b04 age_2010 //age
rename hh_b03_1 BirthYear_2010
rename hh_b03_2 BirthMonth_2010
rename hh_b02 sex_2010
rename hh_b11 occupation_2010

rename hh_c07 education_2010
replace education_2010 = 0 if hh_c03 ==2
drop hh_c03
replace education_2010 = hh_c09 if missing(education_2010)&!missing(hh_c09)
drop hh_c09

rename hh_b27 MigrMotivation_2010
rename hh_b25 LivedYears_2010
rename hh_b26_2 OriginalRegion_2010
rename hh_b26_3 OriginalDistrict_2010

gen schooling_2010 = 2
replace schooling_2010=1 if hh_c02 !=5
replace schooling_2010=. if missing(hh_c02)

rename hh_c02 readwrite_2010
rename hh_b17 MaternalEdu_2010
replace MaternalEdu_2010 = . if MaternalEdu_2010==8

rename hh_b19 Marital_2010
rename hh_u01 measured_2010
rename hh_u03 weight_2010
rename hh_u04 height_2010

gen str measure_2010 = "L" if hh_u05==2
replace measure_2010 = "S" if hh_u05==1

**Merge Happiness Variables**

merge m:1 y2_hhid indidy2 using "$PML/2010-2011_HH_SEC_G_clean.dta"	// Merge with clean SEC_G data. Note: the Panel key is uniquely identified on 
drop if _merge== 2 // the master data are a panel dataset so of course there are a lot of observations that can not be matched to the 2010/11  info you just merged into it(_merge==1). Ideally, all info from the using data (SEC_G) should be matched but for 2 obs. we have no records in the panel key (_merge==2)so you should drop those.
drop _merge

**renaming happiness variables** 
rename hh_g03_1 satisf_health2010 //how satisfied are you with your health
rename hh_g03_2 satisf_fin2010  //how satisfied are you with your financial situation
rename hh_g03_3 satisf_hous2010 //how satisfied are you with your housing
rename hh_g03_4 satisf_job2010 //how satisfied are you with your job
rename hh_g03_5 satisf_healcar2010  //how satisfied are you with your healthcare available
rename hh_g03_6 satisf_edu2010  //how satisfied are you with your education available
rename hh_g03_7 satisf_prot2010  //how satisfied are you with your protection against crime/your safety
rename hh_g03_8 satisf_life2010  //how satisfied are you with your life as a whole
rename hh_g04 consid_rich2010  //Just thinking about your current circumstances, would you describe yourself as rich
rename hh_g05 consid_compar3_2010  //Just thinking about your circumstances that you were living in about 3 years ago, would you describe yourself then as rich
rename hh_g06 consid_compar10_2010  //Just thinking about your circumstances you were living in about 10 years ago, would you describe yourself then as rich

********************************************************************************************
**************** Individual Characteristics 2012/13**********************
merge m:1 y3_hhid using "$PML/TNPS Data/2012-2013/HH_SEC_A.dta"
drop _merge
merge m:1 y3_hhid indidy3 using "$PML/TNPS Data/2012-2013/HH_SEC_B.dta"
drop _merge
merge m:1 y3_hhid indidy3 using "$PML/TNPS Data/2012-2013/HH_SEC_C.dta"
drop _merge
merge m:1 y3_hhid indidy3 using "$PML/TNPS Data/2012-2013/HH_SEC_V.dta"
drop _merge
merge m:1 y3_hhid indidy3 using "$PML/TNPS Data/2012-2013/HH_SEC_E.dta"
drop _merge
merge m:1 y3_hhid indidy3 using "$PML/TNPS Data/2012-2013/HH_SEC_G.dta"
drop _merge


**renaming happiness variables**
rename hh_g03_1 satisf_health2012 //how satisfied are you with your health
rename hh_g03_2 satisf_fin2012 //how satisfied are you with your financial situation
rename hh_g03_3 satisf_hous2012 //how satisfied are you with your housing
rename hh_g03_4 satisf_job2012 //how satisfied are you with your job
rename hh_g03_5 satisf_healcar2012 //how satisfied are you with your healthcare available
rename hh_g03_6 satisf_edu2012 //how satisfied are you with your education available
rename hh_g03_7 satisf_prot2012 //how satisfied are you with your protection against crime/your safety
rename hh_g03_8 satisf_life2012 //how satisfied are you with your life as a whole
rename hh_g04 consid_rich2012 //Just thinking about your current circumstances, would you describe yourself as rich
rename hh_g05 consid_compar3_2012 //Just thinking about your circumstances that you were living in about 3 years ago, would you describe yourself then as rich
rename hh_g06 consid_compar10_2012 //Just thinking about your circumstances you were living in about 10 years ago, would you describe yourself then as rich

rename hh_a18_2 intmonth_2012
rename hh_a18_3 intyear_2012

rename hh_e69 agrihours_2012
replace agrihours_2012 = . if agrihours_2012==999
replace agrihours_2012 = 168 if !missing(agrihours_2012) & agrihours_2012> 168

rename hh_b05 rel_2012
rename hh_b04 age_2012
rename hh_b03_1 BirthYear_2012
rename hh_b03_2 BirthMonth_2012
rename hh_b02 sex_2012
rename hh_b11 occupation_2012

rename hh_c07 education_2012
replace education_2012 = 0 if hh_c03 ==2
drop hh_c03
replace education_2012 = hh_c09 if missing(education_2012)&!missing(hh_c09)

rename hh_b28 MigrMotivation_2012
rename hh_b26 LivedYears_2012
rename hh_b28_2 OriginalRegion_2012
rename hh_b28_3 OriginalDistrict_2012

gen schooling_2012 = 2
replace schooling_2012=1 if hh_c02 !=5
replace schooling_2012=. if missing(hh_c02)

rename hh_b17 MaternalEdu_2012
rename hh_b19 Marital_2012
rename hh_v01 measured_2012
rename hh_v02 why_2012
rename hh_v03 weight_2012
rename hh_v04 height_2012

gen str measure_2012 = "L" if hh_v05==2
replace measure_2012 = "S" if hh_v05==1


merge 1:1 UPI3 using "$PML/TNPS Data/Expenditures.dta"
drop _merge

merge 1:1 UPI3 using "$PML/migration.dta" 
drop _merge

keep UPI3 indidy1 indidy2 indidy3 y1_hhid y2_hhid y3_hhid *_2008 *_2010 *_2012 satisf* migr* return* thhmem


********************************************************************************
********************************* CORRECTIONS  *********************************
********************************************************************************

*************** Correcting occupation **************

replace occupation_2008 = 17 if missing(occupation_2008) & age_2008 <= 6 //replace occupation_2008 by 17 (="too young") if the value is missing and age of the individual is <=6 
replace occupation_2012 = 17 if missing(occupation_2012) & age_2012 <= 6 //replace occupation_2010 by 17 (="too young") if the value is missing and age of the individual is <=6


*************Create and correct Farming household head ************************

gen Farm_2008 = .
replace Farm_2008 = 0 if occupation_2008!=1 & rel_2008==1 //if individual's main occupation the last 12 months is not agriculture/livestock and he is the head of the household
replace Farm_2008 = 1 if occupation_2008==1 & rel_2008==1 //if individual's main occupation the last 12 months is agricultute/livestock and he is the head of the household
bysort y1_hhid: egen farm_2008 = max( Farm_2008) //give the value 0 or 1 to each individual (bysort: repeats the stata_cmd for each group defined by varlist)

gen Farm_2010 = . //SAME for 2010
replace Farm_2010 = 0 if occupation_2010!=1 & rel_2010==1
replace Farm_2010 = 1 if occupation_2010==1 & rel_2010==1
bysort y2_hhid : egen farm_2010 = max( Farm_2010)

gen Farm_2012 = . //SAME for 2012
replace Farm_2012 = 0 if occupation_2012!=1 & rel_2012==1
replace Farm_2012 = 1 if occupation_2012==1 & rel_2012==1
bysort y3_hhid: egen farm_2012 = max( Farm_2012)

drop Farm_2008 Farm_2010 Farm_2012

gen OffFarmhh08_2012 = 1
replace OffFarmhh08_2012 = 0 if farm_2008==1 & farm_2012==1 //if individual's main occupation the last 12 months is agricultute/livestock and he is the head of the household in 2010 and 2012
replace OffFarmhh08_2012 = 0 if farm_2008!=1 //if individual's main occupation the last 12 months is not agricultute/livestock in 2008
replace OffFarmhh08_2012 = 1 if farm_2008==1 & farm_2012!=1 //if individual's main occupation the last 12 months is agricultute/livestock and he is the head of the household in 2008 but not in 2012
replace OffFarmhh08_2012 = . if missing(farm_2008) | missing(farm_2012) //if individual's farm value is missing in 2008 or 2012

gen OffFarm_2008_2012 = 1
replace OffFarm_2008_2012 = 0 if occupation_2008==1 & occupation_2012==1 //if individual's main occupation the last 12 months is agriculture/livestock in 2008 and 2012
replace OffFarm_2008_2012 = 0 if occupation_2008!=1 //if individual's main occupation the last 12 months is not agriculture/livestock in 2008
replace OffFarm_2008_2012 = . if missing(occupation_2008) | missing(occupation_2012) //if individual's occupation value is missing in 2008 or 2012

******************** Correcting Age ********************************

gen Diff_1 = BirthYear_2008 - BirthYear_2012
gen Diff_2 = BirthYear_2010 - BirthYear_2012
gen Diff_3 = BirthYear_2008 - BirthYear_2010

replace BirthYear_2008 = BirthYear_2010 if Diff_1!=0 & Diff_2==0 //if individual's year of birth has changed between 2008 and 2012 but not between 2010 and 2012
replace age_2008 = intyear_2008 - BirthYear_2008 if Diff_1!=0 & Diff_2==0 //individual's age=diff between if individual's year of birth has changed between 2008 and 2012 but not between 2010 and 2012
replace BirthYear_2012 = BirthYear_2010 if Diff_1!=0 & Diff_3==0 //if individual's year of birth has changed between 2008 and 2012 but not between 2008 and 2010
replace age_2012 = intyear_2012 - BirthYear_2012 if Diff_1!=0 & Diff_3==0 //individual's age=diff between if individual's year of birth has changed between 2008 and 2012 but not between 2008 and 2010
drop Diff_*

replace BirthYear_2008 = 2007 if UPI3==12023	// 2007 as birthyear in 2010 weight is to high to be a newborn in 2008
replace BirthYear_2012 = 2007 if UPI3==12023

gen Diff_1 = BirthMonth_2008 - BirthMonth_2012
gen Diff_2 = BirthMonth_2010 - BirthMonth_2012
gen Diff_3 = BirthMonth_2008 - BirthMonth_2010
replace BirthMonth_2008 = BirthMonth_2010 if Diff_1!=0 & Diff_2==0 //if individual's month of birth has changed between 2008 and 2012 but not between 2010 and 2012
replace BirthMonth_2012 = BirthMonth_2010 if Diff_1!=0 & Diff_3==0 //if individual's month of birth has changed between 2008 and 2012 but not between 2008 and 2010
drop Diff_*

*********************** Correcting Sex ***************************

gen diff_1 = sex_2008 - sex_2012
gen diff_2 = sex_2010 - sex_2012
gen diff_3 = sex_2008 - sex_2010
replace sex_2008 = sex_2010 if diff_1!=0 & diff_2==0  //if individual's sex has changed between 2008 and 2012 but not between 2010 and 2012
replace sex_2012 = sex_2010 if diff_1!=0 & diff_3==0  //if individual's sex has changed between 2008 and 2012 but not between 2008 and 2010
drop diff_*

******************* Correcting Migration Motivation rate *****************************
replace MigrMotivation_2012 = MigrMotivation_2010 if missing(MigrMotivation_2012)

******** GPS data ********

merge m:1 y3_hhid using "$PML/TNPS Data/2012-2013/HouseholdGeovars_Y3.dta"
drop _merge 

//See definition above
rename dist* dist*_2012
rename land02 AgricPercentKm_2012
rename land04 PopDens_2012
rename lat_dd_mod lat_2012
rename lon_dd_mod long_2012

keep UPI3 indidy1 indidy2 indidy3 y1_hhid y2_hhid y3_hhid *_2008 *_2010 *_2012 satisf* migr* return* thhmem

rename y1_hhid hhid
merge m:1 hhid using "$PML/TNPS Data/2008-2009/HH.Geovariables_Y1.dta"  

rename dist02 dist01_2008
rename dist03 dist02_2008
rename dist04 dist03_2008
rename dist05 dist05_2008
rename dist06 dist04_2008
rename lat_modified lat_2008
rename lon_modified long_2008
rename hhid y1_hhid

keep UPI3 indidy1 indidy2 indidy3 y1_hhid y2_hhid y3_hhid *_2008 *_2010 *_2012 satisf* migr* return* thhmem

save "$PML/TNPS Data/Panel_wide.dta", replace


**reshape dataset to long format
use "$PML/TNPS Data/Panel_wide.dta", replace

**************************************************
**create Household size variables for years 2012 and 2010
**2012
sort y3_hhid indidy3
by y3_hhid: gen thhmem_2012=_N if indidy3!=.

**2010 
sort y2_hhid indidy2
by y2_hhid: gen thhmem_2010=_N if indidy2!=.

**2008
rename thhmem thhmem_2008
***********************************************************

loc sat_vars "satisf_health satisf_fin satisf_hous satisf_marie satisf_job satisf_life satisf_healcar satisf_edu satisf_prot consid_compar3_ consid_compar10_"
reshape long `sat_vars' thhmem_ sex_ dist_Y1Y3_ BirthYear_ BirthMonth_ age_ rel_ occupation_ MaternalEdu_ Marital_ LivedYears_ MigrMotivation_ schooling_ education_ agrihours_ consid_ measured_ why_ weight_ height_ measure_ OriginalRegion_ OriginalDistrict_ readwrite_ intmonth_ intyear_ fisher_ Expenditures_ migrate2008_ return2008_ migr2008_ farm_ OffFarm_ dist01_ dist02_ dist03_ dist04_ dist05_ AgricPercentKm_ PopDens_ lat_ long_ dist_, i(UPI3) j(year)

save "$PML/TNPS Data/Panel_long.dta", replace //save for final panel to use

**************************************************
***Clean variables in long format for analysis! **
use "$PML/TNPS Data/Panel_long.dta", clear

**recoding satisfaction so a high number equals satisfaction
**Satisfied Life**
/*should be
very satisfied=8
satisfied=7
somewhat satisfied=6
neither satisfied nor dissatisfied=5
somewhat dissatisfied=4
dissatisfied=3
very dissatisfied=2
not aplicable=1
*/
**SATISFACTION WITH LIFE**
gen satisf_life_=1 if satisf_life==8 //changing not applicable from 
replace satisf_life_=2 if satisf_life==7 //changing very dissatisfied from 7 to 2
replace satisf_life_=3 if satisf_life==6 //changing dissatisfied from 6 to 3
replace satisf_life_=4 if satisf_life==5 //changing somewhat dissatisfied from 5 to 4
replace satisf_life_=5 if satisf_life==4 //changing neither satis nor disatisf from
replace satisf_life_=6 if satisf_life==3 //changing somewhat satisfied from 3 to six
replace satisf_life_=7 if satisf_life==2 //changing Satisfied from =2 to =7
replace satisf_life_=8 if satisf_life==1 //changing very satisfied from 1 to 8

**SATISFACTION WITH HOUSE**
gen satisf_hous_=1 if satisf_hous==8 //changing not applicable from 
replace satisf_hous_=2 if satisf_hous==7 //changing very dissatisfied from 7 to 2
replace satisf_hous_=3 if satisf_hous==6 //changing dissatisfied from 6 to 3
replace satisf_hous_=4 if satisf_hous==5 //changing somewhat dissatisfied from 5 to 4
replace satisf_hous_=5 if satisf_hous==4 //changing neither satis nor disatisf from
replace satisf_hous_=6 if satisf_hous==3 //changing somewhat satisfied from 3 to six
replace satisf_hous_=7 if satisf_hous==2 //changing Satisfied from =2 to =7
replace satisf_hous_=8 if satisf_hous==1 //changing very satisfied from 1 to 8

**SATISFACTION WITH JOB**
gen satisf_job_=1 if satisf_job==8 //changing not applicable from 
replace satisf_job_=2 if satisf_job==7 //changing very dissatisfied from 7 to 2
replace satisf_job_=3 if satisf_job==6 //changing dissatisfied from 6 to 3
replace satisf_job_=4 if satisf_job==5 //changing somewhat dissatisfied from 5 to 4
replace satisf_job_=5 if satisf_job==4 //changing neither satis nor disatisf from
replace satisf_job_=6 if satisf_job==3 //changing somewhat satisfied from 3 to six
replace satisf_job_=7 if satisf_job==2 //changing Satisfied from =2 to =7
replace satisf_job_=8 if satisf_job==1 //changing very satisfied from 1 to 8


**SATISFACTION WITH HEALTH**
gen satisf_health_=1 if satisf_health==8 //changing not applicable from 
replace satisf_health_=2 if satisf_health==7 //changing very dissatisfied from 7 to 2
replace satisf_health_=3 if satisf_health==6 //changing dissatisfied from 6 to 3
replace satisf_health_=4 if satisf_health==5 //changing somewhat dissatisfied from 5 to 4
replace satisf_health_=5 if satisf_health==4 //changing neither satis nor disatisf from
replace satisf_health_=6 if satisf_health==3 //changing somewhat satisfied from 3 to six
replace satisf_health_=7 if satisf_health==2 //changing Satisfied from =2 to =7
replace satisf_health_=8 if satisf_health==1 //changing very satisfied from 1 to 8


**SATISFACTION WITH FINANCES**
gen satisf_fin_=1 if satisf_fin==8 //changing not applicable from 8 to 1
replace satisf_fin_=2 if satisf_fin==7 //changing very dissatisfied from 7 to 2
replace satisf_fin_=3 if satisf_fin==6 //changing dissatisfied from 6 to 3
replace satisf_fin_=4 if satisf_fin==5 //changing somewhat dissatisfied from 5 to 4
replace satisf_fin_=5 if satisf_fin==4 //changing neither satis nor disatisf from
replace satisf_fin_=6 if satisf_fin==3 //changing somewhat satisfied from 3 to six
replace satisf_fin_=7 if satisf_fin==2 //changing Satisfied from =2 to =7
replace satisf_fin_=8 if satisf_fin==1 //changing very satisfied from 1 to 8


**migration vars for not HHFE
label var migrate2008_ "Migration variable"
gen rural_urban=1 if migrate2008_==2 //migrate=2 is rural urban migrants
//replace rural_urban=0 if migrate2008_!=2 & migrate2008_!=.
//replace rural_urban=. if migrate2008_==6 & migrate2008_==1 & migrate2008_==5 & migrate2008_==4 //we give missing values to everyone except same-rural we only want same-rural (3) in the control group, make sure other types of migrants are not in the control group!!(urban-urban is 6, rural-rual is 1, urban-rural is 5, same-urban)
replace rural_urban=0 if migrate2008_==3 //migrate=3 is same rural nonmigrants
replace rural_urban=0 if migrate2008_==1
label var rural_urban "Dummy for rural urban migration"
sort UPI3 year
by UPI3: replace rural_urban= 0 if year==2010 & migrate2008[_n+1]!=.
by UPI3: replace rural_urban= 0 if year==2008 & migrate2008[_n+2]!=.

**include rural-rural dummy, urban-rural, and urban-urban 
**IIN MIGRATE2008_ VARIABLE THIS IS HOW IT'S CODED: 
**rural-rural= 1 in migrate_2008_2012
**urban-rural=5 in migrate_2008_2012
**urban-urban=6
**same-urban=4
**rural_urban=2
**same_rural=3
gen rural_rural=1 if migrate2008_==1 //migrate=1 means rural-rural migrant
//replace rural_rural=0 if migrate2008_!=1 & migrate2008_!=.
//replace rural_rural=. if migrate2008_==5 & migrate2008_==6 & migrate2008_==4 & migrate2008_==2
replace rural_rural=0 if migrate2008_==3 //migrate=3 is same rural nonmigrants
replace rural_rural=0 if migrate2008_==2
label var rural_rural "Migrated to and from a rural location dummy"
sort UPI3 year
by UPI3: replace rural_rural= 0 if year==2010 & migrate2008[_n+1]!=.
by UPI3: replace rural_rural= 0 if year==2008 & migrate2008[_n+2]!=.


**include same-rural dummy and same-urban dummy**
***same-rural
gen same_rural=1 if migrate2008_==3 //migrate=3 is same rural nomigrants
//replace same_rural=0 if migrate2008_!=3 & migrate2008_!=.
replace same_rural=0 if migrate2008_==2 //migrate=2 --> rural-urban migrants
replace same_rural=0 if migrate2008_==1 // migrate==1 is rural-rural migrants
label var same_rural "Dummy for non-migrants (rural)"
sort UPI3 year
by UPI3: replace same_rural= 0 if year==2010 & migrate2008[_n+1]!=.
by UPI3: replace same_rural= 0 if year==2008 & migrate2008[_n+2]!=.


**same-urban
gen same_urban=1 if migrate2008_==4
//replace same_urban=0 if migrate2008_!=4 & migrate2008_!=.
replace same_urban=0 if migrate2008_==6 & migrate2008_==5
label var same_urban "Dummy for non-migrants (urban)"
sort UPI3 year
by UPI3: replace same_urban= 0 if year==2010 & migrate2008[_n+1]!=.
by UPI3: replace same_urban= 0 if year==2010 & migrate2008[_n+1]!=.


***Migraiton variable for DIFFERENTIATING BETWEEN 2NDARY CITIES**
**rural-rural
gen rural_rur=1 if migr2008_==1
replace rural_rur=0 if migr2008_==4 //same rural nonmigrants 
replace rural_rur=0 if migr2008_==2 //2 is for rural_urban1 where urban1 indicates big city
replace rural_rur=0 if migr2008_==3 //3 is when person migrates to 2dary city

**rural_urban with urban BIG CITIES
gen rural_urb1=1 if migr2008_==2 //2 is for migrate to big city
replace rural_urb1=0 if migr2008_==4 //same rural nonmigrants
replace rural_urb1=0 if migr2008_==3 //migrate to 2ndary city
replace rural_urb1=0 if migr2008_==1 //1 is for rural rural migrants

**rural_urban with urban 2NDARY CITIES
gen rural_urb2=1 if migr2008_==3 //3 is for 2ndary citeis
replace rural_urb2=0 if migr2008_==2 //2 is for migrate to a big city
replace rural_urb2=0 if migr2008_==4 //4 is same rural nonmigrants
replace rural_urb2=0 if migr2008_==1 // 1 is for rural rural migrants

**rural NON migrants
gen same_rur=1 if migr2008_==4
replace same_rur=0 if migr2008_==3 //3 is for 2ndary cities
replace same_rur=0 if migr2008_==2 //2 is migrate into a big city
replace same_rur=0 if migr2008_==1 //1 is for rural rural migrants

**************************

**household identification
encode y1_hhid, gen(y1_hhid_no)
encode y2_hhid, gen(y2_hhid_no)
encode y3_hhid, gen(y3_hhid_no)
gen HH_ID= y1_hhid_no //initial household ID

// height and weight are in the data allready (calculations are better done once the data is reshaped so that you don't have to do it for each year separately)
 
gen BMIadult= weight/(height_/100)^2 
replace BMIadult = . if BMIadult < 14.156 & sex_==1 	// WHO cutoff for implausible values -4SD for 19 year old male
replace BMIadult = . if BMIadult > 41.317 & sex_==1 	// WHO cutoff for implausible values -4SD for 19 year old male
replace BMIadult = . if BMIadult < 12.951 & sex_== 2    // WHO cutoff for implausible values -4SD for 19 year old female
replace BMIadult=. if BMIadult > 42.689 & sex_== 2 	// WHO cutoff for implausible values +4SD for 19 year old female

**gender variable, F=1!! 
gen sex=0 if sex_==1
replace sex=1 if sex_==2  

**age variable
gen agesqr=age_^2

gen age_cat=0 if age_>=0 & age_<10
replace age_cat=1 if age_>=10 & age_<20
replace age_cat=2 if age_>=20 & age_<30
replace age_cat=3 if age_>=30 & age_<40
replace age_cat=4 if age_>=40 & age_<50
replace age_cat=5 if age_>=50 & age_<60
replace age_cat=6 if age_>=60 & age_<70
replace age_cat=7 if age_>=70 & age_<60
replace age_cat=8 if age_>=80 & age_<90

**marriage variable for controls
tab Marital_, gen(marital)

rename marital1 mar_monogamous
rename marital2 mar_polygamous
rename marital3 mar_livtog
rename marital4 mar_seperated
rename marital5 mar_div
rename marital6 mar_never
rename marital7 mar_widow

gen married=. 
replace married=1 if mar_monogamous==1
replace married=1 if mar_polygamous==1
replace married=1 if mar_livtog==1
replace married=0 if mar_seperated==1
replace married=0 if mar_div==1
replace married=0 if mar_never==1
replace married=0 if mar_widow==1


**generate expenditures variable
**expenditures per capita (per HH)
gen expPHH=Expenditures_/thhmem_
gen expPHHlog_=log(expPHH)

**occupation, we need unemployed, employagr, 
tab occupation_, gen(o)
rename o1 employagr
rename o13 unemployed_seeking
rename o16 unemployed
rename o14 student


**relationship to HH head
**rename relationship to head of hh, we want hhhead, spouse, and child
rename rel_ relat_2HHhead
tab relat_2HHhead, gen(f)
rename f1 HHhead
rename f2 HHhead_spouse
rename f3 HHhead_child

**Education
gen edu_yrs = .
replace edu_yrs = 0 if missing(education_) & schooling_ == 2
replace edu_yrs = 0 if age_ < 6 & schooling_!=1             // Correction for young children
replace edu_yrs = 0 if education_==0 | education_==1               // 0 & preprimary
replace edu_yrs = 1 if education_== 11                             // D1
replace edu_yrs = 2 if education_== 12              // D2
replace edu_yrs = 3 if education_== 13              // D3
replace edu_yrs = 4 if education_== 14              // D4
replace edu_yrs = 5 if education_== 15              // D5
replace edu_yrs = 6 if education_== 16              // D6
replace edu_yrs = 7 if education_== 17              | education_ ==2            // D7 & Adult
replace edu_yrs = 8 if education_== 18 | education_ == 19| education_ == 20| education_ ==21      // D8 & Preform I & MS+ & F1
replace edu_yrs = 9 if education_== 22              // F2
replace edu_yrs = 10 if education_== 23            // F2
replace edu_yrs = 11 if education_== 24 | education_==25       // F4 & O+
replace edu_yrs = 12 if education_== 31            // F5
replace edu_yrs = 13 if education_== 32 | education_ ==33      // F6 & A+
replace edu_yrs = 14 if education_== 41 | education_ == 34     // U1 &  Diploma
replace edu_yrs = 15 if education_== 42            // U2
replace edu_yrs = 16 if education_== 43            // U3
replace edu_yrs = 17 if education_== 44            // U4
replace edu_yrs = 18 if education_== 45            // U5

**Labeling
label var employagr "Agriculture Employment"
label var unemployed_seeking "Seeking Employment"
label var unemployed "Unemployed"
label var student "Student"
label var married "Married"
label var dist02_ "Distance"
label var sex "Gender"
label var age_ "Age 2008"
label var agesqr "Age 2008 squared"
label var edu_yrs "Education 2008"
label var MaternalEdu_ "Maternal Edu"
label var HHhead_child "Child of HH Head"
label var HHhead_spouse "Spouse of HH Head"
label var HHhead "HH Head"
 
label var expPHHlog_ "Consumption"
label var BMIadult "Health"
label var satisf_health_ "Satisfaction Health"
label var satisf_fin_ "Satisfcation Finances"
label var satisf_hous_ "Satisfaction House"
label var satisf_job_ "Satisfaction Job"
label var satisf_life_ "Satisfaction Life"
label var consid_compar3_ "Satisfaction compared to 3 years ago"
label var consid_compar10_ "Satisfaction compared to 10 years ago"

save "$PML/TNPS Data/Panel_long.dta", replace //save for final panel to use

*******************************************************************************
**********CREATE LONG data set to use in DiD HHFE analysis w/o 2010 data***********
use "$PML/TNPS Data/Panel_long.dta", clear
**drop observations under age 15
drop if age_<15

drop if year==2010
gen Year = 1 if year == 2008
replace Year = 2 if year == 2012
xtset UPI3 year

**migration vars for HHFE
**Rural Urban
gen rural_urbanHHFE=1 if migrate2008_==2 
//replace rural_urban_HHFE=0 if migrate2008_!=2 & migrate2008_!=.
//replace rural_urban_HHFE=0 if migrate2008_==6 & migrate2008_==1 & migrate2008_==5 & migrate2008_==4 //we give missing values to everyone except same-rural we only want same-rural (3) in the control group, make sure other types of migrants are not in the control group!!(urban-urban is 6, rural-rual is 1, urban-rural is 5, same-urban)
replace rural_urbanHHFE=0 if migrate2008_==3 //migrate2008=3 means same-rural (nonmigrante)
replace rural_urbanHHFE=0 if migrate2008_==1 
label var rural_urbanHHFE "Dummy for rural urban migration"
//tab rural_urbanHHFE if rural_urbanHHFE==0

**rural rural
gen rural_ruralHHFE=1 if migrate2008_==1
//replace rural_rural_HHFE=0 if migrate2008_!=1 & migrate2008_!=.
//replace rural_rural_HHFE=. if migrate2008_==5 & migrate2008_==6 & migrate2008_==4 & migrate2008_==2
replace rural_ruralHHFE=0 if migrate2008_==3
replace rural_ruralHHFE=0 if migrate2008_==2
//replace rural_ruralHHFE=0 if migrate2008_==2
label var rural_ruralHHFE "Migrated to and from a rural location dummy"

***same-rural
gen same_ruralHHFE=1 if migrate2008_==3
replace same_ruralHHFE=0 if migrate2008_==2 
replace same_ruralHHFE=0 if migrate2008_==1
label var same_ruralHHFE "Dummy for non-migrants (rural)"

**same-urban
gen same_urbanHHFE=1 if migrate2008_==4
replace same_urbanHHFE=0 if migrate2008_==6 
replace same_urbanHHFE=0 if migrate2008_==5
label var same_urbanHHFE "Dummy for non-migrants (urban)"


**

***Migraiton variable for DIFFERENTIATING BETWEEN 2NDARY CITIES**
**rural-rural
gen rural_rurHHFE=1 if migr2008_==1
replace rural_rurHHFE=0 if migr2008_==4 //same rural nonmigrants 
replace rural_rurHHFE=0 if migr2008_==2 //2 is for rural_urban1 where urban1 indicates big city
replace rural_rurHHFE=0 if migr2008_==3 //3 is when person migrates to 2dary city

**rural_urban with urban BIG CITIES
gen rural_urb1HHFE=1 if migr2008_==2 //2 is for migrate to big city
replace rural_urb1HHFE=0 if migr2008_==4 //same rural nonmigrants
replace rural_urb1HHFE=0 if migr2008_==3 //migrate to 2ndary city
replace rural_urb1HHFE=0 if migr2008_==1 //1 is for rural rural migrants

**rural_urban with urban 2NDARY CITIES
gen rural_urb2HHFE=1 if migr2008_==3 //3 is for 2ndary citeis
replace rural_urb2HHFE=0 if migr2008_==2 //2 is for migrate to a big city
replace rural_urb2HHFE=0 if migr2008_==4 //4 is same rural nonmigrants
replace rural_urb2HHFE=0 if migr2008_==1 // 1 is for rural rural migrants

**rural NON migrants
gen same_rurHHFE=1 if migr2008_==4
replace same_rurHHFE=0 if migr2008_==3 //3 is for 2ndary cities
replace same_rurHHFE=0 if migr2008_==2 //2 is migrate into a big city
replace same_rurHHFE=0 if migr2008_==1 //1 is for rural rural migrants

**************************


*****Differentiating between baseline happier ppl**
//1
//2
//3
//4
//5
//6
//7
//8


/*
*****I THINK THIS IS WRONG:*****
tab migrate2008_, gen(m)
rename m1 rural_rural_HHFE
rename m2 rural_urban_HHFE
rename m3 same_rural_HHFE
rename m4 same_urban_HHFE
rename m5 urban_rural_HHFE
rename m6 urban_urban_HHFE 
*/

/*
**DOUBLE CHECKING variables** USING TAB GEN(M) IS WRONG
tab migrate2008_ if migrate2008_==2
tab rural_urban if rural_urban==1
tab rural_urbanHHFE if rural_urbanHHFE==1

tab migrate2008_ if migrate2008_==3
tab rural_urban if rural_urban==0
tab rural_urbanHHFE if rural_urbanHHFE==0

**DOUBLE CHECKING using other method from first long (w/o hhfe) cleaning
tab migrate2008_ if migrate2008_==3
tab rural_urban if rural_urban==0
tab rural_urban_HHFE if rural_urban_HHFE==0

tab migrate2008_ if migrate2008_==3
tab rural_rural if rural_rural==0
tab rural_rural_HHFE if rural_rural_HHFE==0
*/

**Create satisfaction variables differentiating between baseline low and high 
**Dummy for satisfaction low and high
gen satisf_life_LH = 1 if satisf_life_ >=4
replace satisf_life_LH = 0 if satisf_life_ <4
label var satisf_life_LH "dummy if person is more satisfied vs more dissatisfied"


*********************************************
**Baseline controls, create lagged variables
gl con_varsHHFE "expPHH expPHHlog_ BMIadult satisf_health_ satisf_fin_ satisf_hous_ satisf_job_ satisf_life_ satisf_life_LH employagr unemployed_seeking unemployed student married mar_monogamous dist02_ sex age_ agesqr edu_yrs MaternalEdu_ HHhead_child HHhead_spouse HHhead"


foreach x in $con_varsHHFE {
sort UPI3 year
	gen `x'_2008 =.
 	bys UPI3: replace `x'_2008 = `x'[_n-1]
} //this should create a value in the 2012 rows for each individual expressing the 2008 
//value of that individual (baseline characteristics!!


gl dep_varsHHFE "expPHHlog_ BMIadult satisf_health_ satisf_fin_ satisf_hous_ satisf_job_ satisf_life_ consid_compar3_ consid_compar10_"
sort UPI3 year
foreach q in $dep_varsHHFE {
	gen `q'_D =.
 	bys UPI3: replace `q'_D = `q' - `q'[_n-1] // this generates the difference between the 2012 and 2008 value, which is what we want because it takes out ind. fixed heterogen.
}

**Labeling
label var employagr "Agriculture Employment"
label var unemployed_seeking "Seeking Employment"
label var unemployed "Unemployed"
label var student "Student"
label var married_ "Married"
label var dist02_ "Distance"
label var sex "Gender"
label var age_ "Age 2008"
label var agesqr "Age 2008 squared"
label var edu_yrs "Education 2008"
label var MaternalEdu_ "Maternal Edu"
label var HHhead_child "Child of HH Head"
label var HHhead_spouse "Spouse of HH Head"
label var HHhead "HH Head"
 
label var expPHHlog_ "Consumption"
label var BMIadult "Health"
label var satisf_health "Satisfaction Health"
label var satisf_fin "Satisfcation Finances"
label var satisf_hous "Satisfaction House"
label var satisf_job "Satisfaction Job"
label var satisf_life "Satisfaction Life"
label var consid_compar3_ "Satisfaction compared to 3 years ago"
label var consid_compar10_ "Satisfaction compared to 10 years ago"
 
 
save "$PML/TNPS Data/Panel_longHHFE.dta", replace
