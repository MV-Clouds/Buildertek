({
	doInit : function(component, event, helper) {
        
		 window.open('/apex/buildertek__BT_Payment_App_PDF?id='+component.get("v.recordId"),'_blank');
        $A.get("e.force:closeQuickAction").fire();
	}
})