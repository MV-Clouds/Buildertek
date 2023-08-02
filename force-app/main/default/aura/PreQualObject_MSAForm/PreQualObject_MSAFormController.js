({
    doInit : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
            tabId: opendTab,
            label: "Execute MSA"
        });
        workspaceAPI.setTabIcon({
            tabId: opendTab,
            icon: 'custom:custom5',
            iconAlt: 'Import Master SOVs'
        });
    });
	


        //alert("@@@@@@@@@@@@@@@@@@@"+component.get("v.resendMSA"));
       debugger;
        var recid = component.get("v.recordId");
        if(component.get("v.disable") == undefined || component.get("v.disable") == ""){
            component.set("v.Contractor","NO");
            component.set("v.disable",false);
        }else{
            component.set("v.Contractor","YES");
        }
        
        component.set("v.Spinner", true);
        var action = component.get("c.getMSASettings");
        action.setParams({
            "RecordId" : recid,
            "iscontractor" : component.get("v.Contractor")
        });  
        action.setCallback(this, function(response){
            
            if(response.getState() === 'SUCCESS'){
               
                var result = response.getReturnValue();
                
                
                console.log(JSON.stringify(result.accountdata));
                console.log(JSON.stringify(result.contactdata));
                console.log(JSON.stringify(result.currentdate));
                
                if(result.status == 'Success'){
                    if(component.get("v.Contractor") == 'YES'){
                        
                        if(result.contentVersionID != '' && result.contentVersionID != undefined && result.contentVersionID != null){
                            if(component.get("v.Contractor") == 'YES'){
                                component.set("v.ContendVersionId",result.contentVersionID);
                                var url = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+result.contentVersionID;
                                component.set("v.URLstring",url);
                                
                            }
                            if(result.accountdata != undefined){
                                //component.set("v.ContactId",result.contactData.Id);
                                component.set("v.Name",result.accountdata.buildertek__Company_Name__c);
                                component.set("v.Phone",result.accountdata.buildertek__Phone__c);
                                component.set("v.Fax",result.accountdata.buildertek__Fax__c);
                                component.set("v.Address",result.accountdata.buildertek__Office_Address__c);
                                component.set("v.Citystate",result.accountdata.buildertek__City__c);
                                component.set("v.State",result.accountdata.buildertek__State__c);
                                component.set("v.Zip",result.accountdata.buildertek__ZipCode__c);
                                component.set("v.ContractorLicense",result.accountdata.buildertek__Contractor_License__c);
                                component.set("v.FederalTaxID",result.accountdata.buildertek__Federal_Tax_ID__c);
                                if(component.get("v.Contractor") == "YES"){
                                    
                                    component.set("v.ContractorDate",result.currentdate);
                                }
                                
                                component.set("v.day",result.accountdata.buildertek__Agreement_Day__c);
                                component.set("v.month",result.accountdata.buildertek__Agreement_Month__c);
                                 component.set("v.Year",result.accountdata.buildertek__Agreement_Year__c);
                                
                                /* component.set("v.subContractorBy",result.accountdata.buildertek__Sub_Contract_By__c);
                    component.set("v.subContractorprintedName",result.accountdata.buildertek__Sub_Contract_Printed_Name__c);    
                    component.set("v.subContractorVendorName",result.accountdata.buildertek__Sub_Contractor_Vendor_Name__c	); */   
                            }
                            if(result.contactdata != undefined){
                                component.set("v.subContractorBy",result.contactdata.Name);
                                component.set("v.subContractorprintedName",result.contactdata.Name);
                                component.set("v.subContractorVendorName",result.contactdata.Account.Name);
                            }
                            else if(result.accountdata != undefined){
                                component.set("v.subContractorBy",result.accountdata.buildertek__Sub_Contract_By__c);
                                component.set("v.subContractorprintedName",result.accountdata.buildertek__Sub_Contract_Printed_Name__c);    
                                component.set("v.subContractorVendorName",result.accountdata.buildertek__Sub_Contractor_Vendor_Name__c	); 
                            }
                            if(result.currentdate != undefined){
                                component.set("v.subContractorDate",result.currentdate); 
                            }
                            
                            
                            
                            component.set("v.msaSettings", result.msaSettings); 
                            component.set("v.Spinner", false);
                        }else{
                            var elmnt = document.getElementById("pageTop");
                            elmnt.scrollIntoView();
                            component.set("v.isSuccess",false);
                            component.set("v.isError",true);
                            component.set("v.Message","Please complete sub contractor signature");
                            component.set("v.Spinner", false);                     
                        }
                    }else{
                        if(component.get("v.Contractor") == 'YES'){
                            component.set("v.ContendVersionId",result.contentVersionID);
                            var url = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+result.contentVersionID;
                            component.set("v.URLstring",url);
                            
                        }
                        if(result.accountdata != undefined){
                            //component.set("v.ContactId",result.contactData.Id);
                            component.set("v.Name",result.accountdata.buildertek__Company_Name__c);
                            component.set("v.Phone",result.accountdata.buildertek__Phone__c);
                            component.set("v.Fax",result.accountdata.buildertek__Fax__c);
                            component.set("v.Address",result.accountdata.buildertek__Office_Address__c);
                            component.set("v.Citystate",result.accountdata.buildertek__City__c);
                            component.set("v.State",result.accountdata.buildertek__State__c);
                            component.set("v.Zip",result.accountdata.buildertek__ZipCode__c);
                            component.set("v.ContractorLicense",result.accountdata.buildertek__Contractor_License__c);
                            component.set("v.FederalTaxID",result.accountdata.buildertek__Federal_Tax_ID__c);
                            if(component.get("v.Contractor") == "YES"){
                                
                                component.set("v.ContractorDate",result.currentdate);
                            }
                            console.log("Day : ",result.accountdata.buildertek__Agreement_Day__c);
                             console.log("Day : ",result.accountdata.buildertek__Agreement_Month__c);
                            console.log("Day : ",result.accountdata.buildertek__Agreement_Year__c);
                            component.set("v.day",result.accountdata.buildertek__Agreement_Day__c);
                            component.set("v.month",result.accountdata.buildertek__Agreement_Month__c);
                             component.set("v.Year",result.accountdata.buildertek__Agreement_Year__c);
                            
                            /* component.set("v.subContractorBy",result.accountdata.buildertek__Sub_Contract_By__c);
                    component.set("v.subContractorprintedName",result.accountdata.buildertek__Sub_Contract_Printed_Name__c);    
                    component.set("v.subContractorVendorName",result.accountdata.buildertek__Sub_Contractor_Vendor_Name__c	); */   
                         }
                         if(result.contactdata != undefined){
                             component.set("v.subContractorBy",result.contactdata.Name);
                             component.set("v.subContractorprintedName",result.contactdata.Name);
                             component.set("v.subContractorVendorName",result.contactdata.Account.Name);
                         }
                         else if(result.accountdata != undefined){
                             component.set("v.subContractorBy",result.accountdata.buildertek__Sub_Contract_By__c);
                             component.set("v.subContractorprintedName",result.accountdata.buildertek__Sub_Contract_Printed_Name__c);    
                             component.set("v.subContractorVendorName",result.accountdata.buildertek__Sub_Contractor_Vendor_Name__c	); 
                         }
                         if(result.currentdate != undefined){
                             component.set("v.subContractorDate",result.currentdate); 
                         }
                         
                         
                         
                         component.set("v.msaSettings", result.msaSettings); 
                         component.set("v.Spinner", false);
                         
                     }
                }
            }   
        });
        $A.enqueueAction(action);
        //alert(document.URL.indexOf("#"));
       
      if(document.URL.indexOf("#")==-1 && (component.get("v.Contractor") == 'YES')){
          window.setTimeout(
              $A.getCallback(function() {
                
                  location.reload()
              }), 10
          );
      }
    },
    handleClick : function(component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.isDisabled",true);
        var name = component.get("v.Name");
        var address = component.get("v.Address");
        var citystate = component.get("v.Citystate");
        var state = component.get("v.State");
        var zip = component.get("v.Zip");
        var phone = component.get("v.Phone");
        var fax = component.get("v.Fax");
        var contractorlicence = component.get("v.ContractorLicense");
        var federaltaxId = component.get("v.FederalTaxID");
        
        var subBy = component.get("v.subContractorBy");
        var subprintedName = component.get("v.subContractorprintedName");
        var subVendorName = component.get("v.subContractorVendorName");
        var subDate = component.get("v.subContractorDate");
        
        var By = component.get("v.ContractorBy");
        var printedName = component.get("v.ContractorprintedName");
        var Date = component.get("v.ContractorDate");
        
        var Day =  component.get("v.day");
        var Month =  component.get("v.month");
        var Year =  component.get("v.Year");
        
        //	alert(Day);
         //alert(Month);
       // alert(Year)
        
        var JsonString = {};
        JsonString.jName = name;
        JsonString.jaddress = address;
        JsonString.jcitystate = citystate;
        JsonString.jstate = state;
        JsonString.jzip = zip;
        JsonString.jphone = phone;
        JsonString.jfax = fax;
        JsonString.jcontractorlicence = contractorlicence;
        JsonString.jfederaltaxId = federaltaxId;
        
        JsonString.jsubBy = subBy;
        JsonString.jsubprintedName = subprintedName;
        JsonString.jsubVendorName = subVendorName;
        JsonString.jsubDate = subDate;
        
        JsonString.jcontractorby = By;
        JsonString.jprintedName = printedName;
        JsonString.jcontractorDate = Date;
        
        JsonString.jday = Day;
        JsonString.jmonth = Month;
        var recid = component.get("v.recordId");
        debugger;
        // alert(JsonString);
        
        var action = component.get("c.getJSonString");
        action.setParams({
            "jsonData" : JSON.stringify(JsonString),
            "AccountId" : recid,
            "FileId" : component.get("v.fileimageId"),
            "iscontractor" : component.get("v.disable"),
            
        });  
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var elmnt = document.getElementById("pageTop");
                elmnt.scrollIntoView();
                component.set("v.isSuccess",true);
                component.set("v.Message","Contract signed successfully");
                component.set("v.Spinner", false);
            }else if(state === "ERROR"){
                var elmnt = document.getElementById("pageTop");
                elmnt.scrollIntoView();
                component.set("v.isSuccess",false);
                component.set("v.isError",true);
                component.set("v.Message","ERROR!!!!");
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);  
        
    },
    
    getuploadSignature: function (component, event,helper) {
        component.set("v.parentId", component.get("v.recordId"));
        var recId = component.get("v.parentId");
        
        var signName = component.get("v.SignatureName");
        
        
        var toastEvent = $A.get('e.force:showToast');
        
        
        component.set("v.Spinner", true);
        component.set("v.isDisabled",true);
        
        /* if(component.get("v.disable") == true){
             alert("_______________");
              var contractorvSplit = document.getElementById("ownersign").toDataURL().split(',')[1];
             alert('contractorvSplit'+contractorvSplit);
              component.set("v.iscontractor",true);
         }*/
        if(component.get("v.disable") == false){
            var vSplit = document.getElementById("divsign").toDataURL().split(',')[1];
            var canv = document.getElementById("divsign")
            
            function checkvanvs() {
                var cnv = document.getElementById('divsign');
                if (isCanvasEmpty(cnv)){
                    component.set("v.isSignature",true);
                }
                
                else {
                    component.set("v.isSignature",false);
                    component.set("v.iscontractor",false);
                }
                
            };
            
            function isCanvasEmpty(cnv) {
                const blank = document.createElement('canvas');
                
                blank.width = cnv.width;
                blank.height = cnv.height;
                
                return cnv.toDataURL() === blank.toDataURL();
            }
            checkvanvs()
            
            
            
        }else{
            
            var contractorvSplit = document.getElementById("ownersign").toDataURL().split(',')[1];
            component.set("v.iscontractor",true);
            var canv = document.getElementById("ownersign")
            
            function checkvanvs1() {
                var cnv = document.getElementById('ownersign');
                if (isCanvasEmpty1(cnv)){
                    component.set("v.isCompanySignature",true);
                }
                
                else {
                    component.set("v.isCompanySignature",false);
                    component.set("v.iscontractor",true);
                }
                
            };
            
            function isCanvasEmpty1(cnv) {
                const blank = document.createElement('canvas');
                
                blank.width = cnv.width;
                blank.height = cnv.height;
                
                return cnv.toDataURL() === blank.toDataURL();
            }
            checkvanvs1()
            
        }
        
        if(component.get("v.isSignature") == true){
            
            var error = component.get("c.getErrorMsg");
       
            
            component.set("v.Spinner", false);
            component.set("v.isDisabled",false);
            
        }else if(component.get("v.isCompanySignature") == true){
            component.set("v.Spinner", false);
            component.set("v.isDisabled",false);
        } else{
            
            var signatureaction = component.get("c.saveSign");
            signatureaction.setParams({
                contractorSignbase64Data : encodeURIComponent(contractorvSplit),
                base64Data: encodeURIComponent(vSplit),
                contentType: "image/png",
                recId: recId,
                signName: signName,
                iscontractor : component.get("v.iscontractor"),
            });
            
            signatureaction.setCallback(this, function (e) {
                //alert(e.getState());
                if (e.getState() == 'SUCCESS') {
                    var result = e.getReturnValue();
                    //alert("result"+result);
                    component.set("v.Spinner", false);
                    console.log(result);
                    
                    component.set("v.fileimageId", result);
                    helper.handleclick(component,event,helper);
                    
                } else {
                    component.set("v.Spinner", false);
                    
                    component.set("v.fileimageId", '');
                    helper.handleclick(component,event,helper);
                }
            });
            $A.enqueueAction(signatureaction);
            
            
            
        }
        
        
        //if(component.get("v.ContactId") != null && component.get("v.ContactId") != undefined && component.get("v.ContactId") !=''){ 
        
        var action = component.get("c.UpdateAccount");
        action.setParams({
            "recId" : component.get("v.recordId"),
            "Name"  : component.get("v.Name"),
            "Phone": component.get("v.Phone"),
            "Fax": component.get("v.Fax"),
            "City": component.get("v.Citystate"),
            "State": component.get("v.State"),
            "Zip": component.get("v.Zip"),
            "Address": component.get("v.Address"),
            "Federal": component.get("v.FederalTaxID"),
            "Contractor": component.get("v.ContractorLicense"),
            "subContractorBy" : component.get("v.subContractorBy"),
            "subContractorprintedName" : component.get("v.subContractorprintedName"),
            "subContractorVendorName" : component.get("v.subContractorVendorName"),
            "day" : component.get("v.day"),
            "month" : component.get("v.month"),
              "year" : component.get("v.Year"),
            "isContractor" : component.get("v.Contractor"),
            
        }); 
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                
            }
        });
        $A.enqueueAction(action);
        //}
        
    },
    
    closePage : function(component, event, helper) {
        //window.close('/buildertek__MSASite?id=0011K00002ReIWHQA3');
        // window.open('/0011K00002ReIWHQA3');
        //alert("test"+component.get("v.disable"));
        var recid = component.get("v.recordId");
        if(component.get("v.disable") == true){
            //alert("test"+component.get("v.disable"));
            // window.open('', '_parent', '');
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            
        })
        .catch(function(error) {
           
        });
          //window.location.href ='/'+recid;
         //window.open('/'+recid,'_parent');
           var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId":recid,
            "slideDevName": "detail"
        });
        navEvt.fire();
        }else{
            window.close('/buildertek__MSASite?id=0011K00002ReIWHQA3');
        }
        
        
    },
})