({
    getTemplateBody: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getQuoteLines");
        action.setParams({
            recordId: recordId,
            templateId: component.get("v.selectedTemplate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('get template body');
                console.log({ result });
                component.set("v.quoteLines", result);
            }
        });
        $A.enqueueAction(action);
    },

    getContact: function(component, event, helper) {
        var action = component.get("c.getObjectContact");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert('result ---------> '+result);
                var selectedContact = component.get("v.selectedToContact");
                if (result != undefined) {
                    result.forEach(function(elem){
                        console.log(elem.buildertek__Primary_Contact__c);
                        if(elem.buildertek__Primary_Contact__c){
                            selectedContact.push(elem);
                        }
                    })
                }
                component.set("v.selectedToContact", selectedContact);
                console.log(component.get("v.selectedToContact"));
            }
        });
        $A.enqueueAction(action);
    },

    getProposalImagesList: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getProposalImages");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var result = response.getReturnValue();
                // alert(JSON.stringify(result));
                component.set("v.ProposalImages", result);
                console.log(component.get("v.ProposalImages"));
                //  alert('*****'+component.get("v.ProposalImages"));
            }
        });
        $A.enqueueAction(action);
    },

    getuploadSignature: function(component, event) {
        component.set("v.parentId", component.get("v.recordId"));
        var recId = component.get("v.parentId");

        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.saveSign");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1];

        signatureaction.setParams({
            base64Data: encodeURIComponent(vSplit),
            contentType: "image/png",
            recId: recId,
            signName: signName,
        });
        signatureaction.setCallback(this, function(e) {
            if (e.getState() == 'SUCCESS') {
                var result = e.getReturnValue();
                component.set("v.Spinner", false);
                component.set("v.fileimageId", result);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "Signature Saved Successfully"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                // location.reload();

            } else {
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction);

    },

    acceptandsendemailhelper: function(component, event) {
        //alert('hi2');
        var toIds = [];
        var ccIds = [];
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        var emailIds = component.get("v.emailIds");

        to.forEach(function(v) {
            toIds.push(v.Id)
        });
        cc.forEach(function(v) {
            ccIds.push(v.Id)
        });
          var contentDocumentIds = [];
    var fileInput = component.get("v.selectedfilesFill");
    if (fileInput && fileInput.length > 0) {
        for (var i = 0; i < fileInput.length; i++) {
            var contentDocumentId = fileInput[i].Id;
            contentDocumentIds.push(contentDocumentId);
        }
    }

        var signid = component.get("v.fileimageId");
        // alert('imageId'+component.get("v.fileimageId"));
        var action = component.get("c.acceptandsendProposal");
        action.setParams({
            htmlBody: component.get("v.quoteLines"),
            recordId: component.get("v.recordId"),
            templateId: component.get("v.selectedTemplate"),
            to: toIds,
            cc: ccIds,
            files: contentDocumentIds,
            Subject:  component.get("v.subject"),
            fileid: signid,
            emailIds: emailIds,
            memovalue: component.get("v.memoquote"),
            emailBodyValue: component.get("v.templateEmailBody")

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            // var subject = 'Quote[ref:' + component.get("v.recordId") + ']';
            if (state === "SUCCESS") {
                component.set("v.Spinner", false);
                var result = response.getReturnValue();
                if (result === 'Success') {
                    // $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "Email Sent Successfully"
                    });
                    toastEvent.fire();
                    // location.reload();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'error',
                        "message": result
                    });
                    toastEvent.fire();
                }
                $A.get("e.force:closeQuickAction").fire();
            }
        });

        $A.enqueueAction(action);

    },

    AcceptSignature: function(component, event) {
        component.set("v.Spinner", true);
        component.set("v.parentId", component.get("v.recordId"));
        var recId = component.get("v.parentId");

        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.saveSign");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1];

        signatureaction.setParams({
            base64Data: encodeURIComponent(vSplit),
            contentType: "image/png",
            recId: recId,
            signName: signName
        });
        signatureaction.setCallback(this, function(e) {
            if (e.getState() == 'SUCCESS') {
                var result = e.getReturnValue();

                component.set("v.fileimageId", result);
                setTimeout(
                    function() {
                        component.acceptandSendMethod();
                    }, 2000);


                /* var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       "title": "Success!",
                       "type": 'success',
                       "message": "Signature Saved Successfully"
                   });
                   toastEvent.fire();*/


            } else {
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction);

    },
    getmemovalue: function(component, event, helper) {
        try {
            var action = component.get("c.getmemoval");
            action.setParams({
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                console.log('result-->',result);
                if (state === "SUCCESS") {
                    var result = JSON.parse(response.getReturnValue());
                    if (result.memo != null) {
                        component.set("v.memoquote", result.memo);
                    }
                    if (result.companyname != null) {
                        component.set("v.companyName", result.companyname);
                    }
                    if (result.siteUrl != null) {
                        component.set("v.siteURL", result.siteUrl);
                    }
                    if (result.salesRepName != null) {
                        component.set("v.salesRep", result.salesRepName);
                    }
                    if (result.orgName != null) {
                        component.set("v.orgName", result.orgName);
                    }                   
                    if (result.emailBody != null) {
                        component.set("v.templateEmailBody", result.emailBody);
                    }
                    
                } else{
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": 'error',
                            "message": result
                        });
                        toastEvent.fire();
                }
            });

            $A.enqueueAction(action);
        } catch (error) {
            console.log('error-->',error);
        }
        
    },

        standardFileUploderFileChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var fileId = '';
    
        var existingMapData = component.get('v.selectedfilesFill');
        var newFilesList = event.getParam('files');
        console.log('newFilesList', newFilesList);

        var resultMapArray = [];

        newFilesList.forEach(function(newMap) {
            var resultMap = {
                "Id": newMap.contentVersionId,
                "ContentDocumentId": newMap.documentId,
                "Title": newMap.name.substring(0, newMap.name.lastIndexOf(".")), 
                "ContentSize":  0, 
                "ContentBodyId": newMap.contentBodyId,
                "FileType": newMap.mimeType.split("/")[1],
                "VersionData": '0',
                "FormattedSize": '0KB',
                "isChecked": true 
            };

            resultMapArray.push(resultMap);
        });
        var selected = component.get("v.selectedFile") || [];
        selected.push(...resultMapArray);
        component.set("v.selectedFile", selected);
        console.log('resultMapArray', selected);

        var fileCount = newFilesList.length;
        var files = '';
        var mapData = existingMapData || [];
    
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) {
                fileName = newFilesList[i]['name'].substring(0, newFilesList[i]['name'].lastIndexOf("."));
                fileId = newFilesList[i].documentId;
    
                var obj = {};
                obj['Name'] = fileName;
                obj['Id'] = fileId;
    
                mapData.push(obj);
            }
            files = mapData.map(function(file) {
                return file.Name;
            }).join(', ');
        } else {
            files = fileName;
        }
    
        component.set('v.selectedfilesFill', mapData);
        var fileIds = component.get("v.selectedFillIds") || [];
        mapData.forEach(function(data) {
            // Check if data.Id is not in fileIds before pushing
            if (!fileIds.includes(data.Id)) {
                fileIds.push(data.Id);
            }
        });
        component.set("v.selectedFillIds", fileIds);
        console.log('fileIds 2:->', fileIds);
        console.log('mapData 2 :-->',component.get('v.selectedfilesFill'));
    },
        getFileList: function(component) {
            console.log('in helper');
        var recordId = component.get("v.recordId");
        var action = component.get("c.getRelatedFiles");
        console.log(recordId);
        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var files = response.getReturnValue();
                console.log('FILES :->', files);

                if (files && files.length > 0) {
                    component.set("v.showModel",true);
                    files = this.convertFileSizes(files);
                    var selectedFillIds = component.get("v.selectedFillIds");
                    
                    files.forEach(function(file) {
                        file.isChecked = selectedFillIds.includes(file.ContentDocumentId);
                    });
                    
                    component.set("v.relatedFiles", files);
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                } else {
                    component.set("v.showModel",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'There are no files related to the record.',
                        type : 'error',
                        duration: '5000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); 
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'something went wrong.',
                        type : 'error',
                        duration: '5000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); 
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            }
        });

        $A.enqueueAction(action);
    },
       convertFileSizes: function(files) {
        for (var i = 0; i < files.length; i++) {
            var fileSize = files[i].ContentSize;
            files[i].FormattedSize = this.formatFileSize(fileSize);
        }
        return files;
    },    formatFileSize: function(sizeInBytes) {
        if (isNaN(sizeInBytes) || sizeInBytes <= 0) {
            return 'N/A';
        }

        var units = ['B', 'KB', 'MB', 'GB', 'TB'];
        var i = parseInt(Math.floor(Math.log(sizeInBytes) / Math.log(1024)));
        return Math.round((sizeInBytes / Math.pow(1024, i)) * 100) / 100 + ' ' + units[i];
    },
        onChecboxChanges: function(component, event, helper) {
        var file = event.getSource().get("v.name");
        var selectedFiles2 = component.get("v.selectedFiles2") || [];

        selectedFiles2.push(file);
        component.set("v.selectedFiles2", selectedFiles2);
        console.log('selectedFiles2:', selectedFiles2);
        var selectedFiles = component.get("v.selectedFile") || [];

        // Check if the file is already in the selectedFiles array
        var fileIndex = selectedFiles.findIndex(function(selectedFile) {
            return selectedFile.Id === file.Id;
        });

        if (event.getSource().get("v.checked")) {
            // If the file is not already in the array, add it
            if (fileIndex === -1 && !component.get("v.selectedFillIds").includes(file.ContentDocumentId)) {
                selectedFiles.push(file);
            }
        } else {
            // If the file is in the array, remove it
            if (fileIndex !== -1) {
                selectedFiles.splice(fileIndex, 1);
            }
        }

        component.set("v.selectedFile", selectedFiles);
        console.log('selectedFiles :->', selectedFiles);
    },
        saveButton: function(component, event, helper) {
        // Get the selected files and map data
        var selectedFiles = component.get("v.selectedFile") || [];
        var mapData = component.get("v.selectedfilesFill") || [];

        // Process the selected files and update mapData
        var files = '';
        selectedFiles.forEach(function(selectedFile) {
            var fileName = selectedFile.Title;
            var fileId = selectedFile.ContentDocumentId;

            // Check if the fileId is already in the mapData
            var fileInMap = mapData.some(function(mapFile) {
                return mapFile.Id === fileId;
            });

            // If the fileId is not in the mapData, add it
            if (!fileInMap) {
                var obj = {};
                obj['Name'] = fileName;
                obj['Id'] = fileId;
                mapData.push(obj);

                if (files === '') {
                    files = fileName;
                } else {
                    files += ',' + fileName;
                }
            }
        });

        component.set("v.fileName", files);
        component.set("v.selectedfilesFill", mapData);

        var fileIds = selectedFiles.map(function(v) {
            return v.ContentDocumentId;
        });

        component.set("v.selectedFillIds", fileIds);

        console.log(component.get("v.fileName"));
        console.log('fileIds :->', fileIds);
        console.log('updated mapdata :-->', component.get("v.selectedfilesFill"));
        component.set("v.showModel",false);
    },
    clearPillValues :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name"); 
        var AllPillsList = component.get("v.selectedfilesFill") || [];    
        var selectedFillIds = component.get("v.selectedFillIds") || [];
    
        // Use Array.findIndex to find the index of the selected pill in the list
        var pillIndex = AllPillsList.findIndex(function(pill) {
            return pill.Id === selectedPillId;
        });
    
        if (pillIndex !== -1) {
            // Add the Id to selectedFillIds if not already present
            if (!selectedFillIds.includes(selectedPillId)) {
                selectedFillIds.push(selectedPillId);
            }
    
            // Remove the pill from selected files
            AllPillsList.splice(pillIndex, 1);
    
            // Remove the Id from selectedFillIds
            var fillIdIndex = selectedFillIds.indexOf(selectedPillId);
            if (fillIdIndex !== -1) {
                selectedFillIds.splice(fillIdIndex, 1);
            }
    
            // Update the selected files and selectedFillIds attributes
            component.set("v.selectedfilesFill", AllPillsList);
            component.set("v.selectedFillIds", selectedFillIds);
    
            console.log('Pill removed. Updated selected files:', AllPillsList);
            console.log('Updated selectedFillIds:', selectedFillIds);
            var selectedFiles = component.get("v.selectedFile") || [];
            var selectedFillIdsSet = new Set(selectedFillIds);

            // Filter selectedFiles based on matching selectedFillIds
            var filteredSelectedFiles = selectedFiles.filter(function(file) {
                return selectedFillIdsSet.has(file.ContentDocumentId);
                });

            // Update the attribute with the filtered list
            component.set("v.selectedFile", filteredSelectedFiles);
        } else {
            console.log('Pill not found in the list.');
        }
        
    }

})