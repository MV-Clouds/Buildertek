({

    doInit: function (component, event, helper) {
        console.log('OUTPUT of checkListId : ', component.get("v.checkListId"));
        var action = component.get("c.getChecklistSectionSubsection");
        action.setParams({ checkListId: component.get("v.checkListId") });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.message === 'success') {
                    try {
                        var subSectionMapHolder = result.sectionIdNampMap;
                        var storedSubSectionMap = result.storedSubsectionOrder;
                        var newTemp = {};
                        if (storedSubSectionMap) {
                            newTemp = JSON.parse(storedSubSectionMap);
                        }

                        var globalListWithSectionSubsection = [];

                        var subSectionMap = result.subSectionMap;

                        for (const key in subSectionMapHolder) {
                            var obj = {};
                            obj.sectionId = key;
                            obj.sectionName = subSectionMapHolder[key];
                            obj.existingStoredSubsectionList = [];
                            var subSectionList = subSectionMap[key];
                            //! converting array into set to remove duplicates
                            var jsonObject = subSectionList.map(JSON.stringify);
                            var uniqueSet = new Set(jsonObject);
                            var uniqueArray = Array.from(uniqueSet).map(JSON.parse);
                            //! stored selected values in list
                            var storedList = newTemp[key];
                            if (storedList && storedList.length > 0) {
                                obj.existingStoredSubsectionList = storedList;
                            }

                            uniqueArray.forEach(function (element) {
                                element.label = element.Name;
                                // element.value = element.Id;
                                element.value = element.Name;
                                element.selected = false;

                                if (storedList && storedList.includes(element.Name)) {
                                    element.selected = true;
                                }
                            });
                            
                            helper.obj[key] = obj.existingStoredSubsectionList;
                            obj.subSectionList = helper.reorderSubsection(uniqueArray, obj.existingStoredSubsectionList);
                            console.log('subSectionList ',obj.subSectionList);
                            
                            globalListWithSectionSubsection.push(obj);
                        }

                        component.set("v.globalListWithSectionSubsection", globalListWithSectionSubsection);
                    } catch (error) {
                        console.log('error ', error);
                    }
                } else {
                    console.log('Error', result.message);
                    helper.showToast(component, event, helper,'error', result.message, 'Error');
                }
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
        var action = component.get("c.updateCheckListForSubsectionOrder");
        action.setParams({ checkListId: component.get("v.checkListId"), jsonSubsectionOrderedString: JSON.stringify(helper.obj) });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                helper.showToast(component, event, helper,'Success', 'Subsection Ordering Updated.', 'success');
                var compEvent = component.getEvent("childOrderSubsectionComponentEvent");
                compEvent.fire();
            } else {
                var errors = response.getError();
                console.log('errors ', { errors });

                if (errors && errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                    helper.showToast(component, event, helper,'error', errors[0].message, 'Error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleChildSectionEvent: function (component, event, helper) {
        try {
            var getResult = event.getParam('payload');
            helper.obj[getResult.iterId] = getResult.values;
            component.set("v.globalMapWithSectionWithSubsection", helper.obj);
        } catch (error) {
            console.log('Error', error);
        }
    },
})