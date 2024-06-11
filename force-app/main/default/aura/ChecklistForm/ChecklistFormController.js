({
    doInit: function (component, event, helper) {
        //Site Url Get
        var url = window.location.href;
        var siteUrl = url.split('?');
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
                component.set("v.Questions", result);
            }
        });
        $A.enqueueAction(action);


        var action3 = component.get("c.getProjectName");
        action3.setParams({
            "Ids": component.get("v.recordId")
        });
        action3.setCallback(this, function (c) {
            if (c.getState() === 'SUCCESS') {

                var result = c.getReturnValue();
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
		// get the first file using array index[0]
		var file = fileInput[0];

        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0 && file.size > 4500000) {
            try {
                component.set("v.fileName", 'Alert : File size cannot exceed ' + '4500000' + ' bytes.\n' + ' Selected file size: ' + file.size);
                alert('File size cannot exceed ' + '4500000' + ' bytes.\n' + ' Selected file size: ' + file.size);

            } catch (error) {
                console.log('error in upload ',error);
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