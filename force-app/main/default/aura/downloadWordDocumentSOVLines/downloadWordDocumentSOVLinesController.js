({
	doInit : function(component, event, helper) {
		window.open('/apex/buildertek__SOVLinesWordDocument?id='+component.get("v.recordId"),'_blank');
        $A.get("e.force:closeQuickAction").fire();
	}
})