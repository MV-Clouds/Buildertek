({  
    doInit : function(component, event, helper) {

        var action = component.get("c.getOrgBaseURL");
        action.setParams({});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log({ state });
            var result = response.getReturnValue();
            console.log({ result });

        });
        $A.enqueueAction(action);


	    var recordId = component.get("v.recordId");
        console.log('recordID ==>' + recordId);
        if (recordId != undefined & recordId != null) {
            console.log('1');
            component.set('v.checkInRec.buildertek__Project__c', recordId);
            component.set('v.desableProjectSelection', true);
            console.log('2');
        } else {
            component.set('v.desableProjectSelection', false);
        }

        /*  for Date Created Default value */
        var todayDate = new Date();
        console.log('cuurentDate with ISO string ==>' + todayDate.toISOString());
        const offset = todayDate.getTimezoneOffset(); 
        console.log('offset ==>' + offset);
        todayDate = new Date(todayDate.getTime()-(offset*60*1000)); 
        console.log('todayDate with Offset ==>' + todayDate);
        var todayDateISO = todayDate.toISOString().split('T')[0];
        component.set('v.checkInRec.buildertek__Date_Created__c', todayDateISO);

        /*  for Weather Default value */
        component.set('v.checkInRec.buildertek__Weather__c', 'Sunny');

        /*  for Status Default value */
        component.set('v.checkInRec.buildertek__Status__c', 'No Issues');

    },

    closeModel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();

        var uploadedFileId = component.get('v.uploadedFileId');
        console.log('uploadedFileId ==>' , uploadedFileId);
        if (uploadedFileId.length > 0) {
            helper.deleteUploadedFiles(component, event, helper, uploadedFileId);
        }

        var recordId = component.get("v.recordId");
        if (recordId == undefined || recordId == null) {
            helper.sendBooleanValue(component, event, helper);
        }
    },

    saveRecordData: function (component, event, helper) {
        helper.saveRecordData(component, event, helper);
    },

    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");

        // Get the file name
        var contentDocId = [];

        var existentList = component.get('v.uploadedFileId');
        console.log('ex lsit =>' + existentList.length);
        if (existentList.length > 0 ) {
            contentDocId = existentList;
        }

        uploadedFiles.forEach(file => {
            console.log(file.name + ' Id ==>' + file.documentId);
            contentDocId.push(file.documentId);
        });
        component.set('v.uploadedFileId', contentDocId);
    
    },

    onImageClick: function (component, event, helper) {
        console.log('image clicked');
        var fileId = event.getSource().get("v.id");
        console.log('Image ID ==>' + fileId);

        var recordFilesId = component.get('v.uploadedFileId');
        console.log('recordFilesId ID ==>' + recordFilesId);

        $A.get('e.lightning:openFiles').fire({
		    recordIds: recordFilesId,
		    selectedRecordId: fileId
		});
    },

})