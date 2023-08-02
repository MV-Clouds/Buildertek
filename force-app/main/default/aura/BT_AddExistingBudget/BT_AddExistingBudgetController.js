({
	init: function(component, event, helper) {
	    
		window.setTimeout($A.getCallback(function() {
	        helper.getContractDetaitls(component, event, helper);
	        var getSelectedRecord = '{"Id":"","Name":""}';
            var result = JSON.parse(getSelectedRecord);
            var compEvent = component.getEvent("SelectedRecordEvents");
            compEvent.setParams({"recordByEvent" : {} });  
            compEvent.fire();
	        
	    }), 100);
    },
    handleComponentEvent : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.BudgetLines.buildertek__Budget__c",selectedAccountGetFromEvent.Id);
	    component.set("v.groupFilter",'buildertek__Budget__c = \''+selectedAccountGetFromEvent.Id+ '\'');
    },
    
    handleComponentEvents : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.BudgetLines.buildertek__Budget__c",selectedAccountGetFromEvent.Id);
	    component.set("v.groupFilter",'buildertek__Budget__c = \''+selectedAccountGetFromEvent.Id+ '\'');
    },
    
    updateBudgetItemRecord : function(component, event, helper) {
        helper.updateBudgetItemRecordobj(component, event, helper);	
    },
    closeModel : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})