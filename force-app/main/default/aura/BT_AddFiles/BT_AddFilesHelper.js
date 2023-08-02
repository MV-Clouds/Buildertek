({
	getConfig : function(component, event, helper) {
	    component.set("v.Spinner", true);
		var mofa, moi, action;
		
        mofa = component.get("v.mainObjectFieldAPI");
        moi = component.get("v.mainObjectId");
        //alert(mofa);
        //alert(moi);
        action = component.get("c.getConfig");
        action.setParams({
            "mofa": mofa,
            "moi": moi
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.Spinner", false);
                console.log(response.getReturnValue());
                component.set("v.selectedBucket",response.getReturnValue().Name);
                component.set("v.selectedFolder",response.getReturnValue().Id);
                
            }
        });
        $A.enqueueAction(action);
	},
	
	getProjectFiles : function(component, event, helper) {
	   component.set("v.Spinner", true);
	    var action = component.get("c.getFiles");
	    action.setParams({
	        "recordId" : component.get("v.mainObjectId"),
	        "objectAPI" : component.get("v.mainObjectFieldAPI")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            component.set("v.Spinner", false);
	            var result = response.getReturnValue();
	            component.set("v.filesList", result);
	            component.set("v.filteredFilesList", result);
	            helper.highlightSelectedRow(component, event, helper);
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	getuploadedFiles:function(component, documentIds){
        //alert(documentIds);
        var action = component.get("c.getFilesUploaded");  
        action.setParams({  
            "recordIds": documentIds,
            "mainObjectId": component.get("v.mainObjectId"),
            "mainObjectFieldAPI": component.get("v.mainObjectFieldAPI"),
            "selectedFiles": component.get("v.selectedFiles")
        });      
        action.setCallback(this,function(response){ 
            var state = response.getState(); 
            //alert('state --------> '+state);
            if(state=='SUCCESS'){  
                component.set("v.Spinner", false);
                var result = response.getReturnValue();
                if(result.IsSuccess == 'Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": result.Message
                    });
                    toastEvent.fire();
                    component.get("v.onSuccess")(result.filesList);    
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": result.Message
                });
                toastEvent.fire();    
            }  
        });  
        $A.enqueueAction(action);  
    },
    
    highlightSelectedRow : function(component, event, helper) {
	    var selectedContracts = component.get("v.isOwnerFiles");
	    var selectedMeetingReports = component.get("v.isRecentFiles");
	    var selectedbidReports = component.get("v.isRelatedFiles");
	    
	    var cmpTargetContracts = component.find('ownerFilesId');
	    var cmpTargetContract = component.find('ownerFileId');
	    
	    var cmpTargetMeetingReports = component.find('recentFilesId');
	    var cmpTargetMeetingReport = component.find('recentFileId');
	    
	    var cmpTargetbidReports = component.find('relatedFilesId');
	    var cmpTargetbidReport = component.find('relatedFileId');
	    
	    if(selectedContracts == true){
	        $A.util.addClass(cmpTargetContracts, 'selected'); 
	        $A.util.addClass(cmpTargetContract, 'selected'); 
	    }else{
	        $A.util.removeClass(cmpTargetContracts, 'selected');
	        $A.util.removeClass(cmpTargetContract, 'selected');
	    } 
	    if(selectedMeetingReports == true){
	        $A.util.addClass(cmpTargetMeetingReports, 'selected'); 
	        $A.util.addClass(cmpTargetMeetingReport, 'selected');
	    }else{
	        $A.util.removeClass(cmpTargetMeetingReports, 'selected');
	        $A.util.removeClass(cmpTargetMeetingReport, 'selected');
	    }
	    
	    if(selectedbidReports == true){
	        $A.util.addClass(cmpTargetbidReports, 'selected'); 
	        $A.util.addClass(cmpTargetbidReport, 'selected');
	    }else{
	        $A.util.removeClass(cmpTargetbidReports, 'selected');
	        $A.util.removeClass(cmpTargetbidReport, 'selected');
	    }
	},
    
})