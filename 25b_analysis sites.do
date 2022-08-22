
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          25b_analysis sites.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      18-AUG-2022
    // 	date last modified      18-AUG-2022
    //  algorithm task          Analyzing combined cancer dataset: (1) Numbers (2) ASIRs for 2016-2018 annual report
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2018 data for inclusion in the 2016-2018 annual report.
    //  methods                 See 30_report cancer.do for detailed methods of each statistic

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
    log using "`logpath'/25b_analysis sites.smcl", replace
** HEADER -----------------------------------------------------
* ****************************************************
* ANALYSIS: SECTION 2 - cancer sites
* Covering:
* 	- Classification of cancer by site (Top 10)
*	- Classification of cancer by site + sex (Top 5)
*	- Data Quality Indicators for:
*			- Basis of Diagnosis
*			- Site + Age
* ****************************************************

**********
** 2018 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear

****************************************************************************** 2018 ****************************************************************************************

drop if dxyr!=2018 //4907 deleted
count //960

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //0 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     female |        484       50.42       50.42
       male |        476       49.58      100.00
------------+-----------------------------------
      Total |        960      100.00
*/

** Note: O&U, NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64 //958 when excluding NMSCs and non-malignant tumours
//for 2018 don't remove non-melanoma skin cancers as these are not SCC or any of the non-reportable morph categories for skin
tab siteiarc if siteiarc!=64 //960 - no in-situ
tab siteiarc ,m //949 - 41 O&U
tab siteiarc patient //934 + 26 MPs

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2018
** All sites excl. in-situ, O&U, non-reportable skin cancers
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if siteiarc>60 //| siteiarc==25 //41 deleted - for 2018 don't remove non-melanoma skin cancers as these are not SCC or any of the non-reportable morph categories for skin
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
siteiarc									count	percentage
Prostate (C61)								221		30.19
Breast (C50)								177		24.18
Colon (C18)									116		15.85
Corpus uteri (C54)							 53		 7.24
Multiple myeloma (C90)						 31		 4.23
Pancreas (C25)								 31	 	 4.23
Rectum (C19-20)								 31		 4.23
Lung (incl. trachea and bronchus) (C33-34)	 28		 3.83
Non-Hodgkin lymphoma (C82-86,C96)			 23		 3.14
Stomach (C16)								 21		 2.87
*/
total count //732
restore

labelbook sex_lab
tab sex ,m


** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2018
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
preserve
drop if siteiarc>60 //| siteiarc==25 //41 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
gsort -top10
tab siteiarc top10 if top10!=0
tab siteiarc top10 if top10!=0 & sex==1 //female: 362
tab siteiarc top10 if top10!=0 & sex==2 //male: 370
contract siteiarc top10 sex if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
year	cancer_site									number	sex
2018	Stomach (C16)								 12		female
2018	Stomach (C16)								  9		male
2018	Colon (C18)									 60		female
2018	Colon (C18)									 56		male
2018	Rectum (C19-20)								  8		female
2018	Rectum (C19-20)								 23		male
2018	Pancreas (C25)								 18		female
2018	Pancreas (C25)								 13		male
2018	Lung (incl. trachea and bronchus) (C33-34)	  7		female
2018	Lung (incl. trachea and bronchus) (C33-34)	 21		male
2018	Breast (C50)								176		female
2018	Breast (C50)								  1		male
2018	Corpus uteri (C54)							 53		female
2018	Prostate (C61)								221		male
2018	Non-Hodgkin lymphoma (C82-86,C96)			 13		female
2018	Non-Hodgkin lymphoma (C82-86,C96)			 10		male
2018	Multiple myeloma (C90)						 15		female
2018	Multiple myeloma (C90)						 16		male
*/
total count //732
drop percentage
gen year=2018
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'\version09\2-working\2018_top10_sex" ,replace
restore


labelbook sex_lab
tab sex ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==2 //476 deleted
drop if siteiarc>60 //19 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/484)*100 //all cancers excl. male(476)
gen alltotpercent=(count/960)*100 //all cancers
/*
siteiarc				count	percentage	totpercent	alltotpercent
Breast (C50)			176		54.66		37.28814	18.54584
Colon (C18)				 60		18.63		12.71186	 6.322445
Corpus uteri (C54)		 53		16.46		11.22881	 5.584826
Pancreas (C25)			 18		 5.59		 3.813559	 1.896733
Multiple myeloma (C90)	 15		 4.66		 3.177966	 1.580611
*/
total count //322
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 5 code added by JC for 2018
** MALE - using IARC's site groupings
preserve
drop if sex==1 //484 deleted
drop if siteiarc>60 //| siteiarc==25 //22 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/476)*100 //all cancers excl. female(484)
gen alltotpercent=(count/960)*100 //all cancers
/*
siteiarc									count	percentage	totpercent	alltotpercent
Prostate (C61)								221		65.58		46.33124	23.28767
Colon (C18)									 56		16.62	 	11.74004	 5.900949
Rectum (C19-20)								 23		 6.82		 4.821803	 2.423604
Lung (incl. trachea and bronchus) (C33-34)	 21		 6.23		 4.402516	 2.212856
Multiple myeloma (C90)						 16		 4.75		 3.354298	 1.685985
*/
total count //337
restore


** Determine sequential order of 2018 sites from 2018 top 10
tab siteiarc ,m

preserve
drop if siteiarc>60 //| siteiarc==25 //41 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5                       Multiple myeloma (C90) |
     |-------------------------------------------------------|
  6. |        6                               Pancreas (C25) |
  7. |        7                              Rectum (C19-20) |
  8. |        8   Lung (incl. trachea and bronchus) (C33-34) |
  9. |        9            Non-Hodgkin lymphoma (C82-86,C96) |
 10. |       10                                Stomach (C16) |
     |-------------------------------------------------------|
 11. |       11                                 Kidney (C64) |
 12. |       12                                Bladder (C67) |
 13. |       13                           Cervix uteri (C53) |
 14. |       14                                Thyroid (C73) |
 15. |       15                                 Larynx (C32) |
     |-------------------------------------------------------|
 16. |       16                                  Ovary (C56) |
 17. |       17                   Myeloid leukaemia (C92-94) |
 18. |       18                                  Liver (C22) |
 19. |       19                             Oesophagus (C15) |
 20. |       20           Myeloproliferative disorders (MPD) |
     |-------------------------------------------------------|
 21. |       21                    Gallbladder etc. (C23-24) |
 22. |       22                     Lymphoid leukaemia (C91) |
 23. |       23                        Small intestine (C17) |
 24. |       24         Connective and soft tissue (C47+C49) |
 25. |       25                       Melanoma of skin (C43) |
     |-------------------------------------------------------|
 26. |       26               Brain, nervous system (C70-72) |
 27. |       27                       Other oropharynx (C10) |
 28. |       28                                  Vulva (C51) |
 29. |       29                           Renal pelvis (C65) |
 30. |       30                               Mouth (C03-06) |
     |-------------------------------------------------------|
 31. |       31                                  Penis (C60) |
 32. |       32                              Tongue (C01-02) |
 33. |       33                                 Vagina (C52) |
 34. |       34                            Nasopharynx (C11) |
 35. |       35                                Bone (C40-41) |
     |-------------------------------------------------------|
 36. |       36                             Other skin (C44) |
 37. |       37                                   Anus (C21) |
 38. |       38                           Mesothelioma (C45) |
 39. |       39                  Nose, sinuses etc. (C30-31) |
 40. |       40                                 Tonsil (C09) |
     |-------------------------------------------------------|
 41. |       41                  Leukaemia unspecified (C95) |
 42. |       42                      Salivary gland (C07-08) |
 43. |       43                     Uterus unspecified (C55) |
 44. |       44            Other female genital organs (C57) |
 45. |       45                                    Eye (C69) |
     |-------------------------------------------------------|
 46. |       46                          Adrenal gland (C74) |
 47. |       47                       Hodgkin lymphoma (C81) |
     +-------------------------------------------------------+
*/
drop if order_id>20 //27 deleted
save "`datapath'\version09\2-working\siteorder_2018" ,replace
restore


*****************************
**   Data Quality Indices  **
*****************************
** Added on 04-June-2019 by JC as requested by NS for 2014 cancer annual report

*****************************
** Identifying & Reporting **
** 	 Data Quality Index	   **
** MV,DCO,O+U,UnkAge,CLIN  **
*****************************

tab basis ,m
tab siteicd10 basis ,m 
tab sex ,m //0 missing
tab age ,m //0 missing=999
tab sex age if age==.|age==999 //0 - used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sex if sitecr5db==20 //site=O&U; used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)


tab basis ,m
gen boddqi=1 if basis>4 & basis <9 //800 changes; 
replace boddqi=2 if basis==0 //55 changes
replace boddqi=3 if basis>0 & basis<5 //103 changes
replace boddqi=4 if basis==9 //2 changes
label define boddqi_lab 1 "MV" 2 "DCO"  3 "CLIN" 4 "UNK.BASIS" , modify
label var boddqi "basis DQI"
label values boddqi boddqi_lab

gen siteagedqi=1 if siteiarc==61 //39 changes
replace siteagedqi=2 if age==.|age==999 //0 changes
replace siteagedqi=3 if dob==. & siteagedqi!=2 //6 changes
replace siteagedqi=4 if siteiarc==61 & siteagedqi!=1 //2 changes
replace siteagedqi=5 if sex==.|sex==99 //0 changes
label define siteagedqi_lab 1 "O&U SITE" 2 "UNK.AGE" 3 "UNK.DOB" 4 "O&U+UNK.AGE/DOB" 5 "UNK.SEX", modify
label var siteagedqi "site/age DQI"
label values siteagedqi siteagedqi_lab

tab boddqi ,m
generate rectot=_N //960
tab boddqi rectot,m

tab siteagedqi ,m
tab siteagedqi rectot,m


** Create variables for table by basis (DCO% + MV%) in Data Quality section of annual report
** This was done manually in excel for 2014 annual report so the above code has now been updated to be automated in Stata
tab sitecr5db boddqi if boddqi!=. & sitecr5db!=. & sitecr5db<23 & sitecr5db!=2 & sitecr5db!=5 & sitecr5db!=7 & sitecr5db!=9 & sitecr5db!=13 & sitecr5db!=15 & sitecr5db!=16 & sitecr5db!=17 & sitecr5db!=18 & sitecr5db!=19 & sitecr5db!=20
/*
          CR5db sites |        MV        DCO       CLIN  UNK.BASIS |     Total
----------------------+--------------------------------------------+----------
Mouth & pharynx (C00- |        13          0          0          0 |        13 
        Stomach (C16) |        14          2          5          0 |        21 
Colon, rectum, anus ( |       140          2          7          0 |       149 
       Pancreas (C25) |         8          7         16          0 |        31 
Lung, trachea, bronch |        17          3          8          0 |        28 
         Breast (C50) |       171          5          0          1 |       177 
         Cervix (C53) |        13          0          0          0 |        13 
Corpus & Uterus NOS ( |        50          1          3          0 |        54 
       Prostate (C61) |       198          7         15          1 |       221 
Lymphoma (C81-85,88,9 |        38          3         14          0 |        55 
   Leukaemia (C91-95) |        15          2          0          0 |        17 
----------------------+--------------------------------------------+----------
                Total |       677         32         68          2 |       779
*/
** All BOD options
preserve
drop if boddqi==. | sitecr5db==. | sitecr5db>22 | sitecr5db==20 | sitecr5db==2 | sitecr5db==5 | sitecr5db==7 | sitecr5db==9 | sitecr5db==13 | (sitecr5db>14 & sitecr5db<21) //260 deleted
contract sitecr5db boddqi, freq(count) percent(percentage)
input
40	1	677	0
40	2	 32	0
40	3	 68 0
40	4	  2 0
end

label define sitecr5db_lab ///
1 "Mouth & pharynx" ///
2 "Oesophagus" ///
3 "Stomach" ///
4 "Colon, rectum, anus" ///
5 "Liver" ///
6 "Pancreas" ///
7 "Larynx" ///
8 "Lung, trachea, bronchus" ///
9 "Melanoma of skin" ///
10 "Breast" ///
11 "Cervix" ///
12 "Corpus & Uterus NOS" ///
13 "Ovary & adnexa" ///
14 "Prostate" ///
15 "Testis" ///
16 "Kidney & urinary NOS" ///
17 "Bladder" ///
18 "Brain, nervous system" ///
19 "Thyroid" ///
20 "O&U" ///
21 "Lymphoma" ///
22 "Leukaemia" ///
23 "Other digestive" ///
24 "Nose, sinuses" ///
25 "Bone, cartilage, etc" ///
26 "Other skin" ///
27 "Other female organs" ///
28 "Other male organs" ///
29 "Other endocrine" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc" ///
40 "All sites (in this table)" , modify
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab
drop percentage
gen percentage=(count/13)*100 if sitecr5db==1 & boddqi==1
replace percentage=(count/13)*100 if sitecr5db==1 & boddqi==2
replace percentage=(count/13)*100 if sitecr5db==1 & boddqi==3
replace percentage=(count/13)*100 if sitecr5db==1 & boddqi==4
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==1
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==2
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==3
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==4
replace percentage=(count/149)*100 if sitecr5db==4 & boddqi==1
replace percentage=(count/149)*100 if sitecr5db==4 & boddqi==2
replace percentage=(count/149)*100 if sitecr5db==4 & boddqi==3
replace percentage=(count/149)*100 if sitecr5db==4 & boddqi==4
replace percentage=(count/31)*100 if sitecr5db==6 & boddqi==1
replace percentage=(count/31)*100 if sitecr5db==6 & boddqi==2
replace percentage=(count/31)*100 if sitecr5db==6 & boddqi==3
replace percentage=(count/31)*100 if sitecr5db==6 & boddqi==4
replace percentage=(count/28)*100 if sitecr5db==8 & boddqi==1
replace percentage=(count/28)*100 if sitecr5db==8 & boddqi==2
replace percentage=(count/28)*100 if sitecr5db==8 & boddqi==3
replace percentage=(count/28)*100 if sitecr5db==8 & boddqi==4
replace percentage=(count/177)*100 if sitecr5db==10 & boddqi==1
replace percentage=(count/177)*100 if sitecr5db==10 & boddqi==2
replace percentage=(count/177)*100 if sitecr5db==10 & boddqi==3
replace percentage=(count/177)*100 if sitecr5db==10 & boddqi==4
replace percentage=(count/13)*100 if sitecr5db==11 & boddqi==1
replace percentage=(count/13)*100 if sitecr5db==11 & boddqi==2
replace percentage=(count/13)*100 if sitecr5db==11 & boddqi==3
replace percentage=(count/13)*100 if sitecr5db==11 & boddqi==4
replace percentage=(count/54)*100 if sitecr5db==12 & boddqi==1
replace percentage=(count/54)*100 if sitecr5db==12 & boddqi==2
replace percentage=(count/54)*100 if sitecr5db==12 & boddqi==3
replace percentage=(count/54)*100 if sitecr5db==12 & boddqi==4
replace percentage=(count/221)*100 if sitecr5db==14 & boddqi==1
replace percentage=(count/221)*100 if sitecr5db==14 & boddqi==2
replace percentage=(count/221)*100 if sitecr5db==14 & boddqi==3
replace percentage=(count/221)*100 if sitecr5db==14 & boddqi==4
replace percentage=(count/55)*100 if sitecr5db==21 & boddqi==1
replace percentage=(count/55)*100 if sitecr5db==21 & boddqi==2
replace percentage=(count/55)*100 if sitecr5db==21 & boddqi==3
replace percentage=(count/55)*100 if sitecr5db==21 & boddqi==4
replace percentage=(count/17)*100 if sitecr5db==22 & boddqi==1
replace percentage=(count/17)*100 if sitecr5db==22 & boddqi==2
replace percentage=(count/17)*100 if sitecr5db==22 & boddqi==3
replace percentage=(count/17)*100 if sitecr5db==22 & boddqi==4
replace percentage=(count/779)*100 if sitecr5db==40 & boddqi==1
replace percentage=(count/779)*100 if sitecr5db==40 & boddqi==2
replace percentage=(count/779)*100 if sitecr5db==40 & boddqi==3
replace percentage=(count/779)*100 if sitecr5db==40 & boddqi==4
format percentage %04.1f

gen icd10dqi="C00-14" if sitecr5db==1
replace icd10dqi="C16" if sitecr5db==3
replace icd10dqi="C18-21" if sitecr5db==4
replace icd10dqi="C25" if sitecr5db==6
replace icd10dqi="C33-34" if sitecr5db==8
replace icd10dqi="C50" if sitecr5db==10
replace icd10dqi="C53" if sitecr5db==11
replace icd10dqi="C54-55" if sitecr5db==12
replace icd10dqi="C61" if sitecr5db==14
replace icd10dqi="C81-85,88,90,96" if sitecr5db==21
replace icd10dqi="C91-95" if sitecr5db==22
replace icd10dqi="All" if sitecr5db==40

putdocx clear
putdocx begin

putdocx paragraph, style(Heading1)
putdocx text ("Basis - MV%, DCO%, CLIN%, UNK%: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=960): 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename sitecr5db Cancer_Site
rename boddqi Total_DQI
rename count Cases
rename percentage Pct_DQI
rename icd10dqi ICD10
putdocx table tbl_bod = data("Cancer_Site Total_DQI Cases Pct_DQI ICD10"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version09\3-output\2022-08-11_DQI.docx", append
putdocx clear

save "`datapath'\version09\2-working\2018_cancer_dqi_basis.dta" ,replace
label data "BNR-Cancer 2018 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore


preserve
** % tumours - site,age
tab siteagedqi
contract siteagedqi, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Unknown - Site, DOB & Age: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Site,DOB,Age (# tumours/n=960): 2018"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteagedqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_site = data("Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version09\3-output\2022-08-11_DQI.docx", append
putdocx clear

save "`datapath'\version09\2-working\2018_cancer_dqi_siteage.dta" ,replace
label data "BNR-Cancer 2018 Data Quality Index - Site,Age"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore
** Missing sex %
** Missing age %


**********
** 2017 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear

****************************************************************************** 2017 ****************************************************************************************

drop if dxyr!=2017 //4907 deleted
count //977

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //0 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     female |        450       46.06       46.06
       male |        527       53.94      100.00
------------+-----------------------------------
      Total |        977      100.00
*/

** Note: O&U, NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64 //976 when excluding NMSCs and non-malignant tumours
//for 2018 don't remove non-melanoma skin cancers as these are not SCC or any of the non-reportable morph categories for skin
tab siteiarc if siteiarc!=64 //977 - no in-situ
tab siteiarc ,m //977 - 65 O&U
tab siteiarc patient //959 + 18 MPs

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2017
** All sites excl. in-situ, O&U, non-reportable skin cancers
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if siteiarc>60 //| siteiarc==25 //65 deleted - for 2017 don't remove non-melanoma skin cancers as these are not SCC or any of the non-reportable morph categories for skin
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
siteiarc									count	percentage
Prostate (C61)								276		37.81
Breast (C50)								164		22.47
Colon (C18)									104		14.25
Corpus uteri (C54)							 39		 5.34
Rectum (C19-20)								 36		 4.93
Pancreas (C25)								 33		 4.52
Lung (incl. trachea and bronchus) (C33-34)	 22		 3.01
Stomach (C16)								 21		 2.88
Ovary (C56)									 18		 2.47
Bladder (C67)								 17		 2.33
*/
total count //730
restore

labelbook sex_lab
tab sex ,m


** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2017
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
preserve
drop if siteiarc>60 //| siteiarc==25 //41 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
gsort -top10
tab siteiarc top10 if top10!=0
tab siteiarc top10 if top10!=0 & sex==1 //female: 450
tab siteiarc top10 if top10!=0 & sex==2 //male: 527
contract siteiarc top10 sex if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
year	cancer_site									number	sex
2017	Stomach (C16)								  4		female
2017	Stomach (C16)								 17		male
2017	Colon (C18)									 51		female
2017	Colon (C18)									 53		male
2017	Rectum (C19-20)								 12		female
2017	Rectum (C19-20)								 24		male
2017	Pancreas (C25)								 16		female
2017	Pancreas (C25)								 17		male
2017	Lung (incl. trachea and bronchus) (C33-34)	 10		female
2017	Lung (incl. trachea and bronchus) (C33-34)	 12		male
2017	Breast (C50)								161		female
2017	Breast (C50)								  3		male
2017	Corpus uteri (C54)							 39		female
2017	Ovary (C56)									 18		female
2017	Prostate (C61)								276		male
2017	Bladder (C67)								  8		female
2017	Bladder (C67)								  9		male
*/
total count //730
drop percentage
gen year=2017
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'\version09\2-working\2017_top10_sex" ,replace
restore


labelbook sex_lab
tab sex ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==2 //527 deleted
drop if siteiarc>60 //32 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/450)*100 //all cancers excl. male(527)
gen alltotpercent=(count/977)*100 //all cancers
/*
siteiarc			count	percentage	totpercent	alltotpercent
Breast (C50)		161		56.49		33.26446	16.77083
Colon (C18)			 51		17.89		10.53719	 5.3125
Corpus uteri (C54)	 39		13.68		 8.057851	 4.0625
Ovary (C56)			 18		 6.32		 3.719008	 1.875
Pancreas (C25)		 16		 5.61		 3.305785	 1.666667
*/
total count //285
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 5 code added by JC for 2017
** MALE - using IARC's site groupings
preserve
drop if sex==1 //450 deleted
drop if siteiarc>60 //| siteiarc==25 //33 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/527)*100 //all cancers excl. female(450)
gen alltotpercent=(count/977)*100 //all cancers
/*
siteiarc		count	percentage	totpercent	alltotpercent
Prostate (C61)	276		71.32		57.98319	28.75
Colon (C18)		 53		13.70		11.13445	 5.520833
Rectum (C19-20)	 24		 6.20		 5.042017	 2.5
Stomach (C16)	 17		 4.39		 3.571429	 1.770833
Pancreas (C25)	 17		 4.39		 3.571429	 1.770833
*/
total count //387
restore


** Determine sequential order of 2017 sites from 2018 top 10
tab siteiarc ,m

preserve
drop if siteiarc>60 //| siteiarc==25 //65 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5                              Rectum (C19-20) |
     |-------------------------------------------------------|
  6. |        6                               Pancreas (C25) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8                                Stomach (C16) |
  9. |        9                                  Ovary (C56) |
 10. |       10                                Bladder (C67) |
     |-------------------------------------------------------|
 11. |       11                       Multiple myeloma (C90) |
 12. |       12            Non-Hodgkin lymphoma (C82-86,C96) |
 13. |       13                                Thyroid (C73) |
 14. |       14                                 Kidney (C64) |
 15. |       15                           Cervix uteri (C53) |
     |-------------------------------------------------------|
 16. |       16                    Gallbladder etc. (C23-24) |
 17. |       17                             Oesophagus (C15) |
 18. |       18               Brain, nervous system (C70-72) |
 19. |       19                       Hodgkin lymphoma (C81) |
 20. |       20                                 Larynx (C32) |
     |-------------------------------------------------------|
 21. |       21                                  Liver (C22) |
 22. |       22                   Myeloid leukaemia (C92-94) |
 23. |       23                                   Anus (C21) |
 24. |       24                     Uterus unspecified (C55) |
 25. |       25                        Small intestine (C17) |
     |-------------------------------------------------------|
 26. |       26                     Lymphoid leukaemia (C91) |
 27. |       27           Myeloproliferative disorders (MPD) |
 28. |       28                  Leukaemia unspecified (C95) |
 29. |       29                       Melanoma of skin (C43) |
 30. |       30         Connective and soft tissue (C47+C49) |
     |-------------------------------------------------------|
 31. |       31                                  Penis (C60) |
 32. |       32                    Pharynx unspecified (C14) |
 33. |       33                                 Vagina (C52) |
 34. |       34                              Tongue (C01-02) |
 35. |       35                      Salivary gland (C07-08) |
     |-------------------------------------------------------|
 36. |       36                         Hypopharynx (C12-13) |
 37. |       37                           Renal pelvis (C65) |
 38. |       38                               Mouth (C03-06) |
 39. |       39                                 Testis (C62) |
 40. |       40                  Nose, sinuses etc. (C30-31) |
     |-------------------------------------------------------|
 41. |       41           Immunoproliferative diseases (C88) |
 42. |       42                            Nasopharynx (C11) |
 43. |       43                                Bone (C40-41) |
 44. |       44                                 Tonsil (C09) |
 45. |       45                           Mesothelioma (C45) |
     |-------------------------------------------------------|
 46. |       46              Myelodysplastic syndromes (MDS) |
 47. |       47                         Kaposi sarcoma (C46) |
 48. |       48                             Other skin (C44) |
     +-------------------------------------------------------+
*/
drop if order_id>20 //28 deleted
save "`datapath'\version09\2-working\siteorder_2017" ,replace
restore


*****************************
**   Data Quality Indices  **
*****************************
** Added on 04-June-2019 by JC as requested by NS for 2014 cancer annual report

*****************************
** Identifying & Reporting **
** 	 Data Quality Index	   **
** MV,DCO,O+U,UnkAge,CLIN  **
*****************************

tab basis ,m
tab siteicd10 basis ,m 
tab sex ,m //0 missing
tab age ,m //0 missing=999
tab sex age if age==.|age==999 //0 - used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sex if sitecr5db==20 //site=O&U; used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)


tab basis ,m
gen boddqi=1 if basis>4 & basis <9 //726 changes; 
replace boddqi=2 if basis==0 //79 changes
replace boddqi=3 if basis>0 & basis<5 //154 changes
replace boddqi=4 if basis==9 //18 changes
label define boddqi_lab 1 "MV" 2 "DCO"  3 "CLIN" 4 "UNK.BASIS" , modify
label var boddqi "basis DQI"
label values boddqi boddqi_lab

gen siteagedqi=1 if siteiarc==61 //65 changes
replace siteagedqi=2 if age==.|age==999 //0 changes
replace siteagedqi=3 if dob==. & siteagedqi!=2 //1 change
replace siteagedqi=4 if siteiarc==61 & siteagedqi!=1 //0 changes
replace siteagedqi=5 if sex==.|sex==99 //0 changes
label define siteagedqi_lab 1 "O&U SITE" 2 "UNK.AGE" 3 "UNK.DOB" 4 "O&U+UNK.AGE/DOB" 5 "UNK.SEX", modify
label var siteagedqi "site/age DQI"
label values siteagedqi siteagedqi_lab

tab boddqi ,m
generate rectot=_N //977
tab boddqi rectot,m

tab siteagedqi ,m
tab siteagedqi rectot,m


** Create variables for table by basis (DCO% + MV%) in Data Quality section of annual report
** This was done manually in excel for 2014 annual report so the above code has now been updated to be automated in Stata
tab sitecr5db boddqi if boddqi!=. & sitecr5db!=. & sitecr5db<23 & sitecr5db!=2 & sitecr5db!=5 & sitecr5db!=7 & sitecr5db!=9 & sitecr5db!=13 & sitecr5db!=15 & sitecr5db!=16 & sitecr5db!=17 & sitecr5db!=18 & sitecr5db!=19 & sitecr5db!=20
/*
                      |                  basis DQI
          CR5db sites |        MV        DCO       CLIN  UNK.BASIS |     Total
----------------------+--------------------------------------------+----------
Mouth & pharynx (C00- |        12          0          0          0 |        12 
        Stomach (C16) |        13          4          4          0 |        21 
Colon, rectum, anus ( |       111         14         19          1 |       145 
       Pancreas (C25) |        12          5         16          0 |        33 
Lung, trachea, bronch |        14          4          4          0 |        22 
         Breast (C50) |       159          3          2          0 |       164 
         Cervix (C53) |        11          1          0          0 |        12 
Corpus & Uterus NOS ( |        40          1          3          0 |        44 
       Prostate (C61) |       208         16         43          9 |       276 
Lymphoma (C81-85,88,9 |        29          3          8          0 |        40 
   Leukaemia (C91-95) |         9          2          0          1 |        12 
----------------------+--------------------------------------------+----------
                Total |       618         53         99         11 |       781
*/

** All BOD options
preserve
drop if boddqi==. | sitecr5db==. | sitecr5db>22 | sitecr5db==20 | sitecr5db==2 | sitecr5db==5 | sitecr5db==7 | sitecr5db==9 | sitecr5db==13 | (sitecr5db>14 & sitecr5db<21) //260 deleted
contract sitecr5db boddqi, freq(count) percent(percentage)
input
40	1	618	0
40	2	 53	0
40	3	 99 0
40	4	 11 0
end

label define sitecr5db_lab ///
1 "Mouth & pharynx" ///
2 "Oesophagus" ///
3 "Stomach" ///
4 "Colon, rectum, anus" ///
5 "Liver" ///
6 "Pancreas" ///
7 "Larynx" ///
8 "Lung, trachea, bronchus" ///
9 "Melanoma of skin" ///
10 "Breast" ///
11 "Cervix" ///
12 "Corpus & Uterus NOS" ///
13 "Ovary & adnexa" ///
14 "Prostate" ///
15 "Testis" ///
16 "Kidney & urinary NOS" ///
17 "Bladder" ///
18 "Brain, nervous system" ///
19 "Thyroid" ///
20 "O&U" ///
21 "Lymphoma" ///
22 "Leukaemia" ///
23 "Other digestive" ///
24 "Nose, sinuses" ///
25 "Bone, cartilage, etc" ///
26 "Other skin" ///
27 "Other female organs" ///
28 "Other male organs" ///
29 "Other endocrine" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc" ///
40 "All sites (in this table)" , modify
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab
drop percentage
gen percentage=(count/12)*100 if sitecr5db==1 & boddqi==1
replace percentage=(count/12)*100 if sitecr5db==1 & boddqi==2
replace percentage=(count/12)*100 if sitecr5db==1 & boddqi==3
replace percentage=(count/12)*100 if sitecr5db==1 & boddqi==4
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==1
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==2
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==3
replace percentage=(count/21)*100 if sitecr5db==3 & boddqi==4
replace percentage=(count/145)*100 if sitecr5db==4 & boddqi==1
replace percentage=(count/145)*100 if sitecr5db==4 & boddqi==2
replace percentage=(count/145)*100 if sitecr5db==4 & boddqi==3
replace percentage=(count/145)*100 if sitecr5db==4 & boddqi==4
replace percentage=(count/33)*100 if sitecr5db==6 & boddqi==1
replace percentage=(count/33)*100 if sitecr5db==6 & boddqi==2
replace percentage=(count/33)*100 if sitecr5db==6 & boddqi==3
replace percentage=(count/33)*100 if sitecr5db==6 & boddqi==4
replace percentage=(count/22)*100 if sitecr5db==8 & boddqi==1
replace percentage=(count/22)*100 if sitecr5db==8 & boddqi==2
replace percentage=(count/22)*100 if sitecr5db==8 & boddqi==3
replace percentage=(count/22)*100 if sitecr5db==8 & boddqi==4
replace percentage=(count/164)*100 if sitecr5db==10 & boddqi==1
replace percentage=(count/164)*100 if sitecr5db==10 & boddqi==2
replace percentage=(count/164)*100 if sitecr5db==10 & boddqi==3
replace percentage=(count/164)*100 if sitecr5db==10 & boddqi==4
replace percentage=(count/12)*100 if sitecr5db==11 & boddqi==1
replace percentage=(count/12)*100 if sitecr5db==11 & boddqi==2
replace percentage=(count/12)*100 if sitecr5db==11 & boddqi==3
replace percentage=(count/12)*100 if sitecr5db==11 & boddqi==4
replace percentage=(count/44)*100 if sitecr5db==12 & boddqi==1
replace percentage=(count/44)*100 if sitecr5db==12 & boddqi==2
replace percentage=(count/44)*100 if sitecr5db==12 & boddqi==3
replace percentage=(count/44)*100 if sitecr5db==12 & boddqi==4
replace percentage=(count/276)*100 if sitecr5db==14 & boddqi==1
replace percentage=(count/276)*100 if sitecr5db==14 & boddqi==2
replace percentage=(count/276)*100 if sitecr5db==14 & boddqi==3
replace percentage=(count/276)*100 if sitecr5db==14 & boddqi==4
replace percentage=(count/40)*100 if sitecr5db==21 & boddqi==1
replace percentage=(count/40)*100 if sitecr5db==21 & boddqi==2
replace percentage=(count/40)*100 if sitecr5db==21 & boddqi==3
replace percentage=(count/40)*100 if sitecr5db==21 & boddqi==4
replace percentage=(count/12)*100 if sitecr5db==22 & boddqi==1
replace percentage=(count/12)*100 if sitecr5db==22 & boddqi==2
replace percentage=(count/12)*100 if sitecr5db==22 & boddqi==3
replace percentage=(count/12)*100 if sitecr5db==22 & boddqi==4
replace percentage=(count/781)*100 if sitecr5db==40 & boddqi==1
replace percentage=(count/781)*100 if sitecr5db==40 & boddqi==2
replace percentage=(count/781)*100 if sitecr5db==40 & boddqi==3
replace percentage=(count/781)*100 if sitecr5db==40 & boddqi==4
format percentage %04.1f

gen icd10dqi="C00-14" if sitecr5db==1
replace icd10dqi="C16" if sitecr5db==3
replace icd10dqi="C18-21" if sitecr5db==4
replace icd10dqi="C25" if sitecr5db==6
replace icd10dqi="C33-34" if sitecr5db==8
replace icd10dqi="C50" if sitecr5db==10
replace icd10dqi="C53" if sitecr5db==11
replace icd10dqi="C54-55" if sitecr5db==12
replace icd10dqi="C61" if sitecr5db==14
replace icd10dqi="C81-85,88,90,96" if sitecr5db==21
replace icd10dqi="C91-95" if sitecr5db==22
replace icd10dqi="All" if sitecr5db==40

putdocx clear
putdocx begin

putdocx paragraph, style(Heading1)
putdocx text ("Basis - MV%, DCO%, CLIN%, UNK%: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=977): 2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename sitecr5db Cancer_Site
rename boddqi Total_DQI
rename count Cases
rename percentage Pct_DQI
rename icd10dqi ICD10
putdocx table tbl_bod = data("Cancer_Site Total_DQI Cases Pct_DQI ICD10"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version09\3-output\2022-08-11_DQI.docx", append
putdocx clear

save "`datapath'\version09\2-working\2017_cancer_dqi_basis.dta" ,replace
label data "BNR-Cancer 2017 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore


preserve
** % tumours - site,age
tab siteagedqi
contract siteagedqi, freq(count) percent(percentage)

putdocx clear
putdocx begin

// Create a paragraph
putdocx paragraph, style(Heading1)
putdocx text ("Unknown - Site, DOB & Age: 2017"), bold
putdocx paragraph, halign(center)
putdocx text ("Site,DOB,Age (# tumours/n=977): 2017"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteagedqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_site = data("Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version09\3-output\2022-08-11_DQI.docx", append
putdocx clear

save "`datapath'\version09\2-working\2017_cancer_dqi_siteage.dta" ,replace
label data "BNR-Cancer 2017 Data Quality Index - Site,Age"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore
** Missing sex %
** Missing age %


**********
** 2016 **
**********
** Load the dataset
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear

****************************************************************************** 2016 ****************************************************************************************

drop if dxyr!=2016 //4797 deleted
count //1070

***********************
** 3.1 CANCERS BY SITE
***********************
tab icd10 if beh<3 ,m //0 in-situ

tab icd10 ,m //0 missing

tab siteiarc ,m //0 missing

tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     female |        491       45.89       45.89
       male |        579       54.11      100.00
------------+-----------------------------------
      Total |      1,070      100.00
*/

** Note: O&U, NMSCs (non-reportable skin cancers) and in-situ tumours excluded from top ten analysis
tab siteiarc if siteiarc!=25 & siteiarc!=64 //1068 when excluding NMSCs and non-malignant tumours
//for 2018 don't remove non-melanoma skin cancers as these are not SCC or any of the non-reportable morph categories for skin
tab siteiarc if siteiarc!=64 //1070 - no in-situ
tab siteiarc ,m //1070 - 49 O&U
tab siteiarc patient //1034 + 36 MPs

** NS decided on 18march2019 to use IARC site groupings so variable siteiarc will be used instead of sitear
** IARC site variable created based on CI5-XI incidence classifications (see chapter 3 Table 3.1. of that volume) based on icd10
display `"{browse "http://ci5.iarc.fr/CI5-XI/Pages/Chapter3.aspx":IARC-CI5-XI-3}"'


** For annual report - Section 1: Incidence - Table 2a
** Below top 10 code added by JC for 2016
** All sites excl. in-situ, O&U, non-reportable skin cancers
** THIS USED IN ANNUAL REPORT TABLE 1
preserve
drop if siteiarc>60 //| siteiarc==25 //49 deleted - for 2016 don't remove non-melanoma skin cancers as these are not SCC or any of the non-reportable morph categories for skin
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
tab siteiarc top10 if top10!=0
contract siteiarc top10 if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
siteiarc									count	percentage
Prostate (C61)								287		35.88
Breast (C50)								150		18.75
Colon (C18)									112		14.00
Corpus uteri (C54)							 48		 6.00
Lung (incl. trachea and bronchus) (C33-34)	 42		 5.25
Rectum (C19-20)								 42		 5.25
Multiple myeloma (C90)						 35		 4.38
Stomach (C16)								 30		 3.75
Pancreas (C25)								 29		 3.63
Cervix uteri (C53)							 25		 3.13
*/
total count //800
restore

labelbook sex_lab
tab sex ,m


** For annual report - unsure which section of report to be used in
** Below top 10 code added by JC for 2016
** All sites excl. in-situ, O&U, non-reportable skin cancers
** Requested by SF on 16-Oct-2020: Numbers of top 10 by sex
preserve
drop if siteiarc>60 //| siteiarc==25 //41 deleted
tab siteiarc ,m
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag=(_n==1)
replace tag = sum(tag)
sum tag , meanonly
gen top10 = (tag>=(`r(max)'-9))
sum n if tag==(`r(max)'-9), meanonly
replace top10 = 1 if n==`r(max)'
gsort -top10
tab siteiarc top10 if top10!=0
tab siteiarc top10 if top10!=0 & sex==1 //female: 491
tab siteiarc top10 if top10!=0 & sex==2 //male: 579
contract siteiarc top10 sex if top10!=0, freq(count) percent(percentage)
summ
describe
gsort -count
drop top10
/*
year	cancer_site									number	sex
2016	Stomach (C16)								 13		female
2016	Stomach (C16)								 17		male
2016	Colon (C18)									 60		female
2016	Colon (C18)									 52		male
2016	Rectum (C19-20)								 20		female
2016	Rectum (C19-20)								 22		male
2016	Pancreas (C25)								 15		female
2016	Pancreas (C25)								 14		male
2016	Lung (incl. trachea and bronchus) (C33-34)	 11		female
2016	Lung (incl. trachea and bronchus) (C33-34)	 31		male
2016	Breast (C50)								149		female
2016	Breast (C50)								  1		male
2016	Cervix uteri (C53)							 25		female
2016	Corpus uteri (C54)							 48		female
2016	Prostate (C61)								287		male
2016	Multiple myeloma (C90)						 18		female
2016	Multiple myeloma (C90)						 17		male
*/
total count //800
drop percentage
gen year=2016
rename count number
rename siteiarc cancer_site
sort cancer_site sex
order year cancer_site number
save "`datapath'\version09\2-working\2016_top10_sex" ,replace
restore


labelbook sex_lab
tab sex ,m

** For annual report - Section 1: Incidence - Table 1
** FEMALE - using IARC's site groupings (excl. in-situ)
preserve
drop if sex==2 //579 deleted
drop if siteiarc>60 //27 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/491)*100 //all cancers excl. male(579)
gen alltotpercent=(count/1070)*100 //all cancers
/*
siteiarc			count	percentage	totpercent	alltotpercent
Breast (C50)		149		49.17		33.11111	15.25077
Colon (C18)			 60		19.80		13.33333	 6.141249
Corpus uteri (C54)	 48		15.84		10.66667	 4.912999
Cervix uteri (C53)	 25		 8.25		 5.555555	 2.558854
Ovary (C56)			 21		 6.93		 4.666667	 2.149437
*/
total count //303
restore

** For annual report - Section 1: Incidence - Table 1
** Below top 5 code added by JC for 2016
** MALE - using IARC's site groupings
preserve
drop if sex==1 //491 deleted
drop if siteiarc>60 //| siteiarc==25 //22 deleted
bysort siteiarc: gen n=_N
bysort n siteiarc: gen tag5=(_n==1)
replace tag5 = sum(tag5)
sum tag5 , meanonly
gen top5 = (tag5>=(`r(max)'-4))
sum n if tag5==(`r(max)'-4), meanonly
replace top5 = 1 if n==`r(max)'
gsort -top5
tab siteiarc top5 if top5!=0
contract siteiarc top5 if top5!=0, freq(count) percent(percentage)
gsort -count
drop top5

gen totpercent=(count/579)*100 //all cancers excl. female(491)
gen alltotpercent=(count/1070)*100 //all cancers
/*
siteiarc									count	percentage	totpercent	alltotpercent
Prostate (C61)								287		67.37		54.4592		29.37564
Colon (C18)									 52		12.21		 9.867172	 5.322415
Lung (incl. trachea and bronchus) (C33-34)	 31		 7.28		 5.882353	 3.172978
Rectum (C19-20)								 22		 5.16		 4.174573	 2.251791
Multiple myeloma (C90)						 17		 3.99		 3.225806	 1.740021
Stomach (C16)								 17		 3.99		 3.225806	 1.740021
*/
total count //426
restore


** Determine sequential order of 2016 sites from 2018 top 10
tab siteiarc ,m

preserve
drop if siteiarc>60 //| siteiarc==25 //49 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5                              Rectum (C19-20) |
     |-------------------------------------------------------|
  6. |        6   Lung (incl. trachea and bronchus) (C33-34) |
  7. |        7                       Multiple myeloma (C90) |
  8. |        8                                Stomach (C16) |
  9. |        9                               Pancreas (C25) |
 10. |       10                           Cervix uteri (C53) |
     |-------------------------------------------------------|
 11. |       11                                 Kidney (C64) |
 12. |       12                                  Ovary (C56) |
 13. |       13            Non-Hodgkin lymphoma (C82-86,C96) |
 14. |       14                                  Liver (C22) |
 15. |       15                                Bladder (C67) |
     |-------------------------------------------------------|
 16. |       16                                Thyroid (C73) |
 17. |       17                                   Anus (C21) |
 18. |       18                                 Larynx (C32) |
 19. |       19                    Gallbladder etc. (C23-24) |
 20. |       20                             Oesophagus (C15) |
     |-------------------------------------------------------|
 21. |       21                     Lymphoid leukaemia (C91) |
 22. |       22                       Hodgkin lymphoma (C81) |
 23. |       23                        Small intestine (C17) |
 24. |       24                                 Tonsil (C09) |
 25. |       25                                Bone (C40-41) |
     |-------------------------------------------------------|
 26. |       26           Myeloproliferative disorders (MPD) |
 27. |       27                       Melanoma of skin (C43) |
 28. |       28                              Tongue (C01-02) |
 29. |       29                            Nasopharynx (C11) |
 30. |       30                     Uterus unspecified (C55) |
     |-------------------------------------------------------|
 31. |       31                  Leukaemia unspecified (C95) |
 32. |       32                               Mouth (C03-06) |
 33. |       33                       Other oropharynx (C10) |
 34. |       34               Brain, nervous system (C70-72) |
 35. |       35                   Myeloid leukaemia (C92-94) |
     |-------------------------------------------------------|
 36. |       36                                 Vagina (C52) |
 37. |       37         Connective and soft tissue (C47+C49) |
 38. |       38                             Other skin (C44) |
 39. |       39                                    Lip (C00) |
 40. |       40                         Hypopharynx (C12-13) |
     |-------------------------------------------------------|
 41. |       41               Other thoracic organs (C37-38) |
 42. |       42                                  Penis (C60) |
 43. |       43              Other male genital organs (C63) |
 44. |       44                  Nose, sinuses etc. (C30-31) |
 45. |       45                   Other urinary organs (C68) |
     |-------------------------------------------------------|
 46. |       46                         Kaposi sarcoma (C46) |
 47. |       47                                 Testis (C62) |
     +-------------------------------------------------------+
*/
drop if order_id>20 //27 deleted
save "`datapath'\version09\2-working\siteorder_2016" ,replace
restore


*****************************
**   Data Quality Indices  **
*****************************
** Added on 04-June-2019 by JC as requested by NS for 2014 cancer annual report

*****************************
** Identifying & Reporting **
** 	 Data Quality Index	   **
** MV,DCO,O+U,UnkAge,CLIN  **
*****************************

tab basis ,m
tab siteicd10 basis ,m 
tab sex ,m //0 missing
tab age ,m //0 missing=999
tab sex age if age==.|age==999 //0 - used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)
tab sex if sitecr5db==20 //site=O&U; used this table in annual report (see excel 2014 data quality indicators in BNR OneDrive)


tab basis ,m
gen boddqi=1 if basis>4 & basis <9 //765 changes; 
replace boddqi=2 if basis==0 //82 changes
replace boddqi=3 if basis>0 & basis<5 //187 changes
replace boddqi=4 if basis==9 //36 changes
label define boddqi_lab 1 "MV" 2 "DCO"  3 "CLIN" 4 "UNK.BASIS" , modify
label var boddqi "basis DQI"
label values boddqi boddqi_lab

gen siteagedqi=1 if siteiarc==61 //49 changes
replace siteagedqi=2 if age==.|age==999 //0 changes
replace siteagedqi=3 if dob==. & siteagedqi!=2 //6 changes
replace siteagedqi=4 if siteiarc==61 & siteagedqi!=1 //1 change
replace siteagedqi=5 if sex==.|sex==99 //0 changes
label define siteagedqi_lab 1 "O&U SITE" 2 "UNK.AGE" 3 "UNK.DOB" 4 "O&U+UNK.AGE/DOB" 5 "UNK.SEX", modify
label var siteagedqi "site/age DQI"
label values siteagedqi siteagedqi_lab

tab boddqi ,m
generate rectot=_N //1070
tab boddqi rectot,m

tab siteagedqi ,m
tab siteagedqi rectot,m


** Create variables for table by basis (DCO% + MV%) in Data Quality section of annual report
** This was done manually in excel for 2014 annual report so the above code has now been updated to be automated in Stata
tab sitecr5db boddqi if boddqi!=. & sitecr5db!=. & sitecr5db<23 & sitecr5db!=2 & sitecr5db!=5 & sitecr5db!=7 & sitecr5db!=9 & sitecr5db!=13 & sitecr5db!=15 & sitecr5db!=16 & sitecr5db!=17 & sitecr5db!=18 & sitecr5db!=19 & sitecr5db!=20
/*
                      |                  basis DQI
          CR5db sites |        MV        DCO       CLIN  UNK.BASIS |     Total
----------------------+--------------------------------------------+----------
Mouth & pharynx (C00- |        21          0          2          0 |        23 
        Stomach (C16) |        14          5          9          2 |        30 
Colon, rectum, anus ( |       133         13         15          3 |       164 
       Pancreas (C25) |        11          5         12          1 |        29 
Lung, trachea, bronch |        21          2         17          2 |        42 
         Breast (C50) |       140          5          3          2 |       150 
         Cervix (C53) |        23          0          1          1 |        25 
Corpus & Uterus NOS ( |        47          0          3          1 |        51 
       Prostate (C61) |       209         23         47          8 |       287 
Lymphoma (C81-85,88,9 |        32          3         20          5 |        60 
   Leukaemia (C91-95) |        11          0          2          1 |        14 
----------------------+--------------------------------------------+----------
                Total |       662         56        131         26 |       875

                      |                  basis DQI
          CR5db sites |        MV        DCO       CLIN  UNK.BASIS |     Total
----------------------+--------------------------------------------+----------
Mouth & pharynx (C00- |        12          0          0          0 |        12 
        Stomach (C16) |        13          4          4          0 |        21 
Colon, rectum, anus ( |       111         14         19          1 |       145 
       Pancreas (C25) |        12          5         16          0 |        33 
Lung, trachea, bronch |        14          4          4          0 |        22 
         Breast (C50) |       159          3          2          0 |       164 
         Cervix (C53) |        11          1          0          0 |        12 
Corpus & Uterus NOS ( |        40          1          3          0 |        44 
       Prostate (C61) |       208         16         43          9 |       276 
Lymphoma (C81-85,88,9 |        29          3          8          0 |        40 
   Leukaemia (C91-95) |         9          2          0          1 |        12 
----------------------+--------------------------------------------+----------
                Total |       618         53         99         11 |       781
*/

** All BOD options
preserve
drop if boddqi==. | sitecr5db==. | sitecr5db>22 | sitecr5db==20 | sitecr5db==2 | sitecr5db==5 | sitecr5db==7 | sitecr5db==9 | sitecr5db==13 | (sitecr5db>14 & sitecr5db<21) //260 deleted
contract sitecr5db boddqi, freq(count) percent(percentage)
input
40	1	662	0
40	2	 56	0
40	3	131 0
40	4	 26 0
end

label define sitecr5db_lab ///
1 "Mouth & pharynx" ///
2 "Oesophagus" ///
3 "Stomach" ///
4 "Colon, rectum, anus" ///
5 "Liver" ///
6 "Pancreas" ///
7 "Larynx" ///
8 "Lung, trachea, bronchus" ///
9 "Melanoma of skin" ///
10 "Breast" ///
11 "Cervix" ///
12 "Corpus & Uterus NOS" ///
13 "Ovary & adnexa" ///
14 "Prostate" ///
15 "Testis" ///
16 "Kidney & urinary NOS" ///
17 "Bladder" ///
18 "Brain, nervous system" ///
19 "Thyroid" ///
20 "O&U" ///
21 "Lymphoma" ///
22 "Leukaemia" ///
23 "Other digestive" ///
24 "Nose, sinuses" ///
25 "Bone, cartilage, etc" ///
26 "Other skin" ///
27 "Other female organs" ///
28 "Other male organs" ///
29 "Other endocrine" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc" ///
40 "All sites (in this table)" , modify
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab
drop percentage
gen percentage=(count/23)*100 if sitecr5db==1 & boddqi==1
replace percentage=(count/23)*100 if sitecr5db==1 & boddqi==2
replace percentage=(count/23)*100 if sitecr5db==1 & boddqi==3
replace percentage=(count/23)*100 if sitecr5db==1 & boddqi==4
replace percentage=(count/30)*100 if sitecr5db==3 & boddqi==1
replace percentage=(count/30)*100 if sitecr5db==3 & boddqi==2
replace percentage=(count/30)*100 if sitecr5db==3 & boddqi==3
replace percentage=(count/30)*100 if sitecr5db==3 & boddqi==4
replace percentage=(count/164)*100 if sitecr5db==4 & boddqi==1
replace percentage=(count/164)*100 if sitecr5db==4 & boddqi==2
replace percentage=(count/164)*100 if sitecr5db==4 & boddqi==3
replace percentage=(count/164)*100 if sitecr5db==4 & boddqi==4
replace percentage=(count/29)*100 if sitecr5db==6 & boddqi==1
replace percentage=(count/29)*100 if sitecr5db==6 & boddqi==2
replace percentage=(count/29)*100 if sitecr5db==6 & boddqi==3
replace percentage=(count/29)*100 if sitecr5db==6 & boddqi==4
replace percentage=(count/42)*100 if sitecr5db==8 & boddqi==1
replace percentage=(count/42)*100 if sitecr5db==8 & boddqi==2
replace percentage=(count/42)*100 if sitecr5db==8 & boddqi==3
replace percentage=(count/42)*100 if sitecr5db==8 & boddqi==4
replace percentage=(count/150)*100 if sitecr5db==10 & boddqi==1
replace percentage=(count/150)*100 if sitecr5db==10 & boddqi==2
replace percentage=(count/150)*100 if sitecr5db==10 & boddqi==3
replace percentage=(count/150)*100 if sitecr5db==10 & boddqi==4
replace percentage=(count/25)*100 if sitecr5db==11 & boddqi==1
replace percentage=(count/25)*100 if sitecr5db==11 & boddqi==2
replace percentage=(count/25)*100 if sitecr5db==11 & boddqi==3
replace percentage=(count/25)*100 if sitecr5db==11 & boddqi==4
replace percentage=(count/51)*100 if sitecr5db==12 & boddqi==1
replace percentage=(count/51)*100 if sitecr5db==12 & boddqi==2
replace percentage=(count/51)*100 if sitecr5db==12 & boddqi==3
replace percentage=(count/51)*100 if sitecr5db==12 & boddqi==4
replace percentage=(count/287)*100 if sitecr5db==14 & boddqi==1
replace percentage=(count/287)*100 if sitecr5db==14 & boddqi==2
replace percentage=(count/287)*100 if sitecr5db==14 & boddqi==3
replace percentage=(count/287)*100 if sitecr5db==14 & boddqi==4
replace percentage=(count/60)*100 if sitecr5db==21 & boddqi==1
replace percentage=(count/60)*100 if sitecr5db==21 & boddqi==2
replace percentage=(count/60)*100 if sitecr5db==21 & boddqi==3
replace percentage=(count/60)*100 if sitecr5db==21 & boddqi==4
replace percentage=(count/14)*100 if sitecr5db==22 & boddqi==1
replace percentage=(count/14)*100 if sitecr5db==22 & boddqi==2
replace percentage=(count/14)*100 if sitecr5db==22 & boddqi==3
replace percentage=(count/14)*100 if sitecr5db==22 & boddqi==4
replace percentage=(count/875)*100 if sitecr5db==40 & boddqi==1
replace percentage=(count/875)*100 if sitecr5db==40 & boddqi==2
replace percentage=(count/875)*100 if sitecr5db==40 & boddqi==3
replace percentage=(count/875)*100 if sitecr5db==40 & boddqi==4
format percentage %04.1f

gen icd10dqi="C00-14" if sitecr5db==1
replace icd10dqi="C16" if sitecr5db==3
replace icd10dqi="C18-21" if sitecr5db==4
replace icd10dqi="C25" if sitecr5db==6
replace icd10dqi="C33-34" if sitecr5db==8
replace icd10dqi="C50" if sitecr5db==10
replace icd10dqi="C53" if sitecr5db==11
replace icd10dqi="C54-55" if sitecr5db==12
replace icd10dqi="C61" if sitecr5db==14
replace icd10dqi="C81-85,88,90,96" if sitecr5db==21
replace icd10dqi="C91-95" if sitecr5db==22
replace icd10dqi="All" if sitecr5db==40

putdocx clear
putdocx begin

putdocx paragraph, style(Title)
putdocx text ("CANCER 2016-2018 Annual Report: DQI"), bold
putdocx textblock begin
Date Prepared: 18-AUG-2022. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofiles: 20a_clean current years cancer.do and 25b_analysis sites.do
putdocx textblock end
putdocx paragraph, style(Heading1)
putdocx text ("Basis - MV%, DCO%, CLIN%, UNK%: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=1070): 2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename sitecr5db Cancer_Site
rename boddqi Total_DQI
rename count Cases
rename percentage Pct_DQI
rename icd10dqi ICD10
putdocx table tbl_bod = data("Cancer_Site Total_DQI Cases Pct_DQI ICD10"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_bod(1,.), bold

putdocx save "`datapath'\version09\3-output\2022-08-11_DQI.docx", append
putdocx clear

save "`datapath'\version09\2-working\2016_cancer_dqi_basis.dta" ,replace
label data "BNR-Cancer 2016 Data Quality Index - Basis"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore


preserve
** % tumours - site,age
tab siteagedqi
contract siteagedqi, freq(count) percent(percentage)

putdocx clear
putdocx begin

putdocx paragraph, style(Heading1)
putdocx text ("Unknown - Site, DOB & Age: 2016"), bold
putdocx paragraph, halign(center)
putdocx text ("Site,DOB,Age (# tumours/n=1070): 2016"), bold font(Helvetica,14,"blue")
putdocx paragraph
rename siteagedqi Total_DQI
rename count Total_Records
rename percentage Pct_DQI
putdocx table tbl_site = data("Total_DQI Total_Records Pct_DQI"), varnames  ///
        border(start, nil) border(insideV, nil) border(end, nil)
putdocx table tbl_site(1,.), bold

putdocx save "`datapath'\version09\3-output\2022-08-11_DQI.docx", append
putdocx clear

save "`datapath'\version09\2-working\2016_cancer_dqi_siteage.dta" ,replace
label data "BNR-Cancer 2016 Data Quality Index - Site,Age"
notes _dta :These data prepared for Natasha Sobers - 2016-2018 annual report
restore
** Missing sex %
** Missing age %


** Determine sequential order of 2013-2015 sites from 2018 top 10
** Load the dataset
use "`datapath'\version09\2-working\2013-2018_cancer_numbers", clear

**********
** 2015 **
**********
preserve
drop if dxyr!=2015 //4775 deleted
count //1092

** Determine sequential order of 2015 sites from 2018 top 10
tab siteiarc ,m


drop if siteiarc>60 //| siteiarc==25 //40 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                              Rectum (C19-20) |
  5. |        5                           Corpus uteri (C54) |
     |-------------------------------------------------------|
  6. |        6                                Stomach (C16) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8                       Multiple myeloma (C90) |
  9. |        9                               Pancreas (C25) |
 10. |       10            Non-Hodgkin lymphoma (C82-86,C96) |
     |-------------------------------------------------------|
 11. |       11                                  Ovary (C56) |
 12. |       12                                 Kidney (C64) |
 13. |       13                           Cervix uteri (C53) |
 14. |       14                                Bladder (C67) |
 15. |       15               Brain, nervous system (C70-72) |
     |-------------------------------------------------------|
 16. |       16                                Thyroid (C73) |
 17. |       17                             Oesophagus (C15) |
 18. |       18                    Gallbladder etc. (C23-24) |
 19. |       19                     Uterus unspecified (C55) |
 20. |       20                        Small intestine (C17) |
     |-------------------------------------------------------|
 21. |       21                     Lymphoid leukaemia (C91) |
 22. |       22                       Melanoma of skin (C43) |
 23. |       23                                  Liver (C22) |
 24. |       24                                 Larynx (C32) |
 25. |       25                                   Anus (C21) |
     |-------------------------------------------------------|
 26. |       26                              Tongue (C01-02) |
 27. |       27         Connective and soft tissue (C47+C49) |
 28. |       28                   Myeloid leukaemia (C92-94) |
 29. |       29                       Hodgkin lymphoma (C81) |
 30. |       30           Myeloproliferative disorders (MPD) |
     |-------------------------------------------------------|
 31. |       31              Myelodysplastic syndromes (MDS) |
 32. |       32                                 Vagina (C52) |
 33. |       33                               Mouth (C03-06) |
 34. |       34                            Nasopharynx (C11) |
 35. |       35                                 Tonsil (C09) |
     |-------------------------------------------------------|
 36. |       36                  Leukaemia unspecified (C95) |
 37. |       37                       Other oropharynx (C10) |
 38. |       38                  Nose, sinuses etc. (C30-31) |
 39. |       39                                    Eye (C69) |
 40. |       40                      Salivary gland (C07-08) |
     |-------------------------------------------------------|
 41. |       41            Other female genital organs (C57) |
 42. |       42                                 Testis (C62) |
 43. |       43                                  Vulva (C51) |
 44. |       44                                Bone (C40-41) |
 45. |       45                                 Ureter (C66) |
     |-------------------------------------------------------|
 46. |       46                   Other urinary organs (C68) |
 47. |       47                                  Penis (C60) |
 48. |       48               Other thoracic organs (C37-38) |
 49. |       49                    Pharynx unspecified (C14) |
 50. |       50                             Other skin (C44) |
     +-------------------------------------------------------+
*/
drop if order_id>20 //30 deleted
save "`datapath'\version09\2-working\siteorder_2015" ,replace
restore


**********
** 2014 **
**********
preserve
drop if dxyr!=2014 //4983 deleted
count //884

** Determine sequential order of 2014 sites from 2018 top 10
tab siteiarc ,m


drop if siteiarc>60 //| siteiarc==25 //39 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                           Corpus uteri (C54) |
  5. |        5   Lung (incl. trachea and bronchus) (C33-34) |
     |-------------------------------------------------------|
  6. |        6                       Multiple myeloma (C90) |
  7. |        7                                Bladder (C67) |
  8. |        8                              Rectum (C19-20) |
  9. |        9                               Pancreas (C25) |
 10. |       10                                Stomach (C16) |
     |-------------------------------------------------------|
 11. |       11                           Cervix uteri (C53) |
 12. |       12            Non-Hodgkin lymphoma (C82-86,C96) |
 13. |       13                                  Liver (C22) |
 14. |       14                                Thyroid (C73) |
 15. |       15                                  Ovary (C56) |
     |-------------------------------------------------------|
 16. |       16                                 Kidney (C64) |
 17. |       17                    Gallbladder etc. (C23-24) |
 18. |       18                             Oesophagus (C15) |
 19. |       19                       Melanoma of skin (C43) |
 20. |       20                                 Larynx (C32) |
     |-------------------------------------------------------|
 21. |       21         Connective and soft tissue (C47+C49) |
 22. |       22                     Lymphoid leukaemia (C91) |
 23. |       23               Brain, nervous system (C70-72) |
 24. |       24                   Myeloid leukaemia (C92-94) |
 25. |       25                                 Tonsil (C09) |
     |-------------------------------------------------------|
 26. |       26                  Nose, sinuses etc. (C30-31) |
 27. |       27                        Small intestine (C17) |
 28. |       28                         Hypopharynx (C12-13) |
 29. |       29                              Tongue (C01-02) |
 30. |       30                       Other oropharynx (C10) |
     |-------------------------------------------------------|
 31. |       31                                  Penis (C60) |
 32. |       32                  Leukaemia unspecified (C95) |
 33. |       33                                Bone (C40-41) |
 34. |       34           Myeloproliferative disorders (MPD) |
 35. |       35                            Nasopharynx (C11) |
     |-------------------------------------------------------|
 36. |       36                       Hodgkin lymphoma (C81) |
 37. |       37                                   Anus (C21) |
 38. |       38                               Mouth (C03-06) |
 39. |       39                                  Vulva (C51) |
 40. |       40                           Mesothelioma (C45) |
     |-------------------------------------------------------|
 41. |       41                                 Testis (C62) |
 42. |       42                                 Vagina (C52) |
 43. |       43                                    Eye (C69) |
 44. |       44                      Salivary gland (C07-08) |
 45. |       45                   Other urinary organs (C68) |
     |-------------------------------------------------------|
 46. |       46                        Other endocrine (C75) |
 47. |       47           Immunoproliferative diseases (C88) |
 48. |       48              Myelodysplastic syndromes (MDS) |
     +-------------------------------------------------------+
*/
drop if order_id>20 //28 deleted
save "`datapath'\version09\2-working\siteorder_2014" ,replace
restore


**********
** 2013 **
**********
preserve
drop if dxyr!=2013 //4983 deleted
count //884

** Determine sequential order of 2013 sites from 2018 top 10
tab siteiarc ,m


drop if siteiarc>60 //| siteiarc==25 //40 deleted
contract siteiarc, freq(count) percent(percentage)
summ 
describe
gsort -count
gen order_id=_n
list order_id siteiarc
/*
     +-------------------------------------------------------+
     | order_id                                     siteiarc |
     |-------------------------------------------------------|
  1. |        1                               Prostate (C61) |
  2. |        2                                 Breast (C50) |
  3. |        3                                  Colon (C18) |
  4. |        4                              Rectum (C19-20) |
  5. |        5                           Cervix uteri (C53) |
     |-------------------------------------------------------|
  6. |        6                           Corpus uteri (C54) |
  7. |        7   Lung (incl. trachea and bronchus) (C33-34) |
  8. |        8            Non-Hodgkin lymphoma (C82-86,C96) |
  9. |        9                               Pancreas (C25) |
 10. |       10                                 Kidney (C64) |
     |-------------------------------------------------------|
 11. |       11                                Stomach (C16) |
 12. |       12                       Multiple myeloma (C90) |
 13. |       13                                Thyroid (C73) |
 14. |       14                   Myeloid leukaemia (C92-94) |
 15. |       15                                Bladder (C67) |
     |-------------------------------------------------------|
 16. |       16                                  Ovary (C56) |
 17. |       17                    Gallbladder etc. (C23-24) |
 18. |       18                                   Anus (C21) |
 19. |       19                     Lymphoid leukaemia (C91) |
 20. |       20                             Oesophagus (C15) |
     |-------------------------------------------------------|
 21. |       21                                  Liver (C22) |
 22. |       22                       Hodgkin lymphoma (C81) |
 23. |       23                     Uterus unspecified (C55) |
 24. |       24                               Mouth (C03-06) |
 25. |       25           Myeloproliferative disorders (MPD) |
     |-------------------------------------------------------|
 26. |       26         Connective and soft tissue (C47+C49) |
 27. |       27                              Tongue (C01-02) |
 28. |       28               Brain, nervous system (C70-72) |
 29. |       29                                 Larynx (C32) |
 30. |       30                                 Vagina (C52) |
     |-------------------------------------------------------|
 31. |       31                       Melanoma of skin (C43) |
 32. |       32                        Small intestine (C17) |
 33. |       33                       Other oropharynx (C10) |
 34. |       34            Other female genital organs (C57) |
 35. |       35                  Nose, sinuses etc. (C30-31) |
     |-------------------------------------------------------|
 36. |       36                                  Penis (C60) |
 37. |       37                  Leukaemia unspecified (C95) |
 38. |       38                            Nasopharynx (C11) |
 39. |       39                    Pharynx unspecified (C14) |
 40. |       40                      Salivary gland (C07-08) |
     |-------------------------------------------------------|
 41. |       41               Other thoracic organs (C37-38) |
 42. |       42                         Hypopharynx (C12-13) |
 43. |       43                                Bone (C40-41) |
 44. |       44                                 Tonsil (C09) |
 45. |       45                                  Vulva (C51) |
     |-------------------------------------------------------|
 46. |       46                           Mesothelioma (C45) |
     +-------------------------------------------------------+
*/
drop if order_id>20 //26 deleted
save "`datapath'\version09\2-working\siteorder_2013" ,replace
restore
