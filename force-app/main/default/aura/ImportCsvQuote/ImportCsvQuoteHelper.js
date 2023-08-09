({
    save : function(component, helper, file) {
        try{
        var MAX_FILE_SIZE = 750000;
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        // var file = event.getSource().get("v.files");
        console.log('file1 =: ', file)
        var isSelect = component.get("v.isSelect");
        
        if(file != undefined && isSelect){
            if (file.size > this.MAX_FILE_SIZE) {
                alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
                      'Selected file size: ' + file.size);
                return;
            }  
            var fr = new FileReader();
        
            var self = this;
            fr.onload = function() {
                var fileContents = fr.result;
                console.log('fr.type : ', typeof fileContents);
                var base64Mark = 'base64,';
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                
                fileContents = fileContents.substring(dataStart);
                
                helper.upload(component, helper, file, fileContents);
            };
            
            fr.readAsDataURL(file);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Please select file to import', 
                type : 'error',
                duration: '10000',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    } catch(error){
            console.log('eoor => ', {error});
        }
        
    },
      
    upload: function(component, helper, file, fileContents) {
        component.set('v.Spinner', true);
        // $A.util.addClass(component.find("uploading").getElement(), "uploading");
    	// $A.util.removeClass(component.find("uploading").getElement(), "notUploading");
        
        var action = component.get("c.importBudgets"); 
		
        /*
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents), 
            contentType: file.type
        });
        */
        
        action.setParams({
            budgetId: component.get("v.recordId"),
            // fileData: encodeURIComponent(fileContents),
            fileData: fileContents     // ==> Chages For Ticket No : AC -28
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
        //     $A.util.removeClass(component.find("uploading").getElement(), "uploading");
    	// $A.util.addClass(component.find("uploading").getElement(), "notUploading");
            if(state === "SUCCESS") {
                component.set('v.Spinner', false);
                var result = response.getReturnValue();
                console.log('result ', result);
                if(result.isSuccess) {
                    helper.showToast(component, "success", result.strMessage);
                    
                     $A.get('e.force:refreshView').fire();
                }
                else {
                    helper.showToast(component, "error", result.strMessage);
                }
            }
            else {
                component.set('v.Spinner', false);
                var errors = response.getError();
                var error = '';
                
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        error = error + errors[0].message;
                    }
                    
                    helper.showToast(component, "error", error);
                } 
                else {
                    helper.showToast(component, "error", "Unknown error, please try again.");
                }
            }
            
            $A.get("e.force:closeQuickAction").fire();
        });
        
		$A.enqueueAction(action);
    },
    
    showToast : function(component, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "type": type,
            "message": message,
            duration: '10000',
            mode: 'dismissible'
    	});
    	
        toastEvent.fire();
	}
})