local sample = "$sample"
use "$Path\data\randHIE_clean`sample'.dta", clear

********************************************************************************
* look at CONTYR fixed effects, controlled & not, SEPARATELY. compare to AEF
********************************************************************************

* This file produces panels A and B for figure 1.

gen tempctrlsb=.
foreach var of varlist rtotspend {
	eststo clear
	
	foreach term in 5 3 {
	
		local controls="s`term'_sexage_d* s`term'_tinc s`term'_siteenrdate_d*"
		local calyears="s`term'_calyear_d* "
		
* only calendar year controls
		xi: regress `var' contyr_* `calyears' if ENRTERM==`term', cluster(fam_id) nocons
		matrix tempb=e(b)
		matrix tempb = tempb[1,1..`term']
		mat score fe_`var'_cyr_`term'=tempb if e(sample)	
		matrix tempV=e(V)
		local I=`term'
		mat tempSE=J(1,`I',0)
		forval i=1/`I' {
		matrix tempSE[1,`i']=(tempV[`i',`i']^.5)*1.959964
		}
		mat tempU=tempSE+tempb
		mat tempL=-tempSE+tempb
		mat score fe_`var'_cyr_`term'U=tempU if e(sample)
		mat score fe_`var'_cyr_`term'L=tempL if e(sample)
		
		
* full set of controls
		eststo: xi: regress `var' contyr_* `calyears' `controls' if ENRTERM==`term' , cluster(fam_id) nocons
		mat tempb=e(b)
		mat tempb=tempb[1,1..`term']
		mat score fe_`var'_cyr_`term'_ctrls=tempb if e(sample)
		mat tempV=e(V)
		local I=`term'
		mat tempSE=J(1,`I',0)
		forval i=1/`I' {
		matrix tempSE[1,`i']=(tempV[`i',`i']^.5)*1.959964
		}
		mat tempU=tempSE+tempb
		mat tempL=-tempSE+tempb
		mat score fe_`var'_cyr_`term'U_ctrls=tempU if e(sample)
		mat score fe_`var'_cyr_`term'L_ctrls=tempL if e(sample)
		

		}
* label as log or level
*local unit=" (level)"
if substr("`var'",1,1)=="l" {
local unit=" log"
}  
else {
local unit=""
}
* graphs for motivation
sort CONTYR
twoway (connected fe_`var'_cyr_5 CONTYR if ENRTERM==5, msize(large) msymbol(S) mcolor(red) lcolor(red)) ///
	   (connected fe_`var'_cyr_3 CONTYR if ENRTERM==3, msize(large) msymbol(T) mcolor(green) lcolor(green)) ///
	   (rcap fe_`var'_cyr_5U fe_`var'_cyr_5L CONTYR if ENRTERM==5, lcolor(red) lpattern(dash)) ///
	   (rcap fe_`var'_cyr_3U fe_`var'_cyr_3L CONTYR if ENRTERM==3, lcolor(green) lpattern(dash)), ///
	   title("`:var label `var'' spending") ///
	   ytitle(2011`unit' USD) xtitle(Contract year) ///
	   legend(order(1 "5 year term" 2 "3 year term")) graphregion(color(white)) name(unconditional, replace)
graph export "$Path\output\Figure_01a.pdf", replace
twoway (connected fe_`var'_cyr_5_ctrls CONTYR if ENRTERM==5, lpattern(dash) msize(large) msymbol(S) mcolor(red)  lcolor(red)) ///
	   (connected fe_`var'_cyr_3_ctrls CONTYR if ENRTERM==3, lpattern(shortdash) msize(large) msymbol(T) mcolor(green) lcolor(green)) ///
	   (rcap fe_`var'_cyr_5U_ctrls fe_`var'_cyr_5L_ctrls CONTYR if ENRTERM==5, lcolor(red) lpattern(dash)) ///
	   (rcap fe_`var'_cyr_3U_ctrls fe_`var'_cyr_3L_ctrls CONTYR if ENRTERM==3, lcolor(green) lpattern(dash)), ///
	   ytitle(2011`unit' USD) xtitle(Contract year) ///
	   title("`:var label `var'' spending (conditional)") ///
	   legend(order(1 "5 year term" 2 "3 year term")) graphregion(color(white)) name(conditional, replace)
graph export "$Path\output\Figure_01b.pdf", replace
}

