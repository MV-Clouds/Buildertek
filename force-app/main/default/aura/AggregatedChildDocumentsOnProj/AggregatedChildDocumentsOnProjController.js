({
    doInit : function(component, event, helper) {
        var action=component.get('c.getChildName');
        action.setParams({
            recordId:component.get('v.recordId')
        })
        action.setCallback(this, function (response) {
            console.log(response.getState());
            console.log(response.getError());
            console.log(response.getReturnValue());


        });
        $A.enqueueAction(action);

    }
})
