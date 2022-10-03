local sample = "$sample"
use "$Path\data\randHIE_clean`sample'.dta", clear

* This file produces table 3 in the main document.

local demos="sexage_d* tinc"
local controls="calyear_d* siteenrdate_d*"

foreach prefix in "" "l" {
eststo clear
foreach cat in "INP" "OUTP" "DRUG" "SUPP" "DENT" "MENT" {
*eststo: quietly: xi: regress `prefix'r`cat'DOL 	i.p4_`cat'  	enrterm `demos' 	`controls', cluster(fam_id)
eststo: quietly: xi: regress `prefix'r`cat'DOL 	i.p4_`cat'  lastyr	i.p4_`cat'T	enrterm `demos' 	`controls', cluster(fam_id)



********************************************
*make labels for tables******* must repeat *

label var lastyr 			"D.year"

label var _Ip4_`cat'_2 "25\% copay"
label var _Ip4_`cat'_3 "50\% copay"
label var _Ip4_`cat'_4 "95\% copay"

label var _Ip4_`cat'T_2 "D.year$\times$25\% copay"
label var _Ip4_`cat'T_3 "D.year$\times$50\% copay"
label var _Ip4_`cat'T_4 "D.year$\times$95\% copay"
}
*label var _IENRTERM_5  "Enrol. term = 5"
label var enrterm "Enrol. term = 5"

********************************************

estout, style(tex) rename ( ///
		_Ip4_OUTP_2 _Ip4_INP_2 _Ip4_OUTP_3 _Ip4_INP_3 _Ip4_OUTP_4 _Ip4_INP_4 ///
		_Ip4_DRUG_2 _Ip4_INP_2 _Ip4_DRUG_3 _Ip4_INP_3 _Ip4_DRUG_4 _Ip4_INP_4 ///
		_Ip4_SUPP_2 _Ip4_INP_2 _Ip4_SUPP_3 _Ip4_INP_3 _Ip4_SUPP_4 _Ip4_INP_4 ///
		_Ip4_DENT_2 _Ip4_INP_2 _Ip4_DENT_3 _Ip4_INP_3 _Ip4_DENT_4 _Ip4_INP_4 ///
		_Ip4_MENT_2 _Ip4_INP_2 _Ip4_MENT_3 _Ip4_INP_3 _Ip4_MENT_4 _Ip4_INP_4 ///
		_Ip4_OUTPT_2 _Ip4_INPT_2 _Ip4_OUTPT_3 _Ip4_INPT_3 _Ip4_OUTPT_4 _Ip4_INPT_4 ///
		_Ip4_DRUGT_2 _Ip4_INPT_2 _Ip4_DRUGT_3 _Ip4_INPT_3 _Ip4_DRUGT_4 _Ip4_INPT_4 ///
		_Ip4_SUPPT_2 _Ip4_INPT_2 _Ip4_SUPPT_3 _Ip4_INPT_3 _Ip4_SUPPT_4 _Ip4_INPT_4 ///
		_Ip4_DENTT_2 _Ip4_INPT_2 _Ip4_DENTT_3 _Ip4_INPT_3 _Ip4_DENTT_4 _Ip4_INPT_4 ///
		_Ip4_MENTT_2 _Ip4_INPT_2 _Ip4_MENTT_3 _Ip4_INPT_3 _Ip4_MENTT_4 _Ip4_INPT_4) ///
		cells(b(star fmt(%7.2f)) se(par)) stats(N r2, labels ("N" "R$^2$") fmt(%7.0f %7.2f)) /// 
		label varlabels(_cons "Constant (free care)" ///
		_Ip4_INP_2 "25\% coinsurance" _Ip4_INP_3 "50\% coinsurance" _Ip4_INP_4 "95\% coinsurance" ///
		_Ip4_INPT_2 "D.year$\times$25\% coins." _Ip4_INPT_3 "D.year$\times$50\% coins." _Ip4_INPT_4 "D.year$\times$95\% coins.") ///
		order(_cons) ///
		starlevels(* .1 ** .05 *** .01) ///
		mlabels("Inpatient" "Outpatient" "Drugs" "Supplies" "Dental" "Mental Health") ///
indicate("Site $\times$ enrol.=siteenrdate_d*" "Cal. years=calyear_d*" "Demographics=sexage_d* tinc")
*
estout using "$Path\output\Table_03.txt", replace style(tex) rename ( ///
		_Ip4_OUTP_2 _Ip4_INP_2 _Ip4_OUTP_3 _Ip4_INP_3 _Ip4_OUTP_4 _Ip4_INP_4 ///
		_Ip4_DRUG_2 _Ip4_INP_2 _Ip4_DRUG_3 _Ip4_INP_3 _Ip4_DRUG_4 _Ip4_INP_4 ///
		_Ip4_SUPP_2 _Ip4_INP_2 _Ip4_SUPP_3 _Ip4_INP_3 _Ip4_SUPP_4 _Ip4_INP_4 ///
		_Ip4_DENT_2 _Ip4_INP_2 _Ip4_DENT_3 _Ip4_INP_3 _Ip4_DENT_4 _Ip4_INP_4 ///
		_Ip4_MENT_2 _Ip4_INP_2 _Ip4_MENT_3 _Ip4_INP_3 _Ip4_MENT_4 _Ip4_INP_4 ///
		_Ip4_OUTPT_2 _Ip4_INPT_2 _Ip4_OUTPT_3 _Ip4_INPT_3 _Ip4_OUTPT_4 _Ip4_INPT_4 ///
		_Ip4_DRUGT_2 _Ip4_INPT_2 _Ip4_DRUGT_3 _Ip4_INPT_3 _Ip4_DRUGT_4 _Ip4_INPT_4 ///
		_Ip4_SUPPT_2 _Ip4_INPT_2 _Ip4_SUPPT_3 _Ip4_INPT_3 _Ip4_SUPPT_4 _Ip4_INPT_4 ///
		_Ip4_DENTT_2 _Ip4_INPT_2 _Ip4_DENTT_3 _Ip4_INPT_3 _Ip4_DENTT_4 _Ip4_INPT_4 ///
		_Ip4_MENTT_2 _Ip4_INPT_2 _Ip4_MENTT_3 _Ip4_INPT_3 _Ip4_MENTT_4 _Ip4_INPT_4) ///
		cells(b(star fmt(%7.2f)) se(par)) stats(N r2, labels ("N" "R$^2$") fmt(%7.0f %7.2f)) /// 
		label varlabels(_cons "Constant (free care)" ///
		_Ip4_INP_2 "25\% coinsurance" _Ip4_INP_3 "50\% coinsurance" _Ip4_INP_4 "95\% coinsurance" ///
		_Ip4_INPT_2 "D.year$\times$25\% coins." _Ip4_INPT_3 "D.year$\times$50\% coins." _Ip4_INPT_4 "D.year$\times$95\% coins.") ///
		order(_cons) ///
		starlevels(* .1 ** .05 *** .01) ///
		mlabels("Inpatient" "Outpatient" "Drugs" "Supplies" "Dental" "Mental Health") ///
indicate("Site $\times$ enrol.=siteenrdate_d*" "Cal. years=calyear_d*" "Demographics=sexage_d* tinc")

}
