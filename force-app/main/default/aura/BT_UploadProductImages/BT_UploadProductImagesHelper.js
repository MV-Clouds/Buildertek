({
    getUploadedFiles : function(component, event){
        var action = component.get("c.getUploadedFiles");  
        action.setParams({  
            "productId": component.get("v.recordId") 
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action); 
    },
    
    deleteUploadedFile : function(component, event) {  
        var action = component.get("c.deleteProductFile");           
        action.setParams({
            "contentDocumentId": event.currentTarget.id,
            "productId":component.get("v.recordId") 
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                this.getUploadedFiles(component);
                component.set("v.showSpinner", false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Image deleted successfully!!",
                    "type": "success",
                    "duration" : 2000
                });
                toastEvent.fire();
            }  
        });  
        $A.enqueueAction(action);  
    }, 
})