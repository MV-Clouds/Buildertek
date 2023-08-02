({
    getContractDetaitls: function(component, event, helper, dataToUpdate){
			var contract = component.get("v.recordId");
			var sobjName = component.get("v.Object");
			var sObjFields = component.get("v.Fields");
            var action = component.get("c.getContractDetails");
            action.setParams({ contractId : contract, Objects : sobjName, sObjectFields : sObjFields});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                
                if (state === "SUCCESS") {
                   
                    var result = response.getReturnValue();
                        component.set("v.BudgetLines.buildertek__Description__c",result.Name);
                         component.set("v.BudgetLines.buildertek__Unit_Price__c",result.Amount);  
                }
            });
            $A.enqueueAction(action);
	},
	
	
	 updateBudgetItemRecordobj : function(component, event, helper) {
            var BudgetItem = component.get("v.BudgetLines");
            //alert('Grouping ---------> '+BudgetItem.);
            var action = component.get("c.updateBudgetItemRecordMethod");
            action.setParams({BudgetItems : BudgetItem});
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                   
                    var result = response.getReturnValue();
                    if(result.status == "Error"){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: result.Message,
                            type : 'error'
                        });
                        toastEvent.fire();
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: result.Message,
                            type : 'success'
                        });
                        toastEvent.fire();
                    }
                    
                    var recordId = component.get("v.recordId");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    
                }
                
            });
            $A.enqueueAction(action);
    },
})