({
	    handleOK : function(component, event, helper) {
          var action = component.get("c.getFiledata");
        action.setParams({
            "AccountId" : component.get("v.recordId"),
        });
           
         action.setCallback(this, function(response){
             console.log(response.getState());
           //alert("returnval"+response.getReturnValue());
             console.log(response.getReturnValue());
              
            if(response.getState() === 'SUCCESS'){
               $A.get("e.force:closeQuickAction").fire() 
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "MSA Sent Successfully."  
                });
                toastEvent.fire();
            } else{
                  $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "message": "MSA Not Signed"  
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