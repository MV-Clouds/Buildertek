({
    setSelectedRecordId: function (component, event, helper) {
        var selectedRecordId = component.get("v.selectedRecordId");
        component.find("lookupField").set("v.value", selectedRecordId);
    },

    fireOnSelectEvt: function (component, event, helper) {
        var cmpEvent = component.getEvent("onSelectEvt");
        cmpEvent.setParams({
            "childObjectName": component.get("v.childObjectName"),
            "fieldName": component.get("v.fieldName"),
            "selectedRecordId": component.find("lookupField").get("v.value"),
            "index": component.get('v.index'),
            "phaseIndex": component.get('v.phaseIndex'),
            "groupIndex" : component.get('v.groupindex'),
        });
        cmpEvent.fire();
        if (component.find("lookupField").get("v.value") != undefined && component.find("lookupField").get("v.value").length == 0) {
            var record = component.get('v.record');
            if(record != null){
                var fieldName = component.get('v.fieldName');
                record[fieldName] = null;
                record[fieldName.replace('__c', '__r')] = null;
                component.set('v.record', record);
            }
        }
    }
})