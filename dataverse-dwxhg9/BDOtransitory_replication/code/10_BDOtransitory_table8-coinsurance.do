local sample = "$sample"
use "$Path/data/randHIE_clean`sample'.dta", clear


do "$Path/code/ArcElasticity_prices.ado"

* This file produces table 8 in the main document.

set seed 333

local starson=1


local demos="sexage_d* tinc"
local controls="calyear_d* siteenrdate_d*"

*USE ACTUAL PRICE

matrix p=[0,25,50,95]

foreach cat in INP OUTP DRUG SUPP DENT MENT {
ArcElasticity_prices_Cstar r`cat'DOL i.p4_`cat' enrterm `demos' `controls', cluster(fam_id)
quietly bs, cluster(fam_id) reps(999):  ArcElasticity_prices_Cstar r`cat'DOL i.p4_`cat' enrterm `demos' `controls', cluster(fam_id)
*quietly: ArcElasticity_levels_dif rtotspend i.plan_aef enrterm `demos' `controls', cluster(fam_id)

mat tempb_`cat'=e(b)
mat tempse_`cat'=e(se)

*** Make stars
forval i=1/2 {
* for elasticities & difs

test _b[avgAE_aef`i']=0
local tempp_aef`i'_`cat'=r(p)
test _b[avgAE_pxd`i']=0
local tempp_pxd`i'_`cat'=r(p)
* one-sided test for diff. so divide by 2
test _b[diff`i']=0
local tempp_dif`i'_`cat'=r(p)/2
test _b[ded`i']=0
local tempp_ded`i'_`cat'=r(p)

* for optimal coinsurance rates & difs

foreach r in "05" 1 2 5 {
test _b[Cstar_aef_`i'_r`r']=1
local tempp_C_aef`i'_`cat'_r`r'=r(p)
test _b[Cstar_pxd_`i'_r`r']=1
local tempp_C_pxd`i'_`cat'_r`r'=r(p)
test _b[Cstar_dif_`i'_r`r']=0
local tempp_C_dif`i'_`cat'_r`r'=r(p)/2
}
}

*di "`tempp_C_aef1_`cat'_r05'"
*}

*make some tables for displaying arc elasts and their SEs
}


foreach cat in INP OUTP DRUG SUPP DENT MENT {
* AVG ARC ELASTS -- ONE VARIABLE ***********************************************
local AEcomp_`cat'_row1_b="All plans&"+string(round(tempb_`cat'[1,19],.001), "%7.3f")+"&"+string(round(tempb_`cat'[1,20],.001), "%7.3f")+"&"+string(round(tempb_`cat'[1,21],.001), "%7.3f")+"//"
local AEcomp_`cat'_row1_se="&("+string(round(tempse_`cat'[1,19],.001), "%7.3f")+")&("+string(round(tempse_`cat'[1,20],.001), "%7.3f")+")&("+string(round(tempse_`cat'[1,21],.001), "%7.3f")+")//"
local AEcomp_`cat'_row2_b="Excluding free care&"+string(round(tempb_`cat'[1,22],.001), "%7.3f")+"&"+string(round(tempb_`cat'[1,23],.001), "%7.3f")+"&"+string(round(tempb_`cat'[1,24],.001), "%7.3f")+"//"
local AEcomp_`cat'_row2_se="&("+string(round(tempse_`cat'[1,22],.001), "%7.3f")+")&("+string(round(tempse_`cat'[1,23],.001), "%7.3f")+")&("+string(round(tempse_`cat'[1,24],.001), "%7.3f")+")//"

file open myfile using "$Path/output/randHIE_arcelast_avg_`cat'_prices`sample'.txt", write replace

file write myfile "`AEcomp_`cat'_row1_b'" _n
file write myfile "`AEcomp_`cat'_row1_se'" _n
file write myfile "`AEcomp_`cat'_row2_b'" _n
file write myfile "`AEcomp_`cat'_row2_se'" _n

file close myfile

}


* stars for coinsurance
local i=1
foreach cat in INP OUTP DRUG SUPP DENT MENT {
if `starson'==1 {
foreach spec in aef pxd dif {
foreach r in "05" 1 2 5 {
local stars_`spec'=""
di "`r'"
di "`spec'"
di "`tempp_C_`spec'`i'_`cat'_r`r''"
if `tempp_C_`spec'`i'_`cat'_r`r''<=.1 {
local stars_`spec'`i'_`cat'_r`r'="$^{*}$"
}
if `tempp_C_`spec'`i'_`cat'_r`r''<=.05 {
local stars_`spec'`i'_`cat'_r`r'="$^{**}$"
}
if `tempp_C_`spec'`i'_`cat'_r`r''<=.01 {
local stars_`spec'`i'_`cat'_r`r'="$^{***}$"
}
}
}
}

* make table rows for elasticities table
local AEcomp_row1_b="`AEcomp_row1_b'"+"&"+string(round(tempb_`cat'[1,19],.001), "%7.3f")+"`stars_aef'"
local AEcomp_row1_se="`AEcomp_row1_se'"+"&("+string(round(tempse_`cat'[1,19],.001), "%7.3f")+")"
local AEcomp_row2_b="`AEcomp_row2_b'"+"&"+string(round(tempb_`cat'[1,20],.001), "%7.3f")+"`stars_pxd'"
local AEcomp_row2_se="`AEcomp_row2_se'"+"&("+string(round(tempse_`cat'[1,20],.001), "%7.3f")+")"
local AEcomp_row3_b="`AEcomp_row3_b'"+"&"+string(round(tempb_`cat'[1,21],.001), "%7.3f")+"`stars_dif'"
local AEcomp_row3_se="`AEcomp_row3_se'"+"&("+string(round(tempse_`cat'[1,21],.001), "%7.3f")+")"
local AEcomp_row4_b="`AEcomp_row4_b'"+"&"+string(round(tempb_`cat'[1,25],.001), "%7.3f")+"`stars_ded'"
local AEcomp_row4_se="`AEcomp_row4_se'"+"&("+string(round(tempse_`cat'[1,25],.001), "%7.3f")+")"

}




* make table rows for coinsurance table -- aef *********************************
local i = 0
foreach spec in aef pxd dif {

local i = `i' + 1

*** coinsurance rates table

local Ccomp_`spec'_row1_b  = "$ r=0.00005$"
local Ccomp_`spec'_row1_se = ""
local Ccomp_`spec'_row2_b  = "$ r=0.0001$"
local Ccomp_`spec'_row2_se = ""
local Ccomp_`spec'_row3_b  = "$ r=0.0002$"
local Ccomp_`spec'_row3_se = ""
local Ccomp_`spec'_row4_b  = "$ r=0.0005$"
local Ccomp_`spec'_row4_se = ""
}
*
local spec = "aef"
foreach cat in INP OUTP DRUG SUPP DENT MENT {
local Ccomp_`spec'_row1_b="`Ccomp_`spec'_row1_b'"+"&"+string(round(tempb_`cat'[1,27],.001), "%7.3f")+"`stars_aef1_`cat'_r05'"
local Ccomp_`spec'_row1_se="`Ccomp_`spec'_row1_se'"+"&("+string(round(tempse_`cat'[1,27],.001), "%7.3f")+")"
local Ccomp_`spec'_row2_b="`Ccomp_`spec'_row2_b'"+"&"+string(round(tempb_`cat'[1,30],.001), "%7.3f")+"`stars_aef1_`cat'_r1'"
local Ccomp_`spec'_row2_se="`Ccomp_`spec'_row2_se'"+"&("+string(round(tempse_`cat'[1,30],.001), "%7.3f")+")"
local Ccomp_`spec'_row3_b="`Ccomp_`spec'_row3_b'"+"&"+string(round(tempb_`cat'[1,33],.001), "%7.3f")+"`stars_aef1_`cat'_r2'"
local Ccomp_`spec'_row3_se="`Ccomp_`spec'_row3_se'"+"&("+string(round(tempse_`cat'[1,33],.001), "%7.3f")+")"
local Ccomp_`spec'_row4_b="`Ccomp_`spec'_row4_b'"+"&"+string(round(tempb_`cat'[1,36],.001), "%7.3f")+"`stars_aef1_`cat'_r5'"
local Ccomp_`spec'_row4_se="`Ccomp_`spec'_row4_se'"+"&("+string(round(tempse_`cat'[1,36],.001), "%7.3f")+")"
}
local spec = "pxd"
foreach cat in INP OUTP DRUG SUPP DENT MENT {
local Ccomp_`spec'_row1_b="`Ccomp_`spec'_row1_b'"+"&"+string(round(tempb_`cat'[1,28],.001), "%7.3f")+"`stars_aef1_`cat'_r05'"
local Ccomp_`spec'_row1_se="`Ccomp_`spec'_row1_se'"+"&("+string(round(tempse_`cat'[1,28],.001), "%7.3f")+")"
local Ccomp_`spec'_row2_b="`Ccomp_`spec'_row2_b'"+"&"+string(round(tempb_`cat'[1,31],.001), "%7.3f")+"`stars_aef1_`cat'_r1'"
local Ccomp_`spec'_row2_se="`Ccomp_`spec'_row2_se'"+"&("+string(round(tempse_`cat'[1,31],.001), "%7.3f")+")"
local Ccomp_`spec'_row3_b="`Ccomp_`spec'_row3_b'"+"&"+string(round(tempb_`cat'[1,34],.001), "%7.3f")+"`stars_aef1_`cat'_r2'"
local Ccomp_`spec'_row3_se="`Ccomp_`spec'_row3_se'"+"&("+string(round(tempse_`cat'[1,34],.001), "%7.3f")+")"
local Ccomp_`spec'_row4_b="`Ccomp_`spec'_row4_b'"+"&"+string(round(tempb_`cat'[1,37],.001), "%7.3f")+"`stars_aef1_`cat'_r5'"
local Ccomp_`spec'_row4_se="`Ccomp_`spec'_row4_se'"+"&("+string(round(tempse_`cat'[1,37],.001), "%7.3f")+")"
}
local spec = "dif"
foreach cat in INP OUTP DRUG SUPP DENT MENT {
local Ccomp_`spec'_row1_b="`Ccomp_`spec'_row1_b'"+"&"+string(round(tempb_`cat'[1,29],.001), "%7.3f")+"`stars_aef1_`cat'_r05'"
local Ccomp_`spec'_row1_se="`Ccomp_`spec'_row1_se'"+"&("+string(round(tempse_`cat'[1,29],.001), "%7.3f")+")"
local Ccomp_`spec'_row2_b="`Ccomp_`spec'_row2_b'"+"&"+string(round(tempb_`cat'[1,32],.001), "%7.3f")+"`stars_aef1_`cat'_r1'"
local Ccomp_`spec'_row2_se="`Ccomp_`spec'_row2_se'"+"&("+string(round(tempse_`cat'[1,32],.001), "%7.3f")+")"
local Ccomp_`spec'_row3_b="`Ccomp_`spec'_row3_b'"+"&"+string(round(tempb_`cat'[1,35],.001), "%7.3f")+"`stars_aef1_`cat'_r2'"
local Ccomp_`spec'_row3_se="`Ccomp_`spec'_row3_se'"+"&("+string(round(tempse_`cat'[1,35],.001), "%7.3f")+")"
local Ccomp_`spec'_row4_b="`Ccomp_`spec'_row4_b'"+"&"+string(round(tempb_`cat'[1,38],.001), "%7.3f")+"`stars_aef1_`cat'_r5'"
local Ccomp_`spec'_row4_se="`Ccomp_`spec'_row4_se'"+"&("+string(round(tempse_`cat'[1,38],.001), "%7.3f")+")"
}

********************************************************************************

foreach spec in aef pxd dif {
local Ccomp_`spec'_row1_b="`Ccomp_`spec'_row1_b'"+"//"
local Ccomp_`spec'_row1_se="`Ccomp_`spec'_row1_se'"+"//"
local Ccomp_`spec'_row2_b="`Ccomp_`spec'_row2_b'"+"//"
local Ccomp_`spec'_row2_se="`Ccomp_`spec'_row2_se'"+"//"
local Ccomp_`spec'_row3_b="`Ccomp_`spec'_row3_b'"+"//"
local Ccomp_`spec'_row3_se="`Ccomp_`spec'_row3_se'"+"//"
local Ccomp_`spec'_row4_b="`Ccomp_`spec'_row4_b'"+"//"
local Ccomp_`spec'_row4_se="`Ccomp_`spec'_row4_se'"+"//"
}




* write coinsurance tables

foreach spec in aef pxd dif {
file open myfile using "$Path/output/Table_08.txt", write replace

file write myfile "`Ccomp_`spec'_row1_b'" _n
file write myfile "`Ccomp_`spec'_row1_se'" _n
file write myfile "`Ccomp_`spec'_row2_b'" _n
file write myfile "`Ccomp_`spec'_row2_se'" _n
file write myfile "`Ccomp_`spec'_row3_b'" _n
file write myfile "`Ccomp_`spec'_row3_se'" _n
file write myfile "`Ccomp_`spec'_row4_b'" _n
file write myfile "`Ccomp_`spec'_row4_se'" _n

file close myfile
}