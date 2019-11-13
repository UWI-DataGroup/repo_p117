** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5_prep cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      28-OCT-2019
    // 	date last modified      28-OCT-2019
    //  algorithm task          Preparing 2015 cancer dataset for cleaning; Preparing previous years for combined dataset
    //  status                  Completed
    //  objective                To have one dataset with cleaned and grouped 2008 & 2013 data for inclusion in 2014 cancer report.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

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
    log using "`logpath'\5_prep cancer.smcl", replace
** HEADER -----------------------------------------------------

*******************************
** 2014 Non-survival Dataset **
*******************************
/*
JC 04nov2019: 2014 dataset prepared BEFORE 2013 dataset;
Records changed from 2014 to 2013 can be added to 2013_cancer_nonsurvival.dta
and removed from 2014_cancer_nonsurvival.dta
*/
** Load the dataset (2014)
use "`datapath'\version02\1-input\2014_cancer_sites_da", replace
count //927

** Remove non-reportable skin cancers
drop if siteiarc==25 //0 deleted

** Remove non-malignant and non-insitu tumours
drop if beh!=2 & beh!=3 //0 deleted

** Updates to DCOs after checked by KWG 12jun2019 (see excel sheet: ...\Sync\Cancer\CanReg5\DCOs).
replace basis=2 if pid=="20130175"
replace dcostatus=1 if pid=="20130175"

replace basis=9 if pid=="20140027"
replace dcostatus=1 if pid=="20140027"
replace dot=d(08jan2013) if pid=="20140027"
replace dotyear=2013 if pid=="20140027"
replace dxyr=2013 if pid=="20140027"

replace basis=9 if pid=="20140032"
replace dcostatus=1 if pid=="20140032"
replace nsdate=d(11jul2019) if pid=="20140032"
replace dot=d(17jan2013) if pid=="20140032"
replace dotyear=2013 if pid=="20140032"
replace dxyr=2013 if pid=="20140032"

replace basis=9 if pid=="20140033"
replace dcostatus=1 if pid=="20140033"
replace dot=d(28nov2013) if pid=="20140033"
replace dotyear=2013 if pid=="20140033"
replace dxyr=2013 if pid=="20140033"

replace basis=9 if pid=="20140042"
replace basis=6 if pid=="20140042"
replace dcostatus=3 if pid=="20140042"
replace dot=d(03may2012) if pid=="20140042"
replace dotyear=2012 if pid=="20140042"
replace dxyr=2012 if pid=="20140042"
replace nsdate=d(09jul2019) if pid=="20140042"
replace cstatus=3 if pid=="20140042"
replace recstatus=3 if pid=="20140042"

replace resident=2 if pid=="20140049"
replace cstatus=3 if pid=="20140049"
replace recstatus=3 if pid=="20140049"
replace dcostatus=3 if pid=="20140049"

replace basis=9 if pid=="20140078"
replace dcostatus=1 if pid=="20140078"
replace dot=d(18dec2013) if pid=="20140078"
replace dotyear=2013 if pid=="20140078"
replace dxyr=2013 if pid=="20140078"

replace basis=9 if pid=="20140100"
replace dcostatus=1 if pid=="20140100"
replace dot=d(01dec2013) if pid=="20140100"
replace dotyear=2013 if pid=="20140100"
replace dxyr=2013 if pid=="20140100"

replace basis=9 if pid=="20140110"
replace dcostatus=1 if pid=="20140110"
replace dot=d(24feb2013) if pid=="20140110"
replace dotyear=2013 if pid=="20140110"
replace dxyr=2013 if pid=="20140110"

replace basis=9 if pid=="20140117"
replace dot=d(30jun2010) if pid=="20140117"
replace dotyear=2010 if pid=="20140117"
replace dxyr=2010 if pid=="20140117"
replace nsdate=d(05jul2019) if pid=="20140117"
replace cstatus=3 if pid=="20140117"
replace recstatus=3 if pid=="20140117"
replace dcostatus=3 if pid=="20140117"

replace basis=9 if pid=="20140127"
replace dcostatus=1 if pid=="20140127"
replace dot=d(20oct2013) if pid=="20140127"
replace dotyear=2013 if pid=="20140127"
replace dxyr=2013 if pid=="20140127"

replace basis=9 if pid=="20140136"
replace dcostatus=1 if pid=="20140136"
replace dot=d(27mar2013) if pid=="20140136"
replace dotyear=2013 if pid=="20140136"
replace dxyr=2013 if pid=="20140136"

replace basis=9 if pid=="20140154"
replace dcostatus=1 if pid=="20140154"
replace dot=d(15dec2013) if pid=="20140154"
replace dotyear=2013 if pid=="20140154"
replace dxyr=2013 if pid=="20140154"

replace basis=9 if pid=="20140168"
replace dot=d(09feb2012) if pid=="20140168"
replace dotyear=2012 if pid=="20140168"
replace dxyr=2012 if pid=="20140168"
replace nsdate=d(10jul2019) if pid=="20140168"
replace cstatus=3 if pid=="20140168"
replace recstatus=3 if pid=="20140168"
replace dcostatus=3 if pid=="20140168"

replace basis=9 if pid=="20140174"
replace dot=d(30jun2012) if pid=="20140174"
replace dotyear=2012 if pid=="20140174"
replace dxyr=2012 if pid=="20140174"
replace nsdate=d(04jul2019) if pid=="20140174"
replace cstatus=3 if pid=="20140174"
replace recstatus=3 if pid=="20140174"
replace dcostatus=3 if pid=="20140174"

replace basis=9 if pid=="20140192"
replace dcostatus=1 if pid=="20140192"
replace dot=d(14oct2013) if pid=="20140192"
replace dotyear=2013 if pid=="20140192"
replace dxyr=2013 if pid=="20140192"

replace basis=9 if pid=="20140202"
replace dcostatus=1 if pid=="20140202"
replace dot=d(26oct2013) if pid=="20140202"
replace dotyear=2013 if pid=="20140202"
replace dxyr=2013 if pid=="20140202"

replace basis=9 if pid=="20140203"
replace dot=d(26nov2010) if pid=="20140203"
replace dotyear=2010 if pid=="20140203"
replace dxyr=2010 if pid=="20140203"
replace nsdate=d(03jul2019) if pid=="20140203"
replace cstatus=3 if pid=="20140203"
replace recstatus=3 if pid=="20140203"
replace dcostatus=3 if pid=="20140203"

replace basis=9 if pid=="20140205"
replace dcostatus=1 if pid=="20140205"
replace dot=d(30mar2014) if pid=="20140205"
replace nsdate=d(05jul2019) if pid=="20140205"

replace basis=9 if pid=="20140215"
replace dot=d(30jun2007) if pid=="20140215"
replace dotyear=2007 if pid=="20140215"
replace dxyr=2007 if pid=="20140215"
replace nsdate=d(04jul2019) if pid=="20140215"
replace cstatus=3 if pid=="20140215"
replace recstatus=3 if pid=="20140215"
replace dcostatus=3 if pid=="20140215"

replace basis=9 if pid=="20140224"
replace dcostatus=1 if pid=="20140224"
replace dot=d(22oct2013) if pid=="20140224"
replace dotyear=2013 if pid=="20140224"
replace dxyr=2013 if pid=="20140224"

replace basis=9 if pid=="20140228"
replace dcostatus=1 if pid=="20140228"
replace dot=d(18feb2014) if pid=="20140228"
replace admdate=d(18feb2014) if pid=="20140228"
replace nsdate=d(05jul2019) if pid=="20140228"

replace basis=9 if pid=="20140234"
replace dcostatus=1 if pid=="20140234"
replace dot=d(26nov2013) if pid=="20140234"
replace dotyear=2013 if pid=="20140234"
replace dxyr=2013 if pid=="20140234"

replace basis=9 if pid=="20140256"
replace dcostatus=1 if pid=="20140256"
replace dot=d(15mar2014) if pid=="20140256"
replace nsdate=d(04jul2019) if pid=="20140256"

replace basis=1 if pid=="20140257"
replace dcostatus=1 if pid=="20140257"
replace dot=d(29mar2014) if pid=="20140257"
replace nsdate=d(29aug2018) if pid=="20140257"

replace basis=9 if pid=="20140258"
replace dcostatus=1 if pid=="20140258"
replace dot=d(30nov2013) if pid=="20140258"
replace dotyear=2013 if pid=="20140258"
replace dxyr=2013 if pid=="20140258"

replace basis=9 if pid=="20140265"
replace dot=d(14dec1988) if pid=="20140265"
replace dotyear=1988 if pid=="20140265"
replace dxyr=1988 if pid=="20140265"
replace nsdate=d(03jul2019) if pid=="20140265"
replace cstatus=3 if pid=="20140265"
replace recstatus=3 if pid=="20140265"
replace dcostatus=3 if pid=="20140265"

replace basis=9 if pid=="20140268"
replace dcostatus=1 if pid=="20140268"
replace dot=d(26may2013) if pid=="20140268"
replace dotyear=2013 if pid=="20140268"
replace dxyr=2013 if pid=="20140268"

replace basis=9 if pid=="20140269"
replace dcostatus=1 if pid=="20140269"
replace dot=d(21feb2014) if pid=="20140269"

replace basis=9 if pid=="20140270"
replace dcostatus=1 if pid=="20140270"
replace dot=d(29mar2014) if pid=="20140270"

replace basis=9 if pid=="20140283"
replace dcostatus=1 if pid=="20140283"
replace dot=d(10dec2013) if pid=="20140283"
replace dotyear=2013 if pid=="20140283"
replace dxyr=2013 if pid=="20140283"

replace basis=9 if pid=="20140311"
replace dot=d(30jun2009) if pid=="20140311"
replace dotyear=2009 if pid=="20140311"
replace dxyr=2009 if pid=="20140311"
replace nsdate=d(04jul2019) if pid=="20140311"
replace cstatus=3 if pid=="20140311"
replace recstatus=3 if pid=="20140311"
replace dcostatus=3 if pid=="20140311"

replace basis=9 if pid=="20140318"
replace dcostatus=1 if pid=="20140318"
replace dot=d(15may2014) if pid=="20140318"

replace basis=9 if pid=="20140330"
replace dcostatus=1 if pid=="20140330"
replace dot=d(28jun2014) if pid=="20140330"
replace nsdate=d(02jul2019) if pid=="20140330"

replace basis=9 if pid=="20140334"
replace dot=d(30jun2004) if pid=="20140334"
replace dotyear=2004 if pid=="20140334"
replace dxyr=2004 if pid=="20140334"
replace nsdate=d(04jul2019) if pid=="20140334"
replace cstatus=3 if pid=="20140334"
replace recstatus=3 if pid=="20140334"
replace dcostatus=3 if pid=="20140334"

replace basis=1 if pid=="20140353"
replace dcostatus=1 if pid=="20140353"
replace dot=d(11jun2008) if pid=="20140353"
replace dotyear=2008 if pid=="20140353"
replace dxyr=2008 if pid=="20140353"
replace age=96 if pid=="20140353"
replace nsdate=d(02jul2019) if pid=="20140353"

replace basis=9 if pid=="20140365"
replace dcostatus=1 if pid=="20140365"
replace dot=d(07may2014) if pid=="20140365"
replace nsdate=d(05jul2019) if pid=="20140365"

replace basis=9 if pid=="20140367"
replace dcostatus=1 if pid=="20140367"
replace dot=d(14feb2014) if pid=="20140367"

replace basis=9 if pid=="20140370"
replace dcostatus=1 if pid=="20140370"
replace dot=d(21may2014) if pid=="20140370"

replace basis=2 if pid=="20140380"
replace dcostatus=1 if pid=="20140380"
replace dot=d(15apr2013) if pid=="20140380"
replace dotyear=2013 if pid=="20140380"
replace dxyr=2013 if pid=="20140380"
replace nsdate=d(09jul2019) if pid=="20140380"

replace basis=9 if pid=="20140384"
replace dcostatus=1 if pid=="20140384"
replace dot=d(01jan2014) if pid=="20140384"
replace nsdate=d(04jul2019) if pid=="20140384"

replace basis=9 if pid=="20140385"
replace dcostatus=1 if pid=="20140385"
replace dot=d(19jul2014) if pid=="20140385"

replace primarysite="UTERUS" if pid=="20140389"
replace top="559" if pid=="20140389"
replace topography=559 if pid=="20140389"
replace morph=8890 if pid=="20140389"
replace site=16 if pid=="20140389"
replace siteiarc=34 if pid=="20140389"
replace sitecr5db=12 if pid=="20140389"
replace sitear=16 if pid=="20140389"
replace icd10="C55" if pid=="20140389"
replace siteicd10=9 if pid=="20140389"
replace basis=7 if pid=="20140389"
replace dcostatus=1 if pid=="20140389"
replace dot=d(26jun2013) if pid=="20140389"
replace dotyear=2013 if pid=="20140389"
replace dxyr=2013 if pid=="20140389"
replace nsdate=d(10jul2019) if pid=="20140389"
replace rx1=1 if pid=="20140389"
replace rx1d=d(26jun2013) if pid=="20140389"
replace topcat=48 if pid=="20140389"
replace morphcat=21 if pid=="20140389"
replace monset=4 if pid=="20140389"

replace basis=9 if pid=="20140393"
replace dcostatus=1 if pid=="20140393"
replace dot=d(26mar2014) if pid=="20140393"
replace nsdate=d(03jul2019) if pid=="20140393"
replace rx1=5 if pid=="20140393"
replace rx1d=d(29mar2014) if pid=="20140393"

replace basis=1 if pid=="20140404"
replace dcostatus=1 if pid=="20140404"

replace basis=9 if pid=="20140408"
replace dcostatus=1 if pid=="20140408"
replace dot=d(15jul2014) if pid=="20140408"

replace basis=1 if pid=="20140410"
replace dcostatus=1 if pid=="20140410"
replace dot=d(21may2014) if pid=="20140410"
replace nsdate=d(03jul2019) if pid=="20140410"
replace rx1=5 if pid=="20140410"
replace rx1d=d(21may2014) if pid=="20140410"

replace basis=4 if pid=="20140411"
replace dcostatus=1 if pid=="20140411"
replace dot=d(09jan2013) if pid=="20140411"
replace dotyear=2013 if pid=="20140411"
replace dxyr=2013 if pid=="20140411"
replace nsdate=d(03jul2019) if pid=="20140411"
replace rx1=5 if pid=="20140411"
replace rx1d=d(09jan2013) if pid=="20140411"

replace basis=9 if pid=="20140416"
replace dcostatus=1 if pid=="20140416"
replace dot=d(07feb2014) if pid=="20140416"

replace basis=9 if pid=="20140418"
replace dcostatus=1 if pid=="20140418"
replace dot=d(04jul2014) if pid=="20140418"

replace basis=5 if pid=="20140424"
replace dcostatus=1 if pid=="20140424"
replace dot=d(12may2014) if pid=="20140424"
replace hx="SQUAMOUS CELL CARCINOMA" if pid=="20140424"
replace morph=8070 if pid=="20140424"
replace morphcat=3 if pid=="20140424"
replace monset=5 if pid=="20140424"
replace nsdate=d(04jul2019) if pid=="20140424"

replace basis=2 if pid=="20140425"
replace dcostatus=1 if pid=="20140425"
replace dot=d(25jul2014) if pid=="20140425"
replace nsdate=d(03jul2019) if pid=="20140425"

replace basis=9 if pid=="20140430"
replace dcostatus=1 if pid=="20140430"
replace dot=d(01may2014) if pid=="20140430"

replace basis=2 if pid=="20140446"
replace dcostatus=1 if pid=="20140446"
replace dot=d(07aug2014) if pid=="20140446"
replace nsdate=d(05jul2019) if pid=="20140446"

replace basis=7 if pid=="20140452"
replace dot=d(22feb2002) if pid=="20140452"
replace dotyear=2002 if pid=="20140452"
replace dxyr=2002 if pid=="20140452"
replace nsdate=d(04jul2019) if pid=="20140452"
replace cstatus=3 if pid=="20140452"
replace recstatus=3 if pid=="20140452"
replace dcostatus=3 if pid=="20140452"

replace basis=9 if pid=="20140461"
replace dcostatus=1 if pid=="20140461"
replace dot=d(15sep2013) if pid=="20140461"
replace dotyear=2013 if pid=="20140461"
replace dxyr=2013 if pid=="20140461"

replace basis=9 if pid=="20140462"
replace dcostatus=1 if pid=="20140462"
replace dot=d(24jun2013) if pid=="20140462"
replace dotyear=2013 if pid=="20140462"
replace dxyr=2013 if pid=="20140462"

replace basis=7 if pid=="20140465"
replace dot=d(22may2009) if pid=="20140465"
replace dotyear=2009 if pid=="20140465"
replace dxyr=2009 if pid=="20140465"
replace nsdate=d(04jul2019) if pid=="20140465"
replace cstatus=3 if pid=="20140465"
replace recstatus=3 if pid=="20140465"
replace dcostatus=3 if pid=="20140465"

replace basis=9 if pid=="20140468"
replace dcostatus=1 if pid=="20140468"
replace dot=d(24aug2014) if pid=="20140468"
replace nsdate=d(02jul2019) if pid=="20140468"

replace basis=9 if pid=="20140471"
replace dcostatus=1 if pid=="20140471"
replace dot=d(01aug2014) if pid=="20140471"

replace primarysite="SKIN-NOS" if pid=="20140472"
replace top="449" if pid=="20140472"
replace topography=449 if pid=="20140472"
replace site=11 if pid=="20140472"
replace sitecr5db=26 if pid=="20140472"
replace sitear=11 if pid=="20140472"
replace topcat=39 if pid=="20140472"
replace basis=9 if pid=="20140472"
replace dcostatus=1 if pid=="20140472"
replace dot=d(06aug2014) if pid=="20140472"

drop if pid=="20140474" & cr5id=="T3S1" //1 deleted - a met not a MP

replace basis=9 if pid=="20140490" & cr5id=="T1S1"
replace dot=d(30jun2003) if pid=="20140490" & cr5id=="T1S1"
replace dotyear=2003 if pid=="20140490" & cr5id=="T1S1"
replace dxyr=2003 if pid=="20140490" & cr5id=="T1S1"
replace nsdate=d(04jul2019) if pid=="20140490" & cr5id=="T1S1"
replace cstatus=3 if pid=="20140490" & cr5id=="T1S1"
replace recstatus=3 if pid=="20140490" & cr5id=="T1S1"
replace dcostatus=3 if pid=="20140490" & cr5id=="T1S1"

replace basis=9 if pid=="20140490" & cr5id=="T2S1"
replace dcostatus=1 if pid=="20140490" & cr5id=="T2S1"
replace dot=d(01sep2014) if pid=="20140490" & cr5id=="T2S1"
replace nsdate=d(04jul2019) if pid=="20140490" & cr5id=="T2S1"

replace basis=4 if pid=="20140491"
replace dcostatus=1 if pid=="20140491"
replace dot=d(19nov2013) if pid=="20140491"
replace dotyear=2013 if pid=="20140491"
replace dxyr=2013 if pid=="20140491"
replace rx1=5 if pid=="20140491"
replace rx1d=d(16dec2013) if pid=="20140491"
replace nsdate=d(09jul2019) if pid=="20140491"

replace basis=1 if pid=="20140512"
replace dcostatus=1 if pid=="20140512"
replace dot=d(18aug2014) if pid=="20140512"
replace nsdate=d(04jul2019) if pid=="20140512"

replace basis=2 if pid=="20140514"
replace dcostatus=1 if pid=="20140514"
replace dot=d(21aug2014) if pid=="20140514"
replace nsdate=d(03jul2019) if pid=="20140514"

replace basis=2 if pid=="20140517"
replace dcostatus=1 if pid=="20140517"
replace dot=d(12sep2013) if pid=="20140517"
replace dotyear=2013 if pid=="20140517"
replace dxyr=2013 if pid=="20140517"
replace nsdate=d(02jul2019) if pid=="20140517"

replace basis=9 if pid=="20140535"
replace dcostatus=1 if pid=="20140535"
replace dot=d(09mar2014) if pid=="20140535"

replace basis=7 if pid=="20140537"
replace dot=d(04may2001) if pid=="20140537"
replace dotyear=2001 if pid=="20140537"
replace dxyr=2001 if pid=="20140537"
replace nsdate=d(02jul2019) if pid=="20140537"
replace cstatus=3 if pid=="20140537"
replace recstatus=3 if pid=="20140537"
replace dcostatus=3 if pid=="20140537"

replace basis=9 if pid=="20140543"
replace dcostatus=1 if pid=="20140543"
replace dot=d(06oct2014) if pid=="20140543"

replace basis=9 if pid=="20140557"
replace dcostatus=1 if pid=="20140557"
replace dot=d(19aug2014) if pid=="20140557"
replace nsdate=d(04jul2019) if pid=="20140557"

replace basis=9 if pid=="20140563"
replace dcostatus=1 if pid=="20140563"
replace dot=d(11mar2014) if pid=="20140563"

replace basis=9 if pid=="20140570" & cr5id=="T1S1"
replace dcostatus=1 if pid=="20140570" & cr5id=="T1S1"
replace dot=d(12feb2014) if pid=="20140570" & cr5id=="T1S1"

replace basis=9 if pid=="20140570" & cr5id=="T2S1"
replace dcostatus=1 if pid=="20140570" & cr5id=="T2S1"
replace dot=d(12nov2013) if pid=="20140570" & cr5id=="T2S1"
replace dotyear=2013 if pid=="20140570" & cr5id=="T2S1"
replace dxyr=2013 if pid=="20140570" & cr5id=="T2S1"

replace basis=9 if pid=="20140576"
replace dcostatus=1 if pid=="20140576"
replace dot=d(14mar2014) if pid=="20140576"

replace basis=2 if pid=="20140577"
replace dcostatus=1 if pid=="20140577"
replace dot=d(08oct2014) if pid=="20140577"
replace nsdate=d(05jul2019) if pid=="20140577"

replace basis=9 if pid=="20140578"
replace dcostatus=1 if pid=="20140578"
replace dot=d(03sep2014) if pid=="20140578"
replace nsdate=d(04jul2019) if pid=="20140578"

replace basis=9 if pid=="20140584"
replace dcostatus=1 if pid=="20140584"
replace dot=d(13jun2013) if pid=="20140584"
replace dotyear=2013 if pid=="20140584"
replace dxyr=2013 if pid=="20140584"

replace basis=2 if pid=="20140586"
replace dcostatus=1 if pid=="20140586"
replace dot=d(07aug2014) if pid=="20140586"
replace nsdate=d(04jul2019) if pid=="20140586"

replace basis=7 if pid=="20140590"
replace dot=d(24may2012) if pid=="20140590"
replace dotyear=2012 if pid=="20140590"
replace dxyr=2012 if pid=="20140590"
replace nsdate=d(02jul2019) if pid=="20140590"
replace cstatus=3 if pid=="20140590"
replace recstatus=3 if pid=="20140590"
replace dcostatus=3 if pid=="20140590"

replace basis=9 if pid=="20140595"
replace dcostatus=1 if pid=="20140595"
replace dot=d(15sep2014) if pid=="20140595"
replace nsdate=d(04jul2019) if pid=="20140595"

replace basis=2 if pid=="20140597"
replace dcostatus=1 if pid=="20140597"
replace dot=d(15nov2014) if pid=="20140597"
replace nsdate=d(05jul2019) if pid=="20140597"

replace basis=7 if pid=="20140616"
replace dcostatus=1 if pid=="20140616"
replace primarysite="ESOPHAGUS-32CM" if pid=="20140616"
replace top="155" if pid=="20140616"
replace topography=155 if pid=="20140616"
replace hx="ADENOCARCINOMA WITH ADENOSQUAMOUS CARCINOMA COMPONENT" if pid=="20140616"
replace morph=8560 if pid=="20140616"
replace morphcat=12 if pid=="20140616"
replace dot=d(03mar2014) if pid=="20140616"
replace nsdate=d(10jul2019) if pid=="20140616"

replace basis=2 if pid=="20140619"
replace dcostatus=1 if pid=="20140619"
replace dot=d(02dec2014) if pid=="20140619"
replace nsdate=d(02jul2019) if pid=="20140619"

replace basis=9 if pid=="20140635"
replace dcostatus=1 if pid=="20140635"
replace dot=d(21apr2014) if pid=="20140635"

replace basis=1 if pid=="20140641"
replace dcostatus=1 if pid=="20140641"
replace dot=d(30jun2008) if pid=="20140641"
replace dotyear=2008 if pid=="20140641"
replace dxyr=2008 if pid=="20140641"
replace age=77 if pid=="20140641"
replace nsdate=d(10jul2019) if pid=="20140641"

replace basis=9 if pid=="20140644"
replace dcostatus=1 if pid=="20140644"
replace dot=d(11aug2014) if pid=="20140644"
replace nsdate=d(04jul2019) if pid=="20140644"

replace basis=1 if pid=="20140644"
replace dcostatus=1 if pid=="20140644"
replace dot=d(23oct2014) if pid=="20140644"
replace nsdate=d(24jul2018) if pid=="20140644"

replace basis=2 if pid=="20140656"
replace dcostatus=1 if pid=="20140656"
replace dot=d(21aug2014) if pid=="20140656"
replace nsdate=d(04jul2019) if pid=="20140656"

replace basis=7 if pid=="20140659"
replace dcostatus=1 if pid=="20140659"
replace primarysite="LYMPH NODES-RETROPERITONEAL MASS" if pid=="20140659"
replace top="772" if pid=="20140659"
replace topography=772 if pid=="20140659"
replace hx="AGGRESSIVE B CELL LYMPHOMA, DIFFUSE LARGE B-CELL, NON-GERMINAL CENTER SUBTYPE" if pid=="20140659"
replace morph=9680 if pid=="20140659"
replace morphcat=43 if pid=="20140659"
replace topcat=69 if pid=="20140659"
replace icd10="C833" if pid=="20140659"
replace siteicd10=17 if pid=="20140659"
replace sitecr5db=21 if pid=="20140659"
replace siteiarc=53 if pid=="20140659"
replace site=10 if pid=="20140659"
replace sitear=10 if pid=="20140659"
replace dot=d(18jul2014) if pid=="20140659"

replace basis=9 if pid=="20140665"
replace dcostatus=1 if pid=="20140665"
replace dot=d(28nov2013) if pid=="20140665"
replace dotyear=2013 if pid=="20140665"
replace dxyr=2013 if pid=="20140665"

sort pid
/*
20140587 abstracted directly into dataset via Stata data editor as 2008 case;
See frmCaseFinding 4024 and main CR5db and DCO ptnames excel in version02/1-input
Saved in and as: version02\2-working\'2014_cancer_nonsurvival_extras.dta'

20150037 entered directly into Stata editor using 2015 CLEAN CR5db (2015BNR-C.xml)
*/
count //926 (1 deleted above)

clear
use "`datapath'\version02\2-working\2014_cancer_nonsurvival_extras", replace
count //928


** Create missed 2008 dataset
preserve
drop if dxyr!=2008
list pid dot
count //3

save "`datapath'\version02\2-working\2008_cancer_nonsurvival_extras", replace
label data "2014 BNR-Cancer analysed data - 2008 Cases"
note: This dataset was used for 2015 annual report
restore
//import 2008 cases to 2008_cancer_nonsurvival.dta below

** Create missed 2013 dataset
preserve
drop if dxyr!=2013
list pid dot
count //26

save "`datapath'\version02\2-working\2013_cancer_nonsurvival_extras", replace
label data "2014 BNR-Cancer analysed data - 2013 Cases"
note: This dataset was used for 2015 annual report
restore

** Remove cases before 2014 from 2014 dataset
tab dxyr ,m //3 missing
//list pid dot if dxyr==.
replace dxyr=2014 if dxyr==. //3 changes
drop if dxyr!=2014 //43 deleted

count //

** Export dataset to run data in IARCcrg Tools (Check Programme)
gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_iarc
label var dot_iarc "IARC IncidenceDate"

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

** mpseq was dropped so need to create
gen mpseq=0 if persearch==1
replace mpseq=1 if persearch!=1 & regexm(cr5id,"T1") //12 changes
replace mpseq=2 if persearch!=1 & !(strmatch(strupper(cr5id), "*T1*")) //10 changes

export delimited pid mpseq sex topography morph beh grade basis dot_iarc dob_iarc age ///
using "`datapath'\version02\2-working\2014_nonsurvival_iarccrgtools.txt", nolabel replace

/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2014_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2014_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    885 records processed
	0 errors
        
	51 warnings
        - 6 unlikely hx/site
		- 3 unlikely grade/hx
        - 42 unlikely basis/hx
*/
/*	
Results of IARC MP Program:
	24 excluded (non-malignant)
	22 MPs (multiple tumours)
	 3 Duplicate registration
*/
** Below updates needed for warnings/errors report
replace grade=6 if pid=="20140394"
replace grade=6 if pid=="20140659"
replace grade=4 if pid=="20140525"
replace morph=8460 if pid=="20140707"

** Only report non-duplicate MPs (see IARC MP rules on recording and reporting)
display `"{browse "http://www.iacr.com.fr/images/doc/MPrules_july2004.pdf":IARC-MP}"'
tab persearch ,m
//list pid cr5id if persearch==3 //3
drop if pid=="20140555" & cr5id=="T2S1" //1 deleted
replace primarysite="SIGMOID COLON" if pid=="20140887" & cr5id=="T1S1"
replace top="187" if pid=="20140887" & cr5id=="T1S1"
replace topography=187 if pid=="20140887" & cr5id=="T1S1"
replace primarysite="CECUM" if pid=="20140887" & cr5id=="T2S1"
replace top="180" if pid=="20140887" & cr5id=="T2S1"
replace topography=180 if pid=="20140887" & cr5id=="T2S1"
replace persearch=1 if pid=="20140887" & cr5id=="T1S1"
drop if pid=="20140887" & cr5id=="T2S1" //1 deleted
replace primarysite="COLON-SIGMOID" if pid=="20141351" & cr5id=="T1S1"
replace top="187" if pid=="20141351" & cr5id=="T1S1"
replace topography=187 if pid=="20141351" & cr5id=="T1S1"
replace persearch=1 if pid=="20141351" & cr5id=="T1S1"
replace primarysite="COLON-CECUM" if pid=="20141351" & cr5id=="T2S1"
replace top="180" if pid=="20141351" & cr5id=="T2S1"
replace topography=180 if pid=="20141351" & cr5id=="T2S1"
drop if pid=="20141351" & cr5id=="T2S1" //1 deleted

** Updates for multiple primary report (define which is the MP so can remove in survival dataset):
replace persearch=1 if pid=="20140786" & eidmp==1 //1 change
replace persearch=1 if pid=="20140690" & cr5id=="T1S1" //1 change
replace persearch=2 if pid=="20140690" & cr5id=="T5S1" //1 change
replace persearch=1 if pid=="20140672" & eidmp==1 //1 change
replace persearch=1 if pid=="20140566" & eidmp==1 //1 change
replace persearch=1 if pid=="20140526" & eidmp==1 //1 change
replace persearch=1 if pid=="20140339" & eidmp==1 //1 change
replace persearch=1 if pid=="20140176" & eidmp==1 //1 change
replace persearch=1 if pid=="20140077" & eidmp==1 //1 change

** Updates from MP exclusion report (excludes in-situ/unreportable cancers)
label drop persearch_lab
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate/Non-IARC MP" 4 "Done: Exclude", modify
label values persearch persearch_lab
replace persearch=4 if morph==8077 //24 changes

tab persearch ,m
replace persearch=1 if pid=="20140474"
replace persearch=1 if pid=="20140570"
replace persearch=1 if pid=="20140490"

** Check DCOs
tab basis ,m
replace basis=1 if pid=="20140672" & cr5id=="T2S1"
replace dcostatus=1 if pid=="20140672" & cr5id=="T2S1"
replace nsdate=d(24jul2018) if pid=="20140672" & cr5id=="T2S1"

** Re-assign dcostatus for cases with updated death trace-back
tab dcostatus ,m

** Rename cod in prep for death data matching
rename cod codcancer

** Remove non-residents (see IARC validity presentation)
tab resident ,m 
label drop resident_lab
label define resident_lab 1 "Yes" 2 "No" 99 "Unknown", modify
label values resident resident_lab
replace resident=99 if resident==9 //47 changes
//list pid natregno nrn if resident==99
replace natregno=nrn if natregno=="" & nrn!="" & resident==99 //3 changes
replace resident=1 if natregno!="" & !(strmatch(strupper(natregno), "*-9999*")) //16 changes
** Check electoral list and CR5db for those resident=99
//list pid fname lname nrn natregno dob if resident==99
//list pid fname lname addr dob if resident==99
replace natregno="500906-0061" if pid=="20130294"
replace dob=d(06sep1950) if pid=="20130294"
replace resident=1 if pid=="20130294"
replace resident=1 if pid=="20145040" //JC knows this pt was a resident
replace natregno="550416-7015" if pid=="20141414"
replace dob=d(16apr1955) if pid=="20141414"
replace resident=1 if pid=="20141414"
replace natregno="370117-8018" if pid=="20141510"
replace dob=d(17jan1937) if pid=="20141510"
replace resident=1 if pid=="20141510"
replace age=77 if pid=="20141510"

** Remove missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //none missing - 2 are 100+

** Check for missing follow-up
label drop slc_lab
label define slc_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 99 "Unknown", modify
label values slc slc_lab
replace slc=99 if slc==9 //5 changes
tab slc ,m 
** Check missing in CR5db
//list pid if slc==99
replace slc=1 if pid=="20140817"
replace dlc=d(10sep2015) if pid=="20140817"
replace slc=1 if pid=="20140808"
replace dlc=d(27aug2014) if pid=="20140808"
replace dot=d(27aug2014) if pid=="20140808"
replace slc=1 if pid=="20140186"
replace dlc=d(30jun2014) if pid=="20140186"
replace slc=1 if pid=="20140701"
replace dlc=d(15may2014) if pid=="20140701"
replace dot=d(15may2014) if pid=="20140701"
replace slc=1 if pid=="20140773"
replace dlc=d(20feb2014) if pid=="20140773"
replace dot=d(20feb2014) if pid=="20140773"
tab dlc ,m

** Remove ineligibles
tab recstatus ,m

count //

** Save this corrected dataset
save "`datapath'\version02\2-working\2014_cancer_nonsurvival_nonreportable", replace
label data "2014 BNR-Cancer analysed data - Non-survival Dataset"
note: This dataset was used for 2015 annual report

** Removing cases not eligible for reporting
drop if resident==2 //1 deleted
drop if resident==99 //27 deleted
drop if recstatus==3 //0 deleted

count //854

** Save this corrected dataset
save "`datapath'\version02\2-working\2014_cancer_nonsurvival", replace
label data "2014 BNR-Cancer analysed data - Non-survival Dataset"
note: This dataset was used for 2015 annual report

clear

*******************************
** 2008 Non-survival Dataset **
*******************************

** Load the dataset (2008)
use "`datapath'\version02\1-input\2008_cancer_sites_da_v01", replace
count //1209

** Add 2008 cases (3) found in 2014 (DCO) dataset
append using "`datapath'\version02\2-working\2008_cancer_nonsurvival_extras"
count //1212

** Remove non-reportable skin cancers
drop if siteiarc==25 //303 deleted

** Remove non-malignant and non-insitu tumours
drop if beh!=2 & beh!=3 //18 deleted

count //

** Export dataset to run data in IARCcrg Tools (Check Programme)
gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_iarc
label var dot_iarc "IARC IncidenceDate"

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

export delimited pid mpseq sex topography morph beh grade basis dot_iarc dob_iarc age ///
using "`datapath'\version02\2-working\2008_nonsurvival_iarccrgtools.txt", nolabel replace

/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2008_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2008_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    891 records processed
	0 errors
        
	26 warnings
        - 7 unlikely hx/site
		- 1 unlikely beh/hx
        - 18 unlikely grade/hx
*/
/*	
Results of IARC MP Program:
	83 excluded (non-malignant)
	16 MPs (multiple tumours)
	 1 Duplicate registration
*/
** No updates needed for warnings/errors report
** Updates for multiple primary report:
replace persearch=2 if pid=="20080967" & eidmp==2 //1 change
replace persearch=2 if pid=="20080966" & eidmp==2 //1 change
replace persearch=2 if pid=="20080586" & eidmp==2 //1 change
replace persearch=2 if pid=="20080536" & eidmp==2 //1 change
replace persearch=2 if pid=="20080405" & eidmp==2 //1 change
replace persearch=2 if pid=="20080295" & eidmp==2 //1 change
replace persearch=2 if pid=="20080215" & eidmp==2 //1 change
replace persearch=3 if pid=="20080170" & eidmp==2 //1 change
replace recstatus=4 if pid=="20080170" & eidmp==2 //1 change
drop if pid=="20080170" & recstatus==4 //1 deleted - removed duplicate MP
replace persearch=1 if persearch==0|persearch==. //880 changes

** Updates from MP exclusion report (excludes in-situ/unreportable cancers)
label drop persearch_lab
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate/Non-IARC MP" 4 "Done: Exclude", modify
label values persearch persearch_lab
tab beh ,m //84 in-situ so check against exclusion report to find extra
//list pid morph beh if beh!=3
replace beh=3 if pid=="20080695"
replace persearch=4 if beh!=3 //83 changes

tab persearch ,m

** Remove non-residents (see IARC validity presentation)
tab resident ,m 
label drop resident_lab
label define resident_lab 1 "Yes" 2 "No" 99 "Unknown", modify
label values resident resident_lab
replace resident=99 if resident==9 //214 changes
//list pid natregno nrn if resident==99
//replace natregno=nrn if natregno=="" & nrn!="" & resident==99 //3 changes
replace resident=1 if natregno!="" & !(strmatch(strupper(natregno), "*-9999*")) //161 changes
** Check electoral list and CR5db
//list pid natregno if resident==2
replace natregno=subinstr(natregno,"9999","0027",.) if pid=="20080981"
replace resident=1 if pid=="20080981"
drop if resident==2 //0 deleted
** Check electoral list, CR5db, MasterDb, death data for those resident=99
count if resident==99 //54
STOP
//list pid fname lname nrn natregno dob if resident==99
//list pid fname lname addr dob if resident==99
replace natregno=subinstr(natregno,"9999","0120",.) if pid=="20081066"
replace resident=1 if pid=="20081066"
replace resident=1 if pid=="20081073" //see MasterDb frmCF path sample dates are 6 months apart
replace resident=1 if pid=="20081106" //see MasterDb frmCF path & RT dates
replace natregno=subinstr(natregno,"9999","0024",.) if pid=="20081058"
replace resident=1 if pid=="20081058"
replace addr="37 GAYS" if pid=="20081058"




drop if resident==99 //... deleted

** Remove missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //none missing - 2 are 100+

** Check for missing follow-up
label drop slc_lab
label define slc_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 99 "Unknown", modify
label values slc slc_lab
replace slc=99 if slc==9 //5 changes
tab slc ,m 
** Check missing in CR5db
//list pid if slc==99
replace slc=1 if pid=="20140817"
replace dlc=d(10sep2015) if pid=="20140817"
replace slc=1 if pid=="20140808"
replace dlc=d(27aug2014) if pid=="20140808"
replace dot=d(27aug2014) if pid=="20140808"
replace slc=1 if pid=="20140186"
replace dlc=d(30jun2014) if pid=="20140186"
replace slc=1 if pid=="20140701"
replace dlc=d(15may2014) if pid=="20140701"
replace dot=d(15may2014) if pid=="20140701"
replace slc=1 if pid=="20140773"
replace dlc=d(20feb2014) if pid=="20140773"
replace dot=d(20feb2014) if pid=="20140773"
tab dlc ,m

** Remove ineligibles
tab recstatus ,m
drop if recstatus==3 //0 deleted

** Check DCOs
tab basis ,m
replace basis=1 if pid=="20140672" & cr5id=="T2S1"
replace dcostatus=1 if pid=="20140672" & cr5id=="T2S1"
replace nsdate=d(24jul2018) if pid=="20140672" & cr5id=="T2S1"

** Re-assign dcostatus for cases with updated death trace-back
tab dcostatus ,m

** Rename cod in prep for death data matching
rename cod codcancer

count //854


** Save this corrected dataset
save "`datapath'\version02\2-working\2008_cancer_nonsurvival", replace
label data "2008 BNR-Cancer analysed data - Non-survival Dataset"
note: This dataset was used for 2015 annual report

clear

*******************************
** 2013 Non-survival Dataset **
*******************************

** Load the dataset (2013)
use "`datapath'\version02\1-input\2013_cancer_sites_da_v01", replace
count //845

** Remove non-reportable skin cancers
drop if siteiarc==25 //0 deleted

** Remove non-malignant and non-insitu tumours
drop if beh!=2 & beh!=3 //0 deleted

** Check if 2013 cases from 2014 dataset are not already in this dataset
list pid fname lname if pid=="20130175"|pid=="20140027"|pid=="20140032"|pid=="20140033" ///
                       |pid=="20140042"|pid=="20140049"|pid=="20140078"|pid=="20140100" ///
                       |pid=="20140110"|pid=="20140117"|pid=="20140127"|pid=="20140136" ///
                       |pid=="20140154"|pid=="20140168"|pid=="20140174"|pid=="20140192" ///
                       |pid=="20140202"|pid=="20140203"|pid=="20140215"|pid=="20140224" ///
                       |pid=="20140234"|pid=="20140258"|pid=="20140268"|pid=="20140283" ///
                       |pid=="20140380"|pid=="20140389"|pid=="20140411"|pid=="20140461" ///
                       |pid=="20140462"|pid=="20140491"|pid=="20140517"|pid=="20140570" & cr5id=="T2S1" ///
                       |pid=="20140584"|pid=="20140665"|pid==""|pid==""|pid==""|pid==""|pid==""|pid==""

** Add 2013 cases from 2014_cancer_2013only.dta

tab dcostatus ,m

tab resident ,m 
drop if resident==9 //... deleted

** Age check for newly-added cases (IARC crg Tools will do this!)
** Save this corrected dataset
save "`datapath'\version02\2-working\2013_cancer_nonsurvival", replace
label data "2013 BNR-Cancer analysed data - Non-survival Dataset"
note: This dataset was used for 2015 annual report

clear


*******************************
** 2015 Non-survival Dataset **
*******************************
VALIDITY PRESENTATION
Below items should be assessed for missing values:
age (not >3%)
primarysite
stage
follow up (slc, dlc)
(Missing sex, resident and dotyear not acceptable)

tab resident ,m 
drop if resident==9 //... deleted

create var (sourcetot?) with total sources by using duplicate sepby pid
** 2015 quality report (see 15_review_2015_dc.do and incorporate into this dofile)
SOURCES
DCI/DCN/DCO
MAJOR/MINOR DISAGREEMENTS
Total recoded (recodetop recodemorph) - % total changed/total records

Analysis dofiles: For every data output, use putdocx and add in a methods section describing how data output was generated!