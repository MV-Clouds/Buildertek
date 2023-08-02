/*({
    
	getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
})*/


({
	getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
        
    
    
	MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000, //Chunk Max size 750Kb 

    uploadHelper: function(component, event,f) {
       	component.set("v.showLoadingSpinner", true);
       	var file = f;
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            this.showMessage('Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size,false);
            return;
        }

        // Convert file content in Base64
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            self.uploadProcess(component, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },

    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },


    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveFile'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveTheChunkFile");
        action.setParams({
            // Take current object's opened record. You can set dynamic values here as well
            parentId: component.get("v.submittalRecordId"),//component.get("v.submittalRecordId"), 
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });

        // set call back 
        action.setCallback(this, function(response) {
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    this.showMessage('Submittal created successfully',true);
                    component.set("v.showLoadingSpinner", false);
                    var workspaceAPI = component.find("workspace");
                     component.set("v.Spinner", false); 
                    if(!component.get("v.isSaveAndNew")){
                        $A.get("e.force:closeQuickAction").fire();
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({tabId: focusedTabId});
                        })
                        .catch(function(error) {
                            console.log(error);
                        });
                        
                        
                        window.open ("/"+escape(component.get("v.submittalRecordId")),"_Self");
                    }else{
                        component.get("v.isSaveAndNew",false);
                        window.location.reload(true);
                    }
                    
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                component.set("v.Spinner", false); 
                this.showMessage("From server: " + response.getReturnValue(),false);
                window.setTimeout(
                    $A.getCallback(function() {
                        window.open ("/"+escape(component.get("v.submittalRecordId")),"_Self");
                    }), 6000
                );
            } else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.Spinner", false); 
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        this.showMessage("Error message: " + response.getReturnValue(),false);
                    }
                } else {
                    console.log("Unknown error");
                    this.showMessage("Unknown error",false);
                }
                 window.setTimeout(
                    $A.getCallback(function() {
                        window.open ("/"+escape(component.get("v.submittalRecordId")),"_Self");
                    }), 6000
                );
            }
        });
        $A.enqueueAction(action);
    },
    showMessage : function(message,isSuccess) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": isSuccess?"Success!":"Error!",
            "type":isSuccess?"success":"error",
            "message": message,
            'duration': '10000',
            'mode': 'dismissible'
        });
        toastEvent.fire();
    },
    
    
   /* attachuploadedFileToRecord : function(component,event,recordId,FileList){
        var action = component.get("c.attachToRecord");
		 action.setParams({
            // Take current object's opened record. You can set dynamic values here as well
            parentId: component.get("v.submittalRecordId"),//component.get("v.submittalRecordId"), 
             FileIdsList: FileList
        });     
         action.setCallback(this, function(response) {
            attachId = response.getReturnValue();
            var state = response.getState();
             if (state === "SUCCESS") {
                 var response = response.getReturnValue();
                 if(response == 'SUCCESS'){
                     
                 }else{
                     this.showMessage(response,false);
                 }
                 
             }
         });
         
         $A.enqueueAction(action);
    },*/
    
    
    
    
    
    
    
    
    
    
    
    
})