({
	doInit : function(component, event, helper) {
		window.open('/apex/buildertek__ExportPaymentApplication?id='+component.get("v.recordId"),'_blank');
        $A.get("e.force:closeQuickAction").fire();
	}
})