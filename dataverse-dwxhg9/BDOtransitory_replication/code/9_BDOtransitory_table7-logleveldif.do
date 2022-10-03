local sample = "$sample"
clear
set more off

*****************
use "$Path\data\randHIE_clean`sample'.dta", clear


local starson=1

local demos="sexage_d* tinc"
local controls="calyear_d* siteenrdate_d*"

*USE ACTUAL PRICE

matrix p=[0,25,50,95]

foreach cat in INP OUTP DRUG SUPP DENT MENT {
eststo clear
eststo: xi: regress lr`cat' 	 lcopay1_`cat' 				 				enrterm `demos' `controls'
matrix tempb_aef1_`cat'=e(b)
local lambda_aef1_`cat'=tempb_aef1_`cat'[1,1]
matrix tempV_aef1_`cat'=e(V)
local lambda_aef1_`cat'_se=tempV_aef1_`cat'[1,1]^.5
eststo: xi: regress lr`cat' 	lastyr lcopay1_`cat' 		lcopay1_`cat'_lastyr 	enrterm `demos' `controls'
matrix tempb_pxd1_`cat'=e(b)
local lambda_pxd1_`cat'=tempb_pxd1_`cat'[1,2]
matrix tempV_pxd1_`cat'=e(V)
local lambda_pxd1_`cat'_se=tempV_pxd1_`cat'[2,2]^.5

local lambda_dif1_`cat'=`lambda_aef1_`cat''-`lambda_pxd1_`cat''
di `lambda_aef1_`cat''
di `lambda_pxd1_`cat''

local lambda_ded1_`cat' = tempb_pxd1_`cat'[1,2] + tempb_pxd1_`cat'[1,3]

forval i=1/2 {
quietly suest est1 est2, cluster(fam_id)

test _b[est1_mean:lcopay1_`cat']=0
local tempp_aef`i'_`cat'=r(p)

test _b[est2_mean:lcopay1_`cat']=0
local tempp_pxd`i'_`cat'=r(p)

test _b[est1_mean:lcopay1_`cat']=_b[est2_mean:lcopay1_`cat']
local tempp_dif`i'_`cat'=r(p)

test _b[est2_mean:lcopay1_`cat'_lastyr]+_b[est2_mean:lcopay1_`cat']=0
local tempp_ded`i'_`cat'=r(p)
}
}
*make some tables for displaying arc elasts and their SEs


*local loglog_row1_b="Model (\ref{eq:aef})"
*local loglog_row1_se=""
*local loglog_row2_b="Model (\ref{eq:deadline})"
local loglog_row1_b="(i) All Years"
local loglog_row1_se=""
local loglog_row2_b="(ii) D. Years Excl."
local loglog_row2_se=""
local loglog_row3_b="(iii) Diff. (i) - (ii)"
local loglog_row3_se=""
local loglog_row4_b="(iv) Deadline Years"
local loglog_row4_se=""

foreach cat in INP OUTP DRUG SUPP DENT MENT {
if `starson'==1 {
foreach spec in aef pxd  ded {
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
* one-sided test for dif
foreach spec in dif {
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
}

local loglog_row1_b="`loglog_row1_b'"+"&"+string(round(`lambda_aef1_`cat'',.001), "%7.3f")+"`stars_aef'"
local loglog_row1_se="`loglog_row1_se'"+"&("+string(round(`lambda_aef1_`cat'_se',.001), "%7.3f")+")"
local loglog_row2_b="`loglog_row2_b'"+"&"+string(round(`lambda_pxd1_`cat'',.001), "%7.3f")+"`stars_pxd'"
local loglog_row2_se="`loglog_row2_se'"+"&("+string(round(`lambda_pxd1_`cat'_se',.001), "%7.3f")+")"
local loglog_row3_b="`loglog_row3_b'"+"&"+string(round(`lambda_dif1_`cat'',.001), "%7.3f")+"`stars_dif'"
local loglog_row3_se="`loglog_row3_se'"+"&("+string(round(`tempp_dif1_`cat'',.001), "%7.3f")+")"
local loglog_row4_b="`loglog_row4_b'"+"&"+string(round(`lambda_ded1_`cat'',.001), "%7.3f")+"`stars_ded'"
local loglog_row4_se="`loglog_row4_se'"+"&("+string(round(`tempp_ded1_`cat'',.001), "%7.3f")+")"

}
local loglog_row1_b="`loglog_row1_b'"+"\\"
local loglog_row1_se="`loglog_row1_se'"+"\\"
local loglog_row2_b="`loglog_row2_b'"+"\\"
local loglog_row2_se="`loglog_row2_se'"+"\\"
local loglog_row3_b="`loglog_row3_b'"+"\\"
local loglog_row3_se="`loglog_row3_se'"+"\\"
local loglog_row4_b="`loglog_row4_b'"+"\\"
local loglog_row4_se="`loglog_row4_se'"+"\\"

file open myfile using "$Path\output\Table_07.txt", write replace

file write myfile "&Inpatient&Outpatient&Drugs&Supplies&Dental&Mental Health\\" _n
file write myfile "\hline" _n
file write myfile "`loglog_row1_b'" _n
file write myfile "`loglog_row1_se'" _n
file write myfile "`loglog_row2_b'" _n
file write myfile "`loglog_row2_se'" _n
file write myfile "`loglog_row3_b'" _n
file write myfile "`loglog_row3_se'" _n
file write myfile "`loglog_row4_b'" _n
file write myfile "`loglog_row4_se'" _n
file write myfile "\hline" _n

file close myfile
