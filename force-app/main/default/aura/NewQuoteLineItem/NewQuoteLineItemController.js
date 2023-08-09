({
	doInit : function(component, event, helper) {
		helper.getBaseData1(component, event, helper);
	},
    
    cancel : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
    
    save : function(component, event, helper) {
		helper.saveQuoteLine(component, event, helper);
	}
})