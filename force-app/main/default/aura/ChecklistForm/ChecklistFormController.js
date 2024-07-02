({
    doInit: function (component, event, helper) {
        //Site Url Get
        var url = window.location.href;
        var siteUrl = url.split('?');
        var conId = helper.getParameterByName('contactId', url);
        var checklistName = helper.getParameterByName('selectCheckListName', url);
        component.set("v.checkListType", checklistName);
        component.set("v.contactId", conId);
        if (siteUrl[0] != '' && siteUrl[0] != undefined) {
            component.set("v.siteUrl", siteUrl[0].replace('/buildertek__ChecklistForm', ''));
        }
        else {
            component.set("v.siteUrl", '/');
        }

        var action = component.get("c.getAttachmentData");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (a) {
            if (a.getState() === 'SUCCESS') {
                var result = a.getReturnValue();

                component.set("v.imgUrl", component.get("v.siteUrl") + "/servlet/servlet.FileDownload?file=" + result);
            }
        });
        $A.enqueueAction(action);

        var recId = component.get("v.selectedValue");
        var action = component.get("c.getQuestions");
        action.setParams({
            "CheckQuestionId": recId
        });
        action.setCallback(this, function (a) {
            if (a.getState() === 'SUCCESS') {
                component.set("v.showchecklist", true);
                var result = a.getReturnValue();
                console.log('result', result);
                component.set("v.Questions", result);
            }
        });
        $A.enqueueAction(action);


        var action3 = component.get("c.getProjectName");
        action3.setParams({
            "Ids": component.get("v.recordId"),
            "contactId": component.get("v.contactId")
        });
        action3.setCallback(this, function (c) {
            if (c.getState() === 'SUCCESS') {

                var result = c.getReturnValue();
                console.log('result', result);
                debugger;
                //  alert(result)
                if (result != 'error') {
                    component.set('v.DynamiccheckListName', result);
                }
            }
            else {
                console.log(c.getError());
            }
        });
        $A.enqueueAction(action3);
    },

    getcheckboxlist: function (component, event, helper) {
        var Questions = component.get("v.Questions");
        var label = event.getSource().get('v.label');
        for (var i = 0; i < Questions.length; i++) {
            for (var j = 0; j < Questions[i].QuestionsInnerclasslist.length; j++) {
                if (label == Questions[i].QuestionsInnerclasslist[j].QuestionName) {
                    Questions[i].QuestionsInnerclasslist[j].QuestionValues = event.getSource().get('v.value');
                }
            }

        }
        component.set("v.Questions", Questions);
    },

    handleUploadFinished: function (cmp, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded : " + uploadedFiles.length);
        // Get the file name
        uploadedFiles.forEach(file => console.log(file.name));
    },
  
    nameOnchange: function (component, event, helper) {
        if (component.get("v.DynamiccheckListName") != undefined && component.get("v.DynamiccheckListName") != null && component.get("v.DynamiccheckListName") != "") {
            component.set("v.ischecklistNameError", false);
        }
        else {
            component.set("v.ischecklistNameError", true);
        }
    },

    handleClick: function (component, event, helper) {
        helper.handleSubmit(component, event, helper);
    },

    handleFilesChange: function(component, event, helper) {
        var fileInput = component.find("fuploader").get("v.files");
        var file = fileInput[0];
        var fileName = 'No File Selected..';
        
        var fileSizeMB = file.size / (1024 * 1024);         
        if (event.getSource().get("v.files").length > 0 && fileSizeMB > 3) { // Checking if file size exceeds 3 MB
            try {
                component.set("v.fileName", 'Alert : File size cannot exceed 3MB.\n Selected file size: ' + fileSizeMB.toFixed(2) + ' MB');
                alert('File size cannot exceed 3MB\n Selected file size: ' + fileSizeMB.toFixed(2) + ' MB');
            } catch (error) {
                console.log('Error in file upload:', error);
            }
        } else {
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set("v.fileName", fileName);
        }
    },

    closePage: function (component, event, helper) {
        window.close('/apex/buildertek__Pre_QualProcess_VF');
    },

})