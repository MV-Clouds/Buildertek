({
	/*MAX_FILE_SIZE: 4500000,
    save : function(component, helper, file) {
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    		  'Selected file size: ' + file.size);
    	    return;
        }
    
        var fr = new FileReader();
	    var self = this;
       	fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
        
    	    self.upload(component, file, fileContents);
        };

        fr.readAsDataURL(file);
        },
        
    upload: function(component, file, fileContents) {
        var imagesList = component.get("v.");
        var description = component.get("v.description");
        alert('description --------> '+description);
        var options = [];
        var action = component.get("c.saveTheFile"); 
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents), 
            contentType: file.type
        });

        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state === "SUCCESS"){
                component.set("v.Spinner", false);
                component.set("v.attachmentId", a.getReturnValue());
                var attachementId = component.get("v.attachmentId");
                var url = 'https://btservice360-dev-ed.lightning.force.com/servlet/servlet.FileDownload?file='+attachementId;
                options.push({"label":url,"description":description});
                component.set("v.uploadedImagesList", options);
            }
            
        });
            
        $A.enqueueAction(action); 
    },*/
    
    getuploadedFiles:function(component, documentIds){
       // alert('hiii');
        var action = component.get("c.getFiles");  
        action.setParams({  
            "recordIds": documentIds  
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('result--->',result);         
                component.set("v.files",result);
                this.saveModel(component, event, helper);
            }  
        });  
        $A.enqueueAction(action);  
    },
    saveModel : function(component, event, helper) {
	    component.set("v.Spinner", true);
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
	    $A.enqueueAction(action);
	},
})