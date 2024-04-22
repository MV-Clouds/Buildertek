({
    getRecordType : function(component) {
        console.log('getRecordType');
        var action = component.get("c.getRecordType");
        action.setParams({
            "ObjectAPIName": "buildertek__Walk_Through_Line_Items__c"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.recordTypeList", result);
                component.set("v.selectedRecordTypeId", result[0].Id);
            }
        });
        $A.enqueueAction(action);
    },

    getFields : function(component) {
        console.log('getFields');
        var action = component.get("c.getFieldSet");
        action.setParams({
            objName: 'buildertek__Walk_Through_Line_Items__c',
            fieldSetName: 'buildertek__NewfromParent'
        });
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            console.log('fieldSetObj::',fieldSetObj);
            component.set("v.fieldSetValues", fieldSetObj);
            component.set("v.spinner", false);
        })
        $A.enqueueAction(action);
    }
})