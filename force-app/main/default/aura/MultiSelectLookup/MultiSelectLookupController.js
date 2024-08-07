
({
    // To prepopulate the seleted value pill if value attribute is filled
    doInit: function (component, event, helper) {
        $A.util.toggleClass(component.find('resultsDiv'), 'slds-is-open');
        if (!$A.util.isEmpty(component.get('v.selectedRecords'))) {
            helper.searchRecordsHelper(component, event, helper, component.get('v.selectedRecords'));
        }
    },

    // When a keyword is entered in search box
    searchRecords: function (component, event, helper) {
        if (!$A.util.isEmpty(component.get('v.searchString'))) {
            helper.searchRecordsHelper(component, event, helper, []);
        } else {
            $A.util.removeClass(component.find('resultsDiv'), 'slds-is-open');
        }
    },

    // When an item is selected
    selectItem: function (component, event, helper) {
        if (!$A.util.isEmpty(event.currentTarget.id)) {
            var recordsList = component.get('v.recordsList');
            var selectedRecords = component.get('v.selectedRecords') || [];
            var selectedDataObj = component.get('v.selectedDataObj') || [];
            var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if (index != -1) {
                recordsList[index].isSelected = recordsList[index].isSelected === true ? false : true;
                if (selectedRecords.includes(recordsList[index].value)) {
                    selectedRecords.splice(selectedRecords.indexOf(recordsList[index].value), 1);
                    var ind = selectedDataObj.findIndex(x => x.value === event.currentTarget.id)
                    if (ind != -1) { selectedDataObj.splice(ind, 1) }
                } else {
                    selectedRecords.push(recordsList[index].value);
                    selectedDataObj.push(recordsList[index]);
                }
            }
            component.set('v.recordsList', recordsList);
            component.set('v.selectedRecords', selectedRecords);
            component.set('v.selectedDataObj', selectedDataObj);
            var multiSelectLookUpCompEvent = component.getEvent("multiSelectLookUpEvent");
            multiSelectLookUpCompEvent.setParams({ "message": selectedDataObj });
            multiSelectLookUpCompEvent.fire();
        }
        $A.util.removeClass(component.find('resultsDiv'), 'slds-is-open');
    },

    removePill: function (component, event, helper) {
        var recordId = event.getSource().get('v.name');
        var recordsList = component.get('v.recordsList');
        var selectedRecords = component.get('v.selectedRecords');
        var selectedDataObj = component.get('v.selectedDataObj');

        selectedRecords.splice(selectedRecords.indexOf(recordId), 1);
        var index = selectedDataObj.findIndex(x => x.value === recordId)
        if (index != -1) {
            selectedDataObj.splice(index, 1)
        }
        var ind = recordsList.findIndex(x => x.value === recordId)
        if (ind != -1) {
            recordsList[ind].isSelected = false;
        }
        component.set('v.recordsList', recordsList);
        component.set('v.selectedDataObj', selectedDataObj);
        component.set('v.selectedRecords', selectedRecords);
        var multiSelectLookUpCompEvent = component.getEvent("multiSelectLookUpEvent");
        multiSelectLookUpCompEvent.setParams({ "message": selectedDataObj });
        multiSelectLookUpCompEvent.fire();
    },

    showRecords: function (component, event, helper) {
        var disabled = component.get('v.disabled');
        if (!disabled && !$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'), 'slds-is-open');
        }
    },

    // To close the dropdown if clicked outside the inputbox.
    blurEvent: function (component, event, helper) {
        $A.util.removeClass(component.find('resultsDiv'), 'slds-is-open');
    },
})