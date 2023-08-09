({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.mainObjectId");
	    component.find("InvoiceId").set("v.value", recordId);
	},
	
	doSave : function(component, event, helper) {
	    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var receiptToInsert = JSON.stringify(component.get("v.newReceipt"));
        var invoiceId = component.get("v.mainObjectId");
        var action = component.get("c.saveReceipt");
        action.setParams({
           receipts : receiptToInsert,
           invoiceId : invoiceId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.get("v.onSuccess")();  
            }
        });
        $A.enqueueAction(action);
    },
    
    doSaveAndNew : function(component, event, helper) {
        component.set("v.Spinner", true);
        var receiptToInsert = JSON.stringify(component.get("v.newReceipt"));
        var invoiceId = component.get("v.mainObjectId");
        var action = component.get("c.saveReceipt");
        action.setParams({
           receipts : receiptToInsert,
           invoiceId : invoiceId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.newReceipt.buildertek__Receipt_Date__c", null);
                component.set("v.newReceipt.buildertek__Amount__c", null);
                component.set("v.newReceipt.buildertek__Reference__c", '');
                component.set("v.newReceipt.buildertek__Type__c", '');
                component.set("v.Spinner", false);
                //$A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Receipt created successfully',
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    doCancel : function(component, event, helper) {
        component.get("v.onCancel")();    
    }
})