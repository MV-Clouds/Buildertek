({
    doInit: function(component, event, helper) {
        /*    var action = component.get("c.getDocuments");
            var recordId = component.get('v.recordId');
            action.setParams({
                recordId : component.get("v.recordId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    
                    var result = response.getReturnValue();
                    component.set("v.ContentDocumentList", result);
                }
            });
            $A.enqueueAction(action); */


        // templates related code
        var action = component.get("c.GetDocusignTemplates");

        var recordId = component.get('v.recordId');
        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var result = response.getReturnValue();

                component.set("v.TemplatesList", result);

                console.log(result);

            }
        });

        $A.enqueueAction(action);


    },
    handleCheck: function(component, event, helper) {

        // var checkbox = event.getSource(); 
        var check = event.currentTarget.dataset.docid;
        var Submittals = component.get("v.ContentDocumentList");
        var rec = component.get("v.SelectedDocuments");



        //templates related code
        var checkbox = event.currentTarget;
        var temid = checkbox.dataset.temid;
        var classIndex = event.currentTarget.className.split("_")[1];
        var headCheckBox = document.getElementsByClassName('checkSelectAll_' + classIndex)[0];
        var selectedRfqIds = component.get("v.SelectedDocuments");
        var getAllId = document.getElementsByClassName("selectCheck_" + classIndex);

        if (checkbox.checked) {
            if (selectedRfqIds.indexOf(temid) == -1) {
                selectedRfqIds.push(temid);
            }

        } else {

            if (selectedRfqIds.indexOf(temid) > -1) {
                var index = selectedRfqIds.indexOf(temid);
                selectedRfqIds.splice(index, 1);
            }
        }

        console.log(selectedRfqIds);
        component.set("v.SelectedDocuments", selectedRfqIds);


    },



    selectAll: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        //var Submittals = component.get("v.SelectedDocuments");
        var Submittals = component.get("v.TemplatesList");
        var getAllId = component.find("checkContractor");
        var selitems = [];
        if (Submittals != '' && Submittals != null) {
            if (Submittals.length > 0) {
                if (!Array.isArray(getAllId)) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkContractor").set("v.value", true);
                    } else {
                        component.find("checkContractor").set("v.value", false);
                    }
                } else {
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", true);
                            document.getElementsByClassName('inputCheck')[i].checked = true
                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            //Submittals[i] = true;
                            selitems.push(Submittals[i].templateId);
                        }
                    } else {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false);
                            document.getElementsByClassName('inputCheck')[i].checked = false
                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            var Submittals = component.get("v.TemplatesList");
                            Submittals[i].budgetCheck = false;

                        }
                        selitems = [];
                    }
                }
            } else {
                var i = 0;
                if (selectedHeaderCheck == true) {
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkContractor")[i].set("v.value", true);
                        document.getElementsByClassName('inputCheck')[i].checked = true
                    }

                    // component.find("checkContractor").set("v.value", true); 
                    var checkbox = component.find("checkContractor").get("v.text");
                    // Submittals[i].budgetCheck = true;
                    selitems.push(Submittals[i].templateId);
                } else {
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkContractor")[i].set("v.value", false);
                        document.getElementsByClassName('inputCheck')[i].checked = false
                    }

                    var checkbox = component.find("checkContractor").get("v.text");
                    var Submittals = component.get("v.ContentDocumentList");
                    Submittals[i].budgetCheck = false;
                    selitems = [];
                }
            }
        }

        component.set("v.SelectedDocuments", selitems);
    },

    sendEnv: function(component, event, helper) {
        // debugger;
        console.log('Send env');
        var recordId = component.get('v.recordId');
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        var selectedDocId = component.get('v.SelectedDocuments');
        console.log(selectedDocId);

        if (selectedDocId.length > 0) {
            var action = component.get("c.sendDocEnv");
            action.setParams({
                recordId: component.get("v.recordId"),
                SelectedDoc: selectedDocId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                if (state === "SUCCESS") {

                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Your Document Is Sent For DocuSign.',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);

            window.setTimeout(
                $A.getCallback(function() {
                    $A.get('e.force:refreshView').fire();
                }), 2000
            );

        } else {
            component.set("v.Spinner", false);
            component.set("v.showMessage", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: 'Please select atleast one Template',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        }

    },

    Preview: function(component, event, helper) {
        // var action = component.get("c.sendDocEnv");
        var recordId = component.get('v.recordId');

        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        var selectedDocId = component.get('v.SelectedDocuments');

        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__DocuSignPreview"

            },
            "state": {
                "c__recordId": event.currentTarget.dataset.uri,
                "c__SelectedDocuments": event.currentTarget.dataset.Id
            }
        };

        component.set("v.pageReference", pageReference);
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));
        navService.navigate(pageReference);


        /*  var newEvent = $A.get("e.force:navigateToComponent");
        newEvent.setParams({
            componentDef: "DocuSignPreview",
            componentAttributes: {
              recordId : component.get("v.recordId")
           // SelectedDoc : selectedDocId
            }
        });
        newEvent.fire(); */


    },
    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})