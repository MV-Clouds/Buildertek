({
    submitForm: function(component, event, helper, fileContents, parameters) {
        var accountRecord = component.get("v.accountRecord");
        accountRecord.Id = component.get("v.RecordId");
        var action = component.get("c.createPreQual");
        action.setParams({
            boxData: parameters,
            recId: component.get("v.RecordId"),
            accountRecord: accountRecord,
            "ref1": JSON.stringify(component.get("v.reference1")),
            "ref2": JSON.stringify(component.get("v.reference1")),
            "ref3": JSON.stringify(component.get("v.reference1")),
            "projectlist1": JSON.stringify(component.get("v.project1")),
            "projectlist2": JSON.stringify(component.get("v.project2")),
            "projectlist3": JSON.stringify(component.get("v.project3")),
        });

        action.setCallback(this, function(response) {
            // var filesList = component.get("v.removefiledataList")
            console.log(component.get("v.removefiledataList"));


            if (response.getState() === 'SUCCESS' || !filesList) {
                // debugger;
                var result = response.getReturnValue();
                console.log("Result -----  Single PreQual")
                console.log(result)
                var boxfolderId = result.boxFolderId
                    // HTML file input, chosen by user
                var allFilesUploaded = false;
                var allFilesErrorMessages = [];
                let promises = [];
                var fileToUpload = JSON.stringify(component.get("v.fileData"));
                console.log("File included -------------------->" + fileToUpload);
                //  helper.fileUploadByConnected(component,event,JSON.parse(fileToUpload));
                if (result.EnableBox) {
                    var filesList = component.get("v.uploadFileList")
                    for (let i = 0; i < filesList.length; i++) {
                        promises.push(helper.sendtoBox(component, event, helper, filesList[i], boxfolderId, result.accessToken, i));
                    }
                } else {
                    /*  if(component.get("v.uploadFileList").length){
                          var elmnt = document.getElementById("pageTop");
                          elmnt.scrollIntoView();
                          this.uploadHelper(component, event,component.get("v.uploadFileList")[0]);
                          component.set("v.currFileIndex",1)
                      } */
                    console.log("Yes")
                    var vfWindow = component.find("vfFrame").getElement().contentWindow;
                    vfWindow.postMessage(component.get("v.fileData"), '*');
                    window.setTimeout(
                        $A.getCallback(function() {
                            // component.set("v.Spinner",true);
                        }), 5000
                    );
                }
                Promise.all(promises)
                    .then((result) => {
                        console.log("Entered Promise")
                            // debugger;
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
                        component.set("v.isError", true);
                        component.set("v.message", error);
                    })
                    /*
                        helper.sendtoBox(component,event,helper,filesList[0][i],boxfolderId,result.accessToken,i).then(
                            $A.getCallback(function(result) {
                                console.log(result);
                            }),
                            $A.getCallback(function(error){
                                console.log(error);
                                allFilesUploaded = false;
                                let ErrorMessage = 'For file '+i+' '+error.message;
                                allFilesErrorMessages.push(error.Message);
                            })  
                        ).then(function(){
                            console.log(i+'ccc');
                           if( i== filesList[0].length-1){
                               var elmnt = document.getElementById("pageTop");
                    		   elmnt.scrollIntoView();
                                if(allFilesUploaded){     
                                    component.set("v.showSuccessMessage", true);
                                    component.set("v.isDisabled", true);
                                    component.set("v.Spinner", false);
                                    component.set("v.message", 'file(s) uploaded successfully');
                                    component.set("v.isSuccess", true);
                                    component.set("v.isError", false);
                                    component.set("v.Spinner", false);
                                    component.set("v.Spinner", false); 
                                }else{
                                    console.log(allFilesErrorMessages);
                                    component.set("v.Spinner", false);
                                    component.set("v.isError",true);
                                    component.set("v.message", allFilesErrorMessages.toString());
                                }
                           } 
                        });*/

                // }
            } else {
                console.error(response.getError())
                var elmnt = document.getElementById("pageTop");
                elmnt.scrollIntoView();
                //component.set("v.message", result.Message);
                component.set("v.message", 'error!!');
                component.set("v.isSuccess", false);
                component.set("v.isError", true);
                component.set("v.Spinner", false);
            }


        });
        $A.enqueueAction(action);
        console.log(component.get("v.reference1"));
        console.log(component.get("v.project1"));
    },
    MultiplesubmitForm: function(component, event, helper, fileContents, parameters) {
        console.log("yes")
        console.error(JSON.stringify(component.get("v.fileData")));
        var preQualRecord = component.get("v.preQualRecord");
        preQualRecord.Id = component.get("v.RecordId");
        //preQualRecord.buildertek__Account__c = component.get("v.RecordId");
        var action = component.get("c.createMultiPreQual");
        action.setParams({

            boxData: parameters,
            recId: component.get("v.RecordId"),
            preQualRecord: preQualRecord,
            "ref1": JSON.stringify(component.get("v.reference1")),
            "ref2": JSON.stringify(component.get("v.reference1")),
            "ref3": JSON.stringify(component.get("v.reference1")),
            "projectlist1": JSON.stringify(component.get("v.project1")),
            "projectlist2": JSON.stringify(component.get("v.project2")),
            "projectlist3": JSON.stringify(component.get("v.project3")),
        });
        action.setCallback(this, function(response) {
            // var filesList = component.get("v.removefiledataList")

            var filesList = component.get("v.uploadFileList")

            //alert(response.getState());
            if (response.getState() === 'SUCCESS' || !filesList) {
                // debugger;
                var result = response.getReturnValue();
                var boxfolderId = result.boxFolderId
                console.log("Result -----  Multi PreQual")
                console.log(result)
                    // HTML file input, chosen by user
                var allFilesUploaded = false;
                var allFilesErrorMessages = [];
                let promises = [];
                var fileToUpload = JSON.stringify(component.get("v.fileData"));
                // debugger;
                console.log("File Include ---------------> " + fileToUpload);
                if (result.EnableBox) {
                    for (let i = 0; i < filesList.length; i++) {
                        promises.push(helper.sendtoBox(component, event, helper, filesList[i], boxfolderId, result.accessToken, i));
                    }
                } else {
                    /* if(component.get("v.uploadFileList").length){
                         console.error(JSON.stringify(component.get("v.uploadFileList")));
                         var elmnt = document.getElementById("pageTop");
                         elmnt.scrollIntoView();
                         helper.uploadHelper(component, event,component.get("v.uploadFileList")[0]);
                         component.set("v.currFileIndex",1)
                     } */
                    console.log("Yes")
                    var vfWindow = component.find("vfFrame").getElement().contentWindow;
                    console.log({ vfWindow });
                    vfWindow.postMessage(component.get("v.fileData"), '*');
                    window.setTimeout(
                        $A.getCallback(function() {
                            //  component.set("v.Spinner",true);
                        }), 5000
                    );
                }
                Promise.all(promises)
                    .then((result) => {
                        console.log("Entered Promise")
                            // debugger;
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
                        // debugger;
                        component.set("v.Spinner", false);
                        component.set("v.isError", true);
                        component.set("v.message", error);
                    })
                    /*
                        helper.sendtoBox(component,event,helper,filesList[0][i],boxfolderId,result.accessToken,i).then(
                            $A.getCallback(function(result) {
                                console.log(result);
                            }),
                            $A.getCallback(function(error){
                                console.log(error);
                                allFilesUploaded = false;
                                let ErrorMessage = 'For file '+i+' '+error.message;
                                allFilesErrorMessages.push(error.Message);
                            })  
                        ).then(function(){
                            console.log(i+'ccc');
                           if( i== filesList[0].length-1){
                               var elmnt = document.getElementById("pageTop");
                    		   elmnt.scrollIntoView();
                                if(allFilesUploaded){     
                                    component.set("v.showSuccessMessage", true);
                                    component.set("v.isDisabled", true);
                                    component.set("v.Spinner", false);
                                    component.set("v.message", 'file(s) uploaded successfully');
                                    component.set("v.isSuccess", true);
                                    component.set("v.isError", false);
                                    component.set("v.Spinner", false);
                                    component.set("v.Spinner", false); 
                                }else{
                                    console.log(allFilesErrorMessages);
                                    component.set("v.Spinner", false);
                                    component.set("v.isError",true);
                                    component.set("v.message", allFilesErrorMessages.toString());
                                }
                           } 
                        });*/

                // }
            } else {
                var elmnt = document.getElementById("pageTop");
                elmnt.scrollIntoView();
                // debugger;
                //component.set("v.message", result.Message);

                component.set("v.message", 'error!!');
                component.set("v.isSuccess", false);
                component.set("v.isError", true);
                component.set("v.Spinner", false);
            }


        });
        $A.enqueueAction(action);
    },


    sendtoBox: function(component, event, helper, currentFile, boxfolderId, accessToken, iterator) {
        return new Promise($A.getCallback(function(resolve, reject) {
            var data = new FormData();
            data.append('file[' + iterator + ']', currentFile);
            const url = 'https://upload.box.com/api/2.0/files/content?parent_id=' + boxfolderId;
            const xhr = new XMLHttpRequest();
            xhr.open("POST", url, true);
            xhr.setRequestHeader('Access-Control-Allow-Origin', '*');
            xhr.setRequestHeader('Authorization', 'Bearer ' + accessToken);
            xhr.onload = function() {
                var result = JSON.parse(this.responseText);
                if (this.status === 200 || this.status === 201) {
                    var elmnt = document.getElementById("pageTop");
                    elmnt.scrollIntoView();
                    resolve(result);
                } else {
                    console.log(result.message);
                    reject(result.message);
                }
            };
            xhr.send(data);
        }));
    },
    readFiles: function(component, event, helper, file) {
        var filesList = component.get("v.fileData");
        var reader = new FileReader();
        reader.onload = () => {
            var base64 = reader.result.split(',')[1];
            var fileData = {
                    'fileName': file.name,
                    'fileContent': base64,
                    'parentRec': component.get("v.RecordId")
                }
                //filesList.push(fileData);
                //component.set("v.fileData", filesList);
            component.get("v.fileData").push(fileData);


        }
        reader.readAsDataURL(file);
    },

    //----------------Hemanth---------------------

    MAX_FILE_SIZE: 2800000, //Max file size 4.5 MB 
    CHUNK_SIZE: 2800000, //Chunk Max size 750Kb 

    uploadHelper: function(component, event, f) {
        component.set("v.showLoadingSpinner", true);
        var file = f;
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            // debugger;
            component.set("v.showLoadingSpinner", false);
            component.set("v.Spinner", false);
            component.set("v.isError", true);
            component.set("v.isSuccess", false);
            component.set("v.showSuccessMessage", false);
            //component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            component.set("v.message", 'File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            var elmnt = document.getElementById("pageTop");
            elmnt.scrollIntoView();
            window.setTimeout(function() {
                component.set("v.isError", false)
            }, 7000)
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
            parentId: component.get("v.RecordId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });

        // set call back 
        action.setCallback(this, function(response) {
            attachId = response.getReturnValue();
            var state = response.getState();
            // debugger;

            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    if (component.get("v.uploadFileList")[component.get("v.currFileIndex")]) {
                        var idx = component.get("v.currFileIndex");
                        //component.set("v.currFileIndex",idx+1);
                        var fileLst = component.get("v.uploadFileList")
                        fileLst.splice(0, 1);
                        var namelist = component.get("v.FileNameList");
                        namelist.splice(0, 1);

                        component.set("v.FileNameList", namelist);
                        component.set("v.ErrorFileName", namelist[0]);

                        this.uploadHelper(component, event, component.get("v.uploadFileList")[0]);
                    } else {
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
                helper.showMessage("From server: " + response.getReturnValue(), false);
            } else if (state === "ERROR") {
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
    showMessage: function(message, isSuccess) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": isSuccess ? "Success!" : "Error!",
            "type": isSuccess ? "success" : "error",
            "message": message
        });
        toastEvent.fire();
    },
})