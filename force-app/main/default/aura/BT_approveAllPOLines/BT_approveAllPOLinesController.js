({
    doInit : function(component, event, helper) {

        var action = component.get("c.approveallpolines");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(result.status == 'success'){
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