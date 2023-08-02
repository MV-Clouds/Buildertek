({
	doInit : function(component, event, helper) {
        if(component.get("v.RecordId") != undefined){
            console.log('Inn')  
            component.set("v.Spinner", true);
            var isPreview = component.get("v.isPreview"); 
            if(isPreview == 'yes'){
        	component.set("v.isInputDisabled", true);
                
           }else{
            component.set("v.isInputDisabled", false);
           } 
           
            var action = component.get("c.getPickListValuesIntoList"); 
             action.setParams({
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    console.log('company type pick list values'+response.getReturnValue());
                    component.set("v.companyTypeList",response.getReturnValue());
                }
             });
             $A.enqueueAction(action);
        if(isPreview == 'yes'){
          component.set("v.Spinner", false);
        }
        
		var action = component.get("c.getAccount");
         action.setParams({
            "AccountId" : component.get("v.RecordId"),
         });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
               
                if(isPreview != 'yes'){
                component.set("v.acc",response.getReturnValue().acc);
                //console.log("@@@@@@@@@@"+JSON.stringify(response.getReturnValue().acc.Company_Type__c));
                //alert(JSON.stringify(response.getReturnValue().proj[0]));
                component.set("v.project1",(response.getReturnValue().proj[0]));
                component.set("v.project2",(response.getReturnValue().proj[1]));
                component.set("v.project3",(response.getReturnValue().proj[2])); 
                
                component.set("v.reference1",(response.getReturnValue().ref[0]));
                component.set("v.reference2",(response.getReturnValue().ref[1]));
                component.set("v.reference3",(response.getReturnValue().ref[2]));
                }
               //console.log(JSON.stringify(response.getReturnValue()));
				component.set("v.Spinner", false);                
            }
        });
        $A.enqueueAction(action);
        
        }
	},
    handleClick : function(component, event, helper) {
        component.set("v.isNotValid",false);
       var elmnt = document.getElementById("pageTop");
            elmnt.scrollIntoView();
        var isValidFields = component.find('myinput').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
            
        
        /*var amount = component.find("amount");
        var amountval = amount.get("v.validity");
        var amountvalue = amount.get("v.value");
       if(amountvalue == "" || amountvalue == undefined){
             isValidFields = false;
           component.set("v.IsCurrencyError",true);
        }else{
            isValidFields = true;
            component.set("v.IsCurrencyError",false);
        }*/
        
        
        
         var mainphone = component.find("mainphone");
        var mainphoneval = mainphone.get("v.validity");
        var mainphonevalue = mainphone.get("v.value");
        if(mainphonevalue == "" || mainphonevalue == undefined){
             isValidFields = false;
             mainphone.setCustomValidity("Complete this field");
             mainphone.reportValidity();
            
        }else if(mainphoneval.valid == false){
            mainphone.setCustomValidity("Enter a 10 digit mobile number");
             mainphone.reportValidity();
            component.set("v.isNotValid",true);

        }
        
        var owner1phone = component.find("owner1phone");
        var owner1phoneval = owner1phone.get("v.validity");
        var owner1phonevalue = owner1phone.get("v.value");
        if(owner1phonevalue == "" || owner1phonevalue == undefined){
             isValidFields = false;
             owner1phone.setCustomValidity("Complete this field");
             owner1phone.reportValidity();
        }else if(owner1phoneval.valid == false){
            owner1phone.setCustomValidity("Enter a 10 digit mobile number");
             owner1phone.reportValidity();
            component.set("v.isNotValid",true);
        }
         var owner1Email = component.find("owner1Email");
        var owner1val1 = owner1Email.get("v.validity");
        var owner1value = owner1Email.get("v.value");
        //alert("owner1Email"+owner1Email);
        if(owner1value == "" || owner1value == undefined){
             isValidFields = false;
            owner1Email.setCustomValidity("Complete this field");
            owner1Email.reportValidity();
        }else if(owner1val1.valid == false){
            owner1Email.setCustomValidity("Enter a valid email address");
            owner1Email.reportValidity();
            component.set("v.isNotValid",true);
        }
         var owner2email = component.find("owner2email");
        var owner2val1 = owner2email.get("v.validity");
        var owner2value = owner2email.get("v.value");
        if(owner2value != "" && owner2val1.valid == false){
           
            component.set("v.isNotValid",true);
        }
        var owner2phone = component.find("owner2phone");
        var owner2phoneval = owner2phone.get("v.validity");
        var owner2phonevalue = owner2phone.get("v.value");
        if(owner2phonevalue != "" && owner2phoneval.valid == false){
           
            component.set("v.isNotValid",true);
        }

         var tech1email = component.find("tech1email");
        var tech1emailval = tech1email.get("v.validity");
        var tech1emailvalue = tech1email.get("v.value");
        if(tech1emailvalue == "" || tech1emailvalue == undefined){
             isValidFields = false;
            tech1email.setCustomValidity("Complete this field");
            tech1email.reportValidity();
           }else if(tech1emailval.valid == false){
          tech1email.setCustomValidity("Enter a valid email address");
            tech1email.reportValidity();
            component.set("v.isNotValid",true);
        }
        
         var teck1phone = component.find("teck1phone");
        var teck1phoneval = teck1phone.get("v.validity");
        var teck1phonevalue = teck1phone.get("v.value");
        if(teck1phonevalue == "" || teck1phonevalue == undefined){
             isValidFields = false;
            teck1phone.setCustomValidity("Complete this field");
            teck1phone.reportValidity();
        }else if(teck1phoneval.valid == false){
            teck1phone.setCustomValidity("Enter a 10 digit mobile number");
            teck1phone.reportValidity();
            component.set("v.isNotValid",true);
        }
        
        
        
        var tech2email = component.find("tech2email");
        var tech2emailval = tech2email.get("v.validity");
        var tech2emailvalue = tech2email.get("v.value");
        if(tech2emailvalue == "" || tech2emailvalue == undefined){
            tech2email.setCustomValidity("Complete this field");
            tech2email.reportValidity();
             isValidFields = false;
        }else if(tech2emailval.valid == false){
             tech2email.setCustomValidity("Enter a valid email address");
            tech2email.reportValidity();
            component.set("v.isNotValid",true);
        }  
        
        
         var tech2phone = component.find("tech2phone");
        var tech2phoneval = tech2phone.get("v.validity");
        var tech2phonevalue = tech2phone.get("v.value");
        if(tech2phonevalue == "" || tech2phonevalue == undefined){
            tech2phone.setCustomValidity("Complete this field");
            tech2phone.reportValidity();
             isValidFields = false;
        }else if(tech2phoneval.valid == false){
            tech2phone.setCustomValidity("Enter a 10 digit mobile number");
            tech2phone.reportValidity();
            component.set("v.isNotValid",true);
        }  
        
        
        
        
        var estimatorEmail = component.find("estimatorEmail");
        var estimatorEmailval = estimatorEmail.get("v.validity");
        var estimatorEmailvalue = estimatorEmail.get("v.value");
        if(estimatorEmailvalue == "" || estimatorEmailvalue == undefined){
             estimatorEmail.setCustomValidity("Complete this field");
             estimatorEmail.reportValidity();
             isValidFields = false;
        }else if(estimatorEmailval.valid == false){
            estimatorEmail.setCustomValidity("Enter a valid email address");
             estimatorEmail.reportValidity();
            component.set("v.isNotValid",true);
        } 
         var estimatorphone = component.find("estimatorphone");
        var estimatorphoneval = estimatorphone.get("v.validity");
        var estimatorphonevalue = estimatorphone.get("v.value");
        if(estimatorphonevalue == "" || estimatorphonevalue == undefined){
             isValidFields = false;
             estimatorphone.setCustomValidity("Complete this field");
             estimatorphone.reportValidity();
        }else if(estimatorphoneval.valid == false){
            estimatorphone.setCustomValidity("Enter a 10 digit mobile number");
             estimatorphone.reportValidity();
            component.set("v.isNotValid",true);
        } 
          var ForemanEmail = component.find("ForemanEmail");
        var ForemanEmailval = ForemanEmail.get("v.validity");
        var ForemanEmailvalue = ForemanEmail.get("v.value");
        if(ForemanEmailvalue == "" || ForemanEmailvalue == undefined){
             isValidFields = false;
            ForemanEmail.setCustomValidity("Complete this field");
             ForemanEmail.reportValidity();
        }else if(ForemanEmailval.valid == false){
             ForemanEmail.setCustomValidity("Enter a valid email address");
             ForemanEmail.reportValidity();
            component.set("v.isNotValid",true);
        }  
        var ForemanPhone = component.find("ForemanPhone");
        var ForemanPhoneval = ForemanPhone.get("v.validity");
        var ForemanPhonevalue = ForemanPhone.get("v.value");
        if(ForemanPhonevalue == "" || ForemanPhonevalue == undefined){
             isValidFields = false;
             ForemanPhone.setCustomValidity("Complete this field");
             ForemanPhone.reportValidity();
        }else if(ForemanPhoneval.valid == false){
             ForemanPhone.setCustomValidity("Enter a 10 digit mobile number");
             ForemanPhone.reportValidity();
            component.set("v.isNotValid",true);
        } 
        var ReferenceEmail1 = component.find("ReferenceEmail1");
        var ReferenceEmail1val = ReferenceEmail1.get("v.validity");
        var ReferenceEmail1value = ReferenceEmail1.get("v.value");
        if(ReferenceEmail1value == "" || ReferenceEmail1value == undefined){
             isValidFields = false;
             ReferenceEmail1.setCustomValidity("Complete this field");
             ReferenceEmail1.reportValidity();
        }else if(ReferenceEmail1val.valid == false){
             ReferenceEmail1.setCustomValidity("Enter a valid email address");
             ReferenceEmail1.reportValidity();
            component.set("v.isNotValid",true);
        }  
        
         var ReferenceEmail2 = component.find("ReferenceEmail2");
        var ReferenceEmail2val = ReferenceEmail2.get("v.validity");
        var ReferenceEmail2value = ReferenceEmail2.get("v.value");
        if(ReferenceEmail2value == "" || ReferenceEmail2value == undefined){
             isValidFields = false;
             ReferenceEmail2.setCustomValidity("Complete this field");
             ReferenceEmail2.reportValidity();
        }else if(ReferenceEmail2val.valid == false){
             ReferenceEmail2.setCustomValidity("Enter a valid email address");
             ReferenceEmail2.reportValidity();
            component.set("v.isNotValid",true);
        }  
         var ReferenceEmail3 = component.find("ReferenceEmail3");
        var ReferenceEmail3val = ReferenceEmail3.get("v.validity");
        var ReferenceEmail3value = ReferenceEmail3.get("v.value");
        if(ReferenceEmail3value == "" || ReferenceEmail3value == undefined){
             isValidFields = false;
            ReferenceEmail3.setCustomValidity("Complete this field");
             ReferenceEmail3.reportValidity();
        }else if(ReferenceEmail3val.valid == false){
            ReferenceEmail3.setCustomValidity("Enter a valid email address");
             ReferenceEmail3.reportValidity();
            component.set("v.isNotValid",true);
        }  
         var Referencephone1 = component.find("Referencephone1");
        var Referencephone1val = Referencephone1.get("v.validity");
        var Referencephone1value = Referencephone1.get("v.value");
        if(Referencephone1value == "" || Referencephone1value == undefined){
             isValidFields = false;
             Referencephone1.setCustomValidity("Complete this field");
             Referencephone1.reportValidity();
        }else if(Referencephone1val.valid == false){
           Referencephone1.setCustomValidity("Enter a 10 digit mobile number");
             Referencephone1.reportValidity();
            component.set("v.isNotValid",true);
        }  
         var Referencephone2 = component.find("Referencephone2");
        var Referencephone2val = Referencephone2.get("v.validity");
        var Referencephone2value = Referencephone2.get("v.value");
        if(Referencephone2value == "" || Referencephone2value == undefined){
             isValidFields = false;
             Referencephone2.setCustomValidity("Complete this field");
             Referencephone2.reportValidity();
        }else if(Referencephone2val.valid == false){
             Referencephone2.setCustomValidity("Enter a 10 digit mobile number");
             Referencephone2.reportValidity();
            component.set("v.isNotValid",true);
        }  
         var Referencephone3 = component.find("Referencephone3");
        var Referencephone3val = Referencephone3.get("v.validity");
        var Referencephone3value = Referencephone3.get("v.value");
        if(Referencephone3value == "" || Referencephone3value == undefined){
             isValidFields = false;
             Referencephone3.setCustomValidity("Complete this field");
             Referencephone3.reportValidity();
        }else if(Referencephone3val.valid == false){
             Referencephone3.setCustomValidity("Enter a 10 digit mobile number");
             Referencephone3.reportValidity();
            component.set("v.isNotValid",true);
        }  
        
        
        
        
        
        
         var ProjectEmail1 = component.find("ProjectEmail1");
        var ProjectEmail1val = ProjectEmail1.get("v.validity");
        var ProjectEmail1value = ProjectEmail1.get("v.value");
        if(ProjectEmail1value == "" || ProjectEmail1value == undefined){
             isValidFields = false;
            ProjectEmail1.setCustomValidity("Complete this field");
             ProjectEmail1.reportValidity();
        }else if(ProjectEmail1val.valid == false){
             ProjectEmail1.setCustomValidity("Enter a valid email address");
             ProjectEmail1.reportValidity();
            component.set("v.isNotValid",true);
        }  
        
         var ProjectEmail2 = component.find("ProjectEmail2");
        var ProjectEmail2val = ProjectEmail2.get("v.validity");
        var ProjectEmail2value = ProjectEmail2.get("v.value");
        if(ProjectEmail2value == "" || ProjectEmail2value == undefined){
             isValidFields = false;
            ProjectEmail2.setCustomValidity("Complete this field");
             ProjectEmail2.reportValidity();
        }else if(ProjectEmail2val.valid == false){
             ProjectEmail2.setCustomValidity("Enter a valid email address");
             ProjectEmail2.reportValidity();
            component.set("v.isNotValid",true);
        }  
        
         var ProjectEmail3 = component.find("ProjectEmail3");
        var ProjectEmail3val = ProjectEmail3.get("v.validity");
        var ProjectEmail3value = ProjectEmail3.get("v.value");
        if(ProjectEmail3value == "" || ProjectEmail3value == undefined){
             isValidFields = false;
            ProjectEmail3.setCustomValidity("Complete this field");
             ProjectEmail3.reportValidity();
        }else if(ProjectEmail3val.valid == false){
            ProjectEmail3.setCustomValidity("Enter a valid email address");
             ProjectEmail3.reportValidity();
            component.set("v.isNotValid",true);
        } 
        
        var projectphone1 = component.find("projectphone1");
        var projectphone1val = projectphone1.get("v.validity");
        var projectphone1value = projectphone1.get("v.value");
        if(projectphone1value == "" || projectphone1value == undefined){
             isValidFields = false;
             projectphone1.setCustomValidity("Complete this field");
             projectphone1.reportValidity();
        }else if(projectphone1val.valid == false){
            projectphone1.setCustomValidity("Enter a 10 digit mobile number");
             projectphone1.reportValidity();
            component.set("v.isNotValid",true);
        } 
        var projectphone2 = component.find("projectphone2");
        var projectphone2val = projectphone2.get("v.validity");
        var projectphone2value = projectphone2.get("v.value");
        if(projectphone2value == "" || projectphone2value == undefined){
             isValidFields = false;
             projectphone2.setCustomValidity("Complete this field");
             projectphone2.reportValidity();
        }else if(projectphone2val.valid == false){
            projectphone2.setCustomValidity("Enter a 10 digit mobile number");
             projectphone2.reportValidity();
            component.set("v.isNotValid",true);
        } 
        var projectphone3 = component.find("projectphone3");
        var projectphone3val = projectphone3.get("v.validity");
        var projectphone3value = projectphone3.get("v.value");
        if(projectphone3value == "" || projectphone3value == undefined){
             isValidFields = false;
             projectphone3.setCustomValidity("Complete this field");
             projectphone3.reportValidity();
        }else if(projectphone3val.valid == false){
             projectphone3.setCustomValidity("Enter a 10 digit mobile number");
             projectphone3.reportValidity();
            component.set("v.isNotValid",true);
        } 
        
       
        
            if(isValidFields == true){
                if(component.get("v.isNotValid") == false){
                 var parameterData;
        var action = component.get("c.getparameters");
        action.setParams({
         
        });
        action.setCallback(this, function(response){
           
             if(response.getState() === 'SUCCESS'){
                
                 parameterData=JSON.stringify(response.getReturnValue()); 
             }
             });
                
                  
        //alert((component.find("Type").get("v.value")));
         var fileData = component.get("v.fileData");
        console.log('HAndle click'+JSON.stringify(component.get("v.fileData2")));
        //var selectedFiles = document.getElementById('file-upload-input-01').files;
        if(fileData.length > 0){
            
            //component.set("v.createFile", true);
            //var message = component.get("v.postMessage");
            //var vfWindow = component.find("vfFrame").getElement().contentWindow;
            //vfWindow.postMessage(fileData, '*');
            helper.submitForm(component, event, helper, JSON.stringify(fileData),parameterData);
        }else{
            var elmnt = document.getElementById("pageTop");
            elmnt.scrollIntoView();
            component.set("v.message", 'Please upload files');
            component.set("v.isError", true);
            component.set("v.Spinner", false);
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.isError", false);
                }), 6000
            );
        }
            }else{
             var elmnt = document.getElementById("pageTop");
            elmnt.scrollIntoView();
            component.set("v.message", 'Form has validation errors');
            component.set("v.isError", true);
            component.set("v.Spinner", false);
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.isError", false);
                }), 6000
            );
                } 
            
            }else{
                  var elmnt = document.getElementById("pageTop");
            elmnt.scrollIntoView();
            component.set("v.message", 'Please fill the required fields');
            component.set("v.isError", true);
            component.set("v.Spinner", false);
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.isError", false);
                }), 6000
            );
            }
	},
    handleClear : function(component, event, helper){
        
        component.set("v.showConfirmDialogBox",true);
        
    },
    handleConfirmDialogOk : function(component, event, helper) {
        // component.doinits();
        component.set("v.isNotValid",false);
        component.set("v.isButtonDisabled",true);
        component.set("v.check1",false);
        component.set("v.check2",false);
        component.set("v.check3",false);
        component.set("v.check4",false);
        component.set("v.check5",false);
        component.set("v.check6",false);
        component.set("v.check7",false);
        component.set("v.check8",false);
        component.set("v.check9",false);
        component.set("v.isDataCleared",true);
         var proj1 = component.get("v.project1.Id");
         var proj2 = component.get("v.project2.Id");
         var proj3 = component.get("v.project3.Id");
        
        var ref1 = component.get("v.reference1.Id");
         var ref2 = component.get("v.reference2.Id");
         var ref3 = component.get("v.reference3.Id");
        
        component.set("v.acc",component.get("v.account"));
        component.set(("v.acc.Id"),component.get("v.RecordId"));
       
        component.set("v.project1",component.get("v.projectNull1"));
         component.set("v.project2",component.get("v.projectNull2"));
         component.set("v.project3",component.get("v.projectNull3"));
        
        component.set("v.reference1",component.get("v.referenceNull1"));
         component.set("v.reference2",component.get("v.referenceNull2"));
         component.set("v.reference3",component.get("v.referenceNull3"));
        
         
       
        component.set("v.project1.Id",proj1);
         component.set("v.project2.Id",proj2);
         component.set("v.project3.Id",proj3);
        component.set("v.reference1.Id",ref1);
         component.set("v.reference2.Id",ref2);
         component.set("v.reference3.Id",ref3);
       
      component.set('v.showConfirmDialogBox', false);
},
    handleConfirmDialogCancel : function(component, event, helper) {
    component.set('v.showConfirmDialogBox', false);
},
    closePage : function(component, event, helper) {
    	window.close('/apex/view_PreQual_VF');    
    },
    onchangeCompany : function(component, event, helper) {
        //alert(JSON.stringify(component.get("v.acc.buildertek__Type_of_Company__c")));
        //component.set()
    },
     handleFilesChange : function(component, event, helper) {
        // alert(document.getElementById('file-upload-input-01').value);
        var fileName = "No File Selected..";  
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
           // if(!names.includes(component.get("v.fileData")[i]["fileName"])){
             names.push(component.get("v.fileData")[i]["fileName"])
           // }
         }
        for (var i = 0; i < fileCount.length; i++) 
         {
            // if(!names.includes(fileCount[i]["name"])){
               names.push(fileCount[i]["name"])
             //}
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

    },
    checkbox : function(component, event, helper) {
        if(component.get("v.check1") == true && component.get("v.check2") == true && component.get("v.check3") == true &&
          component.get("v.check4") == true && component.get("v.check5") == true && component.get("v.check6") == true &&
           component.get("v.check7") == true && component.get("v.check8") == true && component.get("v.check9") == true){
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
          //alert(document.getElementById('file-upload-input-01').value);
         //document.getElementById('file-upload-input-01').value = null;
        
    },
     changeValidation : function(component, event, helper) {
        var datatype = event.getSource().get("v.type");
        var auraid = event.getSource().get("v.title");
         
       // var fieldvalue = '';
        // fieldvalue = event.getSource().get("v.value");
      // alert(event.getSource().get("v.value"));
        //alert(event.getSource().get("v.validity"));
        if(datatype == "tel" && event.getSource().get("v.value") != undefined){
            if(event.getSource().get("v.value").length == 10){
                event.getSource().setCustomValidity("");
                event.getSource().reportValidity();
            }else{
                event.getSource().setCustomValidity("Enter a 10 digit mobile number");
                event.getSource().reportValidity();
            }
        }
        else if(datatype == "email" && event.getSource().get("v.value") != undefined){
            if(event.getSource().get("v.value").includes("@") == true && (event.getSource().get("v.value").includes(".co") == true || event.getSource().get("v.value").includes(".CO") == true)){
                event.getSource().setCustomValidity("");
                event.getSource().reportValidity();
            }else{
                event.getSource().setCustomValidity("Enter a valid email address");
                event.getSource().reportValidity();
            }
        }
         
         /*if(datatype == "number" && event.getSource().get("v.value") != ""){
             //alert(event.getSource().get("v.value"));
             if(isNaN(event.getSource().get("v.value")) == false){
                 event.getSource().setCustomValidity("");
                event.getSource().reportValidity();
             }else{
                event.getSource().setCustomValidity("Enter a valid Number");
                event.getSource().reportValidity();
             }
         }*/
  
    },
    /*currencyonchange : function(component, event, helper) {
        //alert("onchange"+event.getSource().get("v.value"));
        if(event.getSource().get("v.value") != null){
            component.set("v.IsCurrencyError",false);
        }else{
            component.set("v.IsCurrencyError",true);
        }
    }*/
     
    
    
    
})