({
    doInit : function(component, event, helper) {

        helper.getPaymentTypeHelper(component, event, helper);
        
         helper.getcurr(component, event, helper);
         helper.getrelatedrfqvendorlist(component, event, helper);
        
        
        var action40 = component.get("c.getFieldSet");
        action40.setParams({
            objectName: 'buildertek__SOV_Payment_Application__c',
            fieldSetName: 'buildertek__ListOfFields'
        });
        action40.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                
                var listOfFields0 = JSON.parse(response.getReturnValue());
                // alert(listOfFields);
                console.log(listOfFields0);
                component.set("v.listOfFields0", listOfFields0);
                
                  var action2 = component.get("c.GetadmindetailsforPA");
        action2.setCallback(this, function (result) {
            var state = result.getState();
            if (state === "SUCCESS") {
                var resultData = result.getReturnValue();
                if (resultData != null ) {
                    console.log("Result of admin : ",result)
                    component.set("v.isadminpa", resultData);
                }
            }
        });  
        $A.enqueueAction(action2);
                //---------------------------------------------------------------------------------------------------------------     
                    var action41 = component.get("c.getFieldSet");
                action41.setParams({
                    objectName: 'buildertek__SOV_Payment_Application__c',
                    fieldSetName: 'buildertek__ListOfFields1'
                });
                action41.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        
                        var listOfFields1 = JSON.parse(response.getReturnValue());
                        // alert(listOfFields);
                        console.log(listOfFields1);
                        component.set("v.listOfFields1", listOfFields1); 
                
                //---------------------------------------------------------------------------------------------------------------------
                
                     var action42 = component.get("c.getFieldSet");
                action42.setParams({
                    objectName: 'buildertek__SOV_Payment_Application__c',
                    fieldSetName: 'buildertek__ListOfFields2'
                });
                action42.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        
                        var listOfFields2 = JSON.parse(response.getReturnValue());
                        // alert(listOfFields);
                        console.log(listOfFields2);
                        component.set("v.listOfFields2", listOfFields2);
                        
                    } else {
                        console.log('Error');
                    }
                });
                $A.enqueueAction(action42); 
                
                //--------------------------------------------------------------------------------------------------------------------------------------             
                           	} else {
				console.log('Error');
			}
		});
		$A.enqueueAction(action41); 
                
                //-----------------------------------------------------------------------------------------------------------------
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action40);
        //Fetching Record Type Id  
     //   var recordTypeId = component.get( "v.pageReference" ).state.recordTypeId;  
        
     //   component.set("v.RecordTypeId",recordTypeId);
        
        console.log('================>'+component.get("v.recordId"));
        var action2 = component.get("c.GetadmindetailsforPA");
        action2.setCallback(this, function (result) {
            var state = result.getState();
            if (state === "SUCCESS") {
                var resultData = result.getReturnValue();
                if (resultData != null ) {
                    component.set("v.isadminpa", resultData);
                }
            }
        });  
        $A.enqueueAction(action2);
        
   
        
        
        //component.set("v.isnew", true);
        // component.find("application#").set("v.value","1");
        component.set("v.isnewpayment", false);
        component.set("v.isopen", false);
        var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            // debugger;
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    // debugger;
                    var PATyle = component.get("c.getSovType");
                    PATyle.setCallback(this, function (response1) {
                        if (response1.getState() == 'SUCCESS') {
                            var result = response1.getReturnValue();
                            if(result != null){
                               // component.find("PAtype").set(result);
                                component.set("v.RecordTypeId",result);
                            }
                        }
                    });
                    $A.enqueueAction(PATyle);
                    
                    component.set("v.communityUserId",commUserId);
                    component.set("v.Iscommunity",true);
                    component.set("v.isnewpayment", true);
                    component.set("v.Vendorname",result.buildertek__Account_Id__c);
                   
                    component.find("vendorName").set("v.value",component.get("v.Vendorname"))    // this line is previously commented  i changes it on 30-12
                    component.find("companyName").set("v.value",component.get("v.isadminpa"));
                    var pageNumber = component.get("v.PageNumber");
                    var pageSize = component.get("v.pageSize");
                    var recordId = component.get("v.recordId");
                    // helper.getRfqListApproved(component, event, helper, pageNumber, pageSize);
                    var options = [ {'label': 'New Payment Application', 'value': 'option1'}, {'label': 'Import Approved SOVs', 'value': 'option3'} ]
                    component.set("v.options",options)
                }else{
                    // component.set("v.isnew", true);
                    
                    // debugger;
                    var PATyle = component.get("c.getARSovType");
                    PATyle.setCallback(this, function (response1) {
                        if (response1.getState() == 'SUCCESS') {
                            var result = response1.getReturnValue();
                            if(result != null){
                               // component.find("PAtype").set(result);
                                component.set("v.RecordTypeId",result);
                            }
                        }
                    });
                    $A.enqueueAction(PATyle);
                    
                    
                }
                var action1 = component.get("c.getParentProject");
                // debugger;
                var value = helper.getParameterByName(component, event, 'inContextOfRef');
                var context = '';
                var parentRecordId = '';
               // component.set("v.parentRecordId", parentRecordId);
                if (value != null) {
                    context = JSON.parse(window.atob(value));
                    parentRecordId = context.attributes.recordId;
                    component.set("v.parentRecordId", parentRecordId);
                } else {
                    var relatedList = window.location.pathname;
                    var stringList = relatedList.split("/");
                    parentRecordId = stringList[4];
                    if (parentRecordId == 'related') {
                        var stringList = relatedList.split("/");
                        parentRecordId = stringList[3];
                    }
                    component.set("v.parentRecordId", parentRecordId);
                }
                if(parentRecordId != null && parentRecordId != ''){
                    var action1 = component.get("c.getParentProject");
                    action1.setParams({
                        recordId: parentRecordId,
                    });
                    action1.setCallback(this, function (response) {
                        if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                            var objName = response.getReturnValue();
                            if(objName == 'buildertek__Project__c'){
                                
                                component.set("v.parentprojectRecordId", parentRecordId);
                               // alert(component.get("v.parentprojectRecordId"))
                            }
                        } 
                    });
                    $A.enqueueAction(action1);
                }
            }
        });
        $A.enqueueAction(action);

    },
    
    getSelectedName: function (component, event) {
        
        var selectedRows = event.getParam('selectedRows');
        var y =[];
        component.set("v.listOfSelectedRFQIds",y);
        var selectedRowList =component.get("v.listOfSelectedRFQIds")
        
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            if(selectedRowList.indexOf(selectedRows[i].Id) < 0){
                selectedRowList.push(selectedRows[i].Id)
            }
            component.set("v.listOfSelectedRFQIds",selectedRowList)
            
        }
        
    },
    
    getSeletedPAIds: function (component, event) {
        
        var selectedRows = event.getParam('selectedRows');
        var y =[];
        component.set("v.listOfSelectedRFQIds",y);
        var selectedRowList =component.get("v.listOfSelectedRFQIds")
        
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            if(selectedRowList.indexOf(selectedRows[i].Id) < 0){
                selectedRowList.push(selectedRows[i].Id)
            }
            component.set("v.listOfSelectedRFQIds",selectedRowList)
            
        }
        
    },
    getSeletedCompanyApprovedIds: function (component, event) {
        
        var selectedRows = event.getParam('selectedRows');
        var y =[];
        component.set("v.listOfSelectedRFQIds",y);
        var selectedRowList =component.get("v.listOfSelectedRFQIds")
        
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            if(selectedRowList.indexOf(selectedRows[i].Id) < 0){
                selectedRowList.push(selectedRows[i].Id)
            }
            component.set("v.listOfSelectedRFQIds",selectedRowList)
            //alert(component.get("v.listOfSelectedRFQIds"));
            
        }
        
    },
    handleChangeButtonGroup:function(component, event, helper){
        var auraIdField = event.getSource().getLocalId();
        // console.log(auraIdField);
        console.log(component.find(auraIdField).get("v.value"));
        component.set("v.checkBoxValue",component.find(auraIdField).get("v.value"));
    },
    
    isNext:function(component, event, helper){
    //   debugger;
        
        var optionSelected = component.get("v.checkBoxValue");
        
        if(optionSelected == 'option1'){
            
            var ac1 = component.get("c.newpayment")
            $A.enqueueAction(ac1)
            component.set("v.Spinner", false);
        }else if(optionSelected == 'option2'){
            
            var ac2 = component.get("c.ImportMasterSOVs")
            $A.enqueueAction(ac2) 
            component.set("v.Spinner", false);
            
        }else if(optionSelected == 'option4'){
            
            // import company approved Payment Apps
            
            
            var action = component.get("c.getVendorPaymentApps");
            action.setParams({
                "projectId" : component.get("v.parentprojectRecordId") 
            });
            action.setCallback(this, function(response){
                
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    if(result.length > 0){
                        component.set("v.isOption4",true);
                        component.set("v.isnewpayment", true);
                        component.set("v.isnew", false);
                        component.find("companyName").set("v.value",component.get("v.isadminpa"));
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: 'You dont have any Company Accepted Payment Apps',
                            duration: "5000",
                            key: "info_alt",
                            type: "error",
                        });
                        toastEvent.fire(); 
                    }
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
            
            
            
        }else if(optionSelected == 'option5'){
            
            // import company approved sov's
            
            // debugger;
             var action = component.get("c.getCompanyApprovedScheduleOValues");
            action.setParams({
                "projectId" : component.get("v.parentprojectRecordId") 
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    if(result.length > 0){
                        component.set("v.isOption5",true);
                        component.set("v.isnewpayment", true);
                        component.set("v.isnew", false);
                        component.find("companyName").set("v.value",component.get("v.isadminpa"));
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: 'You dont have any Company Approved SOVs',
                            duration: "5000",
                            key: "info_alt",
                            type: "error",
                        });
                        toastEvent.fire();  
                    }
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
            
            
            
            

            
        } else if(optionSelected == 'option6'){
            component.set("v.isImportCustomerApproved",true);
            var action = component.get("c.getCustomerApprovedScheduleOValues");
            action.setParams({
                "projectId" : component.get("v.parentprojectRecordId") 
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    for(var i=0;i<result.length;i++){
                        
                        if(result[i].buildertek__Project__c){
                            result[i].buildertek__Project__c = result[i].buildertek__Project__r.Name;
                        }
                        
                    }
                    
                    component.set("v.ImportCustomerApprovedSOVsList",result);
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
            
        } 
            
            else if(optionSelected == ''){
                component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'ERROR',
                message: 'Please Select an Option',
                duration: "5000",
                key: "info_alt",
                type: "error",
                mode: "pester",
            });
            toastEvent.fire();
        }
        
        
    },
    
    newpayment : function(component, event, helper) {
        component.set("v.isnewpayment", true);
        component.set("v.isnew", false);
        component.find("companyName").set("v.value",component.get("v.isadminpa"));
    },
    ImportMasterSOVs : function(component, event, helper) {
        component.set("v.isnew", false);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var recordId = component.get("v.recordId");
        console.log(component.get("v.recordId"));
        helper.getRfqList(component, event, helper, pageNumber, pageSize);
        
    },
    doCancel :function(component, event, helper) {
        component.set("v.isnew", true);
        if(component.get("v.isCompanyApprovedSOV") == true){
            component.set("v.isImportCompanyApproved", false);
            component.set("v.IsActive", false);
            component.set("v.isnewpayment", true);
            component.set("v.IsBudgetLines", true);
            component.set("v.isnew", false);
            component.set("v.isopen", true);
            component.set("v.isUseMasterSOV", false);
            component.set("v.isImportVendor",false); 
            
        }else{
            component.set("v.isImportCompanyApproved", false);
            component.set("v.IsActive", false);
            component.set("v.isnewpayment", false);
            component.set("v.isopen", false);
            component.set("v.isUseMasterSOV", false);
            component.set("v.isImportVendor",false); 
        }
       
        //var ac = component.get("c.closeEditPopup1")
        //$A.enqueueAction(ac);
    },
    
    
    
    
    closeCustomerApproved :function(component, event, helper) {
        component.set("v.isImportCustomerApproved", false);
        component.set("v.IsActive", false);
        component.set("v.isnewpayment", false);
        component.set("v.isopen", false);
        component.set("v.isUseMasterSOV", false);
        component.set("v.isImportVendor",false); 
    },
    
    
    doCancel2 :function(component, event, helper) {
        component.set("v.isnew", false);
        component.set("v.IsActive", false);
        component.set("v.isnewpayment", true);
        component.set("v.isopen", false);
        component.set("v.isUseMasterSOV", false);
        component.set("v.isImportVendor",false); 
        //var ac = component.get("c.closeEditPopup1")
        //$A.enqueueAction(ac);
    },
    redirectToPayment :function(component, event, helper) {
        
        if(component.get("v.Iscommunity") == true){
            var recId = component.get("v.recordId");
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": recId
            });
            navEvt.fire();
        }else{
            
            component.set("v.isnew", true);
            component.set("v.IsActive", false);
            component.set("v.isnewpayment", false);
            component.set("v.isopen", true);
            component.set("v.IsBudgetLines", true);
            component.set("v.isUseMasterSOV", false);
            component.set("v.isImportVendor",false); 
            //var ac = component.get("c.closeEditPopup1")
            //$A.enqueueAction(ac); 
        }
        
        
    }, 
    importSheetLines: function (component, event, helper) {

        var action = component.get("c.createlines");
        action.setParams({
            "projectId" : component.get("v.parentprojectRecordId"),
            "RecordTypeId" : component.get("v.RecordTypeId"),
        })
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var sheetId = result.Id;
                component.set("v.redirectRecordId",sheetId);
                // setTimeout(function () {
                var records = component.get("v.rfqRecordList");
                var selectedSheetIds = component.get("v.listOfSelectedRFQIds");
                
                if(selectedSheetIds.length>0){
                    helper.importContinuationSheetItems(component, event, helper, selectedSheetIds,sheetId);
                }else{
                    helper.showErrorToast(component,event,helper,'Error!','Please select SOV ');
                }
                // }, 200);
            }
        });
        if(component.get("v.Iscommunity") == false){
            $A.enqueueAction(action); 
        }else{
            var selectedSheetIds = component.get("v.listOfSelectedRFQIds");
            var sheetId = component.get("v.recordId");
            if(selectedSheetIds.length>0){
                helper.importContinuationSheetItems(component, event, helper, selectedSheetIds,sheetId);
            }else{
                helper.showErrorToast(component,event,helper,'Error!','Please select SOV ');
            }
        }
        
    },
    selectAllRfq : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.rfqRecordList")));
        var getAllId = component.find("checkRFQ");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", true);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", true);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedRFQIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", false);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", false);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedRFQIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    
    
    selectRfq: function (component, event, helper) {
        var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.listOfSelectedRFQIds");
        var getAllId = component.find("checkRFQ");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckRFQ").get("v.checked")){
                    component.find("headCheckRFQ").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckRFQ").get("v.checked")){
                        component.find("headCheckRFQ").set("v.checked",true);
                    }
                }
            }
        }else{
            if(component.find("headCheckRFQ").get("v.checked")){
                component.find("headCheckRFQ").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedRFQIds",selectedRfqIds);
    },
    
    handleOnSubmit : function(component, event, helper) {
        console.log('handle submit');
           event.preventDefault();
        if(component.get("v.Iscommunity") == true){
            var inputname1 = component.find("inputname1#"); 
            var inputnameval1 = inputname1.get("v.value");
              var c =  inputnameval1.trim();
         /*   var inputproject = component.find("project#"); 
            var inputprojectval = inputproject.get("v.value"); */
            
           if(c != "" && c != null){
                var label = event.getSource().get("v.label");
                if(label == "Save and Import SOVs"){
                    component.set("v.iscall",true);
                }
                component.set("v.Spinner", true);
                
                /*component.set("v.message", true);*/
                
                
                if(component.get("v.Iscommunity") == true){
                    
                    component.set("v.IsBudgetLines",false);
                    
                  //Prevent default submit
                    var eventFields = event.getParam("fields"); //get the fields 
                    
                    eventFields['buildertek__Owner_Account__c'] = component.get("v.Vendorname"); 
                    component.find('leadCreateForm').submit(eventFields);
                    component.set("v.applicationValues",eventFields)
                    
                    
                    
                }else{
                    component.set("v.IsBudgetLines",true);
                    component.set("v.Spinner", false);
                    component.set("v.isOpen", true);
                    event.preventDefault(); //Prevent default submit
                    var eventFields = event.getParam("fields"); //get the fields
                    //  component.find('leadCreateForm').submit(eventFields);
                    component.set("v.applicationValues",eventFields) 
                    
                    
                }
                
            } else{
                
             //   if(inputnameval == "" || inputnameval == null){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'Payment application name is required',
                        duration: "3000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
              /*  }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'Project is required',
                        duration: "3000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
            } */
        }
        }
        else{
            console.log('inisde else condition');
            if(component.get("v.isOption4") != true && component.get("v.isOption5") != true){
                console.log('inisde sub if condition');
                var inputname = component.find("inputname#"); 
                var inputnameval = inputname.get("v.value");
                var a =  inputnameval.trim();
                console.log({a});
                if(a != "" && a != null){
                    var label = event.getSource().get("v.label");
                
                if(label == "Save and Import SOVs"){
                    component.set("v.iscall",true);
                }
                component.set("v.Spinner", true);
                            
                if(component.get("v.Iscommunity") == true){
                    
                    component.set("v.IsBudgetLines",false);
                    
                    event.preventDefault(); //Prevent default submit
                    var eventFields = event.getParam("fields"); //get the fields
                    component.find('leadCreateForm').submit(eventFields);
                    component.set("v.applicationValues",eventFields)
                    
                    
                    
                }else{                    
                    component.set("v.IsBudgetLines",false);
                    //Prevent default submit
                    var eventFields = event.getParam("fields"); //get the fields
                    console.log({eventFields});
                    component.find('leadCreateForm').submit(eventFields);
                    component.set("v.applicationValues",eventFields)

                    console.log(component.get("v.applicationValues"));

                    
                }
                }else{
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'Payment application name is required',
                        duration: "3000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('inisde sub else condition');
                var inputname = component.find("inputname#"); 
                var inputnameval = inputname.get("v.value");
                var a =  inputnameval.trim();
                if(a != "" && a != null){
                    var label = event.getSource().get("v.label");
                    
                    if(label == "Save and Import SOVs"){
                        component.set("v.iscall",true);
                    }
                    component.set("v.Spinner", true);
                    
                    /*component.set("v.message", true);*/
                    
                    
                    if(component.get("v.Iscommunity") == true){
                        
                        component.set("v.IsBudgetLines",false);
                        
                        event.preventDefault(); //Prevent default submit
                        var eventFields = event.getParam("fields"); //get the fields
                        //eventFields['buildertek__Owner_Account__c'] = accountId
                        component.find('leadCreateForm').submit(eventFields);
                        component.set("v.applicationValues",eventFields)
                        
                        
                        
                    }else{
                        /*component.set("v.IsBudgetLines",true);
                        component.set("v.Spinner", false);
                        component.set("v.isOpen", true);
                        event.preventDefault(); //Prevent default submit
                        var eventFields = event.getParam("fields"); //get the fields
                        //  component.find('leadCreateForm').submit(eventFields);
                        component.set("v.applicationValues",eventFields) */
                        
                        component.set("v.IsBudgetLines",false);
                        
                        //Prevent default submit
                        var eventFields = event.getParam("fields"); //get the fields
                        //eventFields['buildertek__Owner_Account__c'] = accountId
                        component.find('leadCreateForm').submit(eventFields);
                        component.set("v.applicationValues",eventFields)
                        
                    }
                }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'ERROR',
                            message: 'Payment application name is required',
                            duration: "3000",
                            key: "info_alt",
                            type: "error",
                            mode: "pester",
                        });
                        toastEvent.fire();
                    }
            
            }
        }
       
        
    },
    
    
    importCompanyApprovedSOvs : function(component, event, helper) {
        
        if(component.get("v.Iscommunity") == true){
            component.set("v.IsBudgetLines",false);
            component.set("v.IsActive",true);
            component.set("v.isnewpayment", false);
            
        }
    },
    
    saveSheetLines : function(component, event, helper) {
        var eventFields = component.get("v.applicationValues");
        component.find('leadCreateForm').submit(eventFields);
        /*var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();*/
        
    },
    
    ImportSOVs : function(component, event, helper) {
        var action = component.get("c.GetSheetid");
        component.set("v.isOpen", false);
        
        
        action.setParams({
            recordId : component.get("v.recordId") //component.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            if(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    
                    var overlayLib;
                    var modalBody;
                    var modalFooter;
                    $A.createComponents([
                        ["c:ImportMasterSovToPaymentApp",{
                            "recordId": result.Id,
                            "paymentAppId" : component.get("v.recordId"),
                            "cancelCallback": function () {
                                overlayLib.close();
                            }
                        }]
                    ],
                                        function(components, status){
                                            if (status === "SUCCESS") {
                                                modalBody = components[0];
                                                component.find('overlayLib').showCustomModal({
                                                    // header: 'Import Master SOVs',
                                                    body: modalBody,
                                                    footer: modalFooter,
                                                    showCloseButton: true,
                                                    cssClass: "my-modal,my-custom-class,my-other-class",
                                                    closeCallback: function () {}
                                                }).then(function (overlay) {
                                                    overlayLib = overlay;
                                                });
                                            }
                                        });
                }
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    handleOnSuccess : function(component, event, helper) {
        console.log('handle success');
        component.set("v.Spinner", false);
        component.set("v.message", false);
        component.set("v.isnewpayment",false);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var payload = event.getParams().response;
        console.log("record :    ",payload.id);
        component.set("v.recordId",payload.id)
        component.set("v.isOpen", true);
          component.set("v.storeId",payload.id)
        if(component.get("v.Iscommunity") == true){
            
            if(component.get("v.iscall") == true){
                component.set("v.IsActive",true);
                component.set("v.isnewpayment",false);
                helper.getRfqListApproved(component, event, helper, pageNumber, pageSize);
            }
            
            var action = component.get("c.saveCommunityUserId");
            action.setParams({
                recordId :  payload.id  ,
                commUserId : component.get("v.communityUserId")
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                }
            });
            $A.enqueueAction(action);
            if(component.get("v.iscall") == false){  
                //component.set("v.isnewpayment",false);
                //location.reload()
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": payload.id,
                    "slideDevName": "detail"
                });
                navEvt.fire();
                
                
                
            }
            
        }else{
          
            if(component.get("v.isuseSov")){
                component.set("v.isuseSov",false)
                var selectedSheetIds = component.get("v.listOfSelectedRFQIds")
                var sheetId = component.get("v.recordId");
                helper.importContinuationSheetItems2(component, event, helper, selectedSheetIds,sheetId);
            }
            if(component.get("v.iscreateNewSOV")){
                var action2 = component.get("c.deleteline");
                action2.setParams({
                    'recId' : component.get("v.recordId")
                })
                action2.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "detail"
                        });
                     
                        navEvt.fire();
                    }
                });
                $A.enqueueAction(action2);
            }
            if(component.get("v.isCompanyApprovedSOV") == true){
                component.set("v.isImportCompanyApproved",true);
                var action = component.get("c.getCompanyApprovedScheduleOValues");
                action.setParams({
                    "projectId" : component.get("v.parentprojectRecordId") 
                });
                action.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        var result = response.getReturnValue();
                        for(var i=0;i<result.length;i++){
                            
                            if(result[i].buildertek__Project__c){
                                result[i].buildertek__Project__c = result[i].buildertek__Project__r.Name;
                            }
                            
                        }
                        
                        component.set("v.ImportCompanyApprovedSOVsList",result);
                    }
                });
                $A.enqueueAction(action);
            }else{
                if(component.get("v.isOption4") == true){
             /*   var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(function (error) {
                    console.log('Error', JSON.stringify(error));
                }); */
             
                 component.set("v.isImportVendor",true);
            var action = component.get("c.getVendorPaymentApps");
            action.setParams({
                "projectId" : component.get("v.parentprojectRecordId") 
            });
            action.setCallback(this, function(response){
                
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                
                    for(var i=0;i<result.length;i++){
                        
                        if(result[i].buildertek__Owner_Account__c){
                            result[i].buildertek__Owner_Account__c = result[i].buildertek__Owner_Account__r.Name;
                            result[i].buildertek__Project__c = result[i].buildertek__Project__r.Name;
                        }
                        
                    }
                    component.set("v.ImportVendorPaymentAppsList",result);
                }
            });
            $A.enqueueAction(action);   
               /* setTimeout(function () {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": payload.id,
                        "slideDevName": "related" */
                        /*  "recordId": component.get("v.recordId"),
                "slideDevName": "related"*/
                /*    });
                    alert("Second nav")
                    navEvt.fire();
                }, 200); */
            }
                
                else{
                    if(component.get("v.isOption5") != true){
                
                     var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(function (error) {
                    console.log('Error', JSON.stringify(error));
                });
                    
                    setTimeout(function () {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": payload.id,
                        "slideDevName": "related" 
                        /*  "recordId": component.get("v.recordId"),
                "slideDevName": "related"*/
                    });
                  
                    navEvt.fire();
                }, 200);
                    }
                    else{
                     
                      
                         component.set("v.isImportCompanyApproved",true);
            var action = component.get("c.getCompanyApprovedScheduleOValues");
            action.setParams({
                "projectId" : component.get("v.parentprojectRecordId") 
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    for(var i=0;i<result.length;i++){
                        
                        if(result[i].buildertek__Project__c){
                            result[i].buildertek__Project__c = result[i].buildertek__Project__r.Name;
                        }
                        
                    }
                    
                    component.set("v.ImportCompanyApprovedSOVsList",result);
                }
            });
            $A.enqueueAction(action);
                        
                    }
                }
            // component.set("v.IsBudgetLines",false);
            //component.set("v.isOpen",false);
            // component.set("v.isnewpayment",false);
            }
              
        }
        
    }, 
    handleSub  : function(component, event, helper) {
        var label = event.getSource().get("v.label");
        
        if(label == "Save and Import SOVs"){
            component.set("v.iscall",true);
        }
    },
    
    closeEditPopup : function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.IsBudgetLines",false);
        component.set("v.isnew", false);
    },
    closeEditPopup1 : function(component, event, helper) {
        helper.closeEditPopup1(component, event, helper);
    },
    CloseScreen : function(component, event, helper) {
        console.log('close the screen');
        if(component.get("v.Iscommunity") == true){
            component.set("v.isnew", false);
            location.reload();
        }else{
            // component.set("v.isnew", true); 
            helper.closeEditPopup1(component, event, helper);
 
        }
        
        component.set("v.isnewpayment", false);
        //Find the text value of the component with aura:id set to "address"
        
        /*  var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'lightning/o/buildertek__SOV_Payment_Application__c/home'
        });
        urlEvent.fire();*/
    },
    
    useMasterSov : function(component, event, helper) {
        component.set("v.isnew", false);
        component.set("v.isOpen", false);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var recordId = component.get("v.recordId");
        console.log(component.get("v.recordId"));
        helper.getSOVList(component, event, helper, pageNumber, pageSize);
        
    },
    CreateNewSov : function(component, event, helper) {
       
        component.set("v.iscreateNewSOV",true);
        component.find('leadCreateForm').submit( component.get("v.applicationValues"));
      
    },
    
    
    importSOVSheetLines: function (component, event, helper) {  
        var selectedSheetIds = component.get("v.listOfSelectedRFQIds")
        var sheetId = component.get("v.recordId");
        component.find('leadCreateForm').submit( component.get("v.applicationValues"));
        component.set("v.isuseSov",true)
        // helper.importContinuationSheetItems2(component, event, helper, selectedSheetIds,sheetId);
    },  
    selectAllPayApp : function (component, event, helper) {
        
        // debugger;
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.ImportVendorPaymentAppsList")));
        var getAllId = component.find("checkPayApp");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkPayApp").set("v.checked", true);
                    var Id = component.find("checkPayApp").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkPayApp")[i].set("v.checked", true);
                        var Id = component.find("checkPayApp")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedRFQIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkPayApp").set("v.checked", false);
                    var Id = component.find("checkPayApp").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkPayApp")[i].set("v.checked", false);
                        var Id = component.find("checkPayApp")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedRFQIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    selectPayApp: function (component, event, helper) {
        var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.listOfSelectedRFQIds");
        var getAllId = component.find("checkPayApp");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckPayApp").get("v.checked")){
                    component.find("headCheckPayApp").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckPayApp").get("v.checked")){
                        component.find("headCheckPayApp").set("v.checked",true);
                    }
                }
            }
        }else{
            if(component.find("headCheckPayApp").get("v.checked")){
                component.find("headCheckPayApp").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedRFQIds",selectedRfqIds);
    },
    importPaymentApp : function (component, event, helper) {
        component.set("v.Spinner2",true);
        var recIds = component.get("v.listOfSelectedRFQIds");
      //  var action = component.get("c.createlines");
           var action = component.get("c.getPARecord");
        // var appId = component.get("v.paymentAppId");
        action.setParams({
         //   "projectId" : component.get("v.parentprojectRecordId"),
         //   "RecordTypeId" : component.get("v.RecordTypeId"),
            "recordId" : component.get("v.recordId")
        })
        
        action.setCallback(this, function(response) {
          
            var state = response.getState();
            var result = response.getReturnValue();
            var redirectId = response.getReturnValue().Id;
            if (state === "SUCCESS") {
              
                var action2 = component.get("c.importPaymentApps");
                action2.setParams({
                    idList : component.get("v.listOfSelectedRFQIds"),
                    paymentId : redirectId
                })
                action2.setCallback(this, function(response) {
                    var state = response.getState();
                    var result = response.getReturnValue();
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({
                            tabId: focusedTabId
                        });
                    }).catch(function (error) {
                        console.log('Error', JSON.stringify(error));
                    });
                    setTimeout(function () {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": redirectId,
                            "slideDevName": "related"
                            /*"recordId": redirectId,
                        "slideDevName": "detail"*/
                    });
                        navEvt.fire();
                    }, 200);
                    component.set("v.Spinner2",false);
                });
                if(component.get("v.listOfSelectedRFQIds").length != 0){
                    $A.enqueueAction(action2);
                }else{
                    component.set("v.Spinner2",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'No payment applications are selected.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
                
            } 
        }); 
        $A.enqueueAction(action);
    },
    
    importCompanyApprovedLines : function (component, event, helper) {
        // debugger;
        console.log("recordId 2 : ",component.get("v.recordId"));
        if(component.get("v.isCompanyApprovedSOV") == true){
            var action2 = component.get("c.importCompanyApprovedSOVLines");
            
            action2.setParams({
                Id : component.get("v.listOfSelectedRFQIds"),
                recordId : component.get("v.recordId")
            })
            action2.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    }).then(function (response) {
                        
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/"+component.get("v.recordId")
                        });
                        urlEvent.fire();
                    });
                }).catch(function (error) {
                    console.log('Error', JSON.stringify(error));
                });
                
                
                component.set("v.Spinner2",false);
            });
            if(component.get("v.listOfSelectedRFQIds").length != 0){
                $A.enqueueAction(action2);
            }else{
                component.set("v.Spinner2",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'ERROR',
                    message: 'No SOVs are selected.',
                    duration: "5000",
                    key: "info_alt",
                    type: "error",
                    mode: "pester",
                });
                toastEvent.fire();
            }
            
            
        }else{
            /*var action = component.get("c.importCompanyApprovedSOVLines");
        // var appId = component.get("v.paymentAppId");
        action.setParams({
           Id : component.get("v.listOfSelectedRFQIds"),
           recordId : component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
              
            }else{
                
            }
            
        }); 
        $A.enqueueAction(action);*/
            
            
            
        
            component.set("v.Spinner2",true);
            var recIds = component.get("v.listOfSelectedRFQIds");
         //   var action = component.get("c.createlines");
             var action = component.get("c.getPARecord");
            // var appId = component.get("v.paymentAppId");
            action.setParams({
              //  "projectId" : component.get("v.parentprojectRecordId"),
              //  "RecordTypeId" : component.get("v.RecordTypeId"),
                "recordId" : component.get("v.recordId")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
             
                var redirectId = response.getReturnValue().Id;
                if (state === "SUCCESS") {
                    var action2 = component.get("c.importCompanyApprovedSOVLines");
                    action2.setParams({
                        Id : component.get("v.listOfSelectedRFQIds"),
                        recordId : redirectId,
                    })
                    action2.setCallback(this, function(response) {
                        var state = response.getState();
                        var result = response.getReturnValue();
                      
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({
                                tabId: focusedTabId
                            });
                        }).catch(function (error) {
                            console.log('Error', JSON.stringify(error));
                        });
                        setTimeout(function () {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": redirectId,
                                "slideDevName": "related"
                                /*"recordId": redirectId,
                        "slideDevName": "detail"*/
                        });
                        navEvt.fire();
                    }, 200);
                    component.set("v.Spinner2",false);
                });
                if(component.get("v.listOfSelectedRFQIds").length != 0){
                    $A.enqueueAction(action2);
                }else{
                    component.set("v.Spinner2",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'No SOVs are selected.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
                
            } 
        }); 
            $A.enqueueAction(action);
            
        }   
    },
    importCompanyApprovedSOVs : function (component, event, helper) {
        component.set("v.isCompanyApprovedSOV",true);
        component.find('leadCreateForm').submit( component.get("v.applicationValues"));
        
    },
    
    
    importCustomerApprovedLines : function (component, event, helper) {
        // debugger;
        if(component.get("v.isCustomerApprovedSOV") == true){
            var action2 = component.get("c.importCustomerApprovedSOVLines");
            
            action2.setParams({
                Id : component.get("v.listOfSelectedRFQIds"),
                recordId : component.get("v.recordId")
            })
            action2.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    }).then(function (response) {
                       
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/"+component.get("v.recordId")
                        });
                        urlEvent.fire();
                    });
                }).catch(function (error) {
                    console.log('Error', JSON.stringify(error));
                });
                
                
                component.set("v.Spinner2",false);
            });
            if(component.get("v.listOfSelectedRFQIds").length != 0){
                $A.enqueueAction(action2);
            }else{
                component.set("v.Spinner2",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'ERROR',
                    message: 'No SOVs are selected.',
                    duration: "5000",
                    key: "info_alt",
                    type: "error",
                    mode: "pester",
                });
                toastEvent.fire();
            }
            
            
        }else{
           
            
            component.set("v.Spinner2",true);
            var recIds = component.get("v.listOfSelectedRFQIds");
            var action = component.get("c.createlines");
            action.setParams({
                "projectId" : component.get("v.parentprojectRecordId"),
                "RecordTypeId" : component.get("v.RecordTypeId"),
            })
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                var redirectId = response.getReturnValue().Id;
                if (state === "SUCCESS") {
                    var action2 = component.get("c.importCustomerApprovedSOVLines");
                    action2.setParams({
                        Id : component.get("v.listOfSelectedRFQIds"),
                        recordId : result.Id
                    })
                    action2.setCallback(this, function(response) {
                        var state = response.getState();
                        var result = response.getReturnValue();
                        
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({
                                tabId: focusedTabId
                            });
                        }).catch(function (error) {
                            console.log('Error', JSON.stringify(error));
                        });
                        setTimeout(function () {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": redirectId,
                                "slideDevName": "related"
                               
                        });
                        navEvt.fire();
                    }, 200);
                    component.set("v.Spinner2",false);
                });
                if(component.get("v.listOfSelectedRFQIds").length != 0){
                    $A.enqueueAction(action2);
                }else{
                    component.set("v.Spinner2",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'No SOVs are selected.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
                
            } 
        }); 
            $A.enqueueAction(action);
            
        }   
    },

    redirectToPaymentModal :function(component, event, helper) {    
        component.set("v.isnew", false);
        component.set("v.IsActive", false);
        component.set("v.isnewpayment", true);
        component.set("v.isImportCompanyApproved", false);
        component.set("v.isUseMasterSOV", false);
        component.set("v.isImportVendor", false);
    }, 
    
})