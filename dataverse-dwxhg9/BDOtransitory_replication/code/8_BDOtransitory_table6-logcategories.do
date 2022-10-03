local sample = "$sample"
use "$Path/data/randHIE_clean`sample'.dta", clear

* This file produces table 6 in the main document.

local demos="sexage_d* tinc"
local controls="calyear_d* siteenrdate_d*"

eststo clear
foreach cat in "INP" "OUTP" "DRUG" "SUPP" "DENT" "MENT"  {

eststo: quietly: xi: regress lr`cat'DOL 	lastyr lcopay1_`cat' 		lcopay1_`cat'_lastyr 	enrterm `demos' `controls', cluster(fam_id)
}
********************************************
*make labels for tables******* must repeat *

label var lastyr 			"D.year"
label var copay 			"Coins."
label var copay_lastyr 		"Coins.$/times$ D.year"
label var lcopay1			"Log(coins.)"
label var lcopay1_lastyr 	"Log(coins.)$/times$ D.year"
label var lcopay			"Log(coins.)"
label var lcopay_lastyr 	"Log(coins.)$/times$ D.year"
foreach var2 of varlist lcopay1* {
label var `var2' "Log(coins.)"
}
foreach var2 of varlist lcopay1*lastyr {
label var `var2' "Log(coins.)$/times$ D.year"
}
label var enrterm "Enrol. term = 5"

********************************************

estout, style(tex) ///
		cells(b(star fmt(%7.2f)) se(par)) stats(N r2, labels ("N" "R$^2$") fmt(%7.2f)) /// 
		label varlabels(_cons Constant) ///
		starlevels(* .1 ** .05 *** .01) ///
		order(_cons lastyr lcopay1_* lcopay1*lastyr) ///
		rename(lcopay1_OUTP lcopay1_INP lcopay1_DRUG lcopay1_INP lcopay1_SUPP lcopay1_INP lcopay1_DENT lcopay1_INP lcopay1_MENT lcopay1_INP /// 
		lcopay1_OUTP_lastyr lcopay1_INP_lastyr lcopay1_DRUG_lastyr lcopay1_INP_lastyr lcopay1_SUPP_lastyr lcopay1_INP_lastyr lcopay1_DENT_lastyr lcopay1_INP_lastyr lcopay1_MENT_lastyr lcopay1_INP_lastyr) /// 
		mlabels("Inpatient" "Outpatient" "Drugs" "Supplies" "Dental" "Mental Health") ///
indicate("Site $/times$ enrol.=siteenrdate_d*" "Cal. years=calyear_d*" "Demographics=sexage_d* tinc")
*
estout using "$Path/output/Table_06.txt", replace style(tex) ///
		cells(b(star fmt(%7.2f)) se(par)) stats(N r2, labels ("N" "R$^2$") fmt(%7.2f)) /// 
		label varlabels(_cons Constant) ///
		starlevels(* .1 ** .05 *** .01) ///
		order(_cons lastyr lcopay1_* lcopay1*lastyr) ///
		rename(lcopay1_OUTP_lastyr lcopay1_INP_lastyr lcopay1_DRUG_lastyr lcopay1_INP_lastyr lcopay1_SUPP_lastyr lcopay1_INP_lastyr lcopay1_DENT_lastyr lcopay1_INP_lastyr lcopay1_MENT_lastyr lcopay1_INP_lastyr /// 
		lcopay1_OUTP lcopay1_INP lcopay1_DRUG lcopay1_INP lcopay1_SUPP lcopay1_INP lcopay1_DENT lcopay1_INP lcopay1_MENT lcopay1_INP) /// 
		mlabels("Inpatient" "Outpatient" "Drugs" "Supplies" "Dental" "Mental Health") ///
indicate("Site $/times$ enrol.=siteenrdate_d*" "Cal. years=calyear_d*" "Demographics=sexage_d* tinc")


