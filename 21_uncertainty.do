** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          60_uncertainty.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      22-SEP-2021
    // 	date last modified      14-OCT-2021
    //  algorithm task          Performing uncertainty analysis using select sites from cleaned, current cancer dataset
    //  status                  Completed
    //  objective               To have a table/tornado diagram for select sites to determine reason for fluctuations in cases over the years
    //  methods                 Using bootstrap and bsample commands for repetitions and replacements

    ** General algorithm set-up
    version 17.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\60_uncertainty.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* PREP AND FORMAT
**************************************************************************
use "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable", clear


** Use top 10 from 2015 annual report along with sites identified with fluctuations from IARC Hub DQ assessment
keep age siteiarc dxyr sex
drop if dxyr==2008

** Create dataset with absolute case totals for sites based on fluctuations noted in IARC DQ excel sheet
** (X:\The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2015 Cancer Report\Data Discussion with IARC.xlsx)

** Cervix
count if dxyr==2013 & siteiarc==32
gen absolutetot = r(N) if dxyr==2013 & siteiarc==32

count if dxyr==2014 & siteiarc==32
replace absolutetot = r(N) if dxyr==2014 & siteiarc==32

count if dxyr==2015 & siteiarc==32
replace absolutetot = r(N) if dxyr==2015 & siteiarc==32

** Rectum (male + female)
count if dxyr==2013 & siteiarc==14
replace absolutetot = r(N) if dxyr==2013 & siteiarc==14

count if dxyr==2014 & siteiarc==14
replace absolutetot = r(N) if dxyr==2014 & siteiarc==14

count if dxyr==2015 & siteiarc==14
replace absolutetot = r(N) if dxyr==2015 & siteiarc==14

** Multiple Myeloma (female only)
count if dxyr==2013 & siteiarc==55 & sex==1
replace absolutetot = r(N) if dxyr==2013 & siteiarc==55 & sex==1

count if dxyr==2014 & siteiarc==55 & sex==1
replace absolutetot = r(N) if dxyr==2014 & siteiarc==55 & sex==1

count if dxyr==2015 & siteiarc==55 & sex==1
replace absolutetot = r(N) if dxyr==2015 & siteiarc==55 & sex==1

** Stomach (female only)
count if dxyr==2013 & siteiarc==11 & sex==1
replace absolutetot = r(N) if dxyr==2013 & siteiarc==11 & sex==1

count if dxyr==2014 & siteiarc==11 & sex==1
replace absolutetot = r(N) if dxyr==2014 & siteiarc==11 & sex==1

count if dxyr==2015 & siteiarc==11 & sex==1
replace absolutetot = r(N) if dxyr==2015 & siteiarc==11 & sex==1

** Lung (female only)
count if dxyr==2013 & siteiarc==21 & sex==1
replace absolutetot = r(N) if dxyr==2013 & siteiarc==21 & sex==1

count if dxyr==2014 & siteiarc==21 & sex==1
replace absolutetot = r(N) if dxyr==2014 & siteiarc==21 & sex==1

count if dxyr==2015 & siteiarc==21 & sex==1
replace absolutetot = r(N) if dxyr==2015 & siteiarc==21 & sex==1

** Bladder (female only)
count if dxyr==2013 & siteiarc==45 & sex==1
replace absolutetot = r(N) if dxyr==2013 & siteiarc==45 & sex==1

count if dxyr==2014 & siteiarc==45 & sex==1
replace absolutetot = r(N) if dxyr==2014 & siteiarc==45 & sex==1

count if dxyr==2015 & siteiarc==45 & sex==1
replace absolutetot = r(N) if dxyr==2015 & siteiarc==45 & sex==1


** Condense dataset to add absolute case totals to final dataset with the uncertainty results
//preserve
drop if absolutetot==.
drop age
sort siteiarc dxyr
contract siteiarc dxyr absolutetot
drop _freq
rename dxyr year
sort siteiarc year
save "`datapath'\version02\2-working\2013_2014_2015_absolutetotals", replace 
//restore


** Create dataset with all sites
save "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", replace


** Create dataset by year by site by sex (where applicable) - CERVIX
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=32
//drop if year!=2013
//drop if sex==2

mean absolutetot


save "`datapath'\version02\2-working\nouncertainty_cervix", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\nouncertainty_cervix", clear
	
	bsample
	
	summ absolutetot
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\boots_cervix", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 32
//gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc table_means table_low table_high //year
save "`datapath'\version02\3-output\uncertainty_cervix", replace

use "`datapath'\version02\2-working\nouncertainty_cervix", clear
mean absolutetot

clear


** Create dataset by year by site by sex (where applicable) - MULTIPLE MYELOMA
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=55
//drop if year!=2013
//drop if sex==2

summ absolutetot


save "`datapath'\version02\2-working\nouncertainty_multiplemyeloma", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\nouncertainty_multiplemyeloma", clear
	
	bsample
	
	summ absolutetot
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\boots_multiplemyeloma", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 55
//gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc table_means table_low table_high
save "`datapath'\version02\3-output\uncertainty_multiplemyeloma", replace

use "`datapath'\version02\2-working\nouncertainty_multiplemyeloma", clear
mean absolutetot

clear


** Create dataset by year by site by sex (where applicable) - STOMACH
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=11
//drop if year!=2013
//drop if sex==2

summ absolutetot


save "`datapath'\version02\2-working\nouncertainty_stomach", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\nouncertainty_stomach", clear
	
	bsample
	
	summ absolutetot
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\boots_stomach", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 11
//gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc table_means table_low table_high
save "`datapath'\version02\3-output\uncertainty_stomach", replace

use "`datapath'\version02\2-working\nouncertainty_stomach", clear
mean absolutetot

clear


** Create dataset by year by site by sex (where applicable) - LUNG
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=21
//drop if year!=2013
//drop if sex==2

summ absolutetot


save "`datapath'\version02\2-working\nouncertainty_lung", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\nouncertainty_lung", clear
	
	bsample
	
	summ absolutetot
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\boots_lung", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 21
//gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc table_means table_low table_high
save "`datapath'\version02\3-output\uncertainty_lung", replace

use "`datapath'\version02\2-working\nouncertainty_lung", clear
mean absolutetot

clear


** Create dataset by year by site by sex (where applicable) - BLADDER
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=45
//drop if year!=2013
//drop if sex==2

summ absolutetot


save "`datapath'\version02\2-working\nouncertainty_bladder", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\nouncertainty_bladder", clear
	
	bsample
	
	summ absolutetot
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\boots_bladder", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 45
//gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc table_means table_low table_high
save "`datapath'\version02\3-output\uncertainty_bladder", replace

use "`datapath'\version02\2-working\nouncertainty_bladder", clear
mean absolutetot

clear


** Create dataset by year by site by sex (where applicable) - RECTUM
use "`datapath'\version02\2-working\2013_2014_2015_pre-uncertainty_allsites", clear

drop if siteiarc!=14
//drop if year!=2013
//drop if sex==2
//drop sex

summ absolutetot


save "`datapath'\version02\2-working\nouncertainty_rectum", replace

local boots = 5000

** Create blank dataset to store the estimations
clear

set obs `boots'

gen store_means = .
gen store_low = .
gen store_high = .

quietly {
forvalues i = 1(1)`boots' {
	if floor((`i'-1)/100) == (`i'-1)/100 {
		noisily display "Working on `i' out of `boots' at $S_TIME"
	}
	
	preserve
	
	use "`datapath'\version02\2-working\nouncertainty_rectum", clear
	
	bsample
	
	summ absolutetot
	local mean_got = r(mean)
	
	restore
	
	replace store_means = `mean_got' in `i'
	}
}
summ store_means

save "`datapath'\version02\2-working\boots_rectum", replace

quietly {
gen table_means = r(mean)
gen table_low = r(min)
gen table_high = r(max)
gen siteiarc = 14
//gen year = 2013

drop store_means store_low store_high

gen obsid = _n
drop if obsid != 1

drop obsid
}

order siteiarc table_means table_low table_high
save "`datapath'\version02\3-output\uncertainty_rectum", replace

use "`datapath'\version02\2-working\nouncertainty_rectum", clear
mean absolutetot

clear


** Create one table with absolute case totals + uncertainty results from all sites
use "`datapath'\version02\3-output\uncertainty_cervix", clear
append using "`datapath'\version02\3-output\uncertainty_rectum"
append using "`datapath'\version02\3-output\uncertainty_multiplemyeloma"
append using "`datapath'\version02\3-output\uncertainty_stomach"
append using "`datapath'\version02\3-output\uncertainty_lung"
append using "`datapath'\version02\3-output\uncertainty_bladder"

** Re-add siteiarc label
label define siteiarc_lab ///
1 "Lip (C00)" 2 "Tongue (C01-02)" 3 "Mouth (C03-06)" ///
4 "Salivary gland (C07-08)" 5 "Tonsil (C09)" 6 "Other oropharynx (C10)" ///
7 "Nasopharynx (C11)" 8 "Hypopharynx (C12-13)" 9 "Pharynx unspecified (C14)" ///
10 "Oesophagus (C15)" 11 "Stomach (C16)" 12 "Small intestine (C17)" ///
13 "Colon (C18)" 14 "Rectum (C19-20)" 15 "Anus (C21)" ///
16 "Liver (C22)" 17 "Gallbladder etc. (C23-24)" 18 "Pancreas (C25)" ///
19 "Nose, sinuses etc. (C30-31)" 20 "Larynx (C32)" ///
21 "Lung (incl. trachea and bronchus) (C33-34)" 22 "Other thoracic organs (C37-38)" ///
23 "Bone (C40-41)" 24 "Melanoma of skin (C43)" 25 "Other skin (C44)" ///
26 "Mesothelioma (C45)" 27 "Kaposi sarcoma (C46)" 28 "Connective and soft tissue (C47+C49)" ///
29 "Breast (C50)" 30 "Vulva (C51)" 31 "Vagina (C52)" 32 "Cervix uteri (C53)" ///
33 "Corpus uteri (C54)" 34 "Uterus unspecified (C55)" 35 "Ovary (C56)" ///
36 "Other female genital organs (C57)" 37 "Placenta (C58)" ///
38 "Penis (C60)" 39 "Prostate (C61)" 40 "Testis (C62)" 41 "Other male genital organs (C63)" ///
42 "Kidney (C64)" 43 "Renal pelvis (C65)" 44 "Ureter (C66)" 45 "Bladder (C67)" ///
46 "Other urinary organs (C68)" 47 "Eye (C69)" 48 "Brain, nervous system (C70-72)" ///
49 "Thyroid (C73)" 50 "Adrenal gland (C74)" 51 "Other endocrine (C75)" ///
52 "Hodgkin lymphoma (C81)" 53 "Non-Hodgkin lymphoma (C82-86,C96)" ///
54 "Immunoproliferative diseases (C88)" 55 "Multiple myeloma (C90)" ///
56 "Lymphoid leukaemia (C91)" 57 "Myeloid leukaemia (C92-94)" 58 "Leukaemia unspecified (C95)" ///
59 "Myeloproliferative disorders (MPD)" 60 "Myelodysplastic syndromes (MDS)" ///
61 "Other and unspecified (O&U)" ///
62 "All sites(ALL)" 63 "All sites but skin (ALLbC44)" ///
64 "D069: CIN 3"
label var siteiarc "IARC CI5-XI sites"
label values siteiarc siteiarc_lab
/*
merge 1:1 siteiarc year using "`datapath'\version02\2-working\2013_2014_2015_absolutetotals"
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                                18  (_merge==3)
    -----------------------------------------
*/
drop _merge

** Create a variable to identify which sites had fluctations in their sex only
gen sex = "Female only" if siteiarc!=14 & siteiarc!=62
replace sex = "Male + Female" if siteiarc==14|siteiarc==62
*/
rename table_means mean
rename table_low min
rename table_high max
//rename absolutetot cases
order siteiarc mean min max
sort siteiarc mean min max
format min max %2.0f
format mean %2.1f

** Create MS Word results table with absolute case totals + the uncertainty means, min and max values by year, by site, by sex (where applicable)
				**************************
				*	   MS WORD REPORT    *
				* 	UNCERTAINTY RESULTS  *
				**************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: Uncertainty Results"), bold
putdocx textblock begin
Date Prepared: 14-OCT-2021. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021.
Generated using Dofile: 60_uncertainty.do
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Table: Absolute Case Totals + Uncertainty Results for BNR-Cancer for 2013-2015"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted fluctuations in certain sites. A thorough investigation into possible causes for the fluctuations did not reveal any significant changes in abstractor quality or changes at the data sources. As a result, uncertainty analysis was performed to ascertain if the fluctuations were simply the result of the small case numbers due to the smaller population size of Barbados compared to other international territories. For a summary of the above investigation, see the 'Conclusions' tab of this excel workbook: 
'X:\The University of the West Indies\FORDE, Shelly-Ann - BNR\REPORTS\Annual Reports\2015 Cancer Report\Data Discussion with IARC.xlsx'
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) 2015 annual report dataset was used to organize the data into a format to perform the uncertainty analysis (cancer dataset used: "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable"; Note: 2008 cases were ultimately excluded)
putdocx textblock end
putdocx textblock begin
(2) Stata command bootstrap performs nonparametric bootstrap estimation of specified statistics (or expressions) for a Stata command or a user-written program.  Statistics are bootstrapped by resampling the data in memory with replacement.  bootstrap is designed for use with nonestimation commands, functions of coefficients, or user-written programs. In this analysis it is used to create multiple repetitions (5,000) per site per year per sex.
putdocx textblock end
putdocx textblock begin
(3) Stata command bsample replaces the data in memory with a bootstrap sample (random sample with replacement) drawn from the current dataset.  Clusters can be optionally sampled during each replication in place of observations. In this analysis it is used per site per year per sex.
putdocx textblock end
putdocx textblock begin
(4) It was determined by NS and JC on 14-Oct-2021 that the few years of data (2013-2015) were not conducive for accurate interpretation for this type of analysis so we will re-visit this when we analyse 2016-2018 data and can assess 2013-2018 together.
putdocx textblock end
putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("Uncertainty Results Per Site Grouped for 2013-2015"), bold font(Helvetica,14,"blue")
putdocx table tbl1 = data(siteiarc mean min max), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

putdocx save "`datapath'\version02\3-output\2021-10-14_uncertainty_stats_V06.docx", replace
putdocx clear

save "`datapath'\version02\3-output\2013_2014_2015_uncertaintystats" ,replace

clear

use  "`datapath'\version02\2-working\2013_2014_2015_absolutetotals" ,clear

				**************************
				*	   MS WORD REPORT    *
				* 	  ABSOLUTE TOTALS    *
				**************************
putdocx clear
putdocx begin
putdocx paragraph, halign(center)
putdocx text ("Absolute Totals Per Site Per Year (2013-2015)"), bold font(Helvetica,14,"blue")
putdocx table tbl1 = data(siteiarc year absolutetot), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

putdocx save "`datapath'\version02\3-output\2021-10-14_uncertainty_stats_V06.docx", append
putdocx clear

** See below links for info on bootstrap command
display `"{browse "https://www.stata.com/features/overview/bootstrap-sampling-and-estimation/":Bootstrap}"'
display `"{browse "https://www.youtube.com/watch?v=_8-2QBL-9UM":Bootstrap-Video}"'