({
	doInit : function(component, event, helper) {
        var evt = $A.get("e.force:createRecord");
        evt.setParams({
            'entityApiName':'buildertek__Budget__c',
            'defaultFieldValues': {
                'buildertek__Project__c':component.get("v.recordId")
            }
            //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
        });
        evt.fire();
    },
    
    doneRendering: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})