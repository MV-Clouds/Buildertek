({
    getprojectRecord : function(component, event, helper){
        
        var action = component.get("c.UpdateProjects");
        action.setParams({
            projectId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                //alert("2");
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "Success",
                    "message": "Project is updated.",
                    
                });
                //}
            }
            else{
                $A.get("e.force:closeQuickAction").fire();
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error",
                    "message": "Error while updating the Project.",
                    
                });
            }
            
            
        });
        $A.enqueueAction(action);
        
        
    }
})