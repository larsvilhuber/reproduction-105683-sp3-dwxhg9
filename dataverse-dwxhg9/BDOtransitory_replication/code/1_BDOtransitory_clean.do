****************************************************************
				***** KEVIN DEVEREUX ******
				***** FARAH HALA OMRAN ****
				***** MONA BALESH ABADI ***
****************************************************************
use "$Path/data/ICPSR_06439/DS0160/06439-0160-Data.dta"
********************************
***** 1. Merging data sets *****
********************************
***Merging the two data sets of Annual expenses and visits and Demographics***
merge 1:m PERSON using "$Path/data/ICPSR_06439/DS0163/06439-0163-Data.dta"
drop if missing(CONTYR)
*****************************************************************
***** 2. Organizing, Transforming, and generating variables *****
*****************************************************************
*destringing entries*
*********************
destring, replace
destring CONTYR,replace ignore("P*")
destring AGE, replace ignore("A")
forval i=1/5 {
gen contyr_`i'=0
replace contyr_`i'=1 if CONTYR==`i'
}
*************************************************************************
*generating a variable that captures ALL annual expenses per participant*
*************************************************************************
gen inpspend=INPDOL
gen outpspend=OUTPDOL+MENTDOL+DENTDOL+DRUGDOL+SUPPDOL
gen totspend=inpspend+outpspend
order totspend inpspend outpspend
*AEF table 2 suggests mental and dental are excluded
gen inpspend_aef=INPDOL
gen outpspend_aef=OUTPDOL+MENTDOL+DENTDOL
gen totspend_aef=inpspend_aef+outpspend_aef
order totspend_aef inpspend_aef outpspend_aef
***********************************************************************
*generate a backwards count of continuation year
***********************************************************************
gen yrsleft=ENRTERM-CONTYR+1
forval i=1/5 {
gen yrsleft_`i'=0
replace yrsleft_`i'=1 if yrsleft==`i'
}
gen yrsleft3=yrsleft
replace yrsleft3=0 if yrsleft==3
gen lastyr=0
replace lastyr=1 if yrsleft==1
gen last2=lastyr
replace last2=1 if yrsleft==2
gen firstyr=0
replace firstyr=1 if CONTYR==1
***********************************************************************
*generating variable to pool different conisurance rate plans together*
***********************************************************************
tabulate PLAN
drop if PLAN==0
generate EPLAN=.
replace EPLAN=1 if PLAN==1|PLAN==2|PLAN==3|PLAN==4
replace EPLAN=2 if PLAN==13|PLAN==14|PLAN==15|PLAN==16
replace EPLAN=3 if PLAN==8|PLAN==9|PLAN==10
replace EPLAN=4 if PLAN==5|PLAN==6|PLAN==7|PLAN==17|PLAN==18|PLAN==19
replace EPLAN=5 if PLAN==11
replace EPLAN=6 if PLAN==30
tabulate EPLAN
label define EPLAN_label 1 "100% copay" 2 "95% copay" 3 "50% copay" 4 "25% copay" 5 "0% copay" 6 "HMO"
label values EPLAN EPLAN_label
***********************************************************************
*						AEF plan categories
***********************************************************************
label define AEF_label 	1 "Free care" ///
						2 "25% copay" ///
						3 "Mixed copay" ///
						4 "50% copay" ///
						5 "Indiv. deductible" ///
						6 "95% copay"
gen plan_aef=.
replace plan_aef=1 if PLAN==11
replace plan_aef=2 if PLAN==5 | PLAN==6 | PLAN==7
replace plan_aef=3 if PLAN==17 | PLAN==18 | PLAN==19
replace plan_aef=4 if PLAN==8 | PLAN==9 | PLAN==10
replace plan_aef=5 if PLAN==1 | PLAN==13
replace plan_aef=6 if PLAN==14 | PLAN==15 | PLAN==16
replace plan_aef=6 if PLAN==2 | PLAN==3 | PLAN==4
label values plan_aef AEF_label
***********************************************************************
* AEF plan psuedo-categories: assign to spending cat-specific plans
***********************************************************************
foreach cat in MED OUTP INP MENT DENT DRUG SUPP {
gen plan_`cat'=.
}
* copayment levels/in	{0,25,50,95,100} depending on plan and year
*						 1, 2, 3, 4, 5
foreach cat in MED OUTP INP MENT DENT DRUG SUPP {
* free care: all categories zero copay
replace plan_`cat'=1 if PLAN==11
* flat plans across all cats
replace plan_`cat'=2 if PLAN==5 | PLAN==6 | PLAN==7
replace plan_`cat'=2 if PLAN==17 | PLAN==18 | PLAN==19
replace plan_`cat'=3 if PLAN==8 | PLAN==9 | PLAN==10
replace plan_`cat'=4 if PLAN==14 | PLAN==15 | PLAN==16
replace plan_`cat'=4 if PLAN==2 | PLAN==3 | PLAN==4
* Dayton year 1 -- some people has no subsidy (100% copay)
replace plan_`cat'=5 if (PLAN==2 | PLAN==3 | PLAN==4) & CONTYR==1
* apply base rates to mixed & indiv deductible plans
replace plan_`cat'=4 if PLAN==1 | PLAN==13
* dayton year 1 -- those later moved to plan 13 had 100% copayment --- it seems they gain free INP the following year  -- can exploit anticipation effect?
replace plan_`cat'=5 if PLAN==1 & CONTYR==1
}
* fix specialized category rates for mixed & indiv deductible plans
* mixed
replace plan_MENT=3 if PLAN==17 | PLAN==18 | PLAN==19
replace plan_DENT=3 if PLAN==17 | PLAN==18 | PLAN==19
* indiv deductible -- free INP care for those in plan 13 (& plan 1 was moved to 13 after 1st yr)
replace plan_INP=1 if (PLAN==1 & CONTYR>1) | PLAN==13

* since 100% copay only ever happens in 1st year, can't interact it with CONTYR
foreach cat in MED OUTP INP MENT DENT DRUG SUPP {
gen p4_`cat'=plan_`cat'
*conflate 100% copay plan into 95%
replace p4_`cat'=4 if p4_`cat'==5
*drop free care so that it's the base category
replace p4_`cat'=0 if p4_`cat'==1

* for plan4 interactions use _T suffix instead of _lastyr because of glitch in xi: autonaming process
gen p4_`cat'T=p4_`cat'*lastyr
gen p4_`cat'T2=p4_`cat'*last2
gen p4_`cat'I=p4_`cat'*firstyr
}

**** generate plan*last year for regular plan categories
foreach cat in aef MED OUTP INP MENT DENT DRUG SUPP {
* for plan4 interactions use _T suffix instead of _lastyr because of glitch in xi: autonaming process
gen plan_`cat'T=plan_`cat'*lastyr
gen plan_`cat'T2=plan_`cat'*last2
gen plan_`cat'I=plan_`cat'*firstyr
}
label values plan_aefT AEF_label
label values plan_aefT2 AEF_label
label values plan_aefI AEF_label
*pool free care obs in the deadline year with non-deadline years. then must include lastyr, firstyr dummies
replace plan_aefT=0 if plan_aefT==1
replace plan_aefT2=0 if plan_aefT2==1
replace plan_aefI=0 if plan_aefI==1
***********************************************************************
* Now assign copay rates to the category-specific plans
***********************************************************************
foreach cat in MED OUTP INP MENT DENT DRUG SUPP {
gen copay_`cat'=.
replace copay_`cat'=0 if plan_`cat'==1
replace copay_`cat'=25 if plan_`cat'==2
replace copay_`cat'=50 if plan_`cat'==3
replace copay_`cat'=95 if plan_`cat'==4
replace copay_`cat'=100 if plan_`cat'==5

gen lcopay_`cat'=log(copay_`cat')
gen lcopay1_`cat'=log(1+copay_`cat')

gen copay_`cat'_lastyr		=	copay_`cat'*lastyr
gen lcopay_`cat'_lastyr		=	lcopay_`cat'*lastyr
gen lcopay1_`cat'_lastyr	=	lcopay1_`cat'*lastyr

gen copay_`cat'_last2		=	copay_`cat'*last2
gen lcopay_`cat'_last2		=	lcopay_`cat'*last2
gen lcopay1_`cat'_last2		=	lcopay1_`cat'*last2

gen copay_`cat'_firstyr		=	copay_`cat'*firstyr
gen lcopay_`cat'_firstyr	=	lcopay_`cat'*firstyr
gen lcopay1_`cat'_firstyr	=	lcopay1_`cat'*firstyr
}
foreach cat in MED OUTP INP MENT DENT DRUG SUPP {
gen discount_`cat'=100-copay_`cat'
}
***********************************************************************
*generate integer value of copay amount (aef: copay(plan3)=32,copay(plan5)=58)
***********************************************************************
gen copay=.
replace copay=0 if plan_aef==1
replace copay=25 if plan_aef==2
replace copay=32 if plan_aef==3
replace copay=50 if plan_aef==4
replace copay=58 if plan_aef==5
replace copay=95 if plan_aef==6
gen lcopay=log(copay)
gen lcopay1=log(1+copay)

gen copay_lastyr		=	copay*lastyr
gen lcopay_lastyr		=	lcopay*lastyr
gen lcopay1_lastyr		=	lcopay1*lastyr

gen copay_firstyr		=	copay*firstyr
gen lcopay_firstyr		=	lcopay*firstyr
gen lcopay1_firstyr		=	lcopay1*firstyr

***********************************************************************
*generating granular insurance details
***********************************************************************


gen deductible_rate=.
replace deductible_rate=0 if PLAN==11
replace deductible_rate=.05 if PLAN==2 | PLAN==5 | PLAN==8 | PLAN==14
replace deductible_rate=.10 if PLAN==3 | PLAN==6 | PLAN==9 | PLAN==15
replace deductible_rate=.15 if PLAN==4 | PLAN==7 | PLAN==10 | PLAN==16
gen deductible_level=.
replace deductible_level=0 if PLAN==1
replace deductible_level=1000 if PLAN>=2 & PLAN<=10
replace deductible_level=1000 if PLAN>=14 & PLAN<=19




***********************************************************************
*aggregate plans further
***********************************************************************
generate EEPLAN=.
replace EEPLAN=1 if EPLAN==1|EPLAN==2|EPLAN==3
replace EEPLAN=2 if EPLAN==4
replace EEPLAN=3 if EPLAN==5
***********************************************************************
*label site
***********************************************************************
label define SITE_label 1 "Dayton" 2 "Seattle" 3 "Fitchburg" 4 "Franklin Co." 5 "Charleston" 6 "Georgetown Co."
label values SITE SITE_label
label var SITE "Site"
****************************
*generating a non-fixed age variable that indicates the participants age at the year of the contract*
********************************************************************************
	**AGE only indicates the age at enrollment**
generate age=AGE+CONTYR-1
drop if missing(AGE)
sort PERSON CONTYR

***replace yrsleft=0 if ENRTERM==5 & yrsleft==5
*replace yrsleft=0 if ENRTERM==3 & yrsleft==3
********************************************************************************


****************************************************************************
*generating a variable indicating the calendar year of the year in contract*
****************************************************************************
	**ENRDATE only indicates calendar year at enrollment**
tostring ENRDATE,replace
generate calyr=substr(ENRDATE,1,4)
destring calyr, replace
generate calyear=calyr+CONTYR-1
label var calyear "Calendar year"
order CONTYR ENRDATE calyr calyear
*****************************************************
*generating expenses that are adjusted for INFLATION*
*****************************************************
*load in CPI from PWT
compress
drop _m
save "$Path/data/randHIE_clean.dta", replace
clear all
import excel "$Path/data/pwt90.xlsx", sheet("Data") firstrow
keep if country=="United States"
keep year pl_con
rename year calyear
merge 1:m calyear using "$Path/data/randHIE_clean.dta"
keep if _m==3


order MEDDOL INPDOL OUTPDOL DRUGDOL SUPPDOL DENTDOL MENTDOL MDEOFF
foreach var of varlist *DOL *spend *spend_aef {
*real $
gen r`var'=`var'/pl_con
* log real $
gen lr`var'=log(1+r`var')
* indicator any spending
gen i`var'=.
replace i`var'=1 if `var'>0 & !missing(`var')
replace i`var'=0 if `var'==0
}
drop DDSVIS
gen hospVIS=TOTADM
order MDVIS NONMDVIS DENTVIS MENTVIS hospVIS
foreach var of varlist *VIS {
gen l`var'=log(1+`var')
gen i`var'=.
replace i`var'=1 if `var'>0 & !missing(`var')
replace i`var'=0 if `var'==0
*rename `var' r`var'
}

***********************************************************************
*generating a variable that captures ALL annual visits per participant*
***********************************************************************
*generate TotalVis=MENTVIS+DENTVIS+NONMDVIS+TOTADM+MATADM+PREGADM
********************************************************************


	**generating variable to indicate participants whith entries for full term**
duplicates tag PERSON, gen(dup_id)
tab dup_id
sort ENRTERM 
by ENRTERM: tab dup_id

*************************************************************************
*assigning a "numeric" variable to indicate each participant's unique id*
*************************************************************************
	**used when running a reghdfe model to capture individual fixed effects**
encode PERSON, gen(id)
encode BFAMILY, gen(fam_id)

by fam_id, sort: egen pl_con_base=min(pl_con)
gen rINCOME1=INCOME1/pl_con
label var rINCOME1 "Income"

********************************
*labelling variables for display*
********************************
				label variable ECOLLEGE "college attainment"
				label variable EGFPBAS	"health status"                                  
				label variable HSELFREP	"self-reported health characteristics"              
				label variable PAINBAS	"frequency of pain"                       
				label variable WORRYBAS	"worry about health"                                     
				label variable MARSTAT	"marital status"  

***********************************************************************
*label spending categories
***********************************************************************
foreach prefix in "" "r" "lr" "i" {
label var `prefix'MEDDOL "Medical"
label var `prefix'INPDOL "Inpatient"
label var `prefix'OUTPDOL "Outpatient"
label var `prefix'DRUGDOL "Drugs"
label var `prefix'SUPPDOL "Supplies"
label var `prefix'DENTDOL "Dental"
label var `prefix'MENTDOL "Mental"
}
foreach prefix in "" "l" "i" {
label var `prefix'MDVIS "MD"
label var `prefix'NONMDVIS "NONMD"
label var `prefix'DENTVIS "DENT"
label var `prefix'MENTVIS "MENT"
label var `prefix'hospVIS "HOSP"
*label var `prefix'DDSVIS "DDS"
}
foreach prefix in "r" "lr" "i" {
label var `prefix'inpspend "Inpatient"
label var `prefix'outpspend "Outpatient"
label var `prefix'totspend "Total"

label var `prefix'inpspend_aef "Inpatient"
label var `prefix'outpspend_aef "Outpatient"
label var `prefix'totspend_aef "Total"
}

****************************


*** ATTRITION
by id, sort: egen stayfor=count(CONTYR)
keep if stayfor==ENRTERM


*********************************
***** 4. Check for outliers *****
*********************************
tabstat  MEDDOL, stat(mean sd) save
matrix stats=r(StatTotal)
scalar avg=stats[1,1]
scalar stdv=stats[2,1]
gen outliers1=( MEDDOL>avg+3*stdv) | (MEDDOL<avg-3*stdv)
tabulate outliers1

by id, sort: egen outliers_any=max(outliers1)

***********************************************************************
*generate out of pocket total and shares
***********************************************************************
* nominal dollar amounts paid oop
gen amount_oop_tot=0
foreach cat in INP OUTP DRUG SUPP DENT MENT {
gen amount_oop_`cat'=copay_`cat'/100*`cat'DOL
replace amount_oop_tot=amount_oop_tot+amount_oop_`cat'
}
gen avg_copay_weighted=amount_oop_tot/totspend
* share paid oop
gen share_oop_tot=min(amount_oop_tot/totspend,MDEOFF/totspend)
* there are spikes in the pdf at .25, .5, .95 -- for those who do not exceed ded
*-uctible. also spikes at zero (free care) & 
by plan_aef, sort: egen share_oop_tot_plan=mean(share_oop_tot) if outliers_any!=1
by plan_aef, sort: egen avg_copay_weighted_plan=mean(avg_copay_weighted) if outliers_any!=1

gen oopay=share_oop_tot_plan*100
gen avgcopay=avg_copay_weighted_plan*100

* aggregate spending-weighted average coinsurance by plan
*(count aggregate spending by category within each plan, then weight plan coinsurance rates by those when taking average)
gen tempsum=0
foreach cat in INP OUTP DRUG SUPP DENT MENT {
by plan_aef, sort: egen tempsum`cat'=total(r`cat'DOL)
replace tempsum`cat'=tempsum`cat'
replace tempsum=tempsum+tempsum`cat'*copay_`cat'/100
}
by plan_aef, sort: egen tempdenom=total(rtotspend)
gen planavgcopay_=tempsum/tempdenom*100
drop temp*
by id, sort: egen planavgcopay=min(planavgcopay_)
drop planavgcopay_
tab planavg*


gen loopay=log(oopay)
gen loopay1=log(1+oopay)
gen oopay_lastyr		=	oopay*lastyr
gen loopay_lastyr		=	loopay*lastyr
gen loopay1_lastyr		=	loopay1*lastyr
***********************************************************************

* DEMEAN ALL CONTROLS
*set sample first, to make sure they're actually mean zero for the estimation sample

drop if missing(MEDDOL)
drop if missing(fam_id)

encode ENRDATE, gen(enrdate)

local sample_round=0
foreach sample in "" "outliers" {
preserve

if `sample_round'==0 {
drop if outliers_any==1
}

sum TINC
gen tinc=TINC-r(mean)
sum TINC if ENRTERM==3
gen s3_tinc=TINC-r(mean) if ENRTERM==3
sum TINC if ENRTERM==5
gen s5_tinc=TINC-r(mean) if ENRTERM==5

gen ENRTERM5=0
replace ENRTERM5=1 if ENRTERM==5
sum ENRTERM5
gen enrterm=ENRTERM5-r(mean)

replace age=63 if age==64
*create dummies and demean them all.
gen sex_str=string(SEX)
gen age_str=string(age)
gen sexage_str=string(SEX)+string(age)
drop age
gen sitecalyear_str=string(SITE)+string(calyear)
gen calyear_str=string(calyear)
drop calyear
gen siteenrdate_str=string(SITE)+string(enrdate)
gen enrdate_str=string(enrdate)
drop enrdate

*gen sexage_str=concat(string(SEX) string(age)) )
foreach var in sexage sex age sitecalyear calyear siteenrdate enrdate {
encode(`var'_str), gen(`var')
drop `var'_str
tab `var', gen(`var'_d)

foreach dum of varlist `var'_d* {
sum `dum'
replace `dum'=`dum'-r(mean)
///drop `var'_d1
}

foreach term in 3 5 {
foreach dum of varlist `var'_d* {
sum `dum' if ENRTERM==`term'
gen s`term'_`dum'=`dum'-r(mean)
///drop s`term'_`var'_d1
}
}

}




*

save "$Path/data/randHIE_clean`sample'.dta", replace
restore
local sample_round=`sample_round'+1
}

use "$Path/data/randHIE_cleanoutliers.dta", clear



