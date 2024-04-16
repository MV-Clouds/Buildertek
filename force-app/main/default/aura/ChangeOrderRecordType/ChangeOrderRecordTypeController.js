({
    doInit: function (component, event, helper) {
        helper.getRecordTypes(component, event, helper);
        let generalId = component.get("v.generalId");
        if (!generalId) {
            var value = helper.getParameterByName(component, event, 'inContextOfRef');
            var context = '';
            var urlRecordId = '';
            if (value != null) {
                context = JSON.parse(window.atob(value));
                urlRecordId = context.attributes.recordId;
            } else {
                var relatedList = window.location.pathname;
                var stringList = relatedList.split("/");
                urlRecordId = stringList[4];

                if (urlRecordId == 'related') {
                    var stringList = relatedList.split("/");
                    urlRecordId = stringList[3];
                }
            }
            component.set("v.generalId", urlRecordId);
        }
    },

    handleRadioChange: function (component, event, helper) {
        let selectedRecordTypeId = event.getSource().get("v.value");
        let selectedRecordTypeName = event.getSource().get("v.label");
        component.set("v.RecordTypeId", selectedRecordTypeId);
        component.set("v.ParentRecordTypeName", selectedRecordTypeName);
        console.log(`${selectedRecordTypeName}: ${selectedRecordTypeId}`);
    },

    handleSave: function (component, event, helper) {
        let selectedRecordTypeId = component.get("v.RecordTypeId");
        let generalId = component.get("v.generalId");
        let selectedRecordTypeName = component.get("v.ParentRecordTypeName");
        // console.log(`selectedRecordTypeName: ${selectedRecordTypeName}`);
        var evt = $A.get("e.force:navigateToComponent");
        console.log('selectedRecordTypeId:', selectedRecordTypeId);
        evt.setParams({
            componentDef: "c:BT_NewChangeOrderOverride",
            componentAttributes: {
                RecordTypeId: selectedRecordTypeId,
                parentRecordId: generalId || '',
                RecordTypeName: selectedRecordTypeName || '',
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