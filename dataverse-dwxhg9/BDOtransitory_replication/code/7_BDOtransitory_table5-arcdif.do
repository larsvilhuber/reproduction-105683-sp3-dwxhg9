local sample = "$sample"
use "$Path/data/randHIE_clean`sample'.dta", clear


do "$Path/code/ArcElasticity_prices.ado"

* This file produces table 5 in the main document. 

set seed 333

local starson=1


local demos="sexage_d* tinc"
local controls="calyear_d* siteenrdate_d*"

*USE ACTUAL PRICE

matrix p=[0,25,50,95]

foreach cat in INP OUTP DRUG SUPP DENT MENT {
ArcElasticity_prices r`cat'DOL i.p4_`cat' enrterm `demos' `controls', cluster(fam_id)
quietly bs, cluster(fam_id) reps(999):  ArcElasticity_prices r`cat'DOL i.p4_`cat' enrterm `demos' `controls', cluster(fam_id)
*quietly: ArcElasticity_levels_dif rtotspend i.plan_aef enrterm `demos' `controls', cluster(fam_id)

mat tempb_`cat'=e(b)
mat tempse_`cat'=e(se)

forval i=1/2 {
test _b[avgAE_aef`i']=0
local tempp_aef`i'_`cat'=r(p)
test _b[avgAE_pxd`i']=0
local tempp_pxd`i'_`cat'=r(p)
* one-sided test for diff. so divide by 2
test _b[diff`i']=0
local tempp_dif`i'_`cat'=r(p)/2
test _b[ded`i']=0
local tempp_ded`i'_`cat'=r(p)
}

*make some tables for displaying arc elasts and their SEs

*****PAIRWISE TABLES************************************************************
local ii=0
foreach spec in "aef" "pxd" "dif" {
local `spec'mat_`cat'row1_b="Free care"
local `spec'mat_`cat'row2_b="25/%"
local `spec'mat_`cat'row3_b="50/%"
forval i=1/3 {
forval r=2/`i' {
local `spec'mat_`cat'row`i'_b="``spec'mat_`cat'row`i'_b'"+"&"
local `spec'mat_`cat'row`i'_se="``spec'mat_`cat'row`i'_se'"+"&"
}
forval j=`i'/3 {
local `spec'mat_`cat'row`i'_b="``spec'mat_`cat'row`i'_b'"+"&"+string(round(tempb_`cat'[1,`ii'+`j'],.001))
local `spec'mat_`cat'row`i'_se="``spec'mat_`cat'row`i'_se'"+"&("+string(round(tempse_`cat'[1,`ii'+`j'],.001))+")"
}
local ii=`ii'+3-`i'
}
local ii=`ii'+3
}

foreach spec in "aef" "pxd" {
forval i=1/3 {
display "``spec'mat_`cat'row`i'_b'"
display "``spec'mat_`cat'row`i'_se'"
display""
}
display "`ii'"
}

foreach spec in "aef" "pxd" "dif" {
file open myfile using "$Path/output/randHIE_arcelast_pairwise_`spec'_`cat'_prices`sample'.txt", write replace

file write myfile "``spec'mat_`cat'row1_b'//" _n
file write myfile "``spec'mat_`cat'row1_se'//" _n
file write myfile "``spec'mat_`cat'row2_b'//" _n
file write myfile "``spec'mat_`cat'row2_se'//" _n
file write myfile "``spec'mat_`cat'row3_b'//" _n
file write myfile "``spec'mat_`cat'row3_se'//" _n

file close myfile
}
************END PAIRWISE TABLES*************************************************
}

foreach cat in INP OUTP DRUG SUPP DENT MENT {
* AVG ARC ELASTS -- ONE VARIABLE ***********************************************
local AEcomp_`cat'_row1_b="All plans&"+string(round(tempb_`cat'[1,19],.001))+"&"+string(round(tempb_`cat'[1,20],.001))+"&"+string(round(tempb_`cat'[1,21],.001))+"//"
local AEcomp_`cat'_row1_se="&("+string(round(tempse_`cat'[1,19],.001))+")&("+string(round(tempse_`cat'[1,20],.001))+")&("+string(round(tempse_`cat'[1,21],.001))+")//"
local AEcomp_`cat'_row2_b="Excluding free care&"+string(round(tempb_`cat'[1,22],.001))+"&"+string(round(tempb_`cat'[1,23],.001))+"&"+string(round(tempb_`cat'[1,24],.001))+"//"
local AEcomp_`cat'_row2_se="&("+string(round(tempse_`cat'[1,22],.001))+")&("+string(round(tempse_`cat'[1,23],.001))+")&("+string(round(tempse_`cat'[1,24],.001))+")//"

file open myfile using "$Path/output/randHIE_arcelast_avg_`cat'_prices`sample'.txt", write replace

file write myfile "`AEcomp_`cat'_row1_b'" _n
file write myfile "`AEcomp_`cat'_row1_se'" _n
file write myfile "`AEcomp_`cat'_row2_b'" _n
file write myfile "`AEcomp_`cat'_row2_se'" _n

file close myfile

}


*local AEcomp_row1_b="Model (/ref{eq:aef})"
*local AEcomp_row1_se=""
*local AEcomp_row2_b="Model (/ref{eq:deadline})"
local AEcomp_row1_b="(i) All Years"
local AEcomp_row1_se=""
local AEcomp_row2_b="(ii) Non-deadline Years"
local AEcomp_row2_se=""
local AEcomp_row3_b="(iii) Difference (i) - (ii)"
local AEcomp_row3_se=""
local AEcomp_row4_b="(iv) Deadline Years"
local AEcomp_row4_se=""

foreach cat in INP OUTP DRUG SUPP DENT MENT {
if `starson'==1 {
foreach spec in aef pxd dif ded {
local stars_`spec'=""
if `tempp_`spec'1_`cat''<=.1 {
local stars_`spec'="$^{*}$"
}
if `tempp_`spec'1_`cat''<=.05 {
local stars_`spec'="$^{**}$"
}
if `tempp_`spec'1_`cat''<=.01 {
local stars_`spec'="$^{***}$"
}
}
}

local AEcomp_row1_b="`AEcomp_row1_b'"+"&"+string(round(tempb_`cat'[1,19],.001), "%7.3f")+"`stars_aef'"
local AEcomp_row1_se="`AEcomp_row1_se'"+"&("+string(round(tempse_`cat'[1,19],.001), "%7.3f")+")"
local AEcomp_row2_b="`AEcomp_row2_b'"+"&"+string(round(tempb_`cat'[1,20],.001), "%7.3f")+"`stars_pxd'"
local AEcomp_row2_se="`AEcomp_row2_se'"+"&("+string(round(tempse_`cat'[1,20],.001), "%7.3f")+")"
local AEcomp_row3_b="`AEcomp_row3_b'"+"&"+string(round(tempb_`cat'[1,21],.001), "%7.3f")+"`stars_dif'"
local AEcomp_row3_se="`AEcomp_row3_se'"+"&("+string(round(tempse_`cat'[1,21],.001), "%7.3f")+")"
local AEcomp_row4_b="`AEcomp_row4_b'"+"&"+string(round(tempb_`cat'[1,25],.001), "%7.3f")+"`stars_ded'"
local AEcomp_row4_se="`AEcomp_row4_se'"+"&("+string(round(tempse_`cat'[1,25],.001), "%7.3f")+")"

}
local AEcomp_row1_b="`AEcomp_row1_b'"+"//"
local AEcomp_row1_se="`AEcomp_row1_se'"+"//"
local AEcomp_row2_b="`AEcomp_row2_b'"+"//"
local AEcomp_row2_se="`AEcomp_row2_se'"+"//"
local AEcomp_row3_b="`AEcomp_row3_b'"+"//"
local AEcomp_row3_se="`AEcomp_row3_se'"+"//"
local AEcomp_row4_b="`AEcomp_row4_b'"+"//"
local AEcomp_row4_se="`AEcomp_row4_se'"+"//"

file open myfile using "$Path/output/Table_05.txt", write replace

file write myfile "`AEcomp_row1_b'" _n
file write myfile "`AEcomp_row1_se'" _n
file write myfile "`AEcomp_row2_b'" _n
file write myfile "`AEcomp_row2_se'" _n
file write myfile "`AEcomp_row3_b'" _n
file write myfile "`AEcomp_row3_se'" _n
file write myfile "`AEcomp_row4_b'" _n
file write myfile "`AEcomp_row4_se'" _n

file close myfile
