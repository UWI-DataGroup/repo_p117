cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          30b_report cancer_EXCEL.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      26-AUG-2022
    // 	date last modified      31-AUG-2022
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
export_excel title results_2018 results_2017 results_2016 results_2015 results_2014 results_2013 using "`datapath'\version09\3-output\2016-2018AnnualReport_SUMMSTATS_`listdate'.xlsx", firstrow(variables) sheet(Summary, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_SUMMSTATS_`listdate'.xlsx", sheet(Summary) modify
putexcel A1:G1, bold fpat(solid, lightgray)

putexcel A1 = "Title"
putexcel B1 = "Results_2018"
putexcel C1 = "Results_2017"
putexcel D1 = "Results_2016"
putexcel E1 = "Results_2015"
putexcel F1 = "Results_2014"
putexcel G1 = "Results_2013"
putexcel (B4:G4), rownames nformat(number_d2)
putexcel (B6:G6), rownames nformat(number_d2)
putexcel (B8:G8), nformat("0.0")
putexcel (B9:G9), nformat("0.0")
putexcel (B10:G10), nformat("0.0")
putexcel (B11:G11), nformat("0.0")
putexcel save
restore



*************
**  ASIRs  **
*************
** Load the 'all years' ASIRs dataset
preserve
use "`datapath'\version09\2-working\ASIRs" ,clear

** Create Sheet with All Years
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asir ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", firstrow(variables) sheet(AllYears, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", sheet(AllYears) modify
putexcel A1:G1, bold fpat(solid, lightgray)

putexcel A1 = "Cancer_Site"
putexcel B1 = "Year"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASIR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D67), nformat("0.0")
putexcel (E2:E67), nformat("0.0")
putexcel (F2:F67), nformat("0.0")
putexcel (G2:G67), nformat("0.0")
putexcel save
restore

** 2018 FEMALE **
** Load the '2018 top5 F' ASIRs dataset
preserve
use "`datapath'\version09\2-working\ASIRs_2018_female", clear
format asir %04.2f
sort cancer_site asir

** Create Sheet with top5 female
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site number percent asir ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", firstrow(variables) sheet(2018_top5female, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", sheet(2018_top5female) modify
putexcel A1:G1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Cancer_Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASIR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D7), nformat("0.0")
putexcel (E2:E7), nformat("0.0")
putexcel (F2:F7), nformat("0.0")
putexcel (G2:G7), nformat("0.0")
putexcel save
restore

** 2018 MALE **
** Load the '2018 top5 M' ASIRs dataset
preserve
use "`datapath'\version09\2-working\ASIRs_2018_male", clear
format asir %04.2f
sort cancer_site asir

** Create Sheet with top5 male
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site number percent asir ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", firstrow(variables) sheet(2018_top5male, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", sheet(2018_top5male) modify
putexcel A1:G1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Cancer_Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASIR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D7), nformat("0.0")
putexcel (E2:E7), nformat("0.0")
putexcel (F2:F7), nformat("0.0")
putexcel (G2:G7), nformat("0.0")
putexcel save
restore

** 2017 FEMALE **
** Load the '2017 top5 F' ASIRs dataset
preserve
use "`datapath'\version09\2-working\ASIRs_2017_female", clear
format asir %04.2f
sort cancer_site asir

** Create Sheet with top5 female
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site number percent asir ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", firstrow(variables) sheet(2017_top5female, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", sheet(2017_top5female) modify
putexcel A1:G1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Cancer_Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASIR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D7), nformat("0.0")
putexcel (E2:E7), nformat("0.0")
putexcel (F2:F7), nformat("0.0")
putexcel (G2:G7), nformat("0.0")
putexcel save
restore

** 2017 MALE **
** Load the '2017 top5 M' ASIRs dataset
preserve
use "`datapath'\version09\2-working\ASIRs_2017_male", clear
format asir %04.2f
sort cancer_site asir

** Create Sheet with top5 male
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site number percent asir ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", firstrow(variables) sheet(2017_top5male, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", sheet(2017_top5male) modify
putexcel A1:G1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Cancer_Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASIR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D7), nformat("0.0")
putexcel (E2:E7), nformat("0.0")
putexcel (F2:F7), nformat("0.0")
putexcel (G2:G7), nformat("0.0")
putexcel save
restore

** 2016 FEMALE **
** Load the '2016 top5 F' ASIRs dataset
preserve
use "`datapath'\version09\2-working\ASIRs_2016_female", clear
format asir %04.2f
sort cancer_site asir

** Create Sheet with top5 female
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site number percent asir ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", firstrow(variables) sheet(2016_top5female, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", sheet(2016_top5female) modify
putexcel A1:G1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Cancer_Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASIR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D7), nformat("0.0")
putexcel (E2:E7), nformat("0.0")
putexcel (F2:F7), nformat("0.0")
putexcel (G2:G7), nformat("0.0")
putexcel save
restore

** 2016 MALE **
** Load the '2016 top5 M' ASIRs dataset
preserve
use "`datapath'\version09\2-working\ASIRs_2016_male", clear
format asir %04.2f
sort cancer_site asir

** Create Sheet with top5 male
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site number percent asir ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", firstrow(variables) sheet(2016_top5male, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASIRs_`listdate'.xlsx", sheet(2016_top5male) modify
putexcel A1:G1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Cancer_Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASIR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D8), nformat("0.0")
putexcel (E2:E8), nformat("0.0")
putexcel (F2:F8), nformat("0.0")
putexcel (G2:G8), nformat("0.0")
putexcel save
restore


************************
**  Site Order Tables **
************************
** Load each year's site order table into a different sheet
** 2018 **
preserve
use "`datapath'\version09\2-working\siteorder_2018", clear
sort order_id siteiarc

** Create Sheet with 2018
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel order_id siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", firstrow(variables) sheet(SiteOrder_2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", sheet(SiteOrder_2018) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Order_ID"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel (A2:D2), bold fpat(solid, yellow)
putexcel (A3:D3), bold fpat(solid, yellow)
putexcel (A4:D4), bold fpat(solid, yellow)
putexcel (A5:D5), bold fpat(solid, yellow)
putexcel (A6:D6), bold fpat(solid, yellow)
putexcel (A7:D7), bold fpat(solid, yellow)
putexcel (A8:D8), bold fpat(solid, yellow)
putexcel (A9:D9), bold fpat(solid, yellow)
putexcel (A10:D10), bold fpat(solid, yellow)
putexcel (A11:D11), bold fpat(solid, yellow)
putexcel (D2:D21), nformat("0.0")
putexcel save
restore

** 2017 **
preserve
use "`datapath'\version09\2-working\siteorder_2017", clear
sort order_id siteiarc

** Create Sheet with 2017
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel order_id siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", firstrow(variables) sheet(SiteOrder_2017, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", sheet(SiteOrder_2017) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Order_ID"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel (A2:D2), bold fpat(solid, yellow)
putexcel (A3:D3), bold fpat(solid, yellow)
putexcel (A4:D4), bold fpat(solid, yellow)
putexcel (A5:D5), bold fpat(solid, yellow)
putexcel (A6:D6), bold fpat(solid, yellow)
putexcel (A7:D7), bold fpat(solid, yellow)
putexcel (A8:D8), bold fpat(solid, yellow)
putexcel (A9:D9), bold fpat(solid, yellow)
putexcel (A12:D12), bold fpat(solid, yellow)
putexcel (A13:D13), bold fpat(solid, yellow)
putexcel (D2:D21), nformat("0.0")
putexcel save
restore

** 2016 **
preserve
use "`datapath'\version09\2-working\siteorder_2016", clear
sort order_id siteiarc

** Create Sheet with 2016
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel order_id siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", firstrow(variables) sheet(SiteOrder_2016, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", sheet(SiteOrder_2016) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Order_ID"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel (A2:D2), bold fpat(solid, yellow)
putexcel (A3:D3), bold fpat(solid, yellow)
putexcel (A4:D4), bold fpat(solid, yellow)
putexcel (A5:D5), bold fpat(solid, yellow)
putexcel (A6:D6), bold fpat(solid, yellow)
putexcel (A7:D7), bold fpat(solid, yellow)
putexcel (A8:D8), bold fpat(solid, yellow)
putexcel (A9:D9), bold fpat(solid, yellow)
putexcel (A10:D10), bold fpat(solid, yellow)
putexcel (A14:D14), bold fpat(solid, yellow)
putexcel (D2:D21), nformat("0.0")
putexcel save
restore

** 2015 **
preserve
use "`datapath'\version09\2-working\siteorder_2015", clear
sort order_id siteiarc

** Create Sheet with 2015
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel order_id siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", firstrow(variables) sheet(SiteOrder_2015, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", sheet(SiteOrder_2015) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Order_ID"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel (A2:D2), bold fpat(solid, yellow)
putexcel (A3:D3), bold fpat(solid, yellow)
putexcel (A4:D4), bold fpat(solid, yellow)
putexcel (A5:D5), bold fpat(solid, yellow)
putexcel (A6:D6), bold fpat(solid, yellow)
putexcel (A7:D7), bold fpat(solid, yellow)
putexcel (A8:D8), bold fpat(solid, yellow)
putexcel (A9:D9), bold fpat(solid, yellow)
putexcel (A10:D10), bold fpat(solid, yellow)
putexcel (A11:D11), bold fpat(solid, yellow)
putexcel (D2:D21), nformat("0.0")
putexcel save
restore

** 2014 **
preserve
use "`datapath'\version09\2-working\siteorder_2014", clear
sort order_id siteiarc

** Create Sheet with 2014
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel order_id siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", firstrow(variables) sheet(SiteOrder_2014, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", sheet(SiteOrder_2014) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Order_ID"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel (A2:D2), bold fpat(solid, yellow)
putexcel (A3:D3), bold fpat(solid, yellow)
putexcel (A4:D4), bold fpat(solid, yellow)
putexcel (A5:D5), bold fpat(solid, yellow)
putexcel (A6:D6), bold fpat(solid, yellow)
putexcel (A7:D7), bold fpat(solid, yellow)
putexcel (A8:D8), bold fpat(solid, yellow)
putexcel (A10:D10), bold fpat(solid, yellow)
putexcel (A11:D11), bold fpat(solid, yellow)
putexcel (A13:D13), bold fpat(solid, yellow)
putexcel (D2:D21), nformat("0.0")
putexcel save
restore

** 2013 **
preserve
use "`datapath'\version09\2-working\siteorder_2013", clear
sort order_id siteiarc

** Create Sheet with 2013
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel order_id siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", firstrow(variables) sheet(SiteOrder_2013, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_SiteOrder_`listdate'.xlsx", sheet(SiteOrder_2013) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Order_ID"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel (A2:D2), bold fpat(solid, yellow)
putexcel (A3:D3), bold fpat(solid, yellow)
putexcel (A4:D4), bold fpat(solid, yellow)
putexcel (A5:D5), bold fpat(solid, yellow)
putexcel (A7:D7), bold fpat(solid, yellow)
putexcel (A8:D8), bold fpat(solid, yellow)
putexcel (A9:D9), bold fpat(solid, yellow)
putexcel (A10:D10), bold fpat(solid, yellow)
putexcel (A12:D12), bold fpat(solid, yellow)
putexcel (A13:D13), bold fpat(solid, yellow)
putexcel (D2:D21), nformat("0.0")
putexcel save
restore



**********************
**  Number of Cases **
**   Top 10 by Sex  **
**	  (2016-2018)   **
**********************
** Load each year's top 10 tables into a different sheet
** 2018 **
preserve
use "`datapath'\version09\2-working\2018_top10_sex", clear

** Create Sheet with 2018
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex number using "`datapath'\version09\3-output\2016-2018AnnualReport_Top10CasesbySex_`listdate'.xlsx", firstrow(variables) sheet(Top10_2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_Top10CasesbySex_`listdate'.xlsx", sheet(Top10_2018) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Number"
putexcel save
restore

** 2017 **
preserve
use "`datapath'\version09\2-working\2017_top10_sex", clear

** Create Sheet with 2017
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex number using "`datapath'\version09\3-output\2016-2018AnnualReport_Top10CasesbySex_`listdate'.xlsx", firstrow(variables) sheet(Top10_2017, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_Top10CasesbySex_`listdate'.xlsx", sheet(Top10_2017) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Number"
putexcel save
restore

** 2016 **
preserve
use "`datapath'\version09\2-working\2016_top10_sex", clear

** Create Sheet with 2016
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex number using "`datapath'\version09\3-output\2016-2018AnnualReport_Top10CasesbySex_`listdate'.xlsx", firstrow(variables) sheet(Top10_2016, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_Top10CasesbySex_`listdate'.xlsx", sheet(Top10_2016) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Number"
putexcel save
restore



**************************
**  Age-specific Rates  **
**  2018 Top 10 by Sex  **
**	   (2013-2018)      **
**************************
** Load each year's age-specific rates by sex by 2018 top 10 tables into a different sheet
** 2018 **
preserve
use "`datapath'\version09\2-working\2018_top10_age+sex_rates", clear

** Create Sheet with 2018
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age5 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(AgeSpecific_2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", sheet(AgeSpecific_2018) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age5Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E140), nformat("0.0")
putexcel save
restore

** 2017 **
preserve
use "`datapath'\version09\2-working\2017_2018top10_age+sex_rates", clear

** Create Sheet with 2017
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age5 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(AgeSpecific_2017, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", sheet(AgeSpecific_2017) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age5Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E139), nformat("0.0")
putexcel save
restore

** 2016 **
preserve
use "`datapath'\version09\2-working\2016_2018top10_age+sex_rates", clear

** Create Sheet with 2016
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age5 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(AgeSpecific_2016, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", sheet(AgeSpecific_2016) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age5Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E137), nformat("0.0")
putexcel save
restore

** 2015 **
preserve
use "`datapath'\version09\2-working\2015_2018top10_age+sex_rates", clear

** Create Sheet with 2015
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age5 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(AgeSpecific_2015, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", sheet(AgeSpecific_2015) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age5Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E146), nformat("0.0")
putexcel save
restore

** 2014 **
preserve
use "`datapath'\version09\2-working\2014_2018top10_age+sex_rates", clear

** Create Sheet with 2014
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age5 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(AgeSpecific_2014, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", sheet(AgeSpecific_2014) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age5Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E136), nformat("0.0")
putexcel save
restore

** 2013 **
preserve
use "`datapath'\version09\2-working\2013_2018top10_age+sex_rates", clear

** Create Sheet with 2013
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age5 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(AgeSpecific_2013, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_2018Top10AgeSpecificRates_`listdate'.xlsx", sheet(AgeSpecific_2013) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age5Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E141), nformat("0.0")
putexcel save
restore



**************************
**  Age-specific Rates  **
**  2016 + 2017 Top 10  **
**       by Sex         **
**	   (2016 & 2017)    **
**************************
** Load each year's age-specific rates by sex by year top 10 tables into a different sheet
** 2017 **
preserve
use "`datapath'\version09\2-working\2017_top10_age+sex_rates", clear

** Create Sheet with 2017
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age5 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_2016+2017Top10AgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(AgeSpecific_2017, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_2016+2017Top10AgeSpecificRates_`listdate'.xlsx", sheet(AgeSpecific_2017) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age5Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E133), nformat("0.0")
putexcel save
restore

** 2016 **
preserve
use "`datapath'\version09\2-working\2016_top10_age+sex_rates", clear

** Create Sheet with 2016
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age5 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_2016+2017Top10AgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(AgeSpecific_2016, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_2016+2017Top10AgeSpecificRates_`listdate'.xlsx", sheet(AgeSpecific_2016) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age5Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E135), nformat("0.0")
putexcel save
restore




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
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(Totals, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(Totals) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with AllSites
keep if cancer_site!=1

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(AllSites, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(AllSites) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D91), nformat("0.0")
putexcel (E2:E91), nformat("0.0")
putexcel (F2:F91), nformat("0.0")
putexcel (G2:G91), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==2

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(Prostate, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(Prostate) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==3

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(Breast, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(Breast) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==4

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(Colon, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(Colon) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==5

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(Lung, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(Lung) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==6

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(Pancreas, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(Pancreas) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==7

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(MM, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(MM) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==8

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(NHL, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(NHL) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==9

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(Rectum, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(Rectum) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==10

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(CorpusUteri, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(CorpusUteri) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore

preserve
use "`datapath'\version09\2-working\ASMRs_wpp_2013-2021" ,clear
** Create Sheet2 with Prostate
keep if cancer_site==11

//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel cancer_site year number percent asmr ci_lower ci_upper using "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", firstrow(variables) sheet(Stomach, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ASMRs_`listdate'.xlsx", sheet(Stomach) modify
putexcel A1:G1, bold fpat(solid, lightgray)
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "ASMR"
putexcel F1 = "CI_lower"
putexcel G1 = "CI_upper"
putexcel (D2:D10), nformat("0.0")
putexcel (E2:E10), nformat("0.0")
putexcel (F2:F10), nformat("0.0")
putexcel (G2:G10), nformat("0.0")
putexcel save

restore



**************************
**      MORTALITY       **
**  Age-specific Rates  **
**  Top 10 (2013-2021)  **
**************************
** Load each year's MORTALITY age-specific rates tables into a different sheet
** 2021 **
preserve
use "`datapath'\version09\2-working\2021_top10mort_age_rates", clear

** Create Sheet with 2021
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(MortAge_2021, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", sheet(MortAge_2021) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Age10Group"
putexcel D1 = "AgeSpecificRate"
putexcel (D2:D59), nformat("0.0")
putexcel save
restore

** 2020 **
preserve
use "`datapath'\version09\2-working\2020_top10mort_age_rates", clear

** Create Sheet with 2020
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(MortAge_2020, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", sheet(MortAge_2020) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Age10Group"
putexcel D1 = "AgeSpecificRate"
putexcel (D2:D55), nformat("0.0")
putexcel save
restore

** 2019 **
preserve
use "`datapath'\version09\2-working\2019_top10mort_age_rates", clear

** Create Sheet with 2019
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(MortAge_2019, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", sheet(MortAge_2019) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Age10Group"
putexcel D1 = "AgeSpecificRate"
putexcel (D2:D56), nformat("0.0")
putexcel save
restore

** 2018 **
preserve
use "`datapath'\version09\2-working\2018_top10mort_age_rates", clear

** Create Sheet with 2018
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(MortAge_2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", sheet(MortAge_2018) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Age10Group"
putexcel D1 = "AgeSpecificRate"
putexcel (D2:D56), nformat("0.0")
putexcel save
restore

** 2017 **
preserve
use "`datapath'\version09\2-working\2017_top10mort_age_rates", clear

** Create Sheet with 2017
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(MortAge_2017, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", sheet(MortAge_2017) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Age10Group"
putexcel D1 = "AgeSpecificRate"
putexcel (D2:D57), nformat("0.0")
putexcel save
restore

** 2016 **
preserve
use "`datapath'\version09\2-working\2016_top10mort_age_rates", clear

** Create Sheet with 2016
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(MortAge_2016, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", sheet(MortAge_2016) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Age10Group"
putexcel D1 = "AgeSpecificRate"
putexcel (D2:D54), nformat("0.0")
putexcel save
restore

** 2015 **
preserve
use "`datapath'\version09\2-working\2015_top10mort_age_rates", clear

** Create Sheet with 2015
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(MortAge_2015, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", sheet(MortAge_2015) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Age10Group"
putexcel D1 = "AgeSpecificRate"
putexcel (D2:D58), nformat("0.0")
putexcel save
restore

** 2014 **
preserve
use "`datapath'\version09\2-working\2014_top10mort_age_rates", clear

** Create Sheet with 2014
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(MortAge_2014, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", sheet(MortAge_2014) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Age10Group"
putexcel D1 = "AgeSpecificRate"
putexcel (D2:D59), nformat("0.0")
putexcel save
restore

** 2013 **
preserve
use "`datapath'\version09\2-working\2013_top10mort_age_rates", clear

** Create Sheet with 2013
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", firstrow(variables) sheet(MortAge_2013, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificRates_`listdate'.xlsx", sheet(MortAge_2013) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Age10Group"
putexcel D1 = "AgeSpecificRate"
putexcel (D2:D64), nformat("0.0")
putexcel save
restore




**************************
**      MORTALITY       **
**  Age-specific Rates  **
**    Top 10 by Sex     **
**	   (2013-2021)      **
**************************
** Load each year's age-specific rates by sex MORTALITY tables into a different sheet
** 2021 **
preserve
use "`datapath'\version09\2-working\2021_top10mort_age+sex_rates", clear

** Create Sheet with 2021
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", firstrow(variables) sheet(MortAgeSex_2021, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", sheet(MortAgeSex_2021) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age10Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E92), nformat("0.0")
putexcel save
restore

** 2020 **
preserve
use "`datapath'\version09\2-working\2020_top10mort_age+sex_rates", clear

** Create Sheet with 2020
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", firstrow(variables) sheet(MortAgeSex_2020, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", sheet(MortAgeSex_2020) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age10Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E82), nformat("0.0")
putexcel save
restore

** 2019 **
preserve
use "`datapath'\version09\2-working\2019_top10mort_age+sex_rates", clear

** Create Sheet with 2019
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", firstrow(variables) sheet(MortAgeSex_2019, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", sheet(MortAgeSex_2019) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age10Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E86), nformat("0.0")
putexcel save
restore

** 2018 **
preserve
use "`datapath'\version09\2-working\2018_top10mort_age+sex_rates", clear

** Create Sheet with 2018
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", firstrow(variables) sheet(MortAgeSex_2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", sheet(MortAgeSex_2018) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age10Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E83), nformat("0.0")
putexcel save
restore

** 2017 **
preserve
use "`datapath'\version09\2-working\2017_top10mort_age+sex_rates", clear

** Create Sheet with 2017
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", firstrow(variables) sheet(MortAgeSex_2017, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", sheet(MortAgeSex_2017) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age10Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E81), nformat("0.0")
putexcel save
restore

** 2016 **
preserve
use "`datapath'\version09\2-working\2016_top10mort_age+sex_rates", clear

** Create Sheet with 2016
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", firstrow(variables) sheet(MortAgeSex_2016, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", sheet(MortAgeSex_2016) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age10Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E77), nformat("0.0")
putexcel save
restore

** 2015 **
preserve
use "`datapath'\version09\2-working\2015_top10mort_age+sex_rates", clear

** Create Sheet with 2015
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", firstrow(variables) sheet(MortAgeSex_2015, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", sheet(MortAgeSex_2015) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age10Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E84), nformat("0.0")
putexcel save
restore

** 2014 **
preserve
use "`datapath'\version09\2-working\2014_top10mort_age+sex_rates", clear

** Create Sheet with 2014
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", firstrow(variables) sheet(MortAgeSex_2014, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", sheet(MortAgeSex_2014) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age10Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E86), nformat("0.0")
putexcel save
restore

** 2013 **
preserve
use "`datapath'\version09\2-working\2013_top10mort_age+sex_rates", clear

** Create Sheet with 2013
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year cancer_site sex age_10 age_specific_rate using "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", firstrow(variables) sheet(MortAgeSex_2013, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MortAgeSpecificSexRates_`listdate'.xlsx", sheet(MortAgeSex_2013) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Site"
putexcel C1 = "Sex"
putexcel D1 = "Age10Group"
putexcel E1 = "AgeSpecificRate"
putexcel (E2:E96), nformat("0.0")
putexcel save
restore


****************************************
**  Cases by Parish, by Year, by Site **
**			(2013-2018)				  **
****************************************
** Load the analysis numbers dataset
** 2013-2018 (Parish only) **
preserve
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear

contract parish, freq(count) percent(percentage)

** Create Sheet: cases by parish
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel parish count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", firstrow(variables) sheet(Parish_2013-2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", sheet(Parish_2013-2018) modify
putexcel A1:C1, bold fpat(solid, lightgray)

putexcel A1 = "Parish"
putexcel B1 = "Total_Records"
putexcel C1 = "Percent"
putexcel (C2:C13), nformat("0.0")
putexcel save
restore

** 2013-2018 (Year) **
preserve
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear

contract parish dxyr, freq(count) percent(percentage)

** Create Sheet: cases by parish + year
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel parish dxyr count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", firstrow(variables) sheet(ParishbyYear_2013-2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", sheet(ParishbyYear_2013-2018) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Parish"
putexcel B1 = "Year"
putexcel C1 = "Total_Records"
putexcel D1 = "Percent"
putexcel (D2:D70), nformat("0.0")
putexcel save
restore

** 2013-2018 (Site) **
preserve
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear

contract siteiarc parish, freq(count) percent(percentage)

** Create Sheet: cases by parish + site
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel parish siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", firstrow(variables) sheet(ParishbySite_2013-2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", sheet(ParishbySite_2013-2018) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Parish"
putexcel B1 = "Site"
putexcel C1 = "Total_Records"
putexcel D1 = "Percent"
putexcel (D2:D436), nformat("0.0")
putexcel save
restore

** 2013 (Site) **
preserve
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear
drop if dxyr!=2013
contract siteiarc parish, freq(count) percent(percentage)

** Create Sheet: cases by parish + site + year
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel parish siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", firstrow(variables) sheet(ParishbySite_2013, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", sheet(ParishbySite_2013) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Parish"
putexcel B1 = "Site"
putexcel C1 = "Total_Records"
putexcel D1 = "Percent"
putexcel (D2:D222), nformat("0.0")
putexcel save
restore

** 2014 (Site) **
preserve
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear
drop if dxyr!=2014
contract siteiarc parish, freq(count) percent(percentage)

** Create Sheet: cases by parish + site + year
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel parish siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", firstrow(variables) sheet(ParishbySite_2014, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", sheet(ParishbySite_2014) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Parish"
putexcel B1 = "Site"
putexcel C1 = "Total_Records"
putexcel D1 = "Percent"
putexcel (D2:D233), nformat("0.0")
putexcel save
restore

** 2015 (Site) **
preserve
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear
drop if dxyr!=2015
contract siteiarc parish, freq(count) percent(percentage)

** Create Sheet: cases by parish + site + year
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel parish siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", firstrow(variables) sheet(ParishbySite_2015, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", sheet(ParishbySite_2015) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Parish"
putexcel B1 = "Site"
putexcel C1 = "Total_Records"
putexcel D1 = "Percent"
putexcel (D2:D239), nformat("0.0")
putexcel save
restore

** 2016 (Site) **
preserve
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear
drop if dxyr!=2016
contract siteiarc parish, freq(count) percent(percentage)

** Create Sheet: cases by parish + site + year
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel parish siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", firstrow(variables) sheet(ParishbySite_2016, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", sheet(ParishbySite_2016) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Parish"
putexcel B1 = "Site"
putexcel C1 = "Total_Records"
putexcel D1 = "Percent"
putexcel (D2:D230), nformat("0.0")
putexcel save
restore

** 2017 (Site) **
preserve
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear
drop if dxyr!=2017
contract siteiarc parish, freq(count) percent(percentage)

** Create Sheet: cases by parish + site + year
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel parish siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", firstrow(variables) sheet(ParishbySite_2017, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", sheet(ParishbySite_2017) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Parish"
putexcel B1 = "Site"
putexcel C1 = "Total_Records"
putexcel D1 = "Percent"
putexcel (D2:D209), nformat("0.0")
putexcel save
restore

** 2018 (Site) **
preserve
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear
drop if dxyr!=2018
contract siteiarc parish, freq(count) percent(percentage)

** Create Sheet: cases by parish + site + year
//local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel parish siteiarc count percentage using "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", firstrow(variables) sheet(ParishbySite_2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_ParishSite_`listdate'.xlsx", sheet(ParishbySite_2018) modify
putexcel A1:D1, bold fpat(solid, lightgray)

putexcel A1 = "Parish"
putexcel B1 = "Site"
putexcel C1 = "Total_Records"
putexcel D1 = "Percent"
putexcel (D2:D221), nformat("0.0")
putexcel save
restore



*********************************
**  Mortality:Incidence Ratios **
**	   Adjusted + Grouped      **
**        (2016-2018)		   **
*********************************
** Load the adjusted MIRs dataset
preserve
use "`datapath'\version09\3-output\2016-2018_mirs_adjusted" ,clear

** Create Sheet
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel sitecr5db sex mir_all mir_iarc cases_mort_all cases_incid_all using "`datapath'\version09\3-output\2016-2018AnnualReport_MIRs_`listdate'.xlsx", firstrow(variables) sheet(AdjMIRs_2016-2018, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_MIRs_`listdate'.xlsx", sheet(AdjMIRs_2016-2018) modify
putexcel A1:F1, bold fpat(solid, lightgray)

putexcel A1 = "Site_CR5db"
putexcel B1 = "Sex"
putexcel C1 = "MIR"
putexcel D1 = "MIR_IARC"
putexcel E1 = "Cases_Mort"
putexcel F1 = "Cases_Incid"
putexcel (C2:C37), nformat("0.00")
putexcel (D2:D37), nformat("0.0")
putexcel save
restore





******************************
**  Length of Time Between  **
**	  Diagnosis and Death	**
**		   in MONTHS        **
**     (2008,2013-2018)     **
******************************
** Load the Date Difference dataset
preserve
use "`datapath'\version09\2-working\doddotdiff", clear

** Create Sheet
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year median_doddotdiff range_lower range_upper mean_doddotdiff using "`datapath'\version09\3-output\2016-2018AnnualReport_LOTdxdod_`listdate'.xlsx", firstrow(variables) sheet(LOT_dx_dod, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_LOTdxdod_`listdate'.xlsx", sheet(LOT_dx_dod) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Median_MONTHS"
putexcel C1 = "Range_lower_MONTHS"
putexcel D1 = "Range_upper_MONTHS"
putexcel E1 = "Mean_MONTHS"
putexcel (B2:B9), nformat("0.0")
putexcel (C2:C9), nformat("0.0")
putexcel (D2:D9), nformat("0.0")
putexcel (E2:E9), nformat("0.0")
putexcel save
restore




*******************************
**  Resident Status by Year  **
**	  (2008,2013-2018)       **
*******************************
** Load the Nonreportable Incidence dataset
preserve
use "`datapath'\version09\3-output\2008_2013-2018_nonsurvival_nonreportable" ,clear

egen total_2008 = count(pid) if dxyr==2008 & resident!=.
egen total_2013 = count(pid) if dxyr==2013 & resident!=.
egen total_2014 = count(pid) if dxyr==2014 & resident!=.
egen total_2015 = count(pid) if dxyr==2015 & resident!=.
egen total_2016 = count(pid) if dxyr==2016 & resident!=.
egen total_2017 = count(pid) if dxyr==2017 & resident!=.
egen total_2018 = count(pid) if dxyr==2018 & resident!=.

egen nores_2008 = count(pid) if dxyr==2008 & resident!=1
egen nores_2013 = count(pid) if dxyr==2013 & resident!=1
egen nores_2014 = count(pid) if dxyr==2014 & resident!=1
egen nores_2015 = count(pid) if dxyr==2015 & resident!=1
egen nores_2016 = count(pid) if dxyr==2016 & resident!=1
egen nores_2017 = count(pid) if dxyr==2017 & resident!=1
egen nores_2018 = count(pid) if dxyr==2018 & resident!=1

gen percent_nores_2008=nores_2008/total_2008*100
replace percent_nores_2008=round(percent_nores_2008,0.01)
gen percent_nores_2013=nores_2013/total_2013*100
replace percent_nores_2013=round(percent_nores_2013,0.01)
gen percent_nores_2014=nores_2014/total_2014*100
replace percent_nores_2014=round(percent_nores_2014,0.01)
gen percent_nores_2015=nores_2015/total_2015*100
replace percent_nores_2015=round(percent_nores_2015,0.01)
gen percent_nores_2016=nores_2016/total_2016*100
replace percent_nores_2016=round(percent_nores_2016,0.01)
gen percent_nores_2017=nores_2017/total_2017*100
replace percent_nores_2017=round(percent_nores_2017,0.01)
gen percent_nores_2018=nores_2018/total_2018*100
replace percent_nores_2018=round(percent_nores_2018,0.01)

contract resident dxyr total_* nores_* percent_nores_*
rename _freq number
fillmissing total_2008 total_2013 total_2014 total_2015 total_2016 total_2017 total_2018 nores_2008 nores_2013 nores_2014 nores_2015 nores_2016 nores_2017 nores_2018 percent_nores_2008 percent_nores_2013 percent_nores_2014 percent_nores_2015 percent_nores_2016 percent_nores_2017 percent_nores_2018

drop if resident==1
replace total_2008=0 if dxyr!=2008
replace total_2013=0 if dxyr!=2013
replace total_2014=0 if dxyr!=2014
replace total_2015=0 if dxyr!=2015
replace total_2016=0 if dxyr!=2016
replace total_2017=0 if dxyr!=2017
replace total_2018=0 if dxyr!=2018

replace nores_2008=0 if dxyr!=2008
replace nores_2013=0 if dxyr!=2013
replace nores_2014=0 if dxyr!=2014
replace nores_2015=0 if dxyr!=2015
replace nores_2016=0 if dxyr!=2016
replace nores_2017=0 if dxyr!=2017
replace nores_2018=0 if dxyr!=2018

replace percent_nores_2008=0 if dxyr!=2008
replace percent_nores_2013=0 if dxyr!=2013
replace percent_nores_2014=0 if dxyr!=2014
replace percent_nores_2015=0 if dxyr!=2015
replace percent_nores_2016=0 if dxyr!=2016
replace percent_nores_2017=0 if dxyr!=2017
replace percent_nores_2018=0 if dxyr!=2018

order dxyr resident number nores_2008 percent_nores_2008 total_2008 nores_2013 percent_nores_2013 total_2013 nores_2014 percent_nores_2014 total_2014 nores_2015 percent_nores_2015 total_2015 nores_2016 percent_nores_2016 total_2016 nores_2017  percent_nores_2017 total_2017 nores_2018 percent_nores_2018 total_2018

** Create Sheet
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel dxyr resident number nores_2008 percent_nores_2008 total_2008 nores_2013 percent_nores_2013 total_2013 nores_2014 percent_nores_2014 total_2014 nores_2015 percent_nores_2015 total_2015 nores_2016 percent_nores_2016 total_2016 nores_2017 percent_nores_2017 total_2017 nores_2018 percent_nores_2018 total_2018 using "`datapath'\version09\3-output\2016-2018AnnualReport_NonResidents_`listdate'.xlsx", firstrow(variables) sheet(NonResidents, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_NonResidents_`listdate'.xlsx", sheet(NonResidents) modify
putexcel A1:X1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Resident_Status"
putexcel C1 = "Number"
putexcel D1 = "NonResidents_2008"
putexcel E1 = "Percent_NonResidents_2008"
putexcel F1 = "Total_ResidentStatus_2008"
putexcel G1 = "NonResidents_2013"
putexcel H1 = "Percent_NonResidents_2013"
putexcel I1 = "Total_ResidentStatus_2013"
putexcel J1 = "NonResidents_2014"
putexcel K1 = "Percent_NonResidents_2014"
putexcel L1 = "Total_ResidentStatus_2014"
putexcel M1 = "NonResidents_2015"
putexcel N1 = "Percent_NonResidents_2015"
putexcel O1 = "Total_ResidentStatus_2015"
putexcel P1 = "NonResidents_2016"
putexcel Q1 = "Percent_NonResidents_2016"
putexcel R1 = "Total_ResidentStatus_2016"
putexcel S1 = "NonResidents_2017"
putexcel T1 = "Percent_NonResidents_2017"
putexcel U1 = "Total_ResidentStatus_2017"
putexcel V1 = "NonResidents_2018"
putexcel W1 = "Percent_NonResidents_2018"
putexcel X1 = "Total_ResidentStatus_2018"
putexcel (E2:E12), nformat("0.0")
putexcel (H2:H12), nformat("0.0")
putexcel (K2:K12), nformat("0.0")
putexcel (N2:N12), nformat("0.0")
putexcel (Q2:Q12), nformat("0.0")
putexcel (T2:T12), nformat("0.0")
putexcel (W2:W12), nformat("0.0")
putexcel save
restore



**********************************
**  Basis Of Diagnosis by Year  **
**	    (2008,2013-2018)        **
**********************************
** Load the Reportable Nonsurvival dataset
preserve
use "`datapath'\version09\3-output\2008_2013-2018_cancer_reportable_nonsurvival_deidentified" ,clear

egen total_2008 = count(pid) if dxyr==2008
egen total_2013 = count(pid) if dxyr==2013
egen total_2014 = count(pid) if dxyr==2014
egen total_2015 = count(pid) if dxyr==2015
egen total_2016 = count(pid) if dxyr==2016
egen total_2017 = count(pid) if dxyr==2017
egen total_2018 = count(pid) if dxyr==2018

contract basis dxyr total_*
rename _freq number


gen percent=number/total_2008*100
replace percent=number/total_2013*100 if percent==.
replace percent=number/total_2014*100 if percent==.
replace percent=number/total_2015*100 if percent==.
replace percent=number/total_2016*100 if percent==.
replace percent=number/total_2017*100 if percent==.
replace percent=number/total_2018*100 if percent==.
replace percent=round(percent,0.01)

fillmissing total_*

order dxyr basis number percent

** Create Sheet
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel dxyr basis number percent total_2008 total_2013 total_2014 total_2015 total_2016 total_2017 total_2018 using "`datapath'\version09\3-output\2016-2018AnnualReport_BOD_`listdate'.xlsx", firstrow(variables) sheet(BOD, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_BOD_`listdate'.xlsx", sheet(BOD) modify
putexcel A1:K1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "BasisOfDiagnosis"
putexcel C1 = "Number"
putexcel D1 = "Percent"
putexcel E1 = "Total_2008"
putexcel F1 = "Total_2013"
putexcel G1 = "Total_2014"
putexcel H1 = "Total_2015"
putexcel I1 = "Total_2016"
putexcel J1 = "Total_2017"
putexcel K1 = "Total_2018"
putexcel (D2:D57), nformat("0.0")
putexcel save
restore



******************************
**  Length of Time Between  **
**	Death and Certification	**
**	  in WEEKS(2008-2021)   **
******************************
** Load the Date Difference dataset
preserve
use "`datapath'\version09\2-working\regdoddiff", clear

** Create Sheet
local listdate : display %tc_CCYYNNDD_HHMMSS clock(c(current_date) + c(current_time), "DMYhms")
export_excel year median_regdoddiff range_lower range_upper mean_regdoddiff using "`datapath'\version09\3-output\2016-2018AnnualReport_LOTdodregdate_`listdate'.xlsx", firstrow(variables) sheet(LOT_dod_regdate, replace) 

putexcel set "`datapath'\version09\3-output\2016-2018AnnualReport_LOTdodregdate_`listdate'.xlsx", sheet(LOT_dod_regdate) modify
putexcel A1:E1, bold fpat(solid, lightgray)

putexcel A1 = "Year"
putexcel B1 = "Median_WEEKS"
putexcel C1 = "Range_lower_WEEKS"
putexcel D1 = "Range_upper_WEEKS"
putexcel E1 = "Mean_WEEKS"
putexcel (B2:B16), nformat("0.0")
putexcel (C2:C16), nformat("0.0")
putexcel (D2:D16), nformat("0.0")
putexcel (E2:E16), nformat("0.0")
putexcel save
restore
