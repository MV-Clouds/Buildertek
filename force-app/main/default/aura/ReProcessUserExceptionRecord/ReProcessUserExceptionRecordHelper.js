({
	showToast : function(component, event, helper) {
       
        var action = component.get("c.updateEmployeeDetails");       
        var respMessage = "";
        
        action.setParams({
            "SSRecordId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                respMessage = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(respMessage == "Success") {                    
    		toastEvent.setParams({
        		"title": "Success!",
                "type" : "Success",
        		"message": "The record has been updated successfully.",
        		"duration" : "5000"
    		});
    			toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
        }
        
        else {
            toastEvent.setParams({
        		"title": "Error!",
                "type" : "Error",
        		"message": respMessage,
        		"duration" : "5000"
    		});
    		toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }   	
            }
            else {
                console.log(response.getState());
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }            
        });     
        
        
        
         $A.enqueueAction(action);
        
}
    
   
})