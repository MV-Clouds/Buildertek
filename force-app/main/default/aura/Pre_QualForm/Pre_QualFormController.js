({
    doInit: function(component, event, helper) {

        // debugger;
        var action20 = component.get("c.getMetaData");
        action20.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // alert("From server: " + JSON.stringify(response.getReturnValue()));
                var result = response.getReturnValue();
                if (result) {
                    component.set("v.Header", result.buildertek__Header__c);
                    component.set("v.Header1", result.buildertek__Header_1__c);
                    component.set("v.Header2", result.buildertek__Header_2__c);
                    component.set("v.stylesData", result.buildertek__Height_Width__c);
                }
            } else if (state === "INCOMPLETE") {
                console.log("Incomplete Error Line number 12");
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
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
        $A.enqueueAction(action20);

        /* var action = component.get("c.getPickListValuesIntoList"); 
             action.setParams({
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    console.log('company type pick list values'+response.getReturnValue());
                    component.set("v.companyTypeList",response.getReturnValue());
                }
             });
             $A.enqueueAction(action);*/
        var action = component.get("c.getIsMultiPreQual");
        action.setParams({

        });
        action.setCallback(this, function(response) {
            //alert(response.getState())
            if (response.getState() === 'SUCCESS') {

                component.set("v.isMultiplePreQual", response.getReturnValue());
                var isPreview = component.get("v.isPreview");
                //alert(component.get("v.isMultiplePreQual"));
                // if(component.get("v.isMultiplePreQual") == false){ 

                if (component.get("v.RecordId") != '' && component.get("v.RecordId") != undefined) {
                    var recid = component.get("v.RecordId");
                    //alert(recid);
                }
                //alert('@@'+recid);

                component.set("v.Spinner", true);


                console.log('isPreview -----> ' + isPreview);
                console.log('document url ' + component.get("v.documentURL"));
                if (isPreview == 'yes') {
                    component.set("v.isInputDisabled", true);
                } else {
                    component.set("v.isInputDisabled", false);
                }
                component.set("v.Spinner", false);
                console.log("Account Record Id " + component.get("v.RecordId"));
                var action = component.get("c.getAccountRecord");
                action.setParams({
                    recordId: component.get("v.RecordId")
                });
                action.setCallback(this, function(response) {
                    //alert(response.getState())
                    if (response.getState() === 'SUCCESS') {

                        component.set("v.accountRecord", response.getReturnValue().acc);
                        component.set("v.project1", (response.getReturnValue().proj[0]));
                        component.set("v.project2", (response.getReturnValue().proj[1]));
                        component.set("v.project3", (response.getReturnValue().proj[2]));

                        component.set("v.reference1", (response.getReturnValue().ref[0]));
                        component.set("v.reference2", (response.getReturnValue().ref[1]));
                        component.set("v.reference3", (response.getReturnValue().ref[2]));

                    } else {
                        var errors = response.getError();
                        console.log("Error 65 in js " + JSON.stringify(errors))
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " +
                                    errors[0].message);

                            }
                        }
                    }
                });
                $A.enqueueAction(action);
                // }
            }
            //alert(component.get("v.isMultiplePreQual"));
        });
        $A.enqueueAction(action);

        // debugger;



    },

    closePage: function(component, event, helper) {
        window.close('/apex/buildertek__Pre_QualProcess_VF');
    },

    handleFilesChange: function(component, event, helper) {

        var action = component.get("c.checkEnableBox");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue()) {

                    var fileName = "No File Selected..";
                    var fileCount = event.target.files;
                    // alert(JSON.stringify(event.target.files));
                    var fileList = component.get("v.uploadFileList")
                    for (var i = 0; i < event.target.files.length; i++) {
                        fileList.push(event.target.files[i])
                    }

                    component.set("v.uploadFileList", fileList)
                    component.set("v.removefiledataList", fileCount);
                    console.log('fileCount -------> ' + JSON.stringify(fileCount));
                    var files = '';

                    var names = [];
                    for (var i = 0; i < component.get("v.fileData").length; i++) {
                        if (!fileList.includes(event.target.files[i])) {
                            names.push(component.get("v.fileData")[i]["fileName"])
                        }
                    }
                    for (var i = 0; i < fileCount.length; i++) {
                        names.push(fileCount[i]["name"])
                    }

                    component.get("v.fileData")
                    component.set("v.FileNameList", names);
                    var filedata = component.get("v.FileLabelList");

                    if (fileCount.length > 0) {
                        component.set("v.uploadFile", true);
                        for (var i = 0; i < fileCount.length; i++) {

                            fileName = fileCount[i]["name"];
                            if (files == '') {
                                files = fileName;
                            } else {
                                files = files + ',' + fileName;
                            }
                            helper.readFiles(component, event, helper, fileCount[i]);
                        }
                    }
                    component.set("v.fileName", files);
                } else {
                    var a = event.target.files;
                    console.log("Check 1 " + JSON.stringify(a))
                    if (a.length > 0) {

                        var names = [];
                        for (var b = 0; b < a.length; b++) {

                            const fsize = a.item(b).size;
                            const file = Math.round((fsize / 1024));
                            console.log("okokok  : " + file);
                            if (file >= 200000) {
                                var elmnt = document.getElementById("pageTop");
                                elmnt.scrollIntoView();
                                // debugger;
                                //component.set("v.message", result.Message);

                                component.set("v.message", 'File Limit Exceeded.');
                                component.set("v.isSuccess", false);
                                component.set("v.isError", true);
                                component.set("v.Spinner", false);
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        component.set("v.isError", false);
                                    }), 6000
                                );
                            } else {
                                var fileName = "No File Selected..";
                                var fileCount = a[b];
                                var fileList = component.get("v.uploadFileList")
                                if (!fileList.includes(a[b])) {
                                    fileList.push(a[b])
                                }
                                component.set("v.uploadFileList", fileList)
                                component.set("v.removefiledataList", fileCount);
                                console.log('fileCount -------> ' + JSON.stringify(fileCount));
                                var files = '';

                                for (var i = 0; i < component.get("v.fileData").length; i++) {
                                    if (!names.includes(component.get("v.fileData")[i]["fileName"]))
                                        names.push(component.get("v.fileData")[i]["fileName"])
                                }
                                names.push(fileCount["name"])
                                component.get("v.fileData")
                                component.set("v.FileNameList", names);
                                var filedata = component.get("v.FileLabelList");
                                component.set("v.uploadFile", true);
                                fileName = fileCount["name"];
                                if (files == '') {
                                    files = fileName;
                                } else {
                                    files = files + ',' + fileName;
                                }
                                helper.readFiles(component, event, helper, fileCount);
                                component.set("v.fileName", files);
                                console.log("check number : " + component.get("v.fileData"))
                            }

                        }

                    }
                }

            } else if (state === "INCOMPLETE") {
                console.log("Incomplete 101 Line")
            } else if (state === "ERROR") {
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
        $A.enqueueAction(action);

    },


    save: function(component, event, helper) {

        console.log('filedata -------> ' + JSON.stringify(component.get("v.fileData")));
        component.set("v.Spinner", true);
        var elmnt = document.getElementById("pageTop");
        elmnt.scrollIntoView();
        var parameterData;
        var action = component.get("c.getparameters");
        action.setParams({

        });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                parameterData = JSON.stringify(response.getReturnValue());
                var fileData = component.get("v.fileData");
                //var selectedFiles = document.getElementById('file-upload-input-01').files;
                //if(fileData.length > 0){
                //component.set("v.createFile", true);
                //var message = component.get("v.postMessage");
                //var vfWindow = component.find("vfFrame").getElement().contentWindow;
                //vfWindow.postMessage(fileData, '*');
                helper.submitForm(component, event, helper, fileData, parameterData);
                //}
                /*else{
            var elmnt = document.getElementById("pageTop");
            elmnt.scrollIntoView();
            component.set("v.message", 'Please upload files');
            component.set("v.isError", true);
            component.set("v.Spinner", false);
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.isError", false);
                }), 6000
            );
        }*/

            } else {
                console.error(response.getError())
            }
        });
        $A.enqueueAction(action);

    },
    removeRow: function(component, event, helper) {
        var index = event.target.title;
        //alert(index);
        var namelist = component.get("v.FileNameList");
        namelist.splice(index, 1);
        component.set("v.FileNameList", namelist);
        // alert(component.get("v.fileData"));
        var oldFilelist = component.get("v.fileData");
        oldFilelist.splice(index, 1);
        component.set("v.fileData", oldFilelist);
        console.log(JSON.stringify(component.get("v.fileData")));
        var fileList = component.get("v.uploadFileList")
        fileList.splice(index, 1)
        component.set("v.uploadFileList", fileList)

    },

    handleUploadFinished: function(component, event, helper) {
        // alert("ok")
        var uploadedFiles = event.getParam("files");
        //alert("Files uploaded : " + uploadedFiles.length);
        console.log('uploadedFiles ------> ' + JSON.stringify(uploadedFiles));
        var fileIds = [];
        for (var i = 0; i < uploadedFiles.length; i++) {

        }
    },
    savemultiple: function(component, event, helper) {
        // debugger;
        console.log(JSON.stringify(component.get("v.preQualRecord")));

        console.log('filedata -------> ' + JSON.stringify(component.get("v.fileData")));
        component.set("v.Spinner", true);
        var elmnt = document.getElementById("pageTop");
        elmnt.scrollIntoView();
        var parameterData;
        var action = component.get("c.getparameters");
        action.setParams({

        });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                parameterData = JSON.stringify(response.getReturnValue());
                var fileData = component.get("v.fileData");
                helper.MultiplesubmitForm(component, event, helper, fileData, parameterData);
                //}
                /*else{
            var elmnt = document.getElementById("pageTop");
            elmnt.scrollIntoView();
            component.set("v.message", 'Please upload files');
            component.set("v.isError", true);
            component.set("v.Spinner", false);
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.isError", false);
                }), 6000
            );
        }*/

            }
        });
        $A.enqueueAction(action);
    },
    changeValidation: function(component, event, helper) {
        var datatype = event.getSource().get("v.type");
        var auraid = event.getSource().get("v.title");

        // var fieldvalue = '';
        // fieldvalue = event.getSource().get("v.value");
        // alert(event.getSource().get("v.value"));
        //alert(event.getSource().get("v.validity"));
        if (datatype == "tel" && event.getSource().get("v.value") != undefined) {
            if (event.getSource().get("v.value").length == 10) {
                event.getSource().setCustomValidity("");
                event.getSource().reportValidity();
            } else {
                event.getSource().setCustomValidity("Enter a 10 digit mobile number");
                event.getSource().reportValidity();
            }
        } else if (datatype == "email" && event.getSource().get("v.value") != undefined) {
            if (event.getSource().get("v.value").includes("@") == true && (event.getSource().get("v.value").includes(".co") == true || event.getSource().get("v.value").includes(".CO") == true)) {
                event.getSource().setCustomValidity("");
                event.getSource().reportValidity();
            } else {
                event.getSource().setCustomValidity("Enter a valid email address");
                event.getSource().reportValidity();
            }
        }

        /*if(datatype == "number" && event.getSource().get("v.value") != ""){
             //alert(event.getSource().get("v.value"));
             if(isNaN(event.getSource().get("v.value")) == false){
                 event.getSource().setCustomValidity("");
                event.getSource().reportValidity();
             }else{
                event.getSource().setCustomValidity("Enter a valid Number");
                event.getSource().reportValidity();
             }
         }*/

    },

    /*   handleUploadFinished : function(component, event, helper) {
           console.log("Upload Finished");
           
       } */



})