capture program drop ArcElasticity_prices

program ArcElasticity_prices

	syntax varlist(numeric ts fv) [if] [in] [,*]
	
	tokenize `varlist'
	local lhsvar `1'
	macro shift 1
	local rhsvars "`*'"
	display "`rhsvars'"
	
	tokenize `rhsvars'
	local indepvar `1'
	macro shift 1
	local ctrlvars "`*'"
	display "`indepvar'"
	display "`ctrlvars'"
	
	local cat=substr("`lhsvar'",2,length("`lhsvar'")-4)
	
* The regressions
	xi: regress `lhsvar' `indepvar' `ctrlvars' `if' `in', `options'
	matrix tempb=e(b)
	matrix plan_FE_aef=[0,tempb[1,1..3]]
	matrix plan_FE_aef=_b[_cons]*[1,1,1,1]+plan_FE_aef
	xi: regress `lhsvar' `indepvar' `ctrlvars' lastyr i.p4_`cat'T `if' `in', `options'
	matrix tempb=e(b)
	matrix plan_FE_pxd=[0,tempb[1,1..3]]
	matrix plan_FE_pxd=_b[_cons]*[1,1,1,1]+plan_FE_pxd
	local blength = `= colsof(tempb)'
	local dedstart = `blength'-3
	local dedend = `blength'-1
	matrix plan_FE_ded=[0,tempb[1,`dedstart'..`dedend']]
	matrix plan_FE_ded=[0,tempb[1,1..3]]+plan_FE_ded
	matrix plan_FE_ded=(_b[_cons]+_b[lastyr])*[1,1,1,1]+plan_FE_ded
	*matrix plan_FE_ded=plan_FE_pxd+plan_FE_ded
	
	
	***********************
	
* make matrix of observation counts per plan to correspond to arc elasts
matrix ones=[1,1,1,1]
tabulate p4_`cat', matcell(N)
matrix NN=N#ones+ones'#N'
forval i=1/4 {
matrix NN[`i',`i']=0
}


*calc ARC elasticities. first column of output matrix lists comparisons to free care
matrix Pdif=ones#p'-ones'#p
matrix Psum=ones#p'+ones'#p
foreach spec in "aef" "pxd" "ded" {
matrix arcelast_`spec'=J(4,4,0)
matrix q=plan_FE_`spec'
matrix Qdif=ones#q'-ones'#q
matrix Qsum=ones#q'+ones'#q
forvalues i=1/4 {
forvalues j=1/4 {
matrix arcelast_`spec'[`i',`j']=Qdif[`i',`j']/Qsum[`i',`j']/(Pdif[`i',`j']/Psum[`i',`j'])
}
matrix list arcelast_`spec'


*weighted numerators and denominator for full set of arc elasts
matrix arcelast_`spec'_wmat=J(4,4,0)
local denom=0
forvalues j=1/3 {
local jj=`j'+1
forvalues i=`jj'/4 {
matrix arcelast_`spec'_wmat[`i',`j']=arcelast_`spec'[`i',`j']*NN[`i',`j']
local denom=`denom'+NN[`i',`j']
}
}
mata : st_matrix("arcelast_`spec'_w", colsum(rowsum(st_matrix("arcelast_`spec'_wmat"))))

*weighted numerators and denominator -- for no free care
matrix arcelast_`spec'_wmat2=J(4,4,0)
local denom2=0
forvalues j=2/3 {
local jj=`j'+1
forvalues i=`jj'/4 {
matrix arcelast_`spec'_wmat2[`i',`j']=arcelast_`spec'[`i',`j']*NN[`i',`j']
local denom2=`denom2'+NN[`i',`j']
}
}
mata : st_matrix("arcelast_`spec'_w2", colsum(rowsum(st_matrix("arcelast_`spec'_wmat2"))))

*assign weighted arc elasts
matrix avgAE_`spec'=arcelast_`spec'_w[1,1]/`denom'
matrix avgAE_`spec'2=arcelast_`spec'_w2[1,1]/`denom2'

}
}


tempname outmatrix
matrix `outmatrix'=J(1,26,0)
local i=1
foreach spec in "aef" "pxd" {
forval r=1/3 {
local cc=`r'+1
display `cc'
forval c=`cc'/4 {
display "i=`i' spec=`spec' r=`r' c=`c'"
display arcelast_`spec'[`r',`c']
matrix `outmatrix'[1,`i']=arcelast_`spec'[`r',`c']
matrix `outmatrix'[1,`i'+12]=arcelast_aef[`r',`c']-arcelast_pxd[`r',`c']
local i=`i'+1
}
}
}

* weighted arc elasts and diffs
*all
matrix `outmatrix'[1,19]=avgAE_aef
matrix `outmatrix'[1,20]=avgAE_pxd
matrix `outmatrix'[1,21]=avgAE_aef-avgAE_pxd
*no free care
matrix `outmatrix'[1,22]=avgAE_aef2
matrix `outmatrix'[1,23]=avgAE_pxd2
matrix `outmatrix'[1,24]=avgAE_aef2-avgAE_pxd2

*only deadline year -- R1 request
matrix `outmatrix'[1,25]=avgAE_ded
matrix `outmatrix'[1,26]=avgAE_ded2

display `denom'
display `denom2'
mat colnames `outmatrix' = 0vs25_aef 0vs50_aef 0vs95_aef 25vs50_aef 25vs95_aef 50vs95_aef 0vs25_pxd 0vs50_pxd 0vs95_pxd 25vs50_pxd 25vs95_pxd 50vs95_pxd 0vs25_dif 0vs50_dif 0vs95_dif 25vs50_dif 25vs95_dif 50vs95_dif avgAE_aef1 avgAE_pxd1 diff1 avgAE_aef2 avgAE_pxd2 diff2 ded1 ded2
mat list `outmatrix'


	tempvar mySamp
	gen `mySamp' = e(sample)
	ereturn post `outmatrix', esample(`mySamp')	
end
