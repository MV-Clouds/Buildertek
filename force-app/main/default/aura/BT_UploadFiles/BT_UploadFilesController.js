({
	
	init:function(component, event, helper){
	    //alert('RecordId -------> '+component.get("v.mainObjectFieldAPI"));
		helper.getConfig(component, event, helper);
		helper.getProjectFiles(component, event, helper);
	},
	
	showFileNameField : function(component, event, helper) {
    	var input = document.getElementById('fileToUpload');
    	if(input.files.length > 0 ){
    		var file = input.files[0];
    		component.set("v.filename",file.name);
    	}
	},
	
	selectAll : function(component, event, helper) {        
    	var selectedHeaderCheck = event.getSource().get("v.value");
    	var filesList = component.get("v.filesList");
    	var getAllId = component.find("checkContractor");
    	/*if(! Array.isArray(getAllId)){
    	   if(selectedHeaderCheck == true){ 
    	       alert('true');   
    		  component.find("checkContractor").set("v.value", true);
    		  alert('true 1');  
    	   }else{
    	       alert('false');
    		   component.find("checkContractor").set("v.value", false);
    	   }
    	}
    	else{ 
    	    alert('else');*/
    	    if(getAllId != undefined){
    	        if (selectedHeaderCheck == true) {
        			for (var i = 0; i < getAllId.length; i++) {
        				component.find("checkContractor")[i].set("v.value", true); 
        				var checkbox = component.find("checkContractor")[i].get("v.text");  
        				filesList[i].IsChecked = true;
        			}
            			//alert('FilesList --------> '+JSON.stringify(component.get("v.filesList")));
        		} 
        		else{
        			for (var i = 0; i < getAllId.length; i++) {
        				component.find("checkContractor")[i].set("v.value", false);
        				var checkbox = component.find("checkContractor")[i].get("v.text"); 
        				var filesList = component.get("v.filesList");
        				filesList[i].IsChecked = false;
        		   }
        		   //alert('FilesList Final  --------> '+JSON.stringify(component.get("v.filesList")));
        	   }     
    	    }
    		
    	//}
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
		var input = document.getElementById('fileToUpload');
		var fileName =  document.getElementById('fileNameField').value;
		var filesList = component.get("v.filesList");
        var SubOptions = [];
        for(var i=0 ; i < filesList.length;i++){
        	//alert('filesList[i].IsChecked -------> '+filesList[i].IsChecked);
        	if(filesList[i].IsChecked == true){
        		SubOptions.push(filesList[i].FileId);
        	}
        }
    	if(input.files.length > 0 ){
    		var file = input.files[0];
			var att = {};
			att.Size = file.size;
			att.Name = file.name;
			att.Extension = '.'+file.name.split('.').pop();
			att.ContentType = file.type;
			helper.setFileNameWithExtension(att);
			
			att.ContentType = file.type;
			//j$("#fileNameField").val(att.Name);
			att.BucketName = component.get("v.selectedBucket");
			att.Folder = component.get("v.selectedFolder");
			att.Replace = false;
			att.AccessType = 'public';
			att.PublicOnAmazon = true;
			att.AllowCopy = true;
			att.AllowShareViaURL = true;
			att.TrackDownload = false;
			
			document.getElementById('filekey').value = att.Name;
			
			helper.setSuccessActionUrl(component, event, helper, att);
    	}
    	
        if(SubOptions.length > 0){
        	component.set("v.selectedobjInfo",SubOptions);
        	 //component.set("v.isOpen", false);
        	 
        	var action = component.get("c.InsertAttachment");
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
        			if(input.files.length == 0 ){
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
            			/*window.setTimeout(
                            $A.getCallback(function() {
                                $A.get('e.force:refreshView').fire();
                            }), 2000
                        );*/
        			}
        		}
        	});
        	$A.enqueueAction(action);
        }else if(SubOptions.length == 0 && input.files.length == 0 ){
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();  
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please select files"
            });
            toastEvent.fire();
        }/*else{
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();  
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please select files"
            });
            toastEvent.fire();    
        }*/
		
	},
	
	onCancel:function(component, event, helper){
		component.get("v.onCancel")();
	}
})