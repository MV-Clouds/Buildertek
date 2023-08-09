({
	doInit : function(cmp, event, helper) {
		/*var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreatePaymentApplication",
            componentAttributes: {
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();*/
        cmp.set("v.Spinner", true);
        var action = cmp.get("c.getPaymentApplications");
        action.setParams({
            budgetId : cmp.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	var result = response.getReturnValue();
                //cmp.set("v.budgetLines", result.budgetItems);
				var applicationNumber;
				var project = result.project;
                if(result.paymentApplicationsList.length > 0){
                    applicationNumber = parseInt(result.paymentApplicationsList[0].buildertek__Application__c)+1;
                }else{
                    applicationNumber = 1;
                }
                var navService = cmp.find("navService");
                var pageRef = {
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "buildertek__SOV_Payment_Application__c",
                        actionName: "new"
                    },
                    state: {
                    }
                }
                // Replace with your own field values
                var defaultFieldValues = {
                    buildertek__Application__c: applicationNumber,
                    buildertek__Project__c: project,
                    buildertek__Budget__c: cmp.get("v.recordId")
                };
                pageRef.state.defaultFieldValues = cmp.find("pageRefUtils").encodeDefaultFieldValues(defaultFieldValues);
                cmp.set("v.pageReference", pageRef);
         
                var navService = cmp.find("navService");
                var pageRef = cmp.get("v.pageReference");
                //event.preventDefault();
                navService.navigate(pageRef);
                cmp.set("v.Spinner", false);
        	}    
        });
        $A.enqueueAction(action);
        
        
	},
    
    handleSaveSuccess : function(component, event, helper){
     	alert('Saved');   
    }
})