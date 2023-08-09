({
	doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
       debugger;
		var action = component.get("c.RetrieveFieldsets");
        action.setCallback(this, function( response ) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var fieldsList = response.getReturnValue();
                console.log(fieldsList.referencepickvalues);
                component.set("v.GeneralInfoFieldSet",fieldsList.generalInfoList);
                component.set("v.CompanyInfoFieldSet",fieldsList.companyInfoList);
                component.set("v.KeyManageMentSet",fieldsList.KeyManagementList);
                component.set("v.LVEFieldSet",fieldsList.LVEList);
                component.set("v.ContractorFieldSet",fieldsList.ContractorList);
                component.set("v.provinceList",fieldsList.referencepickvalues);
                component.set("v.countryList",fieldsList.referencecountryvalues);
                
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
        
        
        
        if(component.get("v.recordId") != undefined){
            debugger;
            var recId = component.get("v.recordId");
            var isPreview = component.get("v.isPreview");
            
            if(isPreview == 'yes'){
        	component.set("v.isInputDisabled", true);
           }else{
            component.set("v.isInputDisabled", false);
           }
        }
        
        
    },
     
    
   handleClick :function(component, event, helper) {
        
    	//console.log(JSON.parse(JSON.stringify(component.get("v.GeneralInfoFieldSet"))))

    	var obj =[];
        obj.push(...component.get("v.GeneralInfoFieldSet"));
        obj.push(...component.get("v.CompanyInfoFieldSet"));
        obj.push(...component.get("v.KeyManageMentSet"));
        obj.push(...component.get("v.LVEFieldSet"));
        obj.push(...component.get("v.ContractorFieldSet"));
        component.set("v.validAllfields",true)
        //for (const property in obj) {
        for(var i=0;i<obj.length;i++){
             if(obj[i]['fieldName'] == 'Contact_Email__c' || 
               obj[i]['fieldName'] == 'Email_of_Full_time_safety_representative__c' ||
               obj[i]['fieldName'] == 'Technician2_Email_Address__c' ||
               obj[i]['fieldName'] == 'Technician1_Email_Address__c' ||
               obj[i]['fieldName'] == 'Estimator_Email_Address__c' ||
               obj[i]['fieldName'] == 'Design_Engineer_Email_Address__c' ||
                obj[i]['fieldName'] == 'Lead_Glazier_Email_Address__c' ||
                obj[i]['fieldName'] == 'Foreman_Superindentent_Email_Address__c'){
                var fieldName = obj[i]['fieldName'];
                var validRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
                if(obj[i]['fieldValue'].match(validRegex)){
                  
                    //component.set("v.validAllfields",true);
                }else{
                   
                    component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                    
                }
                          
            }
          else  if(obj[i]['fieldName'] == 'Bid_Limit__c' ||
               obj[i]['fieldName'] == 'General_Liability_Coverage__c' ||
               obj[i]['fieldName'] == 'Service_Area_Miles_from_Office__c' ||
               obj[i]['fieldName'] == 'Worker_s_Compensation_Coverage__c' ||
               obj[i]['fieldName'] == 'buildertek__Number_of_Employees__c' ||
               obj[i]['fieldName'] == 'buildertek__Service_Are__c' ||
              // obj[i]['fieldName'] == 'Current_Ratio__c'||
              // obj[i]['fieldName'] == 'Leverage_Ratio__c' ||
               obj[i]['fieldName'] == 'Yr_1_Days_Away_Restructed_or_Transfer_R__c' ||
               obj[i]['fieldName'] == 'Yr_1_Total_Recordable_Incidence_Rate__c' ||
               obj[i]['fieldName'] == 'Year_1_Fatalities_OSHA_300_Log_Col__c' ||
               obj[i]['fieldName'] == 'Year_Founded_Incorporated__c'||
               obj[i]['fieldName'] == 'buildertek__Workers_Compensation_Limit__c' ||
               obj[i]['fieldName'] == 'Average_Job_Size__c'||
               obj[i]['fieldName'] == 'Amount_of_Largest_job_ever_completed__c'||
               obj[i]['fieldName'] == 'What_is_your_current_backlog__c'||
               obj[i]['fieldName'] == 'This_Year_s_est_annual_sales_volume__c'||
               obj[i]['fieldName'] == 'Working_Capital__c'||
               obj[i]['fieldName'] == 'Net_Worth__c'||
               obj[i]['fieldName'] == 'Aggregate_Limit__c'|| 
               obj[i]['fieldName'] == 'Largest_Bond_Issued__c'||
               obj[i]['fieldName'] == 'Most_recent_Bond_Amount__c'||
               obj[i]['fieldName'] == 'Single_Limit__c'){
                var fieldName = obj[i]['fieldName'];
                if(obj[i]['fieldValue']){
                 /*    if( obj[i]['fieldName'] == 'Year_Founded_Incorporated__c'){
                        if(obj[i]['fieldValue'].length == 4){
                            
                        }
                        else{
                            component.set("v.validationMessage","Year is not Valid")
                            component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    elmnt.scrollIntoView();
                        }
                    } */
                    
                }else{
                    component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                }
            }
            else{
                if((obj[i]['fieldValue'] == undefined || obj[i]['fieldValue'] == null || obj[i]['fieldValue'] == '') && (obj[i]['fieldName'] != 'If_Other_LVE_Estimator__c') && (obj[i]['fieldName'] != 'Key_Management2_Full_Name__c') && (obj[i]['fieldName'] != 'Key_Management2_Title__c') && (obj[i]['fieldName'] != 'Key_Management3_Full_Name__c') && (obj[i]['fieldName'] != 'Key_Management3_Title__c') && (obj[i]['fieldName'] != 'Key_Management2_Total_years_experience__c') && (obj[i]['fieldName'] != 'Key_Management2_Years_in_this_position__c') && (obj[i]['fieldName'] != 'Key_Management3_Total_years_experience__c') && (obj[i]['fieldName'] != 'Key_Management3_Years_in_this_position__c')
                  && (obj[i]['fieldName'] != 'Contract_License_State_2__c') && (obj[i]['fieldName'] != 'Contractor_License_Number2__c') && (obj[i]['fieldName'] != 'Contract_License_State_3__c') && (obj[i]['fieldName'] != 'Contractor_License_Number3__c') && (obj[i]['fieldName'] != 'License_ever_been_denied_or_revoked__c') && (obj[i]['fieldName'] != 'Complaints_filed_Contractor_s_State_Lice__c')){
                    var fieldName = obj[i]['fieldName'];
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                }
            }
            
        }
        
         var ref1 = component.get("v.reference1");
        if(ref1.buildertek__Email__c){
            var fieldName = 'referenceemail1val';
                var validRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
                if(ref1.buildertek__Email__c.match(validRegex)){
                  
                    //component.set("v.validAllfields",true);
                }else{
                    component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                }
        }
        
        var ref2 = component.get("v.reference2");
        if(ref2.buildertek__Email__c){
            var fieldName = 'referenceemail2val';
                var validRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
                if(ref2.buildertek__Email__c.match(validRegex)){
                  
                    //component.set("v.validAllfields",true);
                }else{
                    component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                }
        }
        
        var ref3 = component.get("v.reference3");
        if(ref3.buildertek__Email__c){	
            var fieldName = 'referenceemail3val';
                var validRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
                if(ref3.buildertek__Email__c.match(validRegex)){
                  
                    //component.set("v.validAllfields",true);
                }else{
                    component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                }
        }
        
       
        
        
        var project1 = component.get("v.project1");
        if(project1.buildertek__Contact_Email__c){
            var fieldName = 'project1emailval';
                var validRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
                if(project1.buildertek__Contact_Email__c.match(validRegex)){
                  
                    //component.set("v.validAllfields",true);
                }else{
                    component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                }
        }
        if(project1.Contract_Value__c){
            if(isNaN(project1.Contract_Value__c)){
                component.set("v.validAllfields",false);
                var elmnt = document.getElementById('project1ContractValue');
                if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
            }else{
                
            }
        }else{
            component.set("v.validAllfields",false);
            var elmnt = document.getElementById('project1ContractValue');
            if(elmnt){
                  elmnt.scrollIntoView(); 
             } 
        }
        
        
        
        var project2 = component.get("v.project2");
        if(project2.buildertek__Contact_Email__c){
            var fieldName = 'project2emailval';
                var validRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
                if(project2.buildertek__Contact_Email__c.match(validRegex)){
                  
                    //component.set("v.validAllfields",true);
                }else{
                    component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                }
        }
        if(project2.Contract_Value__c){
            if(isNaN(project2.Contract_Value__c)){
                component.set("v.validAllfields",false);
                var elmnt = document.getElementById('project2ContractValue');
                if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
            }else{
                
            }
        }else{
            component.set("v.validAllfields",false);
            var elmnt = document.getElementById('project2ContractValue');
            if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
        }
        
        
       var project3 = component.get("v.project3");
        if(project3.buildertek__Contact_Email__c){
            var fieldName = 'project3emailval';
                var validRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
                if(project3.buildertek__Contact_Email__c.match(validRegex)){
                  
                    //component.set("v.validAllfields",true);
                }else{
                    component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                }
        }
        if(project3.Contract_Value__c){
            if(isNaN(project3.Contract_Value__c)){
                component.set("v.validAllfields",false);
                var elmnt = document.getElementById('project3ContractValue');
                if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
            }else{
                
            }
        }else{
            component.set("v.validAllfields",false);
            var elmnt = document.getElementById('project3ContractValue');
            if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
        }
        
        var submittmail = component.get("v.SubmittedEmail");
        if(submittmail){
            var fieldName = 'submittedemail';
                var validRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
                if(submittmail.match(validRegex)){
                  
                    //component.set("v.validAllfields",true);
                }else{
                    component.set("v.validAllfields",false);
                    var elmnt = document.getElementById(fieldName);
                    if(elmnt){
                       elmnt.scrollIntoView(); 
                    }
                }
        }
        
        
    },
    handleClickSubmit :function(component, event, helper) {
       
    }
    ,
    handleSubmit: function(component, event, helper) {
        if(component.get("v.validAllfields")){
            
            var elmnt = document.getElementById("pageTop");
            if(elmnt){
                elmnt.scrollIntoView(); 
            }
            component.set("v.Spinner", true);
            debugger;
            event.preventDefault();
            const fields = event.getParam('fields');
            fields.Form_Date_Field__c = component.get("v.contactDate");
            fields.Additional_Information_Notes__c = component.get("v.AdditionalNotes");
            fields.Submitted_by_NAME__c = component.get("v.SubmittedName");
            fields.Submitted_by_Title__c = component.get("v.SubmitteTitle");
            fields.Submitted_by_Email__c = component.get("v.SubmittedEmail");
            fields.Send_me_a_opy_of_my_responses__c =component.get("v.Sendmecopy");  
            var fileData = component.get("v.fileData");
            console.log('!!'+fileData);
            
            if(fileData.length > 0){
                helper.submitForm(component, event, helper, JSON.stringify(fileData),JSON.stringify(fields));
            }else{
                component.set("v.Spinner", false);
                var elmnt = document.getElementById("pageTop");
                if(elmnt){
                    elmnt.scrollIntoView(); 
                }
                component.set("v.message", 'Please upload files');
                component.set("v.isError", true);
                component.set("v.Spinner", false);
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set("v.isError", false);
                    }), 6000
                );
            }
        }
        
        
        
        
    },
    handleError: function(component, event) {
        //   alert('error');
        var errors = event.getParams();
        
        console.log("response", JSON.stringify(errors));
    },
    handleFilesChange : function(component, event, helper) {
        
          var action = component.get("c.checkEnableBox");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()){
                    
                      var fileName = "No File Selected..";  
                    var fileCount = event.target.files;
                    // alert(JSON.stringify(event.target.files));
                    var fileList = component.get("v.uploadFileList")
                    for(var i=0;i<event.target.files.length;i++){
                        fileList.push( event.target.files[i])
                    }
                    
                    component.set("v.uploadFileList",fileList)
                    component.set("v.removefiledataList",fileCount);
                    console.log('fileCount -------> '+JSON.stringify(fileCount));
                    var files='';
                    
                    var names =[];
                    for (var i = 0; i < component.get("v.fileData").length; i++) {
                        names.push(component.get("v.fileData")[i]["fileName"])
                    }
                    for (var i = 0; i < fileCount.length; i++) 
                    {
                        names.push(fileCount[i]["name"])
                    }
                    
                    component.get("v.fileData")
                    component.set("v.FileNameList",names);
                    var filedata = component.get("v.FileLabelList");
                    
                    if (fileCount.length > 0) {
                        component.set("v.uploadFile", true);
                        for (var i = 0; i < fileCount.length; i++) 
                        {
                            
                            fileName = fileCount[i]["name"];
                            if(files == ''){
                                files = fileName;
                            }else{
                                files = files+','+fileName;
                            }
                            helper.readFiles(component, event, helper, fileCount[i]);
                        }
                    }
                    component.set("v.fileName", files);
                }
                
                else{
                     var a = event.target.files;
                    console.log("Check 1 "+JSON.stringify(a))
                     if(a.length > 0) {
                      
                         var names =[];
            for(var b=0;b<a.length;b++){
                const fsize = a.item(b).size;
                const file = Math.round((fsize / 1024));
                console.log("okokok")
                if (file >= 2200) {
                    var elmnt = document.getElementById("pageTop");
                    elmnt.scrollIntoView();
                    debugger;
                    //component.set("v.message", result.Message);
                    
                    component.set("v.message", 'File Limit Exceeded.');
                    component.set("v.isSuccess", false);
                    component.set("v.isError", true);
                    component.set("v.Spinner", false);
                    window.setTimeout(
                        $A.getCallback(function() {
                            component.set("v.isError", false);
                        }), 6000
                    );
                } else{
                    var fileName = "No File Selected..";  
                    var fileCount = a[b];
                    var fileList = component.get("v.uploadFileList")
                    if(!fileList.includes(a[b])){
                        fileList.push(a[b])
                    }
                    component.set("v.uploadFileList",fileList)
                    component.set("v.removefiledataList",fileCount);
                    console.log('fileCount -------> '+JSON.stringify(fileCount));
                    var files='';
                 
                    for (var i = 0; i < component.get("v.fileData").length; i++) {
                          if(!names.includes(component.get("v.fileData")[i]["fileName"])){
                        names.push(component.get("v.fileData")[i]["fileName"])
                          }
                    }
                    names.push(fileCount["name"])
                    component.get("v.fileData")
                    component.set("v.FileNameList",names);
                    var filedata = component.get("v.FileLabelList");
                    component.set("v.uploadFile", true);
                    fileName = fileCount["name"];
                    if(files == ''){
                        files = fileName;
                    }else{
                        files = files+','+fileName;
                    }
                    helper.readFiles(component, event, helper, fileCount);
                    component.set("v.fileName", files);
                    console.log("check number : "+component.get("v.fileData"))
                }
                
            }
            
        }
                }
            
            }
            else if (state === "INCOMPLETE") {
                console.log("Incomplete 101 Line")
            }
            else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
     /*   var fileName = "No File Selected..";  
        var fileCount = event.target.files;
        var fileList = component.get("v.uploadFileList")
        for(var i=0;i<event.target.files.length;i++){
            if(!fileList.includes(event.target.files[i])){
                fileList.push( event.target.files[i])
            }
        }
        component.set("v.uploadFileList",fileList)
        component.set("v.removefiledataList",fileCount);
        var files='';
        var names =[];
        for (var i = 0; i < component.get("v.fileData").length; i++) {
            names.push(component.get("v.fileData")[i]["fileName"])
         }
        for (var i = 0; i < fileCount.length; i++) 
         {
               names.push(fileCount[i]["name"])
         }
        
         component.get("v.fileData")
         component.set("v.FileNameList",names);
         var filedata = component.get("v.FileLabelList");
         
         
        if (fileCount.length > 0) {
            component.set("v.uploadFile", true);
            for (var i = 0; i < fileCount.length; i++) 
            {
                fileName = fileCount[i]["name"];
                if(files == ''){
                    files = fileName;
                }else{
                    files = files+','+fileName;
                }
                helper.readFiles(component, event, helper, fileCount[i]);
            }
        }
        component.set("v.fileName", files);	*/

    },
    closePage : function(component, event, helper) {
    	window.close('/apex/view_PreQual_VF');    
    },
    
      checkbox : function(component, event, helper) {
        if(component.get("v.check1") == true && component.get("v.check2") == true && component.get("v.check3") == true &&
          component.get("v.check4") == true && component.get("v.check5") == true && component.get("v.check6") == true && 
           component.get("v.check7") == true && component.get("v.check8") == true && component.get("v.check9") == true &&
           component.get("v.check10") == true && component.get("v.check11") == true && component.get("v.check12") == true &&
           component.get("v.check13") == true && component.get("v.check14") == true && component.get("v.check15") == true  && component.get("v.check16") == true){
            component.set("v.isButtonDisabled",false);
        }else{
            component.set("v.isButtonDisabled",true);
        }
        ///alert(component.get("v.check2"));
    },
    
     removeRow : function(component, event, helper) {
        var index = event.target.title;
        //alert(index);
        var namelist = component.get("v.FileNameList");
        namelist.splice(index,1);
        component.set("v.FileNameList",namelist);
       // alert(component.get("v.fileData"));
        var oldFilelist = component.get("v.fileData");
        oldFilelist.splice(index,1);
        component.set("v.fileData",oldFilelist);
        console.log(JSON.stringify(component.get("v.fileData")));
        var fileList =  component.get("v.uploadFileList")
         fileList.splice(index,1)
          component.set("v.uploadFileList",fileList)
        
    },
    
    removeComma : function(component, event, helper) {
     /*   var yearCheck = component.find("fieldCheck");
        if(yearCheck){
            var a = yearCheck.get("v.value");
            function yearValidation(year) {
                var text = /^[0-9]+$/;
                if(year.length==4) {
                    if (year != 0) {
                        if ((year != "") && (!text.test(year))) {
                            component.set("v.validationMessage",'Please Enter Numeric Values Only.');
                            return false;
                        } 
                        if (year.length != 4) {
                            return false;
                        }
                        var current_year=new Date().getFullYear();
                        return true;
                    } }
                 else{
                     component.set("v.validationMessage",'');
                }
            }
            var getYear = yearValidation(a);
            if(getYear){
                component.set("v.validationMessage",'');
            }
        } */
    },
    
     checkPhone : function(component, event, helper) {
        var getId = event.getSource();
        var auraIdName = getId.getLocalId();
        var a = component.find(auraIdName).get("v.value");
        if(a){
            if(a.length == 10){
                function formatPhoneNumber(phoneNumberString) {
                    var cleaned = ('' + phoneNumberString).replace(/\D/g, '')
                    var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/)
                    if (match) {
                        return '(' + match[1] + ') ' + match[2] + '-' + match[3]
                    }
                    return null
                }
                var FormattedNunber = formatPhoneNumber(a);
                if(FormattedNunber){
                    component.find(auraIdName).set("v.value", FormattedNunber)
                }
            }
        }
        
    }
})