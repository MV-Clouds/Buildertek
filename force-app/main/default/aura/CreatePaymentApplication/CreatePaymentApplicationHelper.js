({
	goToContinuationSheetDetailPage : function(component, event, helper) {
        component.set("v.Spinner", true);
		var workspaceAPI = component.find("workspace");
          
           /* var parentTabId = tabResponse.tabId;
            var isSubtab = tabResponse.isSubtab;*/
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.openTab({
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "recordId" : component.get("v.continuationSheetId"),
                        "componentName": "buildertek__ContinuationSheetItems"
                    },
                    "state": {
                        "buildertek__parentId":  component.get("v.continuationSheetId")
                    }
                },
                focus: true
            }).then(function(response){
                workspaceAPI.focusTab({tabId : response});
                 workspaceAPI.closeTab({tabId: focusedTabId})
                console.log(response);
            })
            
        }).then(function(response){
			component.set("v.Spinner", false);           
            //console.log(response);
        })
        .catch(function(error) {
            console.log(error);
            component.set("v.Spinner", false);
        });
        
	},
    
    createContinuationSheet : function(component, event, helper) {
        component.set("v.Spinner", true);
        //var continuationSheet = component.get("v.continuationSheet");
        //console.log('continuationSheet -------> '+JSON.stringify(continuationSheet));
        var continuationSheet = {'sObjectType': 'buildertek__SOV_Continuation__c'};
        continuationSheet.Name = 'Continuation Sheet - 1';
        continuationSheet.buildertek__Application_Date__c = component.get("v.applicationStartDate");
        continuationSheet.buildertek__Period_To__c = component.get("v.applicationEndDate");
        var applicationNumber = component.get("v.paymentApplicationId");
    	var action = component.get("c.insertContinuationSheet"); 
        action.setParams({
            continuationSheet : continuationSheet,
            paymentApplicationId : component.get("v.paymentRecordId"),
            applicationNumber : applicationNumber
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	var result = response.getReturnValue();
                if(result.isSuccess == true){
                    //component.set("v.IsContinuationSheet", true);
                    //component.set("v.IsPaymentApplication", false);
                    component.set("v.continuationSheetId", result.SuccessMessage);
                    //component.set("v.headerName", 'Create Continuation Sheet Lines');
                    var continuationLines = [];
                    var budgetLines = component.get("v.budgetLines");
                    for(var i=0;i<budgetLines.length;i++){
                        var costCode;
                        if(budgetLines[i].buildertek__Cost_Code__c != undefined){
                        	costCode = budgetLines[i].buildertek__Cost_Code__r.Name;    
                        }else{
                        	costCode = '';    
                        }
                        continuationLines.push({
                            'Name' : budgetLines[i].Name,
                            'buildertek__Description_of_Work__c' : budgetLines[i].Name,
                            'buildertek__Scheduled_Value__c' :  budgetLines[i].buildertek__Original_Budget__c,
                            'buildertek__Work_Completed_from_Previous_Application__c' : 0,
                            'buildertek__Work_Completed__c' : 0,
                            'buildertek__Material_Presently_Stored__c' : 0,
                            'buildertek__Total__c' : 0,
                            'buildertek__New_G_C__c' : 0,
                            'buildertek__Balance_To_Finish__c' : 0
                        });	    
                    }
                    component.set("v.continuationItems", continuationLines);
                	/*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Continuation Sheet Created Successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();*/
                    helper.createContinuationSheetLines(component, event, helper);
                    component.set("v.Spinner", false);
                }
            }    
        });
        $A.enqueueAction(action);
    },
    createContinuationSheetLines : function(component, event, helper) {
        component.set("v.Spinner", true);
    	var sheetLines = component.get("v.continuationItems");	
        var action = component.get("c.createSheetLines");
        action.setParams({
            sheetLines : JSON.stringify(sheetLines),
            continuationId : component.get("v.continuationSheetId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.isSuccess == true){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Payment Application, Continuation Sheet, Continuation Sheet Lines Created Successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    helper.goToContinuationSheetDetailPage(component, event, helper);
                    
                    component.set("v.Spinner", false);
                }		    
            }    
        });
        $A.enqueueAction(action);
    },
    
})