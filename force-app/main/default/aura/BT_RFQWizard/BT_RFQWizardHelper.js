({
	
	
	wizardNavigation : function(component, event, helper, navigateToStep, rfq) {
		var progressbar, rfq;
		
		progressbar = component.find("progressbar");
		progressbar.set("v.currentStep",navigateToStep);
		
		if(rfq.buildertek__RFQ_Workflow_Stage__c !== navigateToStep) {
			rfq.buildertek__RFQ_Workflow_Stage__c = navigateToStep;
			component.set("v.rfq",rfq);
			console.log('---rfq.buildertek__RFQ_Workflow_Stage__c-->',rfq.buildertek__RFQ_Workflow_Stage__c);
			helper.saveRecordData(component, event, helper);
		}
		
		if(navigateToStep === "1") {
			
			//Record Detail
			
			$A.createComponent("force:recordView",{	
	                               "aura:id":"recordDetailComponent",
	                               "recordId":component.get("v.recordId")
                               },function(cmp){
	                               if (component.isValid()) {
	                                   component.set("v.currentComponent",cmp);
	                                   $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
	                               }
	                           });
			
		} else if(navigateToStep === "2") {
			
			// RFQ Items
			
			$A.createComponent("c:BT_Related_List_View",{	
	                               "aura:id":"rlatedListComponent",
	                               "recordId":component.get("v.recordId"),
	                               "rfq":rfq,
	                               "config":component.get("v.rfqConfig")
                           	   },
	                           function(grid){
	                               if (component.isValid()) {
	                                   component.set("v.currentComponent",grid);
	                                   
	                               }
	                           });
		
		} else if(navigateToStep === "3") {
			console.log('---navigateToStep---',navigateToStep);
			// Documents
			$A.createComponent("c:BT_Documents",{
	                               "recordId":component.get("v.recordId"),
	                               "targetObject":"buildertek__RFQ__c",
	                               "explorerConfig":"buildertek__RFQ__c"
                           		},function(document){
	                               if (component.isValid()) {
	                            	   console.log('---document---',document);
	                                   component.set("v.currentComponent",document);
	                                   $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
	                               }
                           		});
		
		} else if(navigateToStep === "4") {
			
			// Vendor List
			
			$A.createComponent("c:BT_RFQVendorList",{
                               		"recordId":component.get("v.recordId"),
                               		"rfq":rfq
                       			},function(grid){
	                               if (component.isValid()) {
	                                   component.set("v.currentComponent",grid);
	                               }
	                           });
		
		} else if(navigateToStep === "5") {
			
			// Review Vendor
			
			$A.createComponent("c:BT_RFQ_Review",{
                               		"recordId":component.get("v.recordId"),
                               		"rfq":rfq
                           		},function(grid){
	                               if (component.isValid()) {
	                                   component.set("v.currentComponent",grid);
	                               }
	                           });
		}
		
		
	},
	
	// Standerd Record Data service save
	saveRecordData: function(component, event, helper) {
	
		component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
		
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + 
                           JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
	}
})