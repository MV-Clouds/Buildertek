({
	doInit : function(component, event, helper) {
        var evt = $A.get("e.force:createRecord");
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        evt.setParams({
            'entityApiName':'buildertek__Check_In__c',
            'defaultFieldValues': {
                'buildertek__Project__c':component.get("v.recordId"),
                'buildertek__Date_Created__c': today,
            }
        });
        evt.fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    
    doneRendering: function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire();
    }
})