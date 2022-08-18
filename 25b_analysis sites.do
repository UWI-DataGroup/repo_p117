
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
    log using "`logpath'/25_analysis cancer.smcl", replace
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
** Below top 10 code added by JC for 2015
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
** Below top 10 code added by JC for 2015
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
** Below top 5 code added by JC for 2015
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

                      |                  basis DQI
          CR5db sites |        MV        DCO       CLIN  UNK.BASIS |     Total
----------------------+--------------------------------------------+----------
Mouth & pharynx (C00- |        23          0          0          0 |        23 
        Stomach (C16) |        23          7          6          0 |        36 
Colon, rectum, anus ( |       143         12          9          2 |       166 
       Pancreas (C25) |         7          7         11          1 |        26 
Lung, trachea, bronch |        13          6         11          0 |        30 
         Breast (C50) |       179         11          5          3 |       198 
         Cervix (C53) |        14          2          0          0 |        16 
Corpus & Uterus NOS ( |        43          2          6          0 |        51 
       Prostate (C61) |       169         25         16          6 |       216 
Lymphoma (C81-85,88,9 |        44          6          5          5 |        60 
   Leukaemia (C91-95) |        11          2          1          2 |        16 
----------------------+--------------------------------------------+----------
                Total |       669         80         70         19 |       838
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

// Create a paragraph
//putdocx pagebreak
putdocx paragraph, style(Title)
putdocx text ("CANCER 2016-2018 Annual Report: DQI"), bold
putdocx textblock begin
Date Prepared: 18-AUG-2022. 
Prepared by: JC using Stata & Redcap data release date: 21-May-2021. 
Generated using Dofiles: 20a_clean current years cancer.do and 25b_analysis sites.do
putdocx textblock end
putdocx paragraph, style(Heading1)
putdocx text ("Basis - MV%, DCO%, CLIN%, UNK%: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Basis (# tumours/n=960)"), bold font(Helvetica,14,"blue")
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
putdocx paragraph, style(Heading1)
putdocx text ("Unknown - Site, DOB & Age: 2018"), bold
putdocx paragraph, halign(center)
putdocx text ("Site,DOB,Age (# tumours/n=960)"), bold font(Helvetica,14,"blue")
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

STOP
PERFORM 2017 + 2016 FULL SITES, SITE ORDER & DQI ALSO!
PERFORM 2013-2015 SITE ORDER ONLY!