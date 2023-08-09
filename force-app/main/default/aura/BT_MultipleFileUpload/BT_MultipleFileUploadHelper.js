({
    // getExistingFiles: function (component) {
    //     var sObjectId = component.get("v.sObjectId");
    //     var action = component.get("c.getAllFilesOnsObjectRecord");
    //     action.setParams({
    //         sObjectId: sObjectId
    //     });
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var existingFilesArr = response.getReturnValue();
    //             if (existingFilesArr != null && existingFilesArr != undefined && existingFilesArr.length > 0) {
    //                 component.set("v.sObjectAttachedFiles", existingFilesArr);
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    handleUploadFinished: function (component, event) {
        var uploadedFileArr = [];
        var sObjectAttachedFiles = component.get("v.sObjectAttachedFiles");
        var sObjectAttachedFilesArr = [];
        if (sObjectAttachedFiles != null && sObjectAttachedFiles != undefined && sObjectAttachedFiles.length > 0) {
            [].forEach.call(sObjectAttachedFiles, function (file) {
                sObjectAttachedFilesArr.push({
                    'Id': file.Id,
                    'Title': file.Title
                });
            });
        }

        var uploadedFiles = event.getParam("files");
        [].forEach.call(uploadedFiles, function (file) {
            uploadedFileArr.push({
                'Id': file.documentId,
                'Name': file.name
            });

            sObjectAttachedFilesArr.push({
                'Id': file.documentId,
                'Title': file.name
            });
        });

        component.set("v.sObjectAttachedFiles", sObjectAttachedFilesArr);

        var filesUploadedPreviously = component.get('v.uploadedFiles');
        if (filesUploadedPreviously != null && filesUploadedPreviously != undefined && filesUploadedPreviously.length > 0) {
            [].forEach.call(filesUploadedPreviously, function (file) {
                uploadedFileArr.push({
                    'Id': file.Id,
                    'Name': file.Name
                });
            });
        }
        component.set("v.uploadedFiles", uploadedFileArr);
    },

    handleCancelUpload: function (component) {
        var uploadedFiles = component.get("v.uploadedFiles");
        var uploadedFileIdArr = [];
        if (uploadedFiles != null && uploadedFiles != undefined && uploadedFiles.length > 0) {
            [].forEach.call(uploadedFiles, function (file) {
                uploadedFileIdArr.push(file.Id);
            });
        }

        var sObjectId = component.get("v.sObjectId");
        var sObjectName = component.get("v.sObjectName");

        var action = component.get("c.deleteFiles");
        action.setParams({
            filesIdArrStr: JSON.stringify(uploadedFileIdArr)
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            this.navigateToRecordDetailPage(component, sObjectId, sObjectName);
        });
        $A.enqueueAction(action);
    },

    handleSaveClick: function (component) {
        var sObjectId = component.get("v.sObjectId");
        var sObjectName = component.get("v.sObjectName");
        this.navigateToRecordDetailPage(component, sObjectId, sObjectName);
    },

    navigateToRecordDetailPage: function (component, sObjectId, sObjectName) {
        var navService = component.find("navService");
        var pageReference = {
            type: "standard__app",
            attributes: {
                pageRef: {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: sObjectId,
                        objectApiName: sObjectName,
                        actionName: "view"
                    }
                }
            }
        };

        navService.generateUrl(pageReference).then($A.getCallback(function (url) {
            window.location.href = url;
        }), $A.getCallback(function (error) {
            window.location.href = "/" + sObjectId;
        }));
    }
})