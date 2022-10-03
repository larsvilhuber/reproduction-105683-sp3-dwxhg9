local sample = "$sample"
use "$Path\data\randHIE_clean`sample'.dta", clear

********************************************************************************
* look at CONTYR fixed effects, controlled & not, SEPARATELY. compare to AEF
********************************************************************************

* This file produces panels C and D for figure 1.

gen tempctrlsb=.
foreach var of varlist rtotspend {
	eststo clear
	
	foreach term in 5 3 {

		local controls="s`term'_sexage_d* s`term'_tinc s`term'_siteenrdate_d*"
		local calyears="s`term'_calyear_d* "
		local samp=0
		
	foreach plansamp in "plan_aef==1" "plan_aef==6" {
		
		local samp=`samp'+1
		display "KKK"
*Look only at CONTYR FEs -- for unconditional PLOT
		xi: regress `var' contyr_* `calyears' if ENRTERM==`term' & `plansamp', cluster(fam_id) nocons
		matrix tempb=e(b)
		matrix tempb = tempb[1,1..`term']
		mat score fe_`var'_cyr_`term'_`samp'=tempb if e(sample)	
		matrix tempV=e(V)
		local I=`term'
		mat tempSE=J(1,`I',0)
		forval i=1/`I' {
		matrix tempSE[1,`i']=(tempV[`i',`i']^.5)*1.959964
		}
		mat tempU=tempSE+tempb
		mat tempL=-tempSE+tempb
		mat score fe_`var'_cyr_`term'U_`samp'=tempU if e(sample)
		mat score fe_`var'_cyr_`term'L_`samp'=tempL if e(sample)
		

* full set of controls
		eststo: xi: regress `var' contyr_*  `calyears' `controls' if ENRTERM==`term' & `plansamp', cluster(fam_id) nocons
		mat tempb=e(b)
		mat tempb=tempb[1,1..`term']
		mat score fe_`var'_cyr_`term'_ctrls_`samp'=tempb if e(sample)
		mat tempV=e(V)
		local I=`term'
		mat tempSE=J(1,`I',0)
		forval i=1/`I' {
		matrix tempSE[1,`i']=(tempV[`i',`i']^.5)*1.959964
		}
		mat tempU=tempSE+tempb
		mat tempL=-tempSE+tempb
		mat score fe_`var'_cyr_`term'U_ctrls_`samp'=tempU if e(sample)
		mat score fe_`var'_cyr_`term'L_ctrls_`samp'=tempL if e(sample)
		
		}
		}
* label as log or level
*local unit=" (level)"
if substr("`var'",1,1)=="l" {
local unit=" (log)"
}  
else {
local unit=""
}
* graphs for motivation
sort CONTYR
twoway (connected fe_`var'_cyr_5_1 CONTYR if ENRTERM==5, msize(large) msymbol(S) mcolor(orange) lcolor(orange)) ///
	   (connected fe_`var'_cyr_5_2 CONTYR if ENRTERM==5, msize(large) msymbol(Sh) mcolor(gold) lcolor(gold)) ///
	   (connected fe_`var'_cyr_3_1 CONTYR if ENRTERM==3, msize(large) msymbol(T) mcolor(teal) lcolor(teal)) ///
	   (connected fe_`var'_cyr_3_2 CONTYR if ENRTERM==3, msize(large) msymbol(Th) mcolor(blue) lcolor(blue)) ///
	   (rcap fe_`var'_cyr_5U_1 fe_`var'_cyr_5L_1 CONTYR if ENRTERM==5, lcolor(orange) lpattern(dash)) ///
	   (rcap fe_`var'_cyr_5U_2 fe_`var'_cyr_5L_2 CONTYR if ENRTERM==5, lcolor(gold) lpattern(dash)) ///
	   (rcap fe_`var'_cyr_3U_1 fe_`var'_cyr_3L_1 CONTYR if ENRTERM==3, lcolor(teal) lpattern(dash)) ///
	   (rcap fe_`var'_cyr_3U_2 fe_`var'_cyr_3L_2 CONTYR if ENRTERM==3, lcolor(blue) lpattern(dash)), ///
	   title("`:var label `var'' spending") ///
	   ytitle(2011`unit' USD) xtitle(Contract year) ///
	   legend(order(1 "5 year term, free care" 2 "5 year term, 95% coins." 3 "3 year term, free care" 4 "3 year term, 95% coins.")) graphregion(color(white)) name(unconditional, replace)
graph export "$Path\output\Figure_01c.pdf", replace
twoway (connected fe_`var'_cyr_5_ctrls_1 CONTYR if ENRTERM==5, lpattern(dash) msize(large) msymbol(S) mcolor(orange) lcolor(orange)) ///
	   (connected fe_`var'_cyr_5_ctrls_2 CONTYR if ENRTERM==5, lpattern(dash) msize(large) msymbol(Sh) mcolor(gold) lcolor(gold)) ///
	   (connected fe_`var'_cyr_3_ctrls_1 CONTYR if ENRTERM==3, lpattern(shortdash) msize(large) msymbol(T) mcolor(teal) lcolor(teal)) ///
	   (connected fe_`var'_cyr_3_ctrls_2 CONTYR if ENRTERM==3, lpattern(shortdash) msize(large) msymbol(Th) mcolor(blue) lcolor(blue)) ///
	   (rcap fe_`var'_cyr_5U_ctrls_1 fe_`var'_cyr_5L_ctrls_1 CONTYR if ENRTERM==5, lcolor(orange) lpattern(dash)) ///
	   (rcap fe_`var'_cyr_5U_ctrls_2 fe_`var'_cyr_5L_ctrls_2 CONTYR if ENRTERM==5, lcolor(gold) lpattern(dash)) ///
	   (rcap fe_`var'_cyr_3U_ctrls_1 fe_`var'_cyr_3L_ctrls_1 CONTYR if ENRTERM==3, lcolor(teal) lpattern(dash)) ///
	   (rcap fe_`var'_cyr_3U_ctrls_2 fe_`var'_cyr_3L_ctrls_2 CONTYR if ENRTERM==3, lcolor(blue) lpattern(dash)), ///
	   ytitle(2011`unit' USD) xtitle(Contract year) ///
	   title("`:var label `var'' spending (conditional)") ///
	   legend(order(1 "5 year term, free care" 2 "5 year term, 95% coins." 3 "3 year term, free care" 4 "3 year term, 95% coins.")) graphregion(color(white)) name(conditional, replace)
graph export "$Path\output\Figure_01d.pdf", replace
}
