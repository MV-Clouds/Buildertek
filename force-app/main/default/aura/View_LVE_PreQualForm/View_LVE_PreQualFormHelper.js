({
    readFiles : function(component, event, helper, file){
        var filesList = component.get("v.fileData");
        var reader = new FileReader(); 
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]; 
            var fileData = {
            'fileName': file.name,
            'fileContent': base64,
            'parentId': component.get("v.recordId")
        }
      //  alert(JSON.stringify(fileData));
        //filesList.push(fileData);
        //component.set("v.fileData", filesList);
        component.get("v.fileData").push(fileData);
        
    }
    reader.readAsDataURL(file);
},
 submitForm : function(component, event, helper, fileContents,parameters){
    debugger;
    var action = component.get("c.savePreQualData");
    action.setParams({
        "JsonString" : parameters,
        "recordId" : component.get("v.recordId"),
        "projectlist1" : JSON.stringify(component.get("v.project1")),
        "projectlist2" : JSON.stringify(component.get("v.project2")),
        "projectlist3" : JSON.stringify(component.get("v.project3")),
        "refList1" : JSON.stringify(component.get("v.reference1")),
        "refList2" : JSON.stringify(component.get("v.reference2")),
        "refList3" : JSON.stringify(component.get("v.reference3"))
    });
    action.setCallback(this, function( response ) {
        var state = response.getState();
        var filesList = component.get("v.uploadFileList")
        if(response.getState() === 'SUCCESS' || !filesList){
            var result = response.getReturnValue();
            if(result.isError == false){
                var boxfolderId = result.boxFolderId
            // HTML file input, chosen by user
            var allFilesUploaded = false;
            var allFilesErrorMessages = [];
            let promises = [];
                 var fileToUpload =  JSON.stringify(component.get("v.fileData"));
                if(result.EnableBox){
            for(let i=0;i<filesList.length;i++){
                promises.push(helper.sendtoBox(component,event,helper,filesList[i],boxfolderId,result.accessToken,i));
            }
                }
               else{
                     if(component.get("v.uploadFileList").length){
                                            var elmnt = document.getElementById("pageTop");
                                        elmnt.scrollIntoView();
                                            helper.uploadHelper(component, event,component.get("v.uploadFileList")[0]);
                                            component.set("v.currFileIndex",1)
                                        }
                /*    var action1 = component.get("c.uploadFilesInSalesforce");
                    action1.setParams({ fileData : fileToUpload });
                    action1.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            console.log("File uploaded in salesforce")
                            console.log(JSON.stringify(response.getReturnValue()))
                        }
                        else if (state === "INCOMPLETE") {
                            
                        }
                            else if (state === "ERROR") {
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        console.log("Error message: " + 
                                                    errors[0].message);
                                    }
                                } else {
                                    console.log("Unknown error");
                                }
                            }
                    });
                    
                    $A.enqueueAction(action1); */
                }
            Promise.all(promises)
            .then((result) => {
                var elmnt = document.getElementById("pageTop");
                elmnt.scrollIntoView();
                component.set("v.showSuccessMessage", true);
                component.set("v.isDisabled", true);
                component.set("v.Spinner", false);
                component.set("v.message", 'file(s) uploaded successfully');
                component.set("v.isSuccess", true);
                component.set("v.isError", false);
                component.set("v.Spinner", false);
                component.set("v.Spinner", false); 
            })
            .catch((error) => {
                component.set("v.Spinner", false);
                component.set("v.isError",true);
                var elmnt = document.getElementById("pageTop");
                elmnt.scrollIntoView();
                if(error == 'Item with the same name already exists'){
                   component.set("v.message", 'File with the same name already exists');
               }else{
                  component.set("v.message", error);
               }
                
            }) 
            }else{
               var elmnt = document.getElementById("pageTop");
                elmnt.scrollIntoView();
                var result = response.getReturnValue();
                component.set("v.isError",true);
               
                component.set("v.Spinner", false);
                component.set("v.message", result.errorMessage); 
            }
            
                
            }else{
                debugger;
                var elmnt = document.getElementById("pageTop");
                elmnt.scrollIntoView();
                var result = response.getReturnValue();
                component.set("v.isError",true);
                console.log("Error");
                console.error(response.getError());
                component.set("v.Spinner", false);
              //  component.set("v.message", result.errorMessage);
              
            }
            });
                $A.enqueueAction(action);
            },
                
                
                
                
                sendtoBox: function(component,event,helper,currentFile,boxfolderId,accessToken,iterator){
              
                    
                    return new Promise($A.getCallback(function (resolve, reject) {
                        var data = new FormData();
                        data.append('file['+iterator+']', currentFile); 
                        const url = 'https://upload.box.com/api/2.0/files/content?parent_id='+boxfolderId;
                        const xhr = new XMLHttpRequest();
                        xhr.open("POST", url, true);
                        xhr.setRequestHeader('Access-Control-Allow-Origin', '*');
                        xhr.setRequestHeader('Authorization', 'Bearer '+accessToken);               
                        xhr.onload = function() {
                            var result = JSON.parse(this.responseText);
                            if(this.status === 200 || this.status === 201) {
                                var elmnt = document.getElementById("pageTop");
                                elmnt.scrollIntoView(); 
                                resolve(result);
                            }
                            else{
                                console.log(result.message);
                                reject(result.message);
                            }  
                        };
                        xhr.send(data);
                    }));
                },
                
                
                
                       MAX_FILE_SIZE: 2800000, //Max file size 4.5 MB 
        CHUNK_SIZE: 2800000, //Chunk Max size 750Kb 
            
            uploadHelper: function(component, event,f) {
                component.set("v.showLoadingSpinner", true);
                var file = f;
                var self = this;
                // check the selected file size, if select file size greter then MAX_FILE_SIZE,
                // then show a alert msg to user,hide the loading spinner and return from function  
                if (file.size > self.MAX_FILE_SIZE) {
                    debugger;
                    component.set("v.showLoadingSpinner", false);
                    component.set("v.Spinner", false);
                    component.set("v.isError", true);
                    component.set("v.isSuccess", false);
                    component.set("v.showSuccessMessage", false);
                    //component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                    component.set("v.message", 'File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                    var elmnt = document.getElementById("pageTop");
                    elmnt.scrollIntoView();
                    window.setTimeout(function(){
                        component.set("v.isError",false)
                    },7000) 
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
                // self.uploadProcess(component, file, fileContents);
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
                        
                        var action = component.get("c.saveFile");
                        
                        action.setParams({
                            
                            // Take current object's opened record. You can set dynamic values here as well
                            parentId: component.get("v.recordId"), 
                            fileName: file.name,
                            base64Data: encodeURIComponent(getchunk),
                            contentType: file.type,
                            fileId: attachId
                        });
                        
                        // set call back 
                        action.setCallback(this, function(response) {
                            attachId = response.getReturnValue();
                            var state = response.getState();
                            debugger;
                           
                            if (state === "SUCCESS") {
                                console.log("File uploaded")
                                // update the start position with end postion
                                startPosition = endPosition;
                                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                                if (startPosition < endPosition) {
                                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                                } else {
                                    if(component.get("v.uploadFileList")[component.get("v.currFileIndex")]){
                                        var idx = component.get("v.currFileIndex");
                                        //component.set("v.currFileIndex",idx+1);
                                        var fileLst = component.get("v.uploadFileList")
                                        fileLst.splice(0,1);
                                        var namelist = component.get("v.FileNameList");
                                        namelist.splice(0,1);
                                        
                                        component.set("v.FileNameList",namelist);
                                        component.set("v.ErrorFileName",namelist[0]);
                                        
                                        this.uploadHelper(component, event,component.get("v.uploadFileList")[0]);
                                    }else{
                                      /*  var signAction = component.get("c.handleClick");
                                        $A.enqueueAction(signAction);
                                        component.set("v.Spinner", false);  
                                        component.set("v.showFileError",false) */
                                    }
                                    // helper.showMessage('your File is uploaded successfully',true);
                                    component.set("v.showLoadingSpinner", false);
                                }
                                // handel the response errors        
                            } else if (state === "INCOMPLETE") {
                                debugger;
                                helper.showMessage("From server: " + response.getReturnValue(),false);
                            } else if (state === "ERROR") {
                                debugger;
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        console.log("Error message: " + errors[0].message);
                                    }
                                } else {
                                    console.log("Unknown error");
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
                                "message": message
                            });
                            toastEvent.fire();
                        }
            })