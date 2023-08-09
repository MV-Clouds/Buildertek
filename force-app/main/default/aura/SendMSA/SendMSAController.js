({
    doInit : function(component, event, helper) {
          var action = component.get("c.getCurrentStage");
        action.setParams({
           
            "accountIds" : component.get("v.recordId"),
        });
         action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue()

               component.set("v.currentstage",result);
            }  
        });
        $A.enqueueAction(action);
        
    },
    
    handleOK : function(component, event, helper){
        component.set("v.ShowBox",true);
        var action = component.get("c.sendEmail");
        action.setParams({
            "accountIds" : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "MSA Sent Successfully."  
                });
                toastEvent.fire();
            }  
        });
        $A.enqueueAction(action);
    },
    handleCancel : function(component, event, helper){
        component.set("v.showConfirmDialog",false);
         $A.get("e.force:closeQuickAction").fire()
    }
    
    
})