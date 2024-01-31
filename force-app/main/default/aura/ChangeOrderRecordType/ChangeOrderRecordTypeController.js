({
    doInit: function (component, event, helper) {
        helper.getRecordTypes(component, event, helper);
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var projectId = '';
        let projectIdFromCO = component.get("v.projectId");
        if (!projectIdFromCO) {
            if (value != null) {
                context = JSON.parse(window.atob(value));
                projectId = context.attributes.recordId;
                component.set("v.projectId", projectId);
            } else {
                var relatedList = window.location.pathname;
                var stringList = relatedList.split("/");
                projectId = stringList[4];

                if (projectId == 'related') {
                    var stringList = relatedList.split("/");
                    projectId = stringList[3];
                }
                component.set("v.projectId", projectId);
            }
        }

    },

    handleRadioChange: function (component, event, helper) {
        let selectedRecordTypeId = event.getSource().get("v.value");
        let selectedRecordTypeName = event.getSource().get("v.label");
        component.set("v.RecordTypeId", selectedRecordTypeId);
        console.log(`${selectedRecordTypeName}: ${selectedRecordTypeId}`);
    },

    handleSave: function (component, event, helper) {
        let selectedRecordTypeId = component.get("v.RecordTypeId");
        let projectId = component.get("v.projectId");
        var evt = $A.get("e.force:navigateToComponent");
        console.log('selectedRecordTypeId:', selectedRecordTypeId);
        evt.setParams({
            componentDef: "c:BT_NewChangeOrderOverride",
            componentAttributes: {
                RecordTypeId: selectedRecordTypeId,
                parentprojectRecordId: projectId
            }
        });

        evt.fire();
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo()
            .then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
            })
            .catch(function (error) {
                console.log(error);
            });
    },


    handleCancel: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo()

            .then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })

            .catch(function (error) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "related"
                });
                navEvt.fire();
            });

        $A.get("e.force:closeQuickAction").fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
    },

})