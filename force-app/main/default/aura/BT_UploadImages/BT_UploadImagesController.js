({
	/*doSave: function(component, event, helper) {
	    component.set("v.Spinner", true);
	    var fileInput = document.getElementById('fileToUpload');
    	var file = fileInput.files[0];
        helper.save(component, helper, file);
    },
    
    onDragOver: function(component, event) {
        event.preventDefault();
    },
    
    onDrop: function(component, event, helper) {
        component.set("v.Spinner", true);
		event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        helper.save(component, helper, files[0]);
	},*/
	
    handleUploadFinished : function(component, event, helper) { 
         var uploadedFiles = event.getParam("files");
        var documentIds = component.get("v.documentIdList");
        var description = component.get("v.description");
      //  var uploadedFiles = event.getParam("files");
        //var documentIds = []; 
        var imagesList = [];
        for(var i=0; i< uploadedFiles.length; i++){
            documentIds.push(uploadedFiles[i].documentId);
        }
        if(documentIds.length > 0){
            helper.getuploadedFiles(component, documentIds);   
        }
                 
    }, 
	
	closeModel: function(component, event, helper) {
	     var action = component.get("c.deleteFiles");
	     action.setParams({
	         filesList : component.get("v.files")
	     });
	     action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            $A.get("e.force:closeQuickAction").fire();        
	        }
	     });
	     $A.enqueueAction(action);      
	},
	saveModel : function(component, event, helper) {
        helper.saveModel(component, event, helper);
	 /*   component.set("v.Spinner", true);
	    var action = component.get("c.insertProposalImages");   
	    action.setParams({
	        parentId : component.get("v.recordId"),
	        description : component.get("v.description"),
	        attachmentId : component.get("v.attachmentId"),
	        filesList : component.get("v.files")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            component.set("v.Spinner", false);
	            var result = response.getReturnValue(); 
	            if(result != undefined){
	                $A.get("e.force:closeQuickAction").fire();
	                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "Success",
                        "message": "Image Uploaded Successfully"
                    });
                    toastEvent.fire();   
	            }
	        }
	    });
	    $A.enqueueAction(action); */
	}
	
})