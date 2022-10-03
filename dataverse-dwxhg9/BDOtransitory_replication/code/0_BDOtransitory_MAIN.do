clear
set more off, permanently
global Path "C:/Users/`c(username)'/Dropbox/UCD/RAND_health/CJE_ACCEPTANCE/BDOtransitory_replication"
cd "$Path/code"

* Install ado files locally
global adobase "$Path/code" 
capture mkdir "$adobase"
sysdir set PERSONAL "$adobase/ado/personal"
sysdir set PLUS "$adobase/ado/plus"
sysdir set SITE "$adobase/ado/site"
ssc install estout
ssc install outtable


* Cleaning
do 1_BDOtransitory_clean.do

* MAIN BODY 

global sample "outliers"

* Figure 1
do 2_BDOtransitory_figure1ab-deadline.do

do 3_BDOtransitory_figure1cd-deadlinesplit.do

* Table 1 done manually

* Table 2
do 4_BDOtransitory_table2-regtotal.do

* Table 3
do 5_BDOtransitory_table3-regcategories.do

* Table 4
do 6_BDOtransitory_table4-leveldif.do

* Table 5
do 7_BDOtransitory_table5-arcdif.do

* Table 6
do 8_BDOtransitory_table6-logcategories.do

* Table 7
do 9_BDOtransitory_table7-logleveldif.do

* Table 8
do 10_BDOtransitory_table8-coinsurance.do
