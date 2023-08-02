({
    getProductId : function(component, event, helper){  
        console.log('Product Id::',component.get('v.recordId'));
    },      
    
    doInit : function(component, event, helper){  
        helper.getUploadedFiles(component, event);
    },      
    
    /*previewFile : function(component, event, helper){  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [event.currentTarget.id]
        });  
    },  
    
    uploadFinished : function(component, event, helper) {  
        helper.getUploadedFiles(component, event);    
        var toastEvent = $A.get("e.force:showToast");
        var uploadedFiles = event.getParam("files");
        var documentId='';
        uploadedFiles.forEach(file => documentId=file.documentId); 
        console.log('Document Id::',documentId); 
        
        var action = component.get("c.updateQuestions");
        action.setParams({ "documentId" :documentId,
                          "productId":component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('STATE::',state);
            if (state === "SUCCESS") { 
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.setParams({
                    "message": "Image uploaded successfully!",
                    "type": "success",
                    "duration" : 2000
                });
                toastEvent.fire(); 
            }
        });
        $A.enqueueAction(action); 
        
    }, 
    
    deleteFile : function(component, event, helper){
        if( confirm("Confirm deleting this file?")){
            component.set("v.showSpinner", true); 
            helper.deleteUploadedFile(component, event);                
        }
    }*/
})