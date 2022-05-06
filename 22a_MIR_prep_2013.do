** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          65_MIR_prep_2013.do
	//  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      06-OCT-2021
    // 	date last modified      06-OCT-2021
    //  algorithm task          Creating IARC site variable on 2013 mortality dataset in preparation for mortality:incidence ratio analysis
    //  status                  Completed
    //  objective               To have cause(s) of death assigned the same site codes as the incidence data
	//							To have multiple cancer causes of death identified and labelled with the correct site code
    //  methods                 Using Angie's previous site variable to transcribe into the IARC site variable

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
    log using "`logpath'\65_MIR_prep_2013.smcl", replace
** HEADER -----------------------------------------------------


* ************************************************************************
* PREP AND FORMAT: MORTALITY DATA
**************************************************************************
use "`datapath'\version02\1-input\2013_cancer_for_MR_only", clear

** Create IARC site variable and assign using Angie's previous variable called 'site'
gen siteiarc=.
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
59 "Myeloproliferative disorders (MPD)" 60 "Myselodysplastic syndromes (MDS)" ///
61 "Other and unspecified (O&U)" ///
62 "All sites(ALL)" 63 "All sites but skin (ALLbC44)" ///
64 "D069: CIN 3"
label var siteiarc "IARC CI5-XI sites"
label values siteiarc siteiarc_lab

order deathid causeofdeath site
** Check cases in Stata's Browse/Edit window using site variable then perform changes below
replace siteiarc=2 if deathid==5330

replace siteiarc=3 if deathid==5272

replace siteiarc=4 if deathid==4856|deathid==5034|deathid==6979

replace siteiarc=5 if deathid==6033

replace siteiarc=9 if deathid==5648|deathid==6596|deathid==7266

replace siteiarc=10 if deathid==5533|deathid==6217|deathid==6868

replace siteiarc=11 if site==2|deathid==5260|deathid==5687|deathid==5749|deathid==5773|deathid==5811 ///
					   |deathid==5817|deathid==5872|deathid==5965|deathid==6083|deathid==6108 ///
					   |deathid==6239|deathid==6240|deathid==6266

replace siteiarc=12 if deathid==5415|deathid==6084|deathid==6854

replace siteiarc=13 if site==3

replace siteiarc=14 if site==4

replace siteiarc=14 if deathid==4953|deathid==5106|deathid==5301|deathid==5475|deathid==5783|deathid==5888 ///
					   |deathid==5983|deathid==6001|deathid==6188|deathid==6368|deathid==6580|deathid==6630 ///
					   |deathid==6870|deathid==6941|deathid==7113|deathid==7202|deathid==7293
					   
replace siteiarc=15 if deathid==6196

replace siteiarc=16 if deathid==4890|deathid==4900|deathid==4938|deathid==5359|deathid==5411|deathid==5580 ///
					   |deathid==5667|deathid==5728|deathid==5861|deathid==6088|deathid==6144|deathid==6179 ///
					   |deathid==6467|deathid==6717|deathid==6984|deathid==6986

replace siteiarc=17 if deathid==5719|deathid==5765|deathid==6057|deathid==7215

replace siteiarc=18 if site==6

replace siteiarc=19 if deathid==6660

replace siteiarc=20 if deathid==5379|deathid==5826|deathid==6425|deathid==6474

replace siteiarc=21 if site==8 & siteiarc==.

replace siteiarc=24 if site==11

replace siteiarc=25 if site==12

replace siteiarc=28 if deathid==4942

replace siteiarc=29 if site==14

replace siteiarc=30 if deathid==4971|deathid==6602

replace siteiarc=31 if deathid==5235

replace siteiarc=32 if site==15

replace siteiarc=33 if deathid==5281|deathid==5358|deathid==5892|deathid==5926|deathid==6500|deathid==6521 ///
					   |deathid==6641|deathid==6654|deathid==7155|deathid==7303|deathid==5838

replace siteiarc=34 if deathid==5960|deathid==6041|deathid==6089|deathid==7088

replace siteiarc=35 if deathid==4955|deathid==5945|deathid==6026|deathid==6295|deathid==6554|deathid==6900 ///
					   |deathid==6932|deathid==7271|deathid==8748

replace siteiarc=37 if deathid==6331
replace site=17 if deathid==6331

replace siteiarc=38 if deathid==5623

replace siteiarc=39 if site==19

replace siteiarc=42 if deathid==5852|deathid==5978|deathid==6110|deathid==6287|deathid==6298|deathid==6323 ///
					   |deathid==6656|deathid==7119

replace siteiarc=45 if deathid==6042|deathid==6273|deathid==6526|deathid==6575|deathid==7180

replace siteiarc=48 if deathid==5373|deathid==5732|deathid==6090|deathid==6433|deathid==6987

replace siteiarc=49 if deathid==5114|deathid==5576|deathid==6651|deathid==7066

replace siteiarc=51 if deathid==5262|deathid==5858|deathid==6597|deathid==7214

replace siteiarc=53 if deathid==5030|deathid==5155|deathid==5706|deathid==5737|deathid==5750|deathid==6024 ///
					   |deathid==6106|deathid==6161|deathid==6699|deathid==6726|deathid==6976|deathid==7038 ///
					   |deathid==7161|deathid==7268

replace siteiarc=55 if deathid==4969|deathid==5009|deathid==5069|deathid==5076|deathid==5520|deathid==5543 ///
					   |deathid==5804|deathid==5863|deathid==6094|deathid==6126|deathid==6271|deathid==6659 ///
					   |deathid==6872|deathid==6916|deathid==6967|deathid==7198

replace siteiarc=56 if deathid==5696|deathid==5884|deathid==6293|deathid==6686|deathid==7194|deathid==7276

replace siteiarc=57 if deathid==4905|deathid==5456|deathid==5873|deathid==5895|deathid==5947|deathid==6046 ///
					   |deathid==6260|deathid==6833|deathid==6884|deathid==6885|deathid==7104|deathid==7257 ///
					   |deathid==7312

replace siteiarc=58 if deathid==5024|deathid==5562|deathid==6152|deathid==6506|deathid==6725|deathid==6768

replace siteiarc=59 if deathid==4932|deathid==7223

replace siteiarc=61 if site==23|site==25|deathid==4977|deathid==6824|deathid==7423

** Assign siteiarc to the previously-identified duplicate observations with multiple cancer CODs
replace siteiarc=29 if deathid==5591 & dupobs==0
replace siteiarc=33 if deathid==5591 & dupobs==1

replace siteiarc=57 if deathid==6006 & dupobs==0
replace siteiarc=39 if deathid==6006 & dupobs==1

replace siteiarc=11 if deathid==6314 & dupobs==0
replace siteiarc=39 if deathid==6314 & dupobs==1

replace siteiarc=13 if deathid==6476 & dupobs==0
replace siteiarc=39 if deathid==6476 & dupobs==1

replace siteiarc=18 if deathid==6611 & dupobs==0
replace siteiarc=55 if deathid==6611 & dupobs==1

replace siteiarc=29 if deathid==6855 & dupobs==0
replace siteiarc=34 if deathid==6855 & dupobs==1

replace siteiarc=16 if deathid==6877 & dupobs==0
replace siteiarc=39 if deathid==6877 & dupobs==1

replace siteiarc=18 if deathid==7267 & dupobs==0
replace siteiarc=17 if deathid==7267 & dupobs==1

replace siteiarc=53 if deathid==7413 & dupobs==0
replace siteiarc=39 if deathid==7413 & dupobs==1

tab siteiarc ,m
count if siteiarc==. //0


** Create ICD-10 groups according to analysis tables in CR5 db (added according to IARC Hub's DQ Assessment Report groupings)
gen sitecr5db=.
label define sitecr5db_lab ///
1 "Mouth & pharynx (C00-14)" ///
2 "Oesophagus (C15)" ///
3 "Stomach (C16)" ///
4 "Colon, rectum, anus (C18-21)" ///
5 "Liver (C22)" ///
6 "Pancreas (C25)" ///
7 "Larynx (C32)" ///
8 "Lung, trachea, bronchus (C33-34)" ///
9 "Melanoma of skin (C43)" ///
10 "Breast (C50)" ///
11 "Cervix (C53)" ///
12 "Corpus & Uterus NOS (C54-55)" ///
13 "Ovary & adnexa (C56)" ///
14 "Prostate (C61)" ///
15 "Testis (C62)" ///
16 "Kidney & urinary NOS (C64-66,68)" ///
17 "Bladder (C67)" ///
18 "Brain, nervous system (C70-72)" ///
19 "Thyroid (C73)" ///
20 "O&U (C26,39,48,76,80)" ///
21 "Lymphoma (C81-85,88,90,96)" ///
22 "Leukaemia (C91-95)" ///
23 "Other digestive (C17,23-24)" ///
24 "Nose, sinuses (C30-31)" ///
25 "Bone, cartilage, etc (C40-41,45,47,49)" ///
26 "Other skin (C44)" ///
27 "Other female organs (C51-52,57-58)" ///
28 "Other male organs (C60,63)" ///
29 "Other endocrine (C74-75)" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc (C69,C38)" ///
34 "All sites but C44"
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab

replace sitecr5db=1 if siteiarc<10
replace sitecr5db=2 if siteiarc==10
replace sitecr5db=3 if siteiarc==11
replace sitecr5db=4 if siteiarc>12 & siteiarc<16
replace sitecr5db=5 if siteiarc==16
replace sitecr5db=6 if siteiarc==18
replace sitecr5db=7 if siteiarc==20
replace sitecr5db=8 if siteiarc==21
replace sitecr5db=9 if siteiarc==24
replace sitecr5db=10 if siteiarc==29
replace sitecr5db=11 if siteiarc==32
replace sitecr5db=12 if siteiarc==33|siteiarc==34
replace sitecr5db=13 if siteiarc==35
replace sitecr5db=14 if siteiarc==39
replace sitecr5db=15 if siteiarc==40
replace sitecr5db=16 if (siteiarc>41 & siteiarc<45) | siteiarc==46
replace sitecr5db=17 if siteiarc==45
replace sitecr5db=18 if siteiarc==48
replace sitecr5db=19 if siteiarc==49
replace sitecr5db=20 if siteiarc==61
replace sitecr5db=21 if siteiarc>51 & siteiarc<56
replace sitecr5db=22 if siteiarc>55 & siteiarc<59
replace sitecr5db=23 if siteiarc==12|siteiarc==17
replace sitecr5db=24 if siteiarc==19
replace sitecr5db=25 if siteiarc==23|siteiarc==26|siteiarc==28
replace sitecr5db=26 if siteiarc==25
replace sitecr5db=27 if siteiarc==30|siteiarc==31|siteiarc==36|siteiarc==37
replace sitecr5db=28 if siteiarc==38|siteiarc==41
replace sitecr5db=29 if siteiarc==50|siteiarc==51
replace sitecr5db=30 if siteiarc==59
replace sitecr5db=31 if siteiarc==60
replace sitecr5db=32 if siteiarc==64
replace sitecr5db=33 if siteiarc==47|siteiarc==22

tab sitecr5db ,m
count if sitecr5db==. //0

** Create death dataset with CODs assigned a site code
save "`datapath'\version02\2-working\2013_mir_mort_prep", replace

** Create variable for site groupings by sex to be used for M:I ratios
***********
** MALES **
***********
** Mouth & pharynx (C00-14)
count if sitecr5db==1 & sex==2
gen cases = r(N) if sitecr5db==1 & sex==2

** Oesophagus (C15)
count if sitecr5db==2 & sex==2
replace cases = r(N) if sitecr5db==2 & sex==2

** Stomach (C16)
count if sitecr5db==3 & sex==2
replace cases = r(N) if sitecr5db==3 & sex==2

** Colon, rectum, anus (C18-21)
count if sitecr5db==4 & sex==2
replace cases = r(N) if sitecr5db==4 & sex==2

** Liver (C22)
count if sitecr5db==5 & sex==2
replace cases = r(N) if sitecr5db==5 & sex==2

** Pancreas (C25)
count if sitecr5db==6 & sex==2
replace cases = r(N) if sitecr5db==6 & sex==2

** Larynx (C32)
count if sitecr5db==7 & sex==2
replace cases = r(N) if sitecr5db==7 & sex==2

** Lung, trachea, bronchus (C33-34)
count if sitecr5db==8 & sex==2
replace cases = r(N) if sitecr5db==8 & sex==2

** Melanoma of skin (C43)
count if sitecr5db==9 & sex==2
replace cases = r(N) if sitecr5db==9 & sex==2

** Prostate (C61)
count if sitecr5db==14 & sex==2
replace cases = r(N) if sitecr5db==14 & sex==2

** Testis (C62)
count if sitecr5db==15 & sex==2
replace cases = r(N) if sitecr5db==15 & sex==2

** Kidney & urinary NOS (C64-66,68)
count if sitecr5db==16 & sex==2
replace cases = r(N) if sitecr5db==16 & sex==2

** Bladder (C67)
count if sitecr5db==17 & sex==2
replace cases = r(N) if sitecr5db==17 & sex==2

** Brain, nervous system (C70-72)
count if sitecr5db==18 & sex==2
replace cases = r(N) if sitecr5db==18 & sex==2

** Thyroid (C73)
count if sitecr5db==19 & sex==2
replace cases = r(N) if sitecr5db==19 & sex==2

** Lymphoma (C81-85,88,90,96)
count if sitecr5db==21 & sex==2
replace cases = r(N) if sitecr5db==21 & sex==2

** Leukaemia (C91-95)
count if sitecr5db==22 & sex==2
replace cases = r(N) if sitecr5db==22 & sex==2

*************
** FEMALES **
*************
** Mouth & pharynx (C00-14)
count if sitecr5db==1 & sex==1
replace cases = r(N) if sitecr5db==1 & sex==1

** Oesophagus (C15)
count if sitecr5db==2 & sex==1
replace cases = r(N) if sitecr5db==2 & sex==1

** Stomach (C16)
count if sitecr5db==3 & sex==1
replace cases = r(N) if sitecr5db==3 & sex==1

** Colon, rectum, anus (C18-21)
count if sitecr5db==4 & sex==1
replace cases = r(N) if sitecr5db==4 & sex==1

** Liver (C22)
count if sitecr5db==5 & sex==1
replace cases = r(N) if sitecr5db==5 & sex==1

** Pancreas (C25)
count if sitecr5db==6 & sex==1
replace cases = r(N) if sitecr5db==6 & sex==1

** Larynx (C32)
count if sitecr5db==7 & sex==1
replace cases = r(N) if sitecr5db==7 & sex==1

** Lung, trachea, bronchus (C33-34)
count if sitecr5db==8 & sex==1
replace cases = r(N) if sitecr5db==8 & sex==1

** Melanoma of skin (C43)
count if sitecr5db==9 & sex==1
replace cases = r(N) if sitecr5db==9 & sex==1

** Breast (C50)
count if sitecr5db==10 & sex==1
replace cases = r(N) if sitecr5db==10 & sex==1

** Cervix (C53)
count if sitecr5db==11 & sex==1
replace cases = r(N) if sitecr5db==11 & sex==1

** Corpus & Uterus NOS (C54-55)
count if sitecr5db==12 & sex==1
replace cases = r(N) if sitecr5db==12 & sex==1

** Ovary & adnexa (C56)
count if sitecr5db==13 & sex==1
replace cases = r(N) if sitecr5db==13 & sex==1

** Kidney & urinary NOS (C64-66,68)
count if sitecr5db==16 & sex==1
replace cases = r(N) if sitecr5db==16 & sex==1

** Bladder (C67)
count if sitecr5db==17 & sex==1
replace cases = r(N) if sitecr5db==17 & sex==1

** Brain, nervous system (C70-72)
count if sitecr5db==18 & sex==1
replace cases = r(N) if sitecr5db==18 & sex==1

** Thyroid (C73)
count if sitecr5db==19 & sex==1
replace cases = r(N) if sitecr5db==19 & sex==1

** Lymphoma (C81-85,88,90,96)
count if sitecr5db==21 & sex==1
replace cases = r(N) if sitecr5db==21 & sex==1

** Leukaemia (C91-95)
count if sitecr5db==22 & sex==1
replace cases = r(N) if sitecr5db==22 & sex==1


** Condense dataset
drop if cases==.
sort sitecr5db sex
contract year sitecr5db sex cases
drop _freq
order year sitecr5db sex cases

gen mort=1

** Create death dataset to use for mortality:incidence ratio
save "`datapath'\version02\2-working\2013_mir_mort", replace

clear

* ************************************************************************
* PREP AND FORMAT: INCIDENCE DATA
**************************************************************************
use "`datapath'\version02\3-output\2008_2013_2014_2015_iarchub_nonsurvival_reportable", clear

drop if dxyr!=2013
count if sitecr5db==. //815
drop sitecr5db
label drop sitecr5db_lab

** Create ICD-10 groups according to analysis tables in CR5 db (added according to IARC Hub's DQ Assessment Report groupings)
gen sitecr5db=.
label define sitecr5db_lab ///
1 "Mouth & pharynx (C00-14)" ///
2 "Oesophagus (C15)" ///
3 "Stomach (C16)" ///
4 "Colon, rectum, anus (C18-21)" ///
5 "Liver (C22)" ///
6 "Pancreas (C25)" ///
7 "Larynx (C32)" ///
8 "Lung, trachea, bronchus (C33-34)" ///
9 "Melanoma of skin (C43)" ///
10 "Breast (C50)" ///
11 "Cervix (C53)" ///
12 "Corpus & Uterus NOS (C54-55)" ///
13 "Ovary & adnexa (C56)" ///
14 "Prostate (C61)" ///
15 "Testis (C62)" ///
16 "Kidney & urinary NOS (C64-66,68)" ///
17 "Bladder (C67)" ///
18 "Brain, nervous system (C70-72)" ///
19 "Thyroid (C73)" ///
20 "O&U (C26,39,48,76,80)" ///
21 "Lymphoma (C81-85,88,90,96)" ///
22 "Leukaemia (C91-95)" ///
23 "Other digestive (C17,23-24)" ///
24 "Nose, sinuses (C30-31)" ///
25 "Bone, cartilage, etc (C40-41,45,47,49)" ///
26 "Other skin (C44)" ///
27 "Other female organs (C51-52,57-58)" ///
28 "Other male organs (C60,63)" ///
29 "Other endocrine (C74-75)" ///
30 "Myeloproliferative disorders (MPD)" ///
31 "Myelodysplastic syndromes (MDS)" ///
32 "D069: CIN 3" ///
33 "Eye,Heart,etc (C69,C38)" ///
34 "All sites but C44"
label var sitecr5db "CR5db sites"
label values sitecr5db sitecr5db_lab

replace sitecr5db=1 if siteiarc<10
replace sitecr5db=2 if siteiarc==10
replace sitecr5db=3 if siteiarc==11
replace sitecr5db=4 if siteiarc>12 & siteiarc<16
replace sitecr5db=5 if siteiarc==16
replace sitecr5db=6 if siteiarc==18
replace sitecr5db=7 if siteiarc==20
replace sitecr5db=8 if siteiarc==21
replace sitecr5db=9 if siteiarc==24
replace sitecr5db=10 if siteiarc==29
replace sitecr5db=11 if siteiarc==32
replace sitecr5db=12 if siteiarc==33|siteiarc==34
replace sitecr5db=13 if siteiarc==35
replace sitecr5db=14 if siteiarc==39
replace sitecr5db=15 if siteiarc==40
replace sitecr5db=16 if (siteiarc>41 & siteiarc<45) | siteiarc==46
replace sitecr5db=17 if siteiarc==45
replace sitecr5db=18 if siteiarc==48
replace sitecr5db=19 if siteiarc==49
replace sitecr5db=20 if siteiarc==61
replace sitecr5db=21 if siteiarc>51 & siteiarc<56
replace sitecr5db=22 if siteiarc>55 & siteiarc<59
replace sitecr5db=23 if siteiarc==12|siteiarc==17
replace sitecr5db=24 if siteiarc==19
replace sitecr5db=25 if siteiarc==23|siteiarc==26|siteiarc==28
replace sitecr5db=26 if siteiarc==25
replace sitecr5db=27 if siteiarc==30|siteiarc==31|siteiarc==36|siteiarc==37
replace sitecr5db=28 if siteiarc==38|siteiarc==41
replace sitecr5db=29 if siteiarc==50|siteiarc==51
replace sitecr5db=30 if siteiarc==59
replace sitecr5db=31 if siteiarc==60
replace sitecr5db=32 if siteiarc==64
replace sitecr5db=33 if siteiarc==47|siteiarc==22

tab sitecr5db ,m
count if sitecr5db==. //0

** Create death dataset with CODs assigned a site code
save "`datapath'\version02\2-working\2013_mir_incid_prep", replace

** Create variable for site groupings by sex to be used for M:I ratios
***********
** MALES **
***********
** Mouth & pharynx (C00-14)
count if sitecr5db==1 & sex==2
gen cases = r(N) if sitecr5db==1 & sex==2

** Oesophagus (C15)
count if sitecr5db==2 & sex==2
replace cases = r(N) if sitecr5db==2 & sex==2

** Stomach (C16)
count if sitecr5db==3 & sex==2
replace cases = r(N) if sitecr5db==3 & sex==2

** Colon, rectum, anus (C18-21)
count if sitecr5db==4 & sex==2
replace cases = r(N) if sitecr5db==4 & sex==2

** Liver (C22)
count if sitecr5db==5 & sex==2
replace cases = r(N) if sitecr5db==5 & sex==2

** Pancreas (C25)
count if sitecr5db==6 & sex==2
replace cases = r(N) if sitecr5db==6 & sex==2

** Larynx (C32)
count if sitecr5db==7 & sex==2
replace cases = r(N) if sitecr5db==7 & sex==2

** Lung, trachea, bronchus (C33-34)
count if sitecr5db==8 & sex==2
replace cases = r(N) if sitecr5db==8 & sex==2

** Melanoma of skin (C43)
count if sitecr5db==9 & sex==2
replace cases = r(N) if sitecr5db==9 & sex==2

** Prostate (C61)
count if sitecr5db==14 & sex==2
replace cases = r(N) if sitecr5db==14 & sex==2

** Testis (C62)
count if sitecr5db==15 & sex==2
replace cases = r(N) if sitecr5db==15 & sex==2

** Kidney & urinary NOS (C64-66,68)
count if sitecr5db==16 & sex==2
replace cases = r(N) if sitecr5db==16 & sex==2

** Bladder (C67)
count if sitecr5db==17 & sex==2
replace cases = r(N) if sitecr5db==17 & sex==2

** Brain, nervous system (C70-72)
count if sitecr5db==18 & sex==2
replace cases = r(N) if sitecr5db==18 & sex==2

** Thyroid (C73)
count if sitecr5db==19 & sex==2
replace cases = r(N) if sitecr5db==19 & sex==2

** Lymphoma (C81-85,88,90,96)
count if sitecr5db==21 & sex==2
replace cases = r(N) if sitecr5db==21 & sex==2

** Leukaemia (C91-95)
count if sitecr5db==22 & sex==2
replace cases = r(N) if sitecr5db==22 & sex==2

*************
** FEMALES **
*************
** Mouth & pharynx (C00-14)
count if sitecr5db==1 & sex==1
replace cases = r(N) if sitecr5db==1 & sex==1

** Oesophagus (C15)
count if sitecr5db==2 & sex==1
replace cases = r(N) if sitecr5db==2 & sex==1

** Stomach (C16)
count if sitecr5db==3 & sex==1
replace cases = r(N) if sitecr5db==3 & sex==1

** Colon, rectum, anus (C18-21)
count if sitecr5db==4 & sex==1
replace cases = r(N) if sitecr5db==4 & sex==1

** Liver (C22)
count if sitecr5db==5 & sex==1
replace cases = r(N) if sitecr5db==5 & sex==1

** Pancreas (C25)
count if sitecr5db==6 & sex==1
replace cases = r(N) if sitecr5db==6 & sex==1

** Larynx (C32)
count if sitecr5db==7 & sex==1
replace cases = r(N) if sitecr5db==7 & sex==1

** Lung, trachea, bronchus (C33-34)
count if sitecr5db==8 & sex==1
replace cases = r(N) if sitecr5db==8 & sex==1

** Melanoma of skin (C43)
count if sitecr5db==9 & sex==1
replace cases = r(N) if sitecr5db==9 & sex==1

** Breast (C50)
count if sitecr5db==10 & sex==1
replace cases = r(N) if sitecr5db==10 & sex==1

** Cervix (C53)
count if sitecr5db==11 & sex==1
replace cases = r(N) if sitecr5db==11 & sex==1

** Corpus & Uterus NOS (C54-55)
count if sitecr5db==12 & sex==1
replace cases = r(N) if sitecr5db==12 & sex==1

** Ovary & adnexa (C56)
count if sitecr5db==13 & sex==1
replace cases = r(N) if sitecr5db==13 & sex==1

** Kidney & urinary NOS (C64-66,68)
count if sitecr5db==16 & sex==1
replace cases = r(N) if sitecr5db==16 & sex==1

** Bladder (C67)
count if sitecr5db==17 & sex==1
replace cases = r(N) if sitecr5db==17 & sex==1

** Brain, nervous system (C70-72)
count if sitecr5db==18 & sex==1
replace cases = r(N) if sitecr5db==18 & sex==1

** Thyroid (C73)
count if sitecr5db==19 & sex==1
replace cases = r(N) if sitecr5db==19 & sex==1

** Lymphoma (C81-85,88,90,96)
count if sitecr5db==21 & sex==1
replace cases = r(N) if sitecr5db==21 & sex==1

** Leukaemia (C91-95)
count if sitecr5db==22 & sex==1
replace cases = r(N) if sitecr5db==22 & sex==1


** Condense dataset
drop if cases==.
sort sitecr5db sex
contract dxyr sitecr5db sex cases
drop _freq
order dxyr sitecr5db sex cases

gen incid=1

** Create death dataset to use for mortality:incidence ratio
save "`datapath'\version02\2-working\2013_mir_incid", replace
