({

    doInit: function (component, event, helper) {
        console.log('OUTPUT of checkListId : ', component.get("v.checkListId"));
        var action = component.get("c.getChecklistSectionSubsection");
        action.setParams({ checkListId: component.get("v.checkListId") });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.message === 'success') {
                    console.log('this is result ', result);
                    var subSectionMapHolder = result.sectionIdNampMap;
                    console.log('subSectionMapHolder ',subSectionMapHolder);
                    var globalListWithSectionSubsection = [];

                    for (const key in subSectionMapHolder) {
                        var obj = {};
                        obj.sectionId = key;
                        obj.sectionName = subSectionMapHolder[key];
                        globalListWithSectionSubsection.push(obj);
                    }
                    console.log('globalListWithSectionSubsection ',globalListWithSectionSubsection);
                    
                    component.set("v.globalListWithSectionSubsection", globalListWithSectionSubsection);
                } else {
                    console.log('Error', result.message);
                    helper.showToast('error', result.message, 'Error');
                }
                console.log('server fetched data', response.getReturnValue());
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },

    closeModel: function (component, event, helper) {
        var compEvent = component.getEvent("childOrderSubsectionComponentEvent");
        compEvent.fire();
    },

    submitDetails: function (component, event, helper) {
        console.log('OUTPUT of data from parent : ', component.get("v.checkListId"));
    },

    handleMultiSelectLookUpComponentEvent: function (component, event, helper) {
        var valueFromChild = event.getParam("message");
        console.log("data from child ", valueFromChild);
    },
})