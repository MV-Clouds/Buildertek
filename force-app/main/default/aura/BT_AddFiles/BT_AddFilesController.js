({
	
	init:function(component, event, helper){
	    component.set("v.isOwnerFiles", true);
		helper.getConfig(component, event, helper);
		helper.getProjectFiles(component, event, helper);
	    
	},
	
	showUserFiles : function(component, event, helper){
	    component.set("v.isOwnerFiles", true);
	    component.set("v.isRecentFiles", false);
	    component.set("v.isRelatedFiles", false);
	    helper.highlightSelectedRow(component, event, helper);
	    helper.getProjectFiles(component, event, helper);
	},
	
	showRecentFiles : function(component, event, helper){
	    component.set("v.isOwnerFiles", false);
	    component.set("v.isRecentFiles", true);
	    component.set("v.isRelatedFiles", false);
	    component.set("v.Spinner", true);
	    var action = component.get("c.getRecentFiles"); 
	    action.setParams({
	        "recordId" : component.get("v.mainObjectId"),
	        "objectAPI" : component.get("v.mainObjectFieldAPI")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            if(result != undefined){
	                component.set("v.filesList", result);    
	            }else{
	                
	            }
	            helper.highlightSelectedRow(component, event, helper);
	            component.set("v.Spinner", false);
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	showRelatedFiles : function(component, event, helper){
	    component.set("v.isOwnerFiles", false);
	    component.set("v.isRecentFiles", false);
	    component.set("v.isRelatedFiles", true);
	    component.set("v.Spinner", true);
	    var action = component.get("c.getRelatedFiles"); 
	    action.setParams({
	        "recordId" : component.get("v.mainObjectId"),
	        "objectAPI" : component.get("v.mainObjectFieldAPI")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            if(result != undefined){
	                component.set("v.filesList", result);    
	            }else{
	                
	            }
	            helper.highlightSelectedRow(component, event, helper);
	            component.set("v.Spinner", false);
	        }
	    });
	    $A.enqueueAction(action);    
	},
	
	handleUploadFinished : function(component, event, helper) { 
	    component.set("v.Spinner", true);
        var uploadedFiles = event.getParam("files");
        var documentIds = [];
        var imagesList = [];
        for(var i=0; i< uploadedFiles.length; i++){
            documentIds.push(uploadedFiles[i].documentId);   
        }
        if(documentIds.length > 0){
            helper.getuploadedFiles(component, documentIds);   
        }else{
            component.set("v.Spinner", false);
        }
                 
    },
    
    SearchFunction : function(component, event, helper){
	    var input, filter, table, tr, td, i,a;
    	input = document.getElementById("filterInput");
    	filter = input.value.toUpperCase();
    	table = document.getElementById("myTable");
    	tr = table.getElementsByTagName("tr");
    	for (i = 0; i < tr.length; i++) {
    		td = tr[i].getElementsByTagName("td")[1];
    		if (td) {
    			a=td;
    			if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
    				tr[i].style.display = "";
    			} else {
    				tr[i].style.display = "none";
    			}
    		}       
    	}
	    
	},
	
	
    handleCheck : function(component, event, helper) {
    	var checkbox = event.getSource();  
    	var filesList = component.get("v.filesList");
    	for(var i=0 ; i < filesList.length;i++){
    		if(filesList[i].FileId == checkbox.get("v.text") && filesList[i].IsChecked == true){
    			filesList[i].IsChecked = true;
    			component.find("checkContractor")[i].set("v.value", true);
    		}
    		else if(filesList[i].FileId == checkbox.get("v.text") && filesList[i].IsChecked == false){
    			 component.find("checkContractor")[i].set("v.value", false);
    		}
    	}
    },
	
	upload:function(component, event, helper){
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		var filesList = component.get("v.filesList");
        var SubOptions = [];
        for(var i=0 ; i < filesList.length;i++){
        	//alert('filesList[i].IsChecked -------> '+filesList[i].IsChecked);
        	if(filesList[i].IsChecked == true){
        		SubOptions.push(filesList[i].FileId);
        	}
        }
    	//alert('length --------> '+SubOptions.length);
        if(SubOptions.length > 0){
        	component.set("v.selectedobjInfo",SubOptions);
        	 //component.set("v.isOpen", false);
        	 
        	var action = component.get("c.AddFileAttachments");
        	action.setParams({
        		IdsList : SubOptions,
        		mainObjectFieldAPI : component.get("v.mainObjectFieldAPI"),
        		mainObjectId : component.get("v.mainObjectId"),
        		selectedFiles : component.get("v.selectedFiles")
        	})
        	action.setCallback(this, function(response) {
        		var state = response.getState();
        		if (state === "SUCCESS") {
        			var result = response.getReturnValue();
        			$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
        			//$A.enqueueAction(component.get("c.onCancel"));
        			var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "File Uploaded Successfully"
                    });
                    toastEvent.fire();
                    component.get("v.onSuccess")(result);
        		}
        	});
        	$A.enqueueAction(action);
        }else{
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();  
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please select files"
            });
            toastEvent.fire();
        }
		
	},
	
	onCancel:function(component, event, helper){
		component.get("v.onCancel")();
	}
})