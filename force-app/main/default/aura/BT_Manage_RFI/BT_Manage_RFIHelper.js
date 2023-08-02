({
	getrfirecords : function(component, event, helper) {
        var action = component.get("c.rfiresgetrfiFieldSet");
        action.setParams({
            sObjectName : "buildertek__RFI_Response__c",
            fieldSetName  : "buildertek__RFI_Response_Community_Field_Set",
            parentRecordId : component.get("v.rfiId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            
            component.set("v.rfiresponsefieldSetValues", fieldSetObj);
        })
        $A.enqueueAction(action);
        var action = component.get("c.getrfiresponeserecords");
        action.setParams({
            parentRecordId : component.get("v.recordId")// component.get("v.rfiId")
        })
        action.setCallback(this, function (response) {
          //  var fieldSetObj = JSON.parse(response.getReturnValue());
             var fieldSetObj = response.getReturnValue();
            //fieldSetObj.push({})
            var mapData = []
            for(var i=0;i<Object.keys(fieldSetObj).length;i++){
                var obj = {};
                obj['rfi'] = Object.keys(fieldSetObj)[i]
                if(fieldSetObj[Object.keys(fieldSetObj)[i]].length){
                    obj['rfires'] = fieldSetObj[Object.keys(fieldSetObj)[i]]
                }else{
                    obj['rfires'] = undefined
                }
                
                mapData.push(obj)
            }
            component.set("v.rfiresponseList", mapData);
        })
        $A.enqueueAction(action);
         
        var action = component.get("c.getrfiresponserelatedfiles");
        action.setParams({
            parentRecordId : component.get("v.rfiId")  //component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fileslist = response.getReturnValue();
            var rfisAndRfiResRecList = component.get("v.rfiresponseList")
            if(rfisAndRfiResRecList){
                for(var i=0;i<rfisAndRfiResRecList.length;i++){
                    if(rfisAndRfiResRecList[i].rfires){
                        
                        for(var j=0;j<rfisAndRfiResRecList[i].rfires.length;j++){
                            
                            if(Object.keys(fileslist).indexOf(rfisAndRfiResRecList[i].rfires[j].Id) > -1){
                                var idx = Object.keys(fileslist).indexOf(rfisAndRfiResRecList[i].rfires[j].Id)
                                rfisAndRfiResRecList[i].rfires[j]['rfiresfilesList'] = Object.values(fileslist)[idx]
                                
                            }
                        }
                    }
                }
            }
            
            //component.set("v.rfiresponsefilesList", fileslist);
            component.set("v.rfiresponseList", rfisAndRfiResRecList);
            /*if(fileslist.length){
               component.set("v.rfiresponsefilesList", fileslist[0]); 
            }else{
                component.set("v.rfiresponsefilesList", fileslist);
            }*/
            
        })
        $A.enqueueAction(action);
	},
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb      
    filesCount : 0,
    fileInputLenght: 0,
     /**
     * This method to upload files
     * @param: File Data
     */
    uploadHelper: function(component, event, recid,helper) {
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fuploader").get("v.files");
        this.fileInputLenght = fileInput.length;
        //alert('uploadHelper--->'+recid);
        for (var i = 0; i < fileInput.length; i++) { 
            var file = fileInput[i];
            var self = this;
            // check the selected file size, if select file size greter then MAX_FILE_SIZE,
            // then show a alert msg to user,hide the loading spinner and return from function 
            if (file.size > self.MAX_FILE_SIZE) {
                component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                this.showMessage('Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size,false);
                return;
            }
            self.uploadFile(component, file,recid,helper); 
        }
    }, 
     /**
     * This method to upload files
     * @param: File Data
     */
    uploadFile:function(component, file,recid,helper) {
        //alert('uploadFile--->'+recid);
        var self = this;
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {              
            component.set("v.IsSpinner",true);
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents,recid,helper);
        });
        objFileReader.readAsDataURL(file);
    }, 
     /**
     * This method to upload files
     * @param: File Data
     */
    uploadProcess: function(component, file, fileContents,recid,helper) {
        //alert('uploadProcess--->'+recid);
        console.log("Uploading files"); 
        var self = this;
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '',recid,helper); 
        
    },
     /**
     * This method to upload files
     * @param: File Data,Safety Event Id
     */
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId,recid,helper) {
        component.set("v.IsSpinner",true); 
       // component.set("v.isSubmit",true);
        // call the apex method 'SaveFile'
        //alert('uploadInChunk--->'+recid);       
        var getchunk = fileContents.substring(startPosition, endPosition);
        //alert('getchunk--->'+getchunk);
        var action = component.get("c.saveTheChunk");
        action.setParams({ 
            parentId: recid,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type, 
            fileId: attachId
        });
        // set call back 
        action.setCallback(this, function(response) { 
            component.set("v.IsSpinner",true);
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            //alert('attachId--->'+attachId);
            var state = response.getState();
            //alert('state--->'+state);
            if (state === "SUCCESS") {
                component.set("v.IsSpinner",true);
                this.filesCount++;
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId,recid,helper);
                } else {
                    this.showMessage('RFI Response created successfully',true);
                   /* var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "related"
                    });
                    navEvt.fire();*/
                    component.set("v.IsSpinner",false);
                    component.set("v.newRFI",false);
                    component.set("v.isrfi",true);
                    component.set("v.newRFIForward",false);
            		component.set("v.newRFIResponseForward",false);  
                    helper.getrfirecords(component, event, helper);
                    //component.set("v.isSubmit",true);
                }
               /* if(this.filesCount == this.fileInputLenght){ 
                    component.set("v.IsSpinner",false);
                   
                }*/
                // handel the response errors        
            } else if (state === "INCOMPLETE") { 
                component.set("v.Spinner", false); 
                this.showMessage("From server: " + response.getReturnValue(),false);
                window.setTimeout(
                    $A.getCallback(function() {
                        window.open ("/"+escape(component.get("v.rfiId")),"_Self");
                    }), 6000
                );
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        this.showMessage("Error message: " + response.getReturnValue(),false);
                    }
                } else {
                    console.log("Unknown error");
                    this.showMessage("Unknown error",false);
                }
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
    
    getFiles : function(component, event, helper,relatedid) {
        //alert(relatedid);
        //alert('selectedFiles length  ------>    '+component.get("v.selectedFiles").length);
        //alert('selectedFiles   ------>    '+JSON.stringify(component.get("v.selectedFiles")));
        var action = component.get("c.getFileAttachments");
        action.setParams({
            "recordId" : relatedid
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result =  response.getReturnValue();
                if(result != undefined){
                    result = JSON.parse(result);     
                }
                var selectedFiles = [];
                var customFiles;
                var standardFiles;
                var attachments;
                if(result != undefined){
                    for(var i=0;i<result.length;i++){
                        customFiles = result[i].customFilesList;
                        standardFiles = result[i].ContentVersionList;
                        attachments = result[i].attachmentList;
                        if(customFiles != undefined){
                            for(var j=0;j<customFiles.length;j++ ){
                                selectedFiles.push({
                                    'Id' : customFiles[j].Id,
                                    'Name' : customFiles[j].Name
                                });
                            }
                        }
                        if(standardFiles != undefined){
                            for(var k=0;k<standardFiles.length;k++ ){
                                selectedFiles.push({
                                    'Id' : standardFiles[k].ContentDocumentId,
                                    'Name' : standardFiles[k].Title
                                });
                            }
                        }
                        
                        if(attachments != undefined){ 
                            for(var l=0;l<attachments.length;l++ ){
                                selectedFiles.push({
                                    'Id' : attachments[l].Id,
                                    'Name' : attachments[l].Name
                                });
                            }
                        } 
                        
                    }
                    component.set("v.selectedFiles", selectedFiles);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
        
     copyfilesHelper : function(component,newresponserecid) {
        var action = component.get("c.copyFiles"); 
        //alert(newresponserecid);
        //alert(JSON.stringify(component.get('v.uploadedFileIds')));
        action.setParams({
            parentId: newresponserecid,            
            fileIds: component.get('v.uploadedFileIds'),
            recordId: component.get('v.recordId')
        });       
        action.setCallback(this, function(a) {
            var state = a.getState(); 
            this.showMessage('RFI Response created successfully',true);
            this.getrfirecords(component, event, helper);
            /* var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "related"
                    });
                    navEvt.fire();*/
            component.set("v.IsSpinner",false);
            
            //location.reload();
            
        });
        $A.enqueueAction(action); 
         
    }
    
    
    
})