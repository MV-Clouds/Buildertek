({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.headerName", 'Create Payment Application');
        component.set("v.ShowPaymentApplicationFields", true);
        var action = component.get("c.getPaymentApplications");
        action.setParams({
            budgetId : component.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	var result = response.getReturnValue();
                component.set("v.budgetLines", result.budgetItems);
                if(result.paymentApplicationsList.length > 0){
                    var applicationNumber = parseInt(result.paymentApplicationsList[0].buildertek__Application__c)+1;
                	component.set("v.ApplicationFound", true);
                    component.set("v.ApplicationNotFound", false);
                    component.set("v.newPaymentApplications", result.paymentApplicationsList[0]);
                    component.set("v.newPaymentApplications.buildertek__Application__c", applicationNumber);
                    //component.set("v.applicationNumber", applicationNumber);
                }else{
                    var applicationNumber = 1;
                    component.set("v.newPaymentApplications.buildertek__Application__c", applicationNumber);
                	component.set("v.ApplicationNotFound", true);
                    component.set("v.ApplicationFound", false);
                }
                component.set("v.Spinner", false);
            }    
        });
        $A.enqueueAction(action);
    },
    
    saveApplication: function(component, event, helper) {
        component.set("v.Spinner", true);
        var newApplication = component.get("v.newPaymentApplications");
        var action = component.get("c.InsertApplication");
        action.setParams({
            paymentApplicationsRecord : newApplication,
            applicationName : component.get("v.paymentApplicationName"),
            periodDate : component.get("v.applicationEndDate")
        });
        action.setCallback(this, function(reponse){
            if(reponse.getState() === "SUCCESS"){
            	var result = reponse.getReturnValue();
                if(result.isSuccess == true){
               		//component.set("v.headerName", 'Create Continuation Sheet');
                    //component.set("v.IsPaymentApplication", true);
                    //component.set("v.ShowPaymentApplicationFields", false);
                    //component.set("v.paymentApplicationId", responsevalue.ApplicationId);
                    component.set("v.paymentRecordId", result.SuccessMessage);
                    component.set("v.applicationEndDate", result.paymentApplication.buildertek__Period_To__c);
                    component.set("v.applicationStartDate", result.paymentApplication.buildertek__Contract_Date__c);
                    var applicationNumber = result.ApplicationId;
                    component.set("v.paymentApplicationId", applicationNumber);
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Application Created Successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); */
                    helper.createContinuationSheet(component, event, helper);
                    component.set("v.Spinner", false);
                }
            }    
        });
        $A.enqueueAction(action);
    },
    
    closeModel : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    
    
    updateContinuationSheetLines : function(component, event, helper) {
        component.set("v.Spinner", true);
        var updatedLines = component.get("v.continuationSheetLines");
        console.log('updatedLines ---------> '+JSON.stringify(updatedLines));
        var action = component.get("c.updateSheetLines");
        action.setParams({
            sheetLines : JSON.stringify(updatedLines)
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	var result = response.getReturnValue();
                if(result.isSuccess == true){
                    component.set("v.ShowInsrtedLines", false);
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
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    component.set("v.Spinner", false);
                }
            }            
        });
        $A.enqueueAction(action);
    },
    
    
    
  
    
    getContinuationSheetForDetails :  function(component, event, helper) {
        var action = component.get("c.getContinuationSheetLines");
        action.setParams({
            recordId :  component.get("v.continuationSheetId") //component.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var Retainage = result.workFromPrevAppTotal + result.workcompletedTotal ;
                component.set("v.getcontinuationSheet", result.continuationSheet);
                var sheetLines = component.get('v.continuationItems');
                var scheduleValueTotal = 0;
                var workFromPrevAppTotal = 0;
                var workcompletedTotal = 0;
                var materialsStoredTotal = 0;
                var totalCompletedStored = 0;
                var gcTotal=0;
                var balanceTotal = 0;   
                if(sheetLines.length){
                    for(var i=0;i<sheetLines.length;i++){
                        scheduleValueTotal += sheetLines[i]['buildertek__Scheduled_Value__c']
                        workFromPrevAppTotal += sheetLines[i]['buildertek__Work_Completed_from_Previous_Application__c']
                        workcompletedTotal += sheetLines[i]['buildertek__Work_Completed__c']
                        materialsStoredTotal += sheetLines[i]['buildertek__Material_Presently_Stored__c']
                        
                        
                        totalCompletedStored += parseInt(sheetLines[i]['buildertek__Material_Presently_Stored__c']) + parseInt(sheetLines[i]['buildertek__Work_Completed_from_Previous_Application__c']) + parseInt(sheetLines[i]['buildertek__Work_Completed__c']);
                        if(parseInt(sheetLines[i]['buildertek__Scheduled_Value__c'])){
                            gcTotal += (parseInt(sheetLines[i]['buildertek__Total__c']) / parseInt(sheetLines[i]['buildertek__Scheduled_Value__c']))*100;  
                        }else{
                            gcTotal += 0;
                        }
                        
                        balanceTotal += parseInt(sheetLines[i]['buildertek__Scheduled_Value__c']) - parseInt(sheetLines[i]['buildertek__Total__c']); 
                    }
                }
                component.set("v.scheduleValueTotal", scheduleValueTotal);
                component.set("v.workFromPrevAppTotal", workFromPrevAppTotal);
                component.set("v.workcompletedTotal", workcompletedTotal);
                component.set("v.materialsStoredTotal", materialsStoredTotal);
                component.set("v.totalCompletedStored", totalCompletedStored);
                component.set("v.gcTotal", gcTotal);
                component.set("v.balanceTotal", balanceTotal);
                
                for(var i=0;i<sheetLines.length;i++){
                    if(parseInt(sheetLines[i].buildertek__Scheduled_Value__c)){
                       sheetLines[i].buildertek__New_G_C__c = (parseInt(sheetLines[i].buildertek__Total__c) / parseInt(sheetLines[i].buildertek__Scheduled_Value__c))*100; 
                    }else{
                        sheetLines[i].buildertek__New_G_C__c = 0;
                    }
                    sheetLines[i].buildertek__Total__c = parseInt(sheetLines[i].buildertek__Material_Presently_Stored__c) + parseInt(sheetLines[i].buildertek__Work_Completed_from_Previous_Application__c) + parseInt(sheetLines[i].buildertek__Work_Completed__c);
                    
                    sheetLines[i].buildertek__Balance_To_Finish__c = parseInt(sheetLines[i].buildertek__Scheduled_Value__c) - parseInt(sheetLines[i].buildertek__Total__c);
                    
                } 
                component.set("v.continuationItems", sheetLines);
                
                if(result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Retainage__c){
                    component.set("v.Retainage", result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Retainage__c);
                }else{
                    component.set("v.Retainage", 0);
                }
                component.set("v.paymentappName", result.continuationSheet.buildertek__SOV_Payment_Application__r.Name);
                component.set("v.ApplicationNo", result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Application__c);
                if(result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Architect__c){
                    component.set("v.Architect", result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Architect__r.Name);
                }else{
                    component.set("v.Architect", '');
                }
                component.set("v.PeriodTo", result.continuationSheet.buildertek__SOV_Payment_Application__r.buildertek__Period_To__c);
                //component.set("v.balanceTotal", result.balanceTotal);
               // component.set("v.continuationSheetId",  result.continuationSheet.Id);
            }
        })
        $A.enqueueAction(action);
    },

    
})