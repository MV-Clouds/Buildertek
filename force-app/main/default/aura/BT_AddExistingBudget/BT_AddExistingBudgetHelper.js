({
    getContractDetaitls: function(component, event, helper, dataToUpdate){
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var contract = component.get("v.recordId");
        var sobjName = component.get("v.Object");
        var sObjFields = component.get("v.Fields");
        var action = component.get("c.getContractDetails");
        action.setParams({ contractId : contract, Objects : sobjName, sObjectFields : sObjFields});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.BudgetLines.buildertek__Description__c",result.Name);
                component.set("v.BudgetLines.buildertek__Unit_Price__c",result.Amount);  
            } else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: response.getError(),
                    type : 'Error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	},
	
	
	 updateBudgetItemRecordobj : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var BudgetItem = component.get("v.BudgetLines");
        var recordId = component.get("v.recordId");
        var action = component.get("c.updateBudgetItemRecordMethod");
        action.setParams({
            BudgetItems: BudgetItem,
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "SHOW"
            }).fire();
            if (response.getState() === "SUCCESS") {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
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
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            
        });
        $A.enqueueAction(action);
    },
})