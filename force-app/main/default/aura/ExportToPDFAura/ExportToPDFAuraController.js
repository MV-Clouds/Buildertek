({
	doInit : function(component, event, helper) {
        
		 window.open('/apex/buildertek__BT_Initial_Payment_App_PDF_Page?id='+component.get("v.recordId"),'_blank');
        $A.get("e.force:closeQuickAction").fire();
	}
})