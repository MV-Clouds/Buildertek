({
    BoxUserReset : function (component, event, helper) {
        var deleteBoxUserAssociation = component.get("c.deleteBoxUserAssociation");
        
        deleteBoxUserAssociation.setParams({
            "userId" : component.get("v.recordId")
        });
        deleteBoxUserAssociation.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state:' + state);
            if (state === "SUCCESS") {
                var toastEvent = $A.get( "e.force:showToast" );
                
                toastEvent.setParams({
                    "title": "Sucess",
                    "message": "Box User Reset sucessful",
                    duration:'4000'
                    
                });
                toastEvent.fire(); 
                
                var urlEvent = $A.get("e.force:navigateToSObject");
                urlEvent.setParams({
                    "recordId": component.get("v.recordId"),
                    "isredirect": "true"
                });
                urlEvent.fire(); 
                $A.get('e.force:refreshView').fire();
            }        
            
            
        });
        $A.enqueueAction(deleteBoxUserAssociation);   
    }
})