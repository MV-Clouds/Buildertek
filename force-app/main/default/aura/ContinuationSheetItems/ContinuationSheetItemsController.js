({
    doInit : function(component, event, helper) {
        
        
         helper.getcurr(component, event, helper);
         helper.getrelatedrfqvendorlist(component, event, helper);
         helper.getIsCOEnable(component, event, helper);

    
        component.set("v.Spinner", true);
        var action = component.get("c.getCommUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    component.set("v.isCommUser",true);
                    var loc = location.href.split('id=')[1];
                    
                    var recordId = location.href.split('id=')[1].split('&userIdFromcommunity=')[0];
                    component.set("v.recordId",recordId)
                }else{
                    component.set("v.isCommUserforpay",true);
                    //  helper.getPaymentRec(component, event, helper);
                }
                
            }
        })
        $A.enqueueAction(action);
        
        //for community
        if(location.href.includes('userIdFromcommunity')){
            var loc = location.href.split('id=')[1];
            var recordId = location.href.split('id=')[1].split('&userIdFromcommunity=')[0];
            var commUserId = location.href.split('id=')[1].split('&userIdFromcommunity=')[1].split("&dummy=")[0];
            
            component.set("v.commUserId",commUserId)
            component.set("v.commrecordId",recordId)
            component.set("v.recordIdClone",recordId);
        }else{
            // for salesforce
            var myPageRef = component.get("v.pageReference");
            var recordId = myPageRef.state.buildertek__parentId;
            
            component.set("v.ClonerecordId",recordId);
            component.set("v.recordIdClone",recordId);
            if(!recordId){
                recordId = component.get("v.recordId");
                component.set("v.recordIdClone",recordId);
                
            }
            var isFromBudget = myPageRef.state.buildertek__isFromBudget;
            component.set("v.isFromBudget",isFromBudget);
            
        }
        
        debugger;
        var action2 = component.get("c.isSovSubmitted");
        var recId = component.get("v.commrecordId")
        if(!recId){
            var recId = component.get("v.ClonerecordId")
            }
        action2.setParams({
            recordId: recId
        });
        action2.setCallback(this, function(response){
            debugger;
            if(response.getState() === "SUCCESS"){
                
                var result = response.getReturnValue();
                if( result.buildertek__Status__c == "Customer Accepted"){
                    component.set("v.iscustomeraccepted",true);
                }
                if( result.buildertek__Status__c == "Company Accepted" || result.buildertek__Status__c == "Company Paid" || result.buildertek__Status__c == "Customer Accepted" ||  result.buildertek__Status__c == "Customer Paid"){
                    component.set("v.DisableonStatus",true);
                  //  component.set("v.IsSubmitted",true);
                    if(result.buildertek__Status__c == "Customer Accepted" || result.buildertek__Status__c == "Company Accepted" || result.buildertek__Status__c == "Company Paid" || result.buildertek__Status__c == "Customer Paid"){
                        component.set("v.disableImportButton",true);
                    }
                }
                if(result.RecordType.Name == 'AR'){
                    component.set("v.isPATypeApp", true);
                }
                if(result.buildertek__Status__c == "Vendor Submitted" || result.buildertek__Status__c == "Company Accepted" ||  result.buildertek__Status__c == "Customer Accepted"){
                    component.set("v.IsSubmitted", true)
                }
            }
        });
        $A.enqueueAction(action2);
        debugger;
        var action = component.get("c.getContinuationSheetLines");
        action.setParams({
            recordId : recordId //component.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                
                debugger;
                var result = response.getReturnValue();
                var sortedSheetLines = result.sheetLines;
              //  alert(sortedSheetLines);
                var Retainage = result.workFromPrevAppTotal + result.workcompletedTotal + result.materialsStoredTotal ;
                if(result.continuationSheet){
                    if (result.continuationSheet.buildertek__SOV_Payment_Application__c != null && result.continuationSheet.buildertek__SOV_Payment_Application__c != '') {
                        if(result.continuationSheet.buildertek__SOV_Payment_Application__r.RecordType.Name == 'PaymentApplication'){
                            component.set("v.isARPaymentApp", true);
                        }
                    
                        if(result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Application__c >= 2){
                          component.set("v.isARPaymentAppImportAvailable", true);
                        }
                    }
                    
                }
                debugger;
                component.set("v.continuationSheet", result.continuationSheet);
                component.set("v.continuationSheetLines", sortedSheetLines);         
                component.set("v.scheduleValueTotal", result.scheduleValueTotal);
                component.set("v.workFromPrevAppTotal", result.workFromPrevAppTotal);
                component.set("v.workcompletedTotal", result.workcompletedTotal);
                component.set("v.materialsStoredTotal", result.materialsStoredTotal);
                component.set("v.totalCompletedStored", result.totalCompletedStored);
             
                component.set("v.gcTotal", result.gcTotal);
                component.set("v.projectId", result.projectId);
                
                if(result.continuationSheet.buildertek__SOV_Payment_Application__r){
                    if(result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Retainage__c){
                        component.set("v.Retainage", result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Retainage__c);
                    }else{
                        component.set("v.Retainage", 0);
                    } 
                }else{
                    component.set("v.Retainage", 0);
                }
                var totalRetainage =  (result.workFromPrevAppTotal+result.workcompletedTotal+result.materialsStoredTotal)*component.get("v.Retainage")/100;
                component.set("v.totalRetainagePercent",totalRetainage)
                component.set("v.paymentappName", result.continuationSheet.buildertek__SOV_Payment_Application__r ? result.continuationSheet.buildertek__SOV_Payment_Application__r.Name : '');
                component.set("v.ApplicationNo", result.continuationSheet.buildertek__SOV_Payment_Application__r ? result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Application__c : '');
                component.set("v.Applicationdate", result.continuationSheet.buildertek__SOV_Payment_Application__r ? result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Submission_Date__c : '');
                
                component.set("v.WorkCompletedTotal", result.continuationSheet.buildertek__SOV_Payment_Application__r ? result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Total_Completed__c : '');
                
                if (result.continuationSheet.buildertek__SOV_Payment_Application__c != null && result.continuationSheet.buildertek__SOV_Payment_Application__c != '') {
                    if(result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Status__c == 'Vendor Submitted'
                       || result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Status__c == 'Partially Rejected'){
                        component.set("v.ispending", true);
                    }
                    if(result.continuationSheet.buildertek__SOV_Payment_Application__r){
                        if(result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Architect__c){
                            component.set("v.Architect", result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Architect__r.Name);
                        }else{
                            component.set("v.Architect", '');
                        }
                    }else{
                        component.set("v.Architect", '');
                    }
                }
                
                component.set("v.PeriodTo", result.continuationSheet.buildertek__SOV_Payment_Application__r ? result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Period_To__c : '');
                component.set("v.balanceTotal", result.balanceTotal);
                debugger;
                component.set("v.continuationSheetId",  result.continuationSheet.Id);
                component.set("v.isApplication", result.isApplication);
                if(result.sheetLines){
                    helper.groupRecords(component, event, helper);
                }
                component.set("v.Spinner", false);
                
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Continuation Sheet Details",
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "custom:custom5",
                        iconAlt: "Continuation Sheet Details"
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
                
            }  
            else{
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Continuation Sheet Details",
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "custom:custom5",
                        iconAlt: "Continuation Sheet Details"
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        });
        
        $A.enqueueAction(action);
        
    },
    onClickAddCSlines : function(component, event, helper) {
        component.set('v.isCSline', true); 
        component.set('v.Spinner', false); 
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields = JSON.parse(response.getReturnValue());
                component.set("v.listOfFields", listOfFields);
                // component.find("Name").set("v.autocomplete","off");
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
        var recordId = component.get("v.continuationSheetId");
    },
    closeCSline : function(component, event, helper) {
        component.set('v.isCSline', false); 
        $A.get('e.force:refreshView').fire();
    },
    handleSubmit: function (component, event, helper) {
        debugger;
        
        component.set("v.Spinner", true); 
        
        var fields = event.getParam("fields");
       
        event.preventDefault(); // Prevent default submit
        if(component.get("v.isSaveAndNew")){
            
            var sheetLineToInsert = JSON.stringify(fields);
            var action = component.get("c.insertSheetLine")
          
            action.setParams({
                sheetLineToInsert : sheetLineToInsert,
                recordId : component.get("v.recordIdClone")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    
                    console.log(response.getReturnValue());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Continuation Sheet Line created successfully',
                        messageTemplate: "Continuation Sheet Line created successfully.",
                        type: 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    var addCsLineAction = component.get("c.onClickAddCSlines");
                    $A.enqueueAction(addCsLineAction);
                }
            })
            $A.enqueueAction(action); 
            
            var status;
            var action2 = component.get("c.getPaymentAppStatus");
            action2.setParams({
                recordId : component.get("v.recordIdClone")
            });
            action2.setCallback(this, function(response){
                var result = response.getReturnValue();
                if(response.getState() === "SUCCESS"){
                    component.set("v.Spinner",false);
                    if(result != "Customer Paid" && result != "Owner Paid"){
                      //  $A.enqueueAction(action);
                    }else{
                        component.find("notifLib").showToast({ "variant":"error", "title": "Error", "message": "You cannot Edit this Payment Application, because it has Already "+result });
                    }
                    
                }
            });
            $A.enqueueAction(action2);   
            
        }else{
            debugger;
          //  component.find('recordViewForm').submit(fields); 
           
           var fields = event.getParam("fields");
            
            event.preventDefault();
            
            
              var sheetLineToInsert = JSON.stringify(fields);
            var action = component.get("c.insertSheetLine")
           
            action.setParams({
                sheetLineToInsert : sheetLineToInsert,
                recordId : component.get("v.recordIdClone")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    
                    component.set("v.Spinner",false);
                    component.set('v.isCSline', false);
                     $A.get('e.force:refreshView').fire();
                    
                    console.log(response.getReturnValue());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Continuation Sheet Line created successfully',
                        messageTemplate: "Continuation Sheet Line created successfully.",
                        type: 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    var addCsLineAction = component.get("c.onClickAddCSlines");
                    $A.enqueueAction(addCsLineAction);
                }
            })
            $A.enqueueAction(action); 
            component.get("v.isSaveAndNew",false);
            
        } 
        
    },
    onRecordSuccess: function (component, event, helper) {
        
        debugger;
        
        component.set("v.Spinner", false);
        var payload = event.getParams().response;
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('/', 14));
        var toastEvent = $A.get("e.force:showToast");
        var recordId = payload.id;
        toastEvent.setParams({
            mode: 'sticky',
            message: 'Continuation Sheet Line created successfully',
            messageTemplate: "Continuation Sheet Line created successfully.",
            type: 'success',
            duration: '10000',
            mode: 'dismissible'
        });
        toastEvent.fire();
        component.set('v.isCSline', false);
        
        if(component.get("v.isSaveAndNew")){
            //$A.get('e.force:refreshView').fire();
            /*var doinitAction = component.get("c.doInit");
            $A.enqueueAction(doinitAction);*/
            var addCsLineAction = component.get("c.onClickAddCSlines");
            $A.enqueueAction(addCsLineAction);
            //component.set('v.isCSline', true);
        }else{
            $A.get('e.force:refreshView').fire();
        }
        component.get("v.isSaveAndNew",false);
        /* var sheetLineItems = component.get("v.continuationSheetLines");
            sheetLineItems.splice(recordId);
            component.set("v.continuationSheetLines",sheetLineItems);*/
    },
    
    
    handleError : function(component, event, helper) {
        var error = event.getParam("error");
        console.log(error);
        var status;
        var action = component.get("c.getPaymentAppStatus");
        action.setParams({
            recordId : component.get("v.recordIdClone")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(response.getState() === "SUCCESS"){
                component.set("v.Spinner",false);
                status = result;
                if(status == "Customer Paid" || status == "Owner Paid"){
                    component.find("notifLib").showToast({ "variant":"error", "title": "Error", "message": "You cannot Edit this Payment Application, because it has Already "+status });
                }else{
                    component.find("notifLib").showToast({ "variant":"error", "title": "Unexpected Error Here", "message": "A message that you want to show. Can place some error attributes if you need" }); 
                }
            }else{
                
            }
            
        });
        $A.enqueueAction(action);
        
        // component.find("notifLib").showToast({ "variant":"error", "title": "Unexpected Error Here", "message": "A message that you want to show. Can place some error attributes if you need" });
    },
    
    
    massUpdate : function(component, event, helper) {
        component.set("v.editLines", true);    
    },
    
    closeModel : function(component, event, helper) {
       if(component.get("v.isCommUser") == true){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "related"
            });
            navEvt.fire();
        } 
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            var myPageRef = component.get("v.pageReference");
            var recordId = myPageRef.state.buildertek__parentId;
            if(!recordId){
                recordId = component.get("v.recordId");
                /*if(!recordId){
                    recordId = myPageRef.attributes.recordId
                }*/
            }
           /* workspaceAPI.openTab({
                url: '/'+recordId,
                focus: true
            });*/
        }).catch(function(error) {
            console.log(error);
        });
      
    },
    
    updateContinuationSheetLines : function(component, event, helper) {
        component.set("v.Spinner", true);
        
        component.set("v.isError", false);
        var updatedLines = component.get("v.continuationSheetLines");
        
        for(var i=0;i < updatedLines.length;i++){
            if(updatedLines[i].buildertek__Description_of_Work__c == undefined){
                component.set("v.isDescription", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Please fill in the Description of work.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            } else if(updatedLines[i].buildertek__Scheduled_Value__c == 0){
                component.set("v.isDescription", true);
                var toastEvent1 = $A.get("e.force:showToast");
                toastEvent1.setParams({
                    message: 'Please fill in the Schedule Values.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent1.fire();
            }else{
                component.set("v.isDescription", false); 
            }
            
        }
        if(component.get("v.isDescription") == false){
            debugger;
            var action = component.get("c.updateSheetLines");
            action.setParams({
                sheetLines : JSON.stringify(updatedLines),
                sheetId : component.get("v.continuationSheet").Id,
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    
                    var result = response.getReturnValue();
                    if(result.isSuccess == true){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Continuation Sheet Lines updated Successfully',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        component.set("v.Spinner", false);
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Description of work cannot be empty',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'Error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", false);
                    }
                } 
                
            });
            $A.enqueueAction(action);
        }
    },
    
    
    
    updateContinuationSheetLinesInGrp : function(component, event, helper) {
        component.set("v.Spinner", true);
        
        component.set("v.isError", false);
        
        if(component.get("v.isGCPercent") == true ){
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: '',
                message: 'G/C field must be less than or equal to 100%.',
                duration: "5000",
                key: "info_alt",
                type: "error",
                mode: "pester",
            });
            toastEvent.fire();
        }else{
                var updatedLinesInGroup = component.get("v.groupedRecords");
        var updatedLines = [];
        if(updatedLinesInGroup && updatedLinesInGroup != "{}"){
            for(var pindex=0; pindex<updatedLinesInGroup.length; pindex++){
                var subgrpRecords = updatedLinesInGroup[pindex].subGroupRecords;
                for(var sunindex =0; sunindex<subgrpRecords.length;sunindex++){
                    var records = subgrpRecords[sunindex].records;
                    for(var recIndex = 0 ; recIndex < records.length;recIndex++){
                        updatedLines.push(records[recIndex]);
                    }
                }
            }
        }
        console.log(updatedLines);
        if(updatedLines.length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: 'No lines to save',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            component.set("v.Spinner", false);
        }
        for(var i=0;i < updatedLines.length;i++){
            if(updatedLines[i].buildertek__Description_of_Work__c == undefined){
                component.set("v.isDescription", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Please fill in the Description of work.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.Spinner", false);
            }else{
                component.set("v.isDescription", false); 
            }
            
        }
        if(component.get("v.isDescription") == false && updatedLines.length){
           
            var action = component.get("c.updateSheetLines");
            action.setParams({
                sheetLines : JSON.stringify(updatedLines),
                sheetId : component.get("v.continuationSheet").Id,
                recordId : component.get("v.recordIdClone")
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    if(result.isSuccess == true){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Continuation Sheet Lines updated Successfully',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        component.set("v.Spinner", false);
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Description of work cannot be empty',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'Error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", false);
                       
                    }
                } 
                
            });
            $A.enqueueAction(action);
        } 
        }
   
        
        
    },
    
    
    onChangeValue : function(component, event, helper) {
        
        var updateFormulaAction = component.get('c.updateFormula');
        var navEvt = $A.get("e.force:navigateToSObject");
        var fieldName = event.getSource().getLocalId();
        updateFormulaAction.setParams({
            'sheetItemId' : component.get("v.continuationSheetLineId"),
            'recordId' : component.get("v.recordId"),
            'sheetId' : component.get("v.continuationSheet").Id,
            'fieldName' :  event.getSource().getLocalId(),
            'fieldValue' :  (event.getSource().get("v.value")!='')?event.getSource().get("v.value"):0
            
        });
        updateFormulaAction.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                component.set("v.continuationSheetLines", response.getReturnValue());
                
            }
        });
        $A.enqueueAction(updateFormulaAction);
    },
    
    changeValue : function(component, event, helper) {
        var recordId = event.getSource().get("v.name");
        var sheetLines = component.get("v.continuationSheetLines");
        var localId = event.getSource().getLocalId();
        var value = event.getSource().get("v.value");
        
        var workCompletedThisPeriod
        var materialPresentlyStored
        var inputField = event.getSource();
        
        if(localId == "buildertek__Work_Completed__c"){
            
            workCompletedThisPeriod = event.getSource().get("v.value");
        }
        
        if(localId == "buildertek__Material_Presently_Stored__c"){
            
            materialPresentlyStored = event.getSource().get("v.value");
        }
        
        
        for(var i=0;i<sheetLines.length;i++){
            if(recordId == sheetLines[i].Id){
                if(!value){
                    value = 0;
                }
                if(localId == "buildertek__Scheduled_Value__c"){
                    sheetLines[i].buildertek__Scheduled_Value__c = parseInt(value);
                }
                if(localId == "buildertek__Work_Completed_from_Previous_Application__c"){
                    sheetLines[i].buildertek__Work_Completed_from_Previous_Application__c = parseInt(value);
                }
                if(localId == "buildertek__Work_Completed__c"){
                    sheetLines[i].buildertek__Work_Completed__c = parseInt(value);   
                }
                if(localId == "buildertek__Material_Presently_Stored__c"){
                    sheetLines[i].buildertek__Material_Presently_Stored__c = parseInt(value);
                }
                sheetLines[i].buildertek__Total__c = parseInt(sheetLines[i].buildertek__Material_Presently_Stored__c) + parseInt(sheetLines[i].buildertek__Work_Completed_from_Previous_Application__c) + parseInt(sheetLines[i].buildertek__Work_Completed__c);
                sheetLines[i].buildertek__G_C__c = (parseInt(sheetLines[i].buildertek__Total__c) / parseInt(sheetLines[i].buildertek__Scheduled_Value__c))*100;
                sheetLines[i].buildertek__Balance_To_Finish__c = parseInt(sheetLines[i].buildertek__Scheduled_Value__c) - parseInt(sheetLines[i].buildertek__Total__c);
                
                var balToFinish2 = parseInt(sheetLines[i].buildertek__Scheduled_Value__c) - (parseInt(sheetLines[i].buildertek__Total__c)-workCompletedThisPeriod);                
                var balToFinish22 = parseInt(sheetLines[i].buildertek__Scheduled_Value__c) - (parseInt(sheetLines[i].buildertek__Total__c)-materialPresentlyStored);                

                if(localId == "buildertek__Work_Completed__c"){
                    if(workCompletedThisPeriod > balToFinish2){
                        inputField.setCustomValidity("Work Completed This Period must be less than Balance To Finish");
                       // component.set("v.IsSaveDisable",true);
                    }else{
                        inputField.setCustomValidity("");
                       // component.set("v.IsSaveDisable",fales);
                    }   
                }
                
                if(localId == "buildertek__Material_Presently_Stored__c"){
                    if(materialPresentlyStored > balToFinish22){
                        inputField.setCustomValidity("Material Presently Stored must be less than Balance To Finish");
                        // component.set("v.IsSaveDisable",true);
                    }else{
                        inputField.setCustomValidity("");
                        // component.set("v.IsSaveDisable",fales);
                    }   
                }
                
            }else if(recordId != null){
                var index = recordId.split("_")[1];
                if(sheetLines[index]){
                    if(!value){
                        value = 0;
                    }
                    if(localId == "buildertek__Scheduled_Value__c"){
                        sheetLines[index].buildertek__Scheduled_Value__c = parseInt(value);
                    }
                    if(localId == "buildertek__Work_Completed_from_Previous_Application__c"){
                        sheetLines[index].buildertek__Work_Completed_from_Previous_Application__c = parseInt(value);
                    }
                    if(localId == "buildertek__Work_Completed__c"){
                        sheetLines[index].buildertek__Work_Completed__c = parseInt(value);
                    }
                    if(localId == "buildertek__Material_Presently_Stored__c"){
                        sheetLines[index].buildertek__Material_Presently_Stored__c = parseInt(value);
                    }
                    sheetLines[index].buildertek__Total__c = parseInt(sheetLines[index].buildertek__Material_Presently_Stored__c) + parseInt(sheetLines[index].buildertek__Work_Completed_from_Previous_Application__c) + parseInt(sheetLines[index].buildertek__Work_Completed__c);
                    sheetLines[index].buildertek__G_C__c = (parseInt(sheetLines[index].buildertek__Total__c) / parseInt(sheetLines[index].buildertek__Scheduled_Value__c))*100;
                    sheetLines[index].buildertek__Balance_To_Finish__c = parseInt(sheetLines[index].buildertek__Scheduled_Value__c) - parseInt(sheetLines[index].buildertek__Total__c);
                    
                    var balToFinish1 = parseInt(sheetLines[index].buildertek__Scheduled_Value__c) - (parseInt(sheetLines[index].buildertek__Total__c)-workCompletedThisPeriod); 
                    var balToFinish11 = parseInt(sheetLines[index].buildertek__Scheduled_Value__c) - (parseInt(sheetLines[index].buildertek__Total__c)-materialPresentlyStored); 

                    if(localId == "buildertek__Work_Completed__c"){
                        if(workCompletedThisPeriod > balToFinish1){
                            inputField.setCustomValidity("Work Completed This Period must be less than Balance To Finish");
                          //  component.set("v.IsSaveDisable",true);
                        }else{
                            inputField.setCustomValidity("");
                           // component.set("v.IsSaveDisable",false);
                        }
                    }
                     if(localId == "buildertek__Material_Presently_Stored__c"){
                    if(materialPresentlyStored > balToFinish11){
                        inputField.setCustomValidity("Material Presently Stored must be less than Balance To Finish");
                        // component.set("v.IsSaveDisable",true);
                    }else{
                        inputField.setCustomValidity("");
                        // component.set("v.IsSaveDisable",fales);
                    }   
                }
                }
            } 
        }
        component.set("v.continuationSheetLines", sheetLines);
    },
    
    
    changeValueInGrp : function(component, event, helper) {
        debugger;
        var recordId = event.getSource().get("v.name");
        component.set("v.IsbuttonDisable", false);
        var linesInGroup = component.get("v.groupedRecords")
        
        var localId = event.getSource().getLocalId();
        var value = event.getSource().get("v.value");
        event.getSource().set("v.value",value)
        
        var workCompletedThisPeriod
        var inputField = event.getSource();
        
        if(localId == "buildertek__Work_Completed__c"){
            workCompletedThisPeriod = event.getSource().get("v.value");
        }
        
         var materialPresentlyStored
        
        if(localId == "buildertek__Material_Presently_Stored__c"){
            materialPresentlyStored = event.getSource().get("v.value");
        }
        
        
        var updatedLinesInGroup = component.get("v.groupedRecords");
        var updatedLines = [];
        
        if(recordId.indexOf('customrec_') > -1){
            var index = recordId.split("customrec_")[1];
            var parentGrpIndex = Number(index.split("_")[0])
            var subGrpIndex = Number(index.split("_")[1])
            var recIndex = Number(index.split("_")[2])
       
            if(updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex]){
                var recordItem = updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex];
                if(!value){
                    value = 0;
                }
                
                if(component.get("v.isCommUser") == true){
                    if(localId == "buildertek__Scheduled_Value__c"){
                        updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Scheduled_Value__c = parseInt(value);
                    }  
                }else{
                    if(localId == "buildertek__Scheduled_Value__c"){
                        updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Scheduled_Value__c = parseInt(value);
                    } 
                }
                
                
                if(component.get("v.isCommUser") == true){
                    if(localId == "buildertek__Work_Completed_from_Previous_Application__c"){
                        updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Vendor_Work_Completed_from_Previous_Appl__c = parseInt(value);
                    } 
                }else{
                    if(localId == "buildertek__Work_Completed_from_Previous_Application__c"){
                        updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Work_Completed_from_Previous_Application__c = parseInt(value);
                    }
                }
                
                if(component.get("v.isCommUser") == true){
                    if(localId == "buildertek__Work_Completed__c"){
                        updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Vendor_Work_Completed_This_Period__c = Number(value);
                    }
                }else{
                    if(localId == "buildertek__Work_Completed__c"){
                        updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Work_Completed__c = Number(value);
                    }  
                }
                
                if(component.get("v.isCommUser") == true){
                    if(localId == "buildertek__Material_Presently_Stored__c"){
                        updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Vendor_Material_Presently_Stored__c = parseFloat(value);
                    }
                }else{
                    if(localId == "buildertek__Material_Presently_Stored__c"){
                        updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Material_Presently_Stored__c = parseFloat(value);
                    } 
                }
                
                if(component.get("v.isCommUser") == true){
                    updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Vendor_Total__c = parseFloat(recordItem.buildertek__Vendor_Material_Presently_Stored__c) + parseInt(recordItem.buildertek__Vendor_Work_Completed_from_Previous_Appl__c) + parseFloat(recordItem.buildertek__Vendor_Work_Completed_This_Period__c);
                    var gcPercent =  (parseInt(recordItem.buildertek__Vendor_Total__c) / parseInt(recordItem.buildertek__Scheduled_Value__c))*100;
                    updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Vendor_G_C__c = gcPercent.toFixed(2);
                    updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Vendor_Balance_To_Finish__c = Number(recordItem.buildertek__Scheduled_Value__c) - Number(recordItem.buildertek__Vendor_Total__c);
                    
                }else{
                    updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Total__c = parseFloat(recordItem.buildertek__Material_Presently_Stored__c) + parseInt(recordItem.buildertek__Work_Completed_from_Previous_Application__c) + parseFloat(recordItem.buildertek__Work_Completed__c);
                    var gcPercent =  (parseInt(recordItem.buildertek__Total__c) / parseInt(recordItem.buildertek__Scheduled_Value__c))*100;
                    updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__G_C__c = gcPercent.toFixed(2);
                    updatedLinesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].buildertek__Balance_To_Finish__c = Number(recordItem.buildertek__Scheduled_Value__c) - Number(recordItem.buildertek__Total__c);
                    
                }
                
                if(component.get("v.isCommUser") == true){
                    var balToFinish = Number(recordItem.buildertek__Scheduled_Value__c) - (Number(recordItem.buildertek__Vendor_Total__c)-workCompletedThisPeriod);
                    var balToFinish45 = Number(recordItem.buildertek__Scheduled_Value__c) - (Number(recordItem.buildertek__Vendor_Total__c)-materialPresentlyStored);
                    
                }else{
                    var balToFinish = Number(recordItem.buildertek__Scheduled_Value__c) - (Number(recordItem.buildertek__Total__c)-workCompletedThisPeriod);
                    var balToFinish45 = Number(recordItem.buildertek__Scheduled_Value__c) - (Number(recordItem.buildertek__Total__c)-materialPresentlyStored);
                    
                }
                
                if(localId == "buildertek__Work_Completed__c"){
                    if(workCompletedThisPeriod > balToFinish ){
                        
                        inputField.setCustomValidity("Work Completed This Period must be less than Balance To Finish");
                        component.set("v.isGCPercent",true);
                        
                    }else{
                        inputField.setCustomValidity("");
                        component.set("v.isGCPercent",false);
                    }
                }
                 if(localId == "buildertek__Material_Presently_Stored__c"){
                    if(materialPresentlyStored > balToFinish45){
                        inputField.setCustomValidity("Material Presently Stored must be less than Balance To Finish");
                         component.set("v.isGCPercent",true);
                    }else{
                        inputField.setCustomValidity("");
                         component.set("v.isGCPercent",false);
                    }   
                }
            }
            
        }else if(updatedLinesInGroup){
            for(var pindex=0; pindex<updatedLinesInGroup.length; pindex++){
                var subgrpRecords = updatedLinesInGroup[pindex].subGroupRecords;
                for(var sunindex =0; sunindex<subgrpRecords.length;sunindex++){
                    var records = subgrpRecords[sunindex].records;
                    for(var recIndex = 0 ; recIndex < records.length;recIndex++){
                        updatedLines.push(records[recIndex]);
                        if(recordId == records[recIndex].Id){
                            if(!value){
                                value = 0;
                            }
                            if(component.get("v.isCommUser") == true){
                                if(localId == "buildertek__Scheduled_Value__c"){
                                    records[recIndex].buildertek__Scheduled_Value__c = parseInt(value);
                                }  
                            }else{
                                if(localId == "buildertek__Scheduled_Value__c"){
                                    records[recIndex].buildertek__Scheduled_Value__c = parseInt(value);
                                }  
                            }
                            
                            if(component.get("v.isCommUser") == true){
                                if(localId == "buildertek__Work_Completed_from_Previous_Application__c"){
                                    records[recIndex].buildertek__Vendor_Work_Completed_from_Previous_Appl__c = parseInt(value);
                                }  
                            }else{
                                if(localId == "buildertek__Work_Completed_from_Previous_Application__c"){
                                    records[recIndex].buildertek__Work_Completed_from_Previous_Application__c = parseInt(value);
                                }  
                            }
                            
                            if(component.get("v.isCommUser") == true){
                                if(localId == "buildertek__Work_Completed__c"){
                                    records[recIndex].buildertek__Vendor_Work_Completed_This_Period__c =Number(value);
                                } 
                            }else{
                                if(localId == "buildertek__Work_Completed__c"){
                                    records[recIndex].buildertek__Work_Completed__c =Number(value);
                                } 
                            }
                            
                            if(component.get("v.isCommUser") == true){
                                if(localId == "buildertek__Material_Presently_Stored__c"){
                                    records[recIndex].buildertek__Vendor_Material_Presently_Stored__c = parseFloat(value);
                                }
                            }else{
                                if(localId == "buildertek__Material_Presently_Stored__c"){
                                    records[recIndex].buildertek__Material_Presently_Stored__c = parseFloat(value);
                                }
                            }
                            
                            if(component.get("v.isCommUser") == true){
                                records[recIndex].buildertek__Vendor_Total__c = parseFloat(records[recIndex].buildertek__Vendor_Material_Presently_Stored__c) + parseInt(records[recIndex].buildertek__Vendor_Work_Completed_from_Previous_Appl__c) + parseFloat(records[recIndex].buildertek__Vendor_Work_Completed_This_Period__c);
                               var gcPercent = (parseInt(records[recIndex].buildertek__Vendor_Total__c) / parseInt(records[recIndex].buildertek__Scheduled_Value__c))*100;
                                records[recIndex].buildertek__Vendor_G_C__c = gcPercent.toFixed(2);
                                records[recIndex].buildertek__Vendor_Balance_To_Finish__c = Number(records[recIndex].buildertek__Scheduled_Value__c) - Number(records[recIndex].buildertek__Vendor_Total__c);
                            }else{
                                records[recIndex].buildertek__Total__c = parseFloat(records[recIndex].buildertek__Material_Presently_Stored__c) + parseInt(records[recIndex].buildertek__Work_Completed_from_Previous_Application__c) + parseFloat(records[recIndex].buildertek__Work_Completed__c);
                               var gcPercent =  (parseInt(records[recIndex].buildertek__Total__c) / parseInt(records[recIndex].buildertek__Scheduled_Value__c))*100;
                                records[recIndex].buildertek__G_C__c =gcPercent.toFixed(2);
                                records[recIndex].buildertek__Balance_To_Finish__c = Number(records[recIndex].buildertek__Scheduled_Value__c) - Number(records[recIndex].buildertek__Total__c);
                            }
                            
                            if(component.get("v.isCommUser") == true){
                                if(localId == "buildertek__Work_Completed__c"){
                                    if(workCompletedThisPeriod > parseInt(records[recIndex].buildertek__Vendor_Balance_To_Finish__c)){
                                         component.set("v.isGCPercent",true);
                                        inputField.setCustomValidity("Work Completed This Period must be less than Balance To Finish");
                                    }else{
                                        inputField.setCustomValidity("");
                                         component.set("v.isGCPercent",false);
                                    }
                                    
                                }
                                if(localId == "buildertek__Material_Presently_Stored__c"){
                                    if(materialPresentlyStored > parseInt(records[recIndex].buildertek__Vendor_Balance_To_Finish__c)){
                                        inputField.setCustomValidity("Material Presently Stored must be less than Balance To Finish");
                                         component.set("v.isGCPercent",true);
                                    }else{
                                        inputField.setCustomValidity("");
                                         component.set("v.isGCPercent",false);
                                    }   
                                }
                            }else{
                                if(localId == "buildertek__Work_Completed__c"){
                                    if(workCompletedThisPeriod > parseInt(records[recIndex].buildertek__Balance_To_Finish__c)){
                                         component.set("v.isGCPercent",true);
                                        inputField.setCustomValidity("Work Completed This Period must be less than Balance To Finish");
                                    }else{
                                        inputField.setCustomValidity("");
                                         component.set("v.isGCPercent",false);
                                    }
                                    
                                }
                                if(localId == "buildertek__Material_Presently_Stored__c"){
                                    if(materialPresentlyStored > parseInt(records[recIndex].buildertek__Balance_To_Finish__c)){
                                        inputField.setCustomValidity("Material Presently Stored must be less than Balance To Finish");
                                         component.set("v.isGCPercent",true);
                                    }else{
                                        inputField.setCustomValidity("");
                                         component.set("v.isGCPercent",false);
                                    }   
                }
                            }
                            
                            break;
                        }
                    }
                }
            }
        }
        console.log(updatedLines);
        
        console.log(updatedLinesInGroup);
        if(value){
            if(value.indexOf('.') > 0 ){
                if(value.split('.')[1].length != 0){
                    component.set("v.groupedRecords", updatedLinesInGroup);
                }
            }else{
                component.set("v.groupedRecords", updatedLinesInGroup);
            }
        }else{
            component.set("v.groupedRecords", updatedLinesInGroup);
        }
        
        
    },

    
    addNewRow : function(component, event, helper){
        var sheetLineItems = component.get("v.continuationSheetLines");
        var index = Number(event.currentTarget.dataset.index);

        var emptyObj = {
            Name: "",
            buildertek__Description_of_Work__c: "",
            buildertek__Scheduled_Value__c : 0,
            buildertek__Work_Completed_from_Previous_Application__c: 0,
            buildertek__Work_Completed__c : 0,
            buildertek__Material_Presently_Stored__c: 0,
            buildertek__Total__c: 0,
            buildertek__G_C__c:0,
            buildertek__Balance_To_Finish__c:0
        }
        sheetLineItems.splice(index+1,0,emptyObj);
        component.set("v.continuationSheetLines",sheetLineItems);
    },
    
    addNewRowInGroup : function(component, event, helper){
        debugger;
        var linesInGroup = component.get("v.groupedRecords")
        var index = event.currentTarget.dataset.index.split('_');
        var parentGrpIndex = Number(index[0])
        var subGrpIndex = Number(index[1])
        var recIndex = Number(index[2])

        var emptyObj = {
            Name: "",
            buildertek__Description_of_Work__c: "",
            buildertek__Scheduled_Value__c : 0,
            buildertek__Item_No__c : "",
            buildertek__Work_Completed_from_Previous_Application__c: 0,
            buildertek__Work_Completed__c : 0,
            buildertek__Material_Presently_Stored__c: 0,
            buildertek__Total__c: 0,
            buildertek__G_C__c:0,
            buildertek__Balance_To_Finish__c:0,
            buildertek__Grouping__c: (linesInGroup[parentGrpIndex].grouping1Name != "" && linesInGroup[parentGrpIndex].grouping1Name != "No Grouping") ? linesInGroup[parentGrpIndex].grouping1Name : '',
            buildertek__Grouping2__c: (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].grouping2Name != "" && linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].grouping2Name != "No Grouping2") ? linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].grouping2Name : '',
        }
        
        linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records.splice(recIndex+1,0,emptyObj);
        component.set("v.groupedRecords",linesInGroup);
        console.log(linesInGroup);
    },
    
    
    
    deleteRow : function(component, event, helper){
        var target = event.target;
        var index = target.getAttribute("data-index");
        var records = component.get('v.continuationSheetLines');
        if (records[index].Id != undefined) {
            component.set('v.deleteContinuationSheetLine', index);
            component.set('v.isdeleteClick', true);
        } else if (records[index].Id == undefined) {
            records.splice(index, 1);
            component.set('v.continuationSheetLines', records);
        }
        
    },
    
    deleteRowInGroup : function(component, event, helper){
        var target = event.target;
        var index = target.getAttribute("data-index").split('_');
        var linesInGroup = component.get("v.groupedRecords")
        var parentGrpIndex = Number(index[0])
        var subGrpIndex = Number(index[1])
        var recIndex = Number(index[2])
        if (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id != undefined) {
            component.set('v.deleteContinuationSheetLine', target.getAttribute("data-index"));
            var deleteSheetLine = linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id;
            var action = component.get("c.getstatus");
            action.setParams({
                recordid: deleteSheetLine
            });
            action.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS') {
                    if(response.getReturnValue() == 'Accepted'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "",
                            "message": "This line is already Accepted, you can't delete this record."
                        });
                        toastEvent.fire();
                    }else{
                        component.set('v.isdeleteClickInGroup', true);
                    }
                } else {
                    console.log('Error');
                }
            });
            $A.enqueueAction(action);
        } else if (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id == undefined) {
            linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records.splice(recIndex, 1);
            component.set("v.groupedRecords",linesInGroup);
        }
        console.log(linesInGroup);
    },
    accceptline : function(component, event, helper){
        var target = event.target;
        var index = target.getAttribute("data-index").split('_');
        var linesInGroup = component.get("v.groupedRecords")
        var parentGrpIndex = Number(index[0])
        var subGrpIndex = Number(index[1])
        var recIndex = Number(index[2])
        if (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id != undefined) {
            component.set('v.acceptContinuationSheetLine', target.getAttribute("data-index"));
            component.set('v.isacceptClickInGroup', true);
        } else if (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id == undefined) {
            linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records.splice(recIndex, 1);
            component.set("v.groupedRecords",linesInGroup);
        }
    },
    cancelacceptline: function (component, event, helper) {
        component.set('v.isacceptClickInGroup', false);
    },
    confirmacceptInGrp: function (component, event, helper) {
        var linesInGroup = component.get("v.groupedRecords")
        var index = component.get('v.acceptContinuationSheetLine')[0].split("_");
        var parentGrpIndex = Number(index[0])
        var subGrpIndex = Number(index[1])
        var recIndex = Number(index[2])
        linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex]
        if (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id != undefined) {
            var acceptSheetLine = linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id;
            component.set('v.isacceptClickInGroup', false);
        }
        var actionDeleteLink;
        actionDeleteLink = component.get("c.acceptsheetline");
        actionDeleteLink.setParams({
            recordId : component.get("v.ClonerecordId"),
            sheetlineIds: acceptSheetLine
        });
        actionDeleteLink.setCallback(this, function (response) {
            component.set("v.Spinner", true);
            var toastEvent = $A.get("e.force:showToast");
            if (component.isValid() && response.getState() === "SUCCESS") {
                if (response.getReturnValue() == 'success') {
                    component.set("v.Spinner", false);
                    $A.get("e.force:refreshView").fire();
                    toastEvent.setParams({
                        "type": "success",
                        "title": "",
                        "message": "Continuation SheetLine updated Successfully."
                    });
                    var sheetLines = component.get("v.continuationSheetLines");
                    component.set("v.continuationSheetLines",sheetLines);
                    helper.groupRecords(component, event, helper);
                } else {
                    component.set("v.Spinner", false);
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": response.getReturnValue()
                    });
                }
            } else {
                component.set("v.Spinner", false);
                toastEvent.setParams({
                    "type": "error",
                    "title": "error",
                    "message": response.getError()[0].message
                });
            }
            toastEvent.fire();
        });
        $A.enqueueAction(actionDeleteLink);
    },
    rejectline : function(component, event, helper){
        var target = event.target;
        var index = target.getAttribute("data-index").split('_');
        var linesInGroup = component.get("v.groupedRecords")
        var parentGrpIndex = Number(index[0])
        var subGrpIndex = Number(index[1])
        var recIndex = Number(index[2])
        if (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id != undefined) {
            component.set('v.rejectContinuationSheetLine', target.getAttribute("data-index"));
            var rejectSheetLine = linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id;
            var action = component.get("c.getreason");
            action.setParams({
                recordid: rejectSheetLine
            });
            action.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS') {
                    var rejectreason = response.getReturnValue();
                    if(rejectreason != null){
                        component.set("v.rejectionreason", rejectreason);
                    }
                } else {
                    console.log('Error');
                }
                component.set('v.isrejectClickInGroup', true);
            });
            $A.enqueueAction(action);
        } else if (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id == undefined) {
            linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records.splice(recIndex, 1);
            component.set("v.groupedRecords",linesInGroup);
        }
    },
    cancelrejectline: function (component, event, helper) {
        component.set('v.isrejectClickInGroup', false);
        component.set("v.rejectionreason",'');
    },
    confirmrejectInGrp: function (component, event, helper) {
        var rejreason = component.get('v.rejectionreason');
         component.set("v.Spinner", true);
        if(component.get('v.rejectionreason') != null && component.get('v.rejectionreason') != undefined && component.get('v.rejectionreason') != ''){
            var linesInGroup = component.get("v.groupedRecords")
            var index = component.get('v.rejectContinuationSheetLine')[0].split("_");
            var parentGrpIndex = Number(index[0])
            var subGrpIndex = Number(index[1])
            var recIndex = Number(index[2])
            linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex]
            if (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id != undefined) {
                var rejectSheetLine = linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id;
                component.set('v.isrejectClickInGroup', false);
            }
            
            var actionrRejectLink;
           
            actionrRejectLink = component.get("c.rejectsheetline");
            actionrRejectLink.setParams({
                sheetlineIds: rejectSheetLine,
                rejectreason : component.get('v.rejectionreason')
            });
            actionrRejectLink.setCallback(this, function (response) {
                debugger;
                var toastEvent = $A.get("e.force:showToast");
                if (component.isValid() && response.getState() === "SUCCESS") {
                    if (response.getReturnValue() == 'success') {
                         component.set("v.Spinner", false);
                        $A.get("e.force:refreshView").fire();
                        toastEvent.setParams({
                            "type": "success",
                            "title": "",
                            "message": "Continuation SheetLine Rejected Successfully."
                        });
                        var sheetLines = component.get("v.continuationSheetLines");
                        component.set("v.continuationSheetLines",sheetLines);
                        helper.groupRecords(component, event, helper);
                        component.set("v.rejectionreason",'');
                    } else {
                         component.set("v.Spinner", false);
                        toastEvent.setParams({
                            "type": "error",
                            "title": "Error!",
                            "message": response.getReturnValue()
                        });
                    }
                } else {
                    toastEvent.setParams({
                        "type": "error",
                        "title": "error",
                        "message": response.getError()[0].message
                    });
                }
                toastEvent.fire();
                 component.set("v.Spinner", false);
            });
            $A.enqueueAction(actionrRejectLink);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error",
                "message": "Please Complete this field."
            }); 
            toastEvent.fire();
        }
        
    },
    cancelline: function (component, event, helper) {
        component.set('v.isdeleteClick', false);
        component.set('v.isdeleteClickInGroup', false);
        
    },
    confirmdelete: function (component, event, helper) {
        var records = component.get('v.continuationSheetLines');
        var index = component.get('v.deleteContinuationSheetLine');
        if (records[index].Id != undefined) {
            var deleteSheetLine = records[index].Id;
            component.set('v.isdeleteClick', false);
        }
        var actionDeleteLink;
        actionDeleteLink = component.get("c.deletesheetline");
        actionDeleteLink.setParams({
            sheetlineIds: deleteSheetLine
        });
        actionDeleteLink.setCallback(this, function (response) {
            var toastEvent = $A.get("e.force:showToast");
            if (component.isValid() && response.getState() === "SUCCESS") {
             
                if (response.getReturnValue() == 'success') {
                    $A.get("e.force:refreshView").fire();
                    toastEvent.setParams({
                        "type": "success",
                        "title": "",
                        "message": "Continuation SheetLine Removed Successfully."
                    });
                    var sheetLines = component.get("v.continuationSheetLines");
                    component.set("v.continuationSheetLines",sheetLines);
                 
                } else {
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": response.getReturnValue()
                    });
                    
                }
            } else {
                toastEvent.setParams({
                    "type": "error",
                    "title": "error",
                    "message": response.getError()[0].message
                });
            }
            toastEvent.fire();
        });
        
        $A.enqueueAction(actionDeleteLink);
    },
    
    confirmdeleteInGrp: function (component, event, helper) {
        var linesInGroup = component.get("v.groupedRecords")
        var index = component.get('v.deleteContinuationSheetLine')[0].split("_");
        var parentGrpIndex = Number(index[0])
        var subGrpIndex = Number(index[1])
        var recIndex = Number(index[2])
        linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex]
        if (linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id != undefined) {
            var deleteSheetLine = linesInGroup[parentGrpIndex].subGroupRecords[subGrpIndex].records[recIndex].Id;
            component.set('v.isdeleteClickInGroup', false);
        }
        var actionDeleteLink;
        actionDeleteLink = component.get("c.deletesheetline");
        actionDeleteLink.setParams({
            sheetlineIds: deleteSheetLine
        });
        actionDeleteLink.setCallback(this, function (response) {
            var toastEvent = $A.get("e.force:showToast");
            if (component.isValid() && response.getState() === "SUCCESS") {
              
                if (response.getReturnValue() == 'success') {
                    $A.get("e.force:refreshView").fire();
                    toastEvent.setParams({
                        "type": "success",
                        "title": "",
                        "message": "Continuation SheetLine Removed Successfully."
                    });
                    var sheetLines = component.get("v.continuationSheetLines");
                    component.set("v.continuationSheetLines",sheetLines);
                    helper.groupRecords(component, event, helper);
                    
                } else {
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": response.getReturnValue()
                    });
    
                }
            } else {
                toastEvent.setParams({
                    "type": "error",
                    "title": "error",
                    "message": response.getError()[0].message
                });
            }
            toastEvent.fire();
        });
        
        $A.enqueueAction(actionDeleteLink);
    },
    
    
  
    
    navigateToApp:function(component, event, helper){
        
        
        if(component.get("v.isCommUser")==true){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.continuationSheet").buildertek__SOV_Payment_Application__c,
                "slideDevName": "detail"
            });
            navEvt.fire();
            
        }else{
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
                workspaceAPI.openTab({
                    url: '/'+component.get("v.continuationSheet").buildertek__SOV_Payment_Application__c,
                    focus: true
                }).then(function(response) {
                    workspaceAPI.openSubtab({
                        parentTabId: response,
                        url: '/'+component.get("v.continuationSheet").buildertek__SOV_Payment_Application__c,
                        focus: true
                    });
                }).catch(function(error) {
                    console.log(error);
                    
                });
            });
           
        }
        
        
    } ,
    
    navigateToSheet:function(component, event, helper){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            workspaceAPI.openTab({
                url: '/'+component.get("v.continuationSheet").Id,
                focus: true
            }).then(function(response) {
                workspaceAPI.openSubtab({
                    parentTabId: response,
                    url: '/'+component.get("v.continuationSheet").buildertek__SOV_Payment_Application__c,
                    focus: true
                });
                
            }).catch(function(error) {
                console.log(error);
            });
        });
        
    },
    

    
    importContinuationSheet : function(component,event,helper){
        var status;
        var action = component.get("c.getPaymentAppStatus");
        action.setParams({
            recordId : component.get("v.recordIdClone")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(response.getState() === "SUCCESS"){
                if(result == "Customer Paid" || result == "Owner Paid"){
                    component.find("notifLib").showToast({ "variant":"error", "title": "Error", "message": "You cannot Edit this Payment Application, because it has Already "+result });
                }else{
                    if(component.get("v.isCommUser")== true){
                        var continuationSheetId = component.get("v.continuationSheet").Id
                        var commUserId = component.get("v.commUserId");
                        var address = '/import-master-sov-sheet?id='+continuationSheetId+'&userIdFromcommunity='+commUserId+'&dummy=ignore'+'&fromsovsheet=ignore'+'/';
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": address,
                            "isredirect" :false
                        });
                        urlEvent.fire();
                        
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    }
                    
                    else{
                        console.log('import popup');
                        
                        var overlayLib;
                        var modalBody;
                        var modalFooter;
                        var myPageRef = component.get("v.pageReference");
                        var recordId = myPageRef.state.buildertek__parentId;
                        if(!recordId){
                        
                        }
                        $A.createComponents([
                            ["c:BT_Import_Master_ContinuationSheetOnCustomPage",{
                                "recordId": component.get("v.continuationSheet").Id,
                                "cancelCallback": function () {
                                    overlayLib.close();
                                }
                            }]
                        ],
                                            function(components, status){
                                                if (status === "SUCCESS") {
                                                    modalBody = components[0];
                                                    component.find('overlayLib').showCustomModal({
                                                        header: 'Import Master Continuation Sheet',
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
            }
            
        });
        $A.enqueueAction(action);
   
    },
    saveAndNew: function (component, event, helper) {
        component.set("v.Spinner", true);
        
        component.set("v.isSaveAndNew",true);
       
        component.set("v.Spinner", false); 
    },
    
    setSaveAndNewFasle :  function (component, event, helper) {
      //  component.set("v.Spinner", true);
        
        component.set("v.isSaveAndNew",false);
       //   component.set("v.Spinner", false);
        
    },
    
    editContinuationSheet : function (component, event, helper) {
        var lineId = event.currentTarget.dataset.id;
        var action = component.get("c.getstatus");
        action.setParams({
            recordid: lineId
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                if(response.getReturnValue() == 'Accepted'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "",
                        "message": "This line is already Accepted, you can't edit this record."
                    });
                    toastEvent.fire();
                }else{
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": lineId
                    });
                    navEvt.fire();
                }
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    
    addChangeOrders : function (component, event, helper) {
        debugger;
        component.set("v.Spinner", true);
        
        var action = component.get("c.getApprovedCOs");
        action.setParams({
            projectId : component.get("v.projectId"),
            commRecId : component.get("v.recordId"),
            sfRecId : component.get("v.ClonerecordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
               
                component.set("v.changeOrdersList", result);
                component.set("v.totalRecords", component.get("v.changeOrdersList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.changeOrdersList").length> i)
                        PaginationList.push(result[i]);    
                }
                
                var addchangeOrders = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.changeOrdersList").length> i)
                        addchangeOrders.push(result[i].coRecord);    
                }
                if(addchangeOrders.length > 0){
                    component.set("v.showVendorCO", true);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "",
                        "message": "There are no Approved Change Orders for this Project."
                    });
                    toastEvent.fire();
                }
                
                component.set("v.ChangeOrdersListIterate", addchangeOrders);
                var cOLIst = component.get("v.ChangeOrdersListIterate");
                for(var i=0;i<cOLIst.length;i++){
                    cOLIst[i].buildertek__Project__c = cOLIst[i].buildertek__Project__r.Name;
                }
                component.set("v.ChangeOrdersListIterate", cOLIst);
                component.set("v.PaginationList", PaginationList);
                component.set("v.Spinner", false);
                
                if(component.get("v.totalRecords") == 0){
                    component.set("v.noCOLines", true)
                }
                
            }     
        });
        if(component.get("v.projectId") != undefined && component.get("v.projectId") != '' && component.get("v.projectId") != null){
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : '',
                message:"This Payment Application is not associated with any Project, so we cannot fetch any Change Orders.",
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
        });
        toastEvent.fire();
            component.set("v.Spinner", false);
        }  
        
        
    }, 
    
    handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();  
        var changeOrders = component.get("v.changeOrdersList");
        for(var i=0 ; i < changeOrders.length;i++){
            if(changeOrders[i].coRecord.Id == checkbox.get("v.text") && changeOrders[i].coCheck == false){
                changeOrders[i].coCheck = true;
            }
            else if(changeOrders[i].coRecord.Id == checkbox.get("v.text") && changeOrders[i].coCheck == true){
                changeOrders[i].coCheck = false;
            }  
        }
    },
    
    closeCOModal : function (component, event, helper) {
        component.set("v.showVendorCO", false);   
    },
    
    selectAll : function(component, event, helper){
        debugger;
        
        
        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
        var changeOrders = component.get("v.changeOrdersList");
        var getAllId = component.find("checkContractor"); 
        if(changeOrders != null){
            if(changeOrders.length > 1){
                if(! Array.isArray(getAllId)){
                    if(selectedHeaderCheck == true){ 
                        component.find("checkContractor").set("v.value", true); 
                    }else{
                        component.find("checkContractor").set("v.value", false);
                    }
                }
                else{ 
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", true); 
                            var checkbox = component.find("checkContractor")[i].get("v.text");  
                            changeOrders[i].coCheck = true;
                        }
                    } 
                    else{
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false); 
                            var checkbox = component.find("checkContractor")[i].get("v.text"); 
                            var changeOrders = component.get("v.changeOrdersList");
                            changeOrders[i].coCheck = false;
                        }
                    } 
                } 
            }
            else{
                var i=0;
                if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true); 
                    var checkbox = component.find("checkContractor").get("v.text");  
                    changeOrders[i].coCheck = true;    
                } 
                else{
                    component.find("checkContractor").set("v.value", false);
                    var checkbox = component.find("checkContractor").get("v.text"); 
                    var changeOrders = component.get("v.changeOrdersList");
                    changeOrders[i].coCheck = false;
                } 
            }
        }
    },
    
    createContinuationSheetLines : function (component, event, helper) {
        debugger;
        component.set("v.Spinner", true);
        var changeOrdersList = component.get("v.changeOrdersList");
        var myPageRef = component.get("v.pageReference");
        
        if(component.get("v.isCommUser") == true){
            var recordId = component.get("v.recordId");
        }else{
            var recordId = myPageRef.state.buildertek__parentId; 
        }
        
        var coList = component.get("v.listOfSelectedACOIds");
        
        var coIds = [];
        for(var i=0 ; i < coList.length;i++){
            coIds.push(coList[i]); 
        }
        debugger;
        if(coIds.length > 0){
            debugger;
            var action = component.get("c.createSheetLinesNew");  
            action.setParams({
                coIds : coIds,
                recordId : recordId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    
                    var result = response.getReturnValue();  
                    if(result.Status === 'Success'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": result.Message,
                            "type": 'Success'
                        });
                        toastEvent.fire(); 
                        component.set("v.showVendorCO",false);
                        component.set("v.Spinner", false);
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        $A.enqueueAction(component.get("c.doInit"));
                        
                    }else{
                        component.set("v.Spinner", false);
                        var action = component.get("c.getPaymentAppStatus");
                        action.setParams({
                            recordId : component.get("v.recordIdClone")
                        });
                        action.setCallback(this, function(response){
                            var result = response.getReturnValue();
                            if(response.getState() === "SUCCESS"){
                                component.set("v.Spinner",false);
                                status = result;
                                if(status == "Customer Paid" || status == "Owner Paid"){
                                    component.find("notifLib").showToast({ "variant":"error", "title": "Error", "message": "You cannot Edit this Payment Application, because it has Already "+status });
                                }else{
                                    component.find("notifLib").showToast({ "variant":"error", "title": "Unexpected Error Here", "message": "A message that you want to show. Can place some error attributes if you need" }); 
                                }
                            }else{
                                
                            }
                            
                        });
                        $A.enqueueAction(action);
                   
                    }
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": 'Please select atleast one Change Order',
                "type": 'Error',
                "duration": '5000',
                "mode": 'dismissible'
            }); 
            toastEvent.fire();
        }    
    },
    
    next: function (component, event, helper) {
        var changeOrdersList = component.get("v.changeOrdersList");
        for(var i=0 ; i < changeOrdersList.length;i++){
            if(changeOrdersList[i].coCheck == true){
                changeOrdersList[i].coCheck = false;
            }  
        }
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(changeOrdersList.length > i){
                Paginationlist.push(changeOrdersList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    previous: function (component, event, helper) {
        var changeOrdersList = component.get("v.changeOrdersList"); 
        for(var i=0 ; i < changeOrdersList.length;i++){
            if(changeOrdersList[i].coCheck == true){
                changeOrdersList[i].coCheck = false;
            }  
        }
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(changeOrdersList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    OnchangeName : function(component, event, helper) {
        var value = event.getSource().get("v.value")
        console.log(value)
        console.log(component.find("csheetLineDescription"));
        if(component.get("v.isSaveAndNew")){
            if( component.find("csheetLineDescription")[0]){
                component.find("csheetLineDescription")[0].set("v.value",value)
            }else if(component.find("csheetLineDescription")){
                component.find("csheetLineDescription").set("v.value",value)
            }
            
        }else{
            component.find("csheetLineDescription").set("v.value",value)
        }
        
    },
    
     
    SubmitForView : function (component, event, helper) {
        
         var action = component.get("c.checkPeriodTo");
        action.setParams({
            recordId : component.get("v.commrecordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result.buildertek__Period_To__c != null  && result.buildertek__Retainage__c != null){
                    
                    var btadminaction = component.get("c.getadminvalues");
                    btadminaction.setCallback(this, function(response){
                        if(response.getState() === 'SUCCESS'){
                            var result = response.getReturnValue();
                            if(result == true){
                                component.set("v.Isbtvalue",true);
                            }else{
                                helper.Submitpayment(component, event, helper);
                            }
                        }     
                    });
                    $A.enqueueAction(btadminaction);
                    
                } else if(result.buildertek__Period_To__c == null){
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'ERROR',
                        // message: 'Payment Application Submitted For View Successfully',
                        message: 'Payment Application Period To field should not be Null.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                
                
                
                
                else if(result.buildertek__Retainage__c == null){
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'ERROR',
                        // message: 'Payment Application Submitted For View Successfully',
                        message: 'Payment Application Retainage field should not be Null.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            }     
        });
        $A.enqueueAction(action);
        
        
        
       
    }, 
    
    
    cancelsubmit : function (component, event, helper) {
        component.set('v.Isbtvalue', false);
        component.set('v.Issignlienrelease', false);
        location.reload();
    },
    confirmsignlienrelease : function (component, event, helper) {
        component.set('v.Isbtvalue', false);
        component.set('v.Issignlienrelease', true);
        debugger;
        var wrapper = document.getElementById("signature-pad");
        helper.getTemplateBody(component, event, helper);
        if (wrapper != undefined) {
            
            var canvas = wrapper.querySelector("canvas");
            var signaturePad;
            
            // Adjust canvas coordinate space taking into account pixel ratio,
            // to make it look crisp on mobile devices.
            // This also causes canvas to be cleared.
            function resizeCanvas() {
                // When zoomed out to less than 100%, for some very strange reason,
                // some browsers report devicePixelRatio as less than 1
                // and only part of the canvas is cleared then.
                var ratio = Math.max(window.devicePixelRatio || 1, 1);
                canvas.width = canvas.offsetWidth * ratio;
                canvas.height = canvas.offsetHeight * ratio;
                canvas.getContext("2d").scale(ratio, ratio);
            }
            
            window.onresize = resizeCanvas;
            resizeCanvas();
            
            window.signaturePad = new SignaturePad(canvas);
            
            document.getElementById("btnClear").onclick = function (event) {
                event.preventDefault();
                console.log(window.signaturePad);
                window.signaturePad.clear();
            }
        }
    },
    Save : function (component, event, helper) {
        if (!signaturePad.isEmpty()) {
            component.set("v.Spinner2", true);
            helper.getuploadSignature(component, event, helper);
            helper.Submitpayment(component, event, helper);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please Sign and Save"
            });
            toastEvent.fire();
        }
    },
    importVendorSubmittedApp: function (component, event, helper) {
  debugger;
        var recordId = component.get("v.ClonerecordId");
        var action = component.get("c.getVendorSubmittedPaymentApps");
        action.setParams({
            projectId : component.get("v.projectId"),
            recordId: recordId
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                
                if(result.length > 0){
                    console.log(result);
                    for(let i=0;i<result.length;i++){
                        result[i].buildertek__Project__c = result[i].buildertek__Project__r.Name;
                        if(result[i].buildertek__Owner_Account__c){
                            result[i].buildertek__Owner_Account__c = result[i].buildertek__Owner_Account__r.Name;
                        }
                        
                    }
                    component.set("v.vendorSubmittedPAlist",result);
                    component.set("v.ShowImportVendorSubmitted",true); 
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": 'error',
                        "message": "You do not have any Company Accepted Vendor Payment Applications"
                       // "message": "You have already Imported Company Accepted Vendor Payment Apps"
                    });
                    toastEvent.fire();
                } 
            }else{
                
            }    
        });
        $A.enqueueAction(action);
        
        
    },
    getSelectedName: function (component, event) {
        
        var selectedRows = event.getParam('selectedRows');
        var y =[];
        component.set("v.listOfSelectedPAIds",y);
        var selectedRowList =component.get("v.listOfSelectedPAIds")
        
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            if(selectedRowList.indexOf(selectedRows[i].Id) < 0){
                selectedRowList.push(selectedRows[i].Id)
            }
            component.set("v.listOfSelectedPAIds",selectedRowList)
            console.log(component.get("v.listOfSelectedPAIds").length);
        }
        
    },
    doCancel : function (component, event) {
        component.set("v.ShowImportVendorSubmitted",false);
        //$A.get("e.force:closeQuickAction").fire()
    },
    importSheetLines : function (component, event) {
        component.set("v.Spinner",true);
        var action = component.get("c.importContinuationLines");
        action.setParams({
            "PAIds" : component.get("v.listOfSelectedPAIds"),
            "recordId" : component.get("v.ClonerecordId")
        });
        action.setCallback(this, function(response){
            console.log(response.getState());
            console.log(response.getError());
            if(response.getState() === 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Lines imported successfully."
                });
                component.set("v.Spinner",false);
                toastEvent.fire();
                component.set("v.ShowImportVendorSubmitted",false);
                $A.get('e.force:refreshView').fire();
            }else{
                component.set("v.Spinner",false);
            }   
        });
        if(component.get("v.listOfSelectedPAIds") != ""){
            $A.enqueueAction(action); 
        }else{
            component.set("v.Spinner",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please select Payment Application',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
       
    },
    
    
    acceptAllContinuationLines : function(component, event, helper) {
        debugger;
        
        
        component.set("v.Spinner", true);
        
        component.set("v.isError", false);
        var updatedLinesInGroup = component.get("v.groupedRecords");
        var updatedLines = [];
        if(updatedLinesInGroup && updatedLinesInGroup != "{}"){
            for(var pindex=0; pindex<updatedLinesInGroup.length; pindex++){
                var subgrpRecords = updatedLinesInGroup[pindex].subGroupRecords;
                for(var sunindex =0; sunindex<subgrpRecords.length;sunindex++){
                    var records = subgrpRecords[sunindex].records;
                    for(var recIndex = 0 ; recIndex < records.length;recIndex++){
                        updatedLines.push(records[recIndex]);
                    }
                }
            }
        }
        console.log(updatedLines);
        if(updatedLines.length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: 'No lines to save',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            component.set("v.Spinner", false);
        }
        for(var i=0;i < updatedLines.length;i++){
            if(updatedLines[i].buildertek__Description_of_Work__c == undefined){
                component.set("v.isDescription", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Please fill in the Description of work.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.Spinner", false);
            }else{
                component.set("v.isDescription", false); 
            }
            
        }
        if(component.get("v.isDescription") == false && updatedLines.length){
            
            var action = component.get("c.updateSheetLines");
            action.setParams({
                sheetLines : JSON.stringify(updatedLines),
                sheetId : component.get("v.continuationSheet").Id,
                recordId : component.get("v.recordIdClone")
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    if(result.isSuccess == true){
component.set("v.Spinner", true);
        var action = component.get("c.AceptConnLines");
        action.setParams({
            recordId : component.get("v.ClonerecordId")
        });
        action.setCallback(this, function(response){
            
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result == "success"){
                    component.set("v.Spinner", false);
                    
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'All Sheet Lines are Accepted Successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            }  else{
                component.set("v.Spinner", false);
            }   
        });
        $A.enqueueAction(action);
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Description of work cannot be empty',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'Error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", false);
                        
                    }
                } 
                
            });
            $A.enqueueAction(action);
        }
 
    },
    getSelectedACORecords: function (component, event) {
        
        var selectedRows = event.getParam('selectedRows');
        
        var y =[];
        component.set("v.listOfSelectedACOIds",y);
        var selectedRowList =component.get("v.listOfSelectedACOIds")
        
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            if(selectedRowList.indexOf(selectedRows[i].Id) < 0){
                selectedRowList.push(selectedRows[i].Id)
            }
            component.set("v.listOfSelectedACOIds",selectedRowList)
            console.log(component.get("v.listOfSelectedPAIds").length);
            
        }
        
    },
    
    
    NavToSovRec: function (component, event, helper) {
        
        var COId = event.currentTarget.dataset.change;
     
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId":COId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }  ,
    
    
})