cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          30b_report cancer_EXCEL.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      26-AUG-2022
    // 	date last modified      29-AUG-2022
    //  algorithm task          Preparing 2013-2018 cancer datasets for reporting in Excel
    //  status                  In progress
    //  objective               To have one dataset with report outputs for 2013-2018 data for 2016-2018 annual report
	//							that allows the report writer to directly create graphs from the data.
    //  methods                 Use putexcel and Stata memory to produce data tables and figures

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
    log using "`logpath'\30b_report cancer_EXCEL.smcl", replace
** HEADER -----------------------------------------------------


*************************
**  SUMMARY STATISTICS **
*************************
** Annual report: Table 1 (executive summary)
** Load the SUMMARY STATS dataset
preserve
use "`datapath'\version09\2-working\2013-2018_summstats" ,clear

** Create Sheet

local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_SUMMSTATS_`listdate'.xlsx", firstrow(variables) sheet(Summary, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_SUMMSTATS_`listdate'.xlsx", sheet(Summary) modify
putexcel A1:G1, bold

putexcel A1 = "Title"
putexcel B1 = "Results_2018"
putexcel C1 = "Results_2017"
putexcel D1 = "Results_2016"
putexcel E1 = "Results_2015"
putexcel F1 = "Results_2014"
putexcel G1 = "Results_2013"
putexcel save

restore

STOP

************************
**  ASIRs - All Years **
************************
** Annual report: Table 1 (executive summary)
** Load the SUMMARY STATS dataset
preserve
use "`datapath'\version09\2-working\ASIRs" ,clear

** Create Sheet with All Years

local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", firstrow(variables) sheet(AllYears, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", sheet(AllYears) modify
putexcel A1:G1, bold

putexcel A1 = "Cancer_Site"
putexcel B1 = "Year"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASIR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore


preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with AllSites
keep if cancer_site!=1

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", firstrow(variables) sheet(AllSites, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV07_`listdate'.xlsx", sheet(AllSites) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore


STOP
*********************
** 2013-2021 ASMRs **
*********************
** JC 26aug2022: Create excel output of death absolute numbers and ASMRs for 2013-2021 and check with NS + SF if they would prefer exel outputs in conjunction with the Word outputs
preserve
** Create a 2013-2021 ASMR dataset
use "`datapath'\version09\2-working\ASMRs_wpp_2021", clear
replace year=9
append using "`datapath'\version09\2-working\ASMRs_wpp_2020"
replace year=8 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2019"
replace year=7 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2018"
replace year=6 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2017"
replace year=5 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2016"
replace year=4 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2015"
replace year=3 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2014"
replace year=2 if year<2
append using "`datapath'\version09\2-working\ASMRs_wpp_2013"
replace year=1 if year<2

label define year_lab 1 "2013" 2 "2014" 3 "2015" 4 "2016" 5 "2017" 6 "2018" 7 "2019" 8 "2020" 9 "2021" ,modify
label values year year_lab

drop percentage
sort cancer_site year asmr
order cancer_site year number percent asmr ci_lower ci_upper

save "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,replace

** Create Sheet1 with Totals
keep if cancer_site==1

local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(Totals, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(Totals) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with AllSites
keep if cancer_site!=1

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(AllSites, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(AllSites) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==2

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(Prostate, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(Prostate) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==3

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(Breast, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(Breast) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==4

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(Colon, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(Colon) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==5

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(Lung, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(Lung) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==6

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(Pancreas, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(Pancreas) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==7

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(MM, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(MM) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==8

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(NHL, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(NHL) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==9

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(Rectum, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(Rectum) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==10

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(CorpusUteri, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(CorpusUteri) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==11

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", firstrow(variables) sheet(Stomach, replace) 

putexcel set "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.xlsx", sheet(Stomach) modify
putexcel A1:G1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel save

restore

****************
** 2021 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2021", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2021 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2021 (Population=281,207)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 24-Aug-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10i_analysis mort_2021_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2021_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2021-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2021_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2021_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2021     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2021"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2021"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2021_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2021_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2020 *
				****************************

putdocx clear
putdocx begin
//putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2021"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2021"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2021_top10mort_age+sex_rates")
putdocx textblock end
//putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore


****************
** 2020 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2020", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2020 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2020 (Population=287,371)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 28-Jun-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10h_analysis mort_2020_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2020_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2020-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2020_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2020_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2020     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2020"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2020"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2020_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2020_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2020 *
				****************************

putdocx clear
putdocx begin
//putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2020"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2020"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2020_top10mort_age+sex_rates")
putdocx textblock end
//putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore


****************
** 2019 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2019", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
//putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2019 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2019 (Population=287,021)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 28-Jun-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10g_analysis mort_2019_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2019_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2019-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2019_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2019_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2019     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2019"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2019"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2019_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2019_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2019 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2019"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2019"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2019_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore


****************
** 2018 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2018", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2018 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2018 (Population=286,640)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 10-May-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10f_analysis mort_2018_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2018_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2018-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2018 prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2018_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2018     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2018_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2018_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2018 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2018_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore


****************
** 2017 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2017", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2017 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2017 (Population=286,229)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 18-May-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10e_analysis mort_2017_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2017_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2017-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2017_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2017_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2017     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2017_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2017_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2017 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2017_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore


****************
** 2016 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2016", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2016 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2016 (Population=285,798)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 18-May-2022.
Prepared by: JC using Stata 
REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10d_analysis mort_2016_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\3-output\2016_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2016-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\3-output\2016_prep mort_deidentified")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2016_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2016     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2016_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2016_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2016 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2016_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore


****************
** 2015 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2015", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2015 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2015 (Population=285,327)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 24-Aug-2022.
Prepared by: JC using Stata 
//REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10c_analysis mort_2015_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\1-input\2015_prep mort")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2016-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\1-input\2015_prep mort")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Althought this cancer death analysis was after the DataGroup SharePoint infrastrucutre (see p117/version02 and VS Code branch '2015AnnualReport V03'), the previous 2015 ASMRs mistakenly used the BSS population totals so these rates have been corrected to the WPP population.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2015_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2015     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2015"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2015_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2015_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2016 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2015"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2015"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2015_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore


****************
** 2014 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2014", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2014 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2014 (Population=284,825)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 24-Aug-2022.
Prepared by: JC using Stata 
//REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10b_analysis mort_2014_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\1-input\2014_cancer_mort_dc")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2016-10 and world population dataset: who2000_10-2; cancer dataset used: "`datapath'\version09\1-input\2014_cancer_mort_dc")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
This cancer death analysis was before the DataGroup SharePoint infrastrucutre so original files and data can be found in path: "...\Sync\DM\Stata\Stata do files\data_cleaning\2014\cancer\versions\version02\" + "...\Sync\DM\Stata\Stata do files\data_analysis\2014\cancer\versions\version01\".
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2014_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2014     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2014"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2014"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2014_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2014_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2014 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2014"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2014"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2014_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

****************
** 2013 ASMRs **
****************
** JC 10may2022: NS requested the ASMRs earlier than rest of stats for Globocan comparison process.
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                *       ASMRs - WPP        *
				****************************

** Output for above ASMRs
use "`datapath'\version09\2-working\ASMRs_wpp_2013", clear
//format asmr %04.2f
//format percentage %04.1f
sort cancer_site year asmr

preserve
putdocx clear
putdocx begin, footer(foot1)
putdocx pagebreak
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CANCER 2013 Annual Report: ASMRs - WPP"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 10. Top 10 Cancer Mortality Statistics for BNR-Cancer, 2013 (Population=284,294)"), bold font(Helvetica,10,"blue")
putdocx textblock begin
Date Prepared: 24-Aug-2022.
Prepared by: JC using Stata 
//REDCap (death) data release date: 06-May-2022.
Generated using Dofile: 10f_analysis mort_2013+2014_age10.do
putdocx textblock end
putdocx paragraph
putdocx text ("Methods"), bold
putdocx textblock begin
(1) No.(tumours): Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (dataset used: "`datapath'\version09\1-input\2013_cancer_for_MR_only")
putdocx textblock end
putdocx textblock begin
(2) ASMR: Excludes ineligible case definition, non-malignant tumours, IARC non-reportable MPs (distrate using WPP population: pop_wpp_2013-10 and world population dataset: who2000_10-2; cancer death dataset used: "`datapath'\version09\1-input\2013_cancer_for_MR_only")
putdocx textblock end
putdocx textblock begin
(3) ASMR: Includes reportable cancer terms on both parts of the CODs so does not only take into account underlying COD so numbers and rates are an overestimation.
putdocx textblock end
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
This cancer death database was based on A.Rose's method so cancer_site is the site groupings created by AR since the cancer CODs were not ICD-10 coded (original files and data can be found in path: "...\Sync\DM\Stata\Stata do files\data_cleaning\2013\cancer\versions\version03\" + "...\Sync\DM\Stata\Stata do files\data_analysis\2013\cancer\versions\version02\"). Site groupings differ slightly from 2014 onwards as 2014 onwards used ICD-10 coded cancer CODs + IARC's site groupings.
putdocx textblock end
//putdocx pagebreak
putdocx table tbl1 = data(cancer_site year number percent asmr ci_lower ci_upper), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

** Output for top10 age-specific rates
preserve
use "`datapath'\version09\2-working\2013_top10mort_age_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				*      MORTALITY: 2013     *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers: 2013"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2013"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2013_top10mort_age_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

clear

** Output for top10 age-specific rates by sex
preserve
use "`datapath'\version09\2-working\2013_top10mort_age+sex_rates", clear

				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
                * Top 10 age-specific rate *
				* by sex - MORTALITY: 2013 *
				****************************

putdocx clear
putdocx begin
putdocx pagebreak

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Age-specific mortality rates for Top 10 cancers by Sex: 2013"), bold
putdocx paragraph, halign(center)
putdocx text ("Mortality Top 10 - 2013"), bold font(Helvetica,14,"blue")
putdocx paragraph
putdocx text ("Note"), bold
putdocx textblock begin
Excludes age groups and sex with no deaths (dataset used: "`datapath'\version09\2-working\2013_top10mort_age+sex_rates")
putdocx textblock end
putdocx paragraph
putdocx table tbl1 = data(year cancer_site sex age_10 age_specific_rate), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore

/*
** Output for cases by PARISH
clear
use "`datapath'\version09\2-working\2013_2014_2015_cancer_numbers", clear
				*******************************
				*	     MS WORD REPORT       *
				*   ANNUAL REPORT STATISTICS  *
                * Cases by parish + yr + site *
				*******************************


** All cases by parish
preserve
tab parish
contract parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=2,750)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename count Total_Records
rename percentage Percent
putdocx table tbl_parish = data("Parish Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_parish(1,.), bold

putdocx save "`datapath'\version09\3-output\2021-08-12_annual_report_stats.docx", append
putdocx clear

save "`datapath'\version09\2-working\2013-2015_cases_parish.dta" ,replace
label data "BNR-Cancer 2013-2015 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore


** All cases by parish + dxyr
preserve
tab parish dxyr
contract parish dxyr, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Year"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (2013: # tumours/n=859)"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (2014: # tumours/n=861)"), bold font(Helvetica,14,"blue")
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (2015: # tumours/n=1,030)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename dxyr Year
rename count Total_Records
rename percentage Percent
putdocx table tbl_year = data("Parish Year Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_year(1,.), bold

putdocx save "`datapath'\version09\3-output\2021-08-12_annual_report_stats.docx", append
putdocx clear

save "`datapath'\version09\2-working\2013-2015_cases_parish+dxyr.dta" ,replace
label data "BNR-Cancer 2013-2015 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore


** All cases by parish + site
preserve
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=2,750)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version09\3-output\2021-08-12_annual_report_stats.docx", append
putdocx clear

save "`datapath'\version09\2-working\2013-2015_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2013-2015 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore


** All cases by parish + site (2013)
preserve
drop if dxyr!=2013
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site: 2013"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=859)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version09\3-output\2021-08-12_annual_report_stats.docx", append
putdocx clear

save "`datapath'\version09\2-working\2013_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2013 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore

** All cases by parish + site (2014)
preserve
drop if dxyr!=2014
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site: 2014"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=861)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version09\3-output\2021-08-12_annual_report_stats.docx", append
putdocx clear

save "`datapath'\version09\2-working\2014_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2014 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore

** All cases by parish + site (2015)
preserve
drop if dxyr!=2015
tab siteiarc parish
contract siteiarc parish, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Cases by Parish + Site: 2015"), bold
putdocx paragraph, halign(center)
putdocx text ("Cases by Parish (# tumours/n=1,030)"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename parish Parish
rename siteiarc Site
rename count Total_Records
rename percentage Percent
putdocx table tbl_site = data("Parish Site Total_Records Percent"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version09\3-output\2021-08-12_annual_report_stats.docx", append
putdocx clear

save "`datapath'\version09\2-working\2015_cases_parish+site.dta" ,replace
label data "BNR-Cancer 2015 Cases by Parish"
notes _dta :These data prepared for Natasha Sobers - 2015 annual report
restore

*/



				****************************
				* 	    MS WORD REPORT     *
				* ANNUAL REPORT STATISTICS *
				* 	 Mortality:Incidence   * 
				*       Ratio RESULTS      *
				****************************
** Create MS Word results table with absolute case totals + the MIRs for grouped years (2016-2018), by site, by sex 
preserve
use "`datapath'\version09\3-output\2016-2018_mirs_adjusted" ,clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Mortality:Incidence Ratios"), bold
putdocx paragraph, style(Heading2)
putdocx text ("MIRs Grouped (Dofile: 22d_MIRs_2016-2018.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table: Case Totals + Mortality:Incidence Ratios for BNR-Cancer Grouped Years (2016-2018)"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Background"), bold
putdocx textblock begin
A data quality assessment performed by the IARC Hub noted large M:I ratios in certain sites. IARC Hub used mortality data from the CARPHA mortality database, which collects data from Ministry of Health and Wellness. This report performs a secondary check using mortality data collected directly from the Barbados Registration Dept. This data quality indicator is one method of assessing completeness.
putdocx textblock end

putdocx paragraph, halign(center)

putdocx table tbl1 = data(sitecr5db sex mir_all mir_iarc cases_mort_all cases_incid_all), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)


local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore
				*******************************
				*	     MS WORD REPORT       *
				*   ANNUAL REPORT STATISTICS  *
                *   Length of Time (DX + DOD) *
				*******************************
preserve
use "`datapath'\version09\2-working\doddotdiff", clear
putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Date Difference"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Date Difference (Dofile: 20d_final clean.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Length of Time Between Diagnosis and Death in MONTHS (Median, Range and Mean), 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below table uses the variables [dot] and [dod] to display results for patients by tumour (i.e. MPs not excluded) that have died. It does not include cases where [dod] is missing, i.e. Alive patients.")

putdocx paragraph, halign(center)

putdocx table tbl1 = data(year median_doddotdiff range_lower range_upper mean_doddotdiff), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx", append
putdocx clear
restore
				*******************************
				*	     MS WORD REPORT       *
				*   ANNUAL REPORT STATISTICS  *
                *   Resident Status by DxYr   *
				*******************************

** SF requested via WhatsApp on 23aug2022: table with dxyr and resident status as wants to see those that are nonreportable due to resident status
preserve
use "`datapath'\version09\3-output\2008_2013-2018_nonsurvival_nonreportable" ,clear

table resident dxyr if resident!=1

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Resident Status"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Resident Status (Dofile: 20d_final clean.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Resident Status, 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below table uses the variables [resident] and [dxyr] to display results for patients only (i.e. MPs excluded).")

putdocx paragraph, halign(center)
putdocx text ("2008,2013-2018"), bold font(Helvetica,10,"blue")
tab2docx resident if dxyr>2007 & patient==1

putdocx paragraph, halign(center)
putdocx text ("Non-Residents by Diagnosis Year, 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx image "`datapath'\version09\2-working\ResidentStatusByYear.png", width(14.98) height(4.36)
putdocx paragraph

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx" ,append
putdocx clear
restore

				*******************************
				*	     MS WORD REPORT       *
				*   ANNUAL REPORT STATISTICS  *
                *  Basis of Diagnosis by DxYr *
				*******************************

** SF requested via Zoom meeting on 18aug2022: table with dxyr and basis
preserve
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Most Valid Basis Of Diagnosis"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Basis Of Diagnosis (Dofile: 25a_analysis numbers.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis Of Diagnosis, 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below table uses the variables [basis] and [dxyr] to display results for patients by tumour (i.e. MPs not excluded).")

putdocx paragraph, halign(center)
putdocx text ("2008,2013-2018"), bold font(Helvetica,10,"blue")
tab2docx basis if dxyr>2007

putdocx paragraph, halign(center)
putdocx text ("Basis Of Diagnosis by Diagnosis Year, 2008-2018."), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx image "`datapath'\version09\2-working\BODbyYear.png", width(17.94) height(5.08)
putdocx paragraph

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx" ,append
putdocx clear
restore

** SF requested via Zoom meeting on 18aug2022: table with dxyr and basis
** For ease, I copied and pasted the below results into the Word doc:

** LOAD 2008, 2013-2018 cleaned cancer incidence dataset from p117/version15/20d_final clean.do
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

count //6682

tab basis dxyr
/*
                      |                                Diagnosis Year
   Basis Of Diagnosis |      2008       2013       2014       2015       2016       2017       2018 |     Total
----------------------+-----------------------------------------------------------------------------+----------
                  DCO |        52         59         41        101         82         79         55 |       469 
        Clinical only |        16         21         38         67        101         83         43 |       369 
Clinical Invest./Ult  |        45         60         36         62         55         58         43 |       359 
Lab test (biochem/imm |         7          5         10         14         31         13         17 |        97 
        Cytology/Haem |        31         31         45         28         23         19         27 |       204 
Hx of mets/Autopsy wi |        24         16         13         19         13         24         21 |       130 
Hx of primary/Autopsy |       635        646        638        754        729        683        752 |     4,837 
              Unknown |         5         46         63         47         36         18          2 |       217 
----------------------+-----------------------------------------------------------------------------+----------
                Total |       815        884        884      1,092      1,070        977        960 |     6,682
*/
table basis dxyr
/*
-------------------------------------------------------------------------------------------------------------------------------
                                                                    |                       Diagnosis Year                     
                                                                    |  2008   2013   2014    2015    2016   2017   2018   Total
--------------------------------------------------------------------+----------------------------------------------------------
Basis Of Diagnosis                                                  |                                                          
  DCO                                                               |    52     59     41     101      82     79     55     469
  Clinical only                                                     |    16     21     38      67     101     83     43     369
  Clinical Invest./Ult Sound/Exploratory Surgery/Autopsy without hx |    45     60     36      62      55     58     43     359
  Lab test (biochem/immuno.)                                        |     7      5     10      14      31     13     17      97
  Cytology/Haem                                                     |    31     31     45      28      23     19     27     204
  Hx of mets/Autopsy with Hx of mets                                |    24     16     13      19      13     24     21     130
  Hx of primary/Autopsy with Hx of primary                          |   635    646    638     754     729    683    752   4,837
  Unknown                                                           |     5     46     63      47      36     18      2     217
  Total                                                             |   815    884    884   1,092   1,070    977    960   6,682
-------------------------------------------------------------------------------------------------------------------------------
*/


contract basis dxyr
rename _freq number

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, halign(center)

putdocx table tbl1 = data(dxyr basis number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version09\3-output\Cancer_2016-2018AnnualReportStatsV06_`listdate'.docx" ,append
putdocx clear