local sample = "$sample"
use "$Path/data/randHIE_clean`sample'.dta", clear
set matsize 800

* This file produces table 4 in the main document.

local demos="sexage_d* tinc"
local controls="calyear_d* siteenrdate_d*"

keep if !missing(fam_id)

gen tempctrlsb=.
foreach cat in "INP" "OUTP" "DRUG" "SUPP" "DENT" "MENT"  {
eststo clear

eststo:	xi: regress r`cat'DOL 		i.p4_`cat'  						 	enrterm `demos' `controls'
		xi: regress r`cat'DOL 		i.p4_`cat'  						 	enrterm `demos' `controls', cluster(fam_id)
** recover plan fixed effects for ARC elasticities
matrix tempb=e(b)
matrix plan_fe_aef_`cat'=tempb[1,1..3]
matrix plan_lvl_aef_`cat'=_b[_cons]*[1,1,1,1]+[0,tempb[1,1..3]]


eststo:	xi: regress r`cat'DOL 		i.p4_`cat'  lastyr		i.p4_`cat'T 	enrterm `demos' `controls'
		xi: regress r`cat'DOL 		i.p4_`cat'  lastyr		i.p4_`cat'T 	enrterm `demos' `controls', cluster(fam_id)
** recover plan fixed effects for ARC elasticities (pxd=price*deadline)
matrix tempb=e(b)
matrix plan_fe_pxd_`cat'=tempb[1,1..3]
matrix plan_lvl_pxd_`cat'=_b[_cons]*[1,1,1,1]+[0,tempb[1,1..3]]


mat plan_lvl_dif_`cat'=plan_lvl_aef_`cat'-plan_lvl_pxd_`cat'
mat plan_fe_dif_`cat'=plan_fe_aef_`cat'-plan_fe_pxd_`cat'


**TEST DIFFs************NOT ARC ELAST*******************************************
display "`cat'"
*levels
quietly suest est1 est2, cluster(fam_id)
*** first test level to level. here we include constants (free care category)
* test constants (free care plan -- base category)
test _b[est1_mean:_cons]=_b[est2_mean:_cons]
local level_p_`cat'_1=round(`r(p)',.001)

foreach plan in 2 3 4 {
test _b[est1_mean:_Ip4_`cat'_`plan']+_b[est1_mean:_cons]=_b[est2_mean:_Ip4_`cat'_`plan']+_b[est2_mean:_cons]
local level_p_`cat'_`plan'=round(`r(p)',.001)
}


*test joint hypothesis -- include free care
test (_b[est1_mean:_cons]=_b[est2_mean:_cons]) ///
	 (_b[est1_mean:_Ip4_`cat'_2]+_b[est1_mean:_cons]=_b[est2_mean:_Ip4_`cat'_2]+_b[est2_mean:_cons]) ///
	 (_b[est1_mean:_Ip4_`cat'_3]+_b[est1_mean:_cons]=_b[est2_mean:_Ip4_`cat'_3]+_b[est2_mean:_cons]) ///
	 (_b[est1_mean:_Ip4_`cat'_4]+_b[est1_mean:_cons]=_b[est2_mean:_Ip4_`cat'_4]+_b[est2_mean:_cons]) 
local level_p_`cat'_all=round(`r(p)',.001)

* test plan effects for other plans
foreach plan in 2 3 4 {
test _b[est1_mean:_Ip4_`cat'_`plan']=_b[est2_mean:_Ip4_`cat'_`plan']
local linear_p_`cat'_`plan'=round(`r(p)',.001)
}
*test joint hypothesis -- include free care
test (_b[est1_mean:_Ip4_`cat'_2]=_b[est2_mean:_Ip4_`cat'_2]) ///
	 (_b[est1_mean:_Ip4_`cat'_3]=_b[est2_mean:_Ip4_`cat'_3]) ///
	 (_b[est1_mean:_Ip4_`cat'_4]=_b[est2_mean:_Ip4_`cat'_4]) 
local linear_p_`cat'_all=round(`r(p)',.001)


*write lines to collect p values
*local line0="`line0'"+"&/multicolumn{2}{c}{`cat'}"
local line0="`line0'"+"&`cat'"
*local line1="`line1'"+"&level&log"
foreach plan in 2 3 4 {
local i=`plan'-1
	local linear_se_`cat'_`plan' = abs(plan_fe_dif_`cat'[1,`i']/invnormal(1-`linear_p_`cat'_`plan''))
local line_se_`plan'="`line_se_`plan''"+"&"+"`line_se_`cat'_`plan''"
local stars=""
if `linear_p_`cat'_`plan''<=.1 {
local stars="*"
}
if `linear_p_`cat'_`plan''<=.05 {
local stars="**"
}
if `linear_p_`cat'_`plan''<=.01 {
local stars="***"
}
local line`plan'="`line`plan''"+"&"+string(round(plan_fe_dif_`cat'[1,`i'],.01))+"`stars'"
}

foreach plan in 1 2 3 4 {
	local level_se_`cat'_`plan' = abs(plan_lvl_dif_`cat'[1,`i']/invnormal(`level_p_`cat'_`plan''))
local level_se_`plan'="`level_se_`plan''"+"&("+string(round(`level_p_`cat'_`plan'',.01), "%7.2f")+")"
	local stars=""
if `level_p_`cat'_`plan''<=.1 {
local stars="*"
}
if `level_p_`cat'_`plan''<=.05 {
local stars="**"
}
if `level_p_`cat'_`plan''<=.01 {
local stars="***"
}
local level`plan'="`level`plan''"+"&"+string(round(plan_lvl_dif_`cat'[1,`plan'],.01), "%7.2f")+"`stars'"
*+"&"+substr("`log_p_`cat'_`plan''",1,3)
}
local lineall="`lineall'"+"&"+substr("`linear_p_`cat'_all'",1,3)
local levelall="`levelall'"+"&"+string(real(substr("`level_p_`cat'_all'",1,3)), "%7.2f")
*/TEST DIFFs************NOT ARC ELAST*******************************************
}
di "`lineall'"
di "`levelall'"












***** prepare p values table (testing equality of plan FEs across specs)
foreach plan in 0 1 2 3 4 {
local line`plan'="`line`plan''"+"//"
display "`line`plan''"
local level`plan'="`level`plan''"+"//"
local level_se_`plan'="`level_se_`plan''"+"//"
}
local lineall="`lineall'"+"//"
local levelall="`levelall'"+"//"


file open myfile using "$Path/output/Table_04.txt", write replace

file write myfile "Free care`level1'" _n
file write myfile " $ p(/hat/lambda_{free}=/hat/lambda_{free}^*)$ `level_se_1'" _n
file write myfile "25/% coinsurance`level2'" _n
file write myfile " $ p(/hat/lambda_{25}=/hat/lambda_{25}^*)$ `level_se_2'" _n
file write myfile "50/% coinsurance`level3'" _n
file write myfile " $ p(/hat/lambda_{50}=/hat/lambda_{50}^*)$ `level_se_3'" _n
file write myfile "95/% coinsurance`level4'" _n
file write myfile " $ p(/hat/lambda_{95}=/hat/lambda_{95}^*)$ `level_se_4'" _n
file write myfile "/hline" _n
file write myfile "Joint test $ p(/hat/lambda=/hat/lambda^*)$ `levelall'" _n
file write myfile "/hline" _n
file write myfile "/hline"

file close myfile
