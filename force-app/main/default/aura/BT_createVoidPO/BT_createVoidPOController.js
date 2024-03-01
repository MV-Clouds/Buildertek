({
    doInit : function(component, event, helper) {

        var action = component.get("c.createVoidPO");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(result.status == 'success'){
                var sObjectEvent = $A.get("e.force:navigateToSObject");
                sObjectEvent.setParams({
                    "recordId": result.createRecordId
                })
                sObjectEvent.fire();
                helper.showToastHelper(component, event, helper,result.status , result.message , result.status , 3000 );
            }
            else if(result.status == 'error'){
                helper.showToastHelper(component, event, helper,result.status , result.message , result.status , 3000 )
            }
            $A.get("e.force:closeQuickAction").fire() ;
        });
        $A.enqueueAction(action);
    },

})