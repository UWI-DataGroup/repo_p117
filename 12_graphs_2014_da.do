** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			12_graphs_2014_da.do
    //  project:				BNR
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      28-MAR-2019
    // 	date last modified	    28-MAR-2019
    //  algorithm task			Generate graphs for report: (1) Tumours by parish & sex (2) CODs (3) Death Sites (4) Patients by age group
    //  status                  Completed
    //  objectve                To have one dataset with cleaned, grouped and analysed 2014 data for 2014 cancer report.

    ** DO FILE BASED ON
    * AMC Rose code for BNR Cancer 2008 annual report

    ** General algorithm set-up
    version 15
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
    log using "`logpath'\12_graphs_2014_da.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* ANALYSIS: GRAPHS: ALL for Annual Report
* Covering
* Fig 1: Tumours by month and sex 
** EXTRA FOR TM PRESENTATION CARPHA 2015: Tumours by age-group and sex
** also do patients by age-group and sex as not sure which she prefers
* Note: Fig 2: los/survival already done in 5_section4
* Fig 3: CoD as bar chart (cancer vs non-cancer vs NK)
* Fig 4: death by site
*
***********************************************************************
** Fig 1: Graph of numbers of tumours by month (men and women combined)
***********************************************************************
** Change dataset to one without population data

** For this chart, we need the dataset without population data
use "`datapath'\version01\2-working\2014_cancer_rx_outcomes_da", clear


** Fig. 1.: Graph of numbers of events by parish (men and women combined)
preserve
collapse (sum) case , by(parish sex)

** New parish variable with recoded value for unknown
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen parishnew = parish
replace parishnew=12 if parishnew==99
label var parishnew "Parish"
label define parishnew_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 12 "Unknown", modify
label values parishnew parishnew_lab

drop if parishnew==12 //2 deleted
replace parishnew = parishnew+0.25 if sex==2 //11 changes
sort sex parishnew
** JC: see line 93: changed highest number from 85 to 50, as fewer cases here (graph looks better!)
#delimit ;
graph twoway 	(bar case parishnew if sex==2, yaxis(1) col(lavender) barw(0.5) )
				(bar case parishnew if sex==1, yaxis(1) col(magenta*0.5)  barw(0.5) ),
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Parish", size(large) margin(t=3)) 
			xscale(range(1(1)11))
			xmtick(1(1)11)

			ylab(0(40)160, labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of tumours", size(large) margin(r=3)) 
			ymtick(0(20)160)
			/// title info
			title("Figure 1. Number of tumours in male and female cancer patients by parish, Barbados, 2014 (N=927)", size(vlarge) margin(medium) color(white) fcolor(lavender) lcolor(black) box)
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Number of tumours (men)") 
			lab(2 "Number of tumours (women)")
			)
			name(figure1, replace)
			;
#delimit cr
restore


********************************************************************************
** Fig. 3 causes of death as bar chart: cancer, non-cancer, NK
********************************************************************************

preserve
use "`datapath'\version01\2-working\2014_cancer_rx_outcomes_da", clear
sort sex cod
keep if deceased==1 & dodyear<2018
collapse (sum) case , by(cod)
recode cod 9=3
label define cod2_lab 1 "cancer" 2 "non-cancer" 3 "unknown"
label values cod cod2_lab

#delimit ;
graph twoway 	(bar case cod , yaxis(1) col("lavender") barw(0.5) ),
			/// Making background white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 , valuelabel
					
	       	labs(large) nogrid glc("231 231 240") angle(0))
	       	xtitle("Cause of death", size(vlarge) margin(t=3)) 
			//xscale(range(1(1)3))
			//xmtick(1(1)3)

			ylab(0(100)400, labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of tumours", size(vlarge) margin(r=3)) 
			ymtick(0(50)400)
			/// title info
			title("Figure 2. Cause of death for 474 cancer patients diagnosed in 2014 who died" "by 31 December 2017, Barbados", size(huge) margin(medium) color(white) fcolor(lavender) lcolor(black) box)
			/// Legend information
			legend(off size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Number of tumours (men)") 
			lab(2 "Number of tumours (women)")
			)
			name(figure2, replace)
			;
#delimit cr

restore


********************************************************************************
** Fig. 4 death by specific site
********************************************************************************

preserve
use "`datapath'\version01\2-working\2014_cancer_rx_outcomes_da", clear
sort sex siteiarc
keep if deceased==1 & dodyear<2018 //424 deleted
drop if cod!=1
count //476
collapse (sum) case , by(siteiarc)
sort siteiarc
gsort -case
** These will be difficult to show on a chart so let's re-input into more
** amenable names

drop _all
input id site2 case
1	1	85	// colorectal (colon 65, rectum 19, anus 1)
2	2	37  // uterus (23), cervix (7), other female genital organs (ovary 3, vag 2, vul 2)
3   3   50	// lymphoid/blood (MM 20, NHL 14, LL 5, ML 4, Leu 3, HL 1, MPD 1, MDS 1, Immuno 1)
4	4	66	// prostate (64), other male genital organs (penis 2)
5	5	46  // stomach (17), other digestive organs (liver 10, oseoph 8, GB 8, small intest 3)
6	6	51	// breast (51)
7   7   32  // respiratory and intra-thoracic (lung 28, larynx 4)
8   8   20  // pancreas  (20)
9   9   16  // head & neck (lip etc.)(hypo 4, nose 3, oro 3, naso 2, tongue 2, tonsil 1, mouth 1)
10  10  15  // urinary tract (bladder 11, kidney 4)
11  11  15  // misc. sites (bone 1, skin 3, meso 4, brain 4, thyroid 3)
12  12  43  // O&U (oth & unk)(43)
end

sort site2
label define site2_lab 1 "Colorectal" 2 "Uterus, OFG" 3 "Prostate, OMG" 4 "Lymph/blood" ///
					   5 "Stomach+other GI" 6 "Breast" 7 "Respiratory" ///
					   8 "Pancreas" 9 "Head & Neck"  10 "Urinary tract" ///
					   11 "Misc. Sites" 12 "O&U (other & unk)"
label values site2 site2_lab

#delimit ;
graph twoway 	(bar case site if site<7 , yaxis(1) col(lavender) barw(0.5) ),
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6, valuelabel
		
	       	labs(large) nogrid glc(gs12) angle(0))
	       	xtitle("", size(vlarge) margin(t=3)) 
			//xscale(range(1(1)3))
			//xmtick(1(1)3)

			ylab(0(20)80, labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of tumours", size(large) margin(r=3)) 
			ymtick(0(10)80)
			/// title info
			title("Figure 3. Site of cancer for 476 fatal tumours diagnosed in 2014 which caused" "death within 3 years, Barbados", size(huge) margin(medium) color(white) fcolor(lavender) lcolor(black) box)
			/// Legend information
			legend(off size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Number of tumours (men)") 
			lab(2 "Number of tumours (women)")
			)
			name(figure3, replace)
			;
#delimit cr



#delimit ;
graph twoway 	(bar case site if site>6 , yaxis(1) col(lavender) barw(0.5) ),
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(7 8 9 10 11 12, valuelabel
		
	       	labs(large) nogrid glc(gs12) angle(0))
	       	xtitle("Site of tumour", size(vlarge) margin(t=3)) 
			//xscale(range(1(1)3))
			//xmtick(1(1)3)

			ylab(0(20)80, labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of tumours", size(large) margin(r=3)) 
			ymtick(0(10)80)
			
			/// Legend information
			legend(off size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Number of tumours (men)") 
			lab(2 "Number of tumours (women)")
			)
			name(figure4, replace)
			;
#delimit cr

restore


********************************************************************************
** Fig. 4 death by specific site - ALTERNATIVE using siteicd10 from dofile 6
********************************************************************************
** NOT USED!

preserve
use "`datapath'\version01\2-working\2014_cancer_rx_outcomes_da", clear
sort sex siteicd10
keep if deceased==1 & dodyear<2018 //424 deleted
drop if cod!=1
count //476
collapse (sum) case , by(siteicd10)
sort siteicd10
gsort -case
** These will be difficult to show on a chart so let's re-input into more
** amenable names
/*
drop _all
input id site2 case
1	1	85	// colorectal (colon 65, rectum 19, anus 1)
2	2	37  // uterus (23), cervix (7), other female genital organs (ovary 3, vag 2, vul 2)
3   3   50	// lymphoid/blood (MM 20, NHL 14, LL 5, ML 4, Leu 3, HL 1, MPD 1, MDS 1, Immuno 1)
4	4	66	// prostate (64), other male genital organs (penis 2)
5	5	46  // stomach (17), other digestive organs (liver 10, oseoph 8, GB 8, small intest 3)
6	6	51	// breast (51)
7   7   32  // respiratory and intra-thoracic (lung 28, larynx 4)
8   8   20  // pancreas  (20)
9   9   16  // head & neck (lip etc.)(hypo 4, nose 3, oro 3, naso 2, tongue 2, tonsil 1, mouth 1)
10  10  15  // urinary tract (bladder 11, kidney 4)
11  11  15  // misc. sites (bone 1, skin 3, meso 4, brain 4, thyroid 3)
12  12  43  // O&U (oth & unk)(43)
end

sort site2
label define site2_lab 1 "Colorectal" 2 "Uterus, OFG" 3 "Prostate, OMG" 4 "Lymph/blood" ///
					   5 "Stomach+other GI" 6 "Breast" 7 "Respiratory" ///
					   8 "Pancreas" 9 "Head & Neck"  10 "Urinary tract" ///
					   11 "Misc. Sites" 12 "O&U (other & unk)"
label values site2 site2_lab
*/
#delimit ;
graph twoway 	(bar case siteicd10 if siteicd10<9 , yaxis(1) col(lavender) barw(0.5) ),
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6, valuelabel
		
	       	labs(large) nogrid glc(gs12) angle(0))
	       	xtitle("", size(vlarge) margin(t=3)) 
			//xscale(range(1(1)3))
			//xmtick(1(1)3)

			ylab(0(20)80, labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of tumours", size(large) margin(r=3)) 
			ymtick(0(10)80)
			/// title info
			title("Figure 3. Site of cancer for 476 fatal tumours diagnosed in 2014 which caused" "death within 3 years, Barbados", size(huge) margin(medium) color(white) fcolor(lavender) lcolor(black) box)
			/// Legend information
			legend(off size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Number of tumours (men)") 
			lab(2 "Number of tumours (women)")
			)
			name(figure3b, replace)
			;
#delimit cr



#delimit ;
graph twoway 	(bar case siteicd10 if siteicd10>8 , yaxis(1) col(lavender) barw(0.5) ),
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(7 8 9 10 11 12, valuelabel
		
	       	labs(large) nogrid glc(gs12) angle(0))
	       	xtitle("Site of tumour", size(vlarge) margin(t=3)) 
			//xscale(range(1(1)3))
			//xmtick(1(1)3)

			ylab(0(20)80, labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of tumours", size(large) margin(r=3)) 
			ymtick(0(10)80)
			
			/// Legend information
			legend(off size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Number of tumours (men)") 
			lab(2 "Number of tumours (women)")
			)
			name(figure4b, replace)
			;
#delimit cr

restore

***********************************************************************
** Fig 1: Graph of numbers of tumours by month (men and women combined)
***********************************************************************

**********************
** Now repeat but with age-group but using PATIENTS not tumours
preserve
drop if patient==2
collapse (sum) case , by(age_10 sex)
rename age_10 agegrp

** New agegrp variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen agenew = agegrp
sort sex agenew
replace agenew=1 if agenew==2 //2 changes
replace case=8 if agenew==1 & agegrp==1 & sex==1 //1 change
replace case=6 if agenew==1 & agegrp==1 & sex==2 //1 change
drop if agegrp==2 //2 deleted
recode agenew 3=2 //2 changes
recode agenew 4=3 //2 changes
recode agenew 5=4 //2 changes
recode agenew 6=5 //2 changes
recode agenew 7=6 //2 changes
recode agenew 8=7 //2 changes
recode agenew 9=8 //2 changes
label define agenew_lab 1 "0-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65-74" /// 
				  7 "75-84" 8 "85 & over" ,modify
label values agenew agenew_lab

replace agenew = agenew+0.25 if sex==2 //8 changes
sort sex agenew

#delimit ;
graph twoway 	(bar case agenew if sex==2, yaxis(1) col(lavender) barw(0.5) )
				(bar case agenew if sex==1, yaxis(1) col(magenta*0.5)  barw(0.5) ) ,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)8))
			xmtick(1(1)8)

			ylab(0(30)180, labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of tumours", size(large) margin(r=3)) 
			ymtick(0(15)180)
			/// title info
			title("Figure 4. Number of tumours in male and female cancer patients by age group," "Barbados, 2014 (N=912)", size(huge) margin(medium) color(white) fcolor(lavender) lcolor(black) box)
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2)
			lab(1 "Number of patients (men)") 
			lab(2 "Number of patients (women)")
			)
			name(figure5, replace)
			;
#delimit cr
restore
