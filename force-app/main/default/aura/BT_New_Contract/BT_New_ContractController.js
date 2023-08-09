({
	doInit : function(component, event, helper) {
        var evt = $A.get("e.force:createRecord");
        evt.setParams({
            'entityApiName':'buildertek__Contract__c',
            'defaultFieldValues': {
                'buildertek__Project__c':component.get("v.recordId")
            }
            //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
        });
        evt.fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    
    doneRendering: function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire();
    }
})