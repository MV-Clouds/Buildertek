({
    getFields: function (component, event, helper) {
        debugger;
        var action = component.get("c.getFieldSet");
        action.setParams({
            objectName: 'buildertek__Purchase_Order__c',
            fieldSetName: 'buildertek__Order_PO',
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var result = response.getReturnValue();
                console.log(result)
                var listOfFields = JSON.parse(result.headers);
                component.set("v.HeaderList", listOfFields);
                
                component.set("v.listOfFields",result.poRecordList);
                
                
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    }
})