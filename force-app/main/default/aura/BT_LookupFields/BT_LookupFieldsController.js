({
    setSelectedRecordId: function (component, event, helper) {
        var selectedRecordId = component.get("v.selectedRecordId");
        component.find("lookupField").set("v.value", selectedRecordId);
    },

    fireOnSelectEvt: function (component, event, helper) {
        var id = event.getSource().get('v.value');
        console.log('id---->',id);
        if (component.find("lookupField").get("v.value") != undefined && component.find("lookupField").get("v.value").length == 0) {
            var record = component.get('v.record');
            if(record != null){
                var fieldName = component.get('v.fieldName');
                record[fieldName] = null;
                record[fieldName.replace('__c', '__r')] = null;
                component.set('v.record', record);
            }
        }
        if (id.length > 0) {
            console.log('phase index : ', component.get('v.phaseIndex'));
            var cmpEvent = component.getEvent("onSelectEvt");
            cmpEvent.setParams({
                "childObjectName": component.get("v.childObjectName"),
                "phaseIndex": component.get('v.phaseIndex'),
                "fieldName": component.get("v.fieldName"),
                "selectedRecordId": component.find("lookupField").get("v.value"),
                "index": component.get('v.index'),
                "groupIndex" : component.get('v.groupindex'),
            });
            cmpEvent.fire();
        } else {
            var cmpEvent = component.getEvent("oClearRecordEvent");
            cmpEvent.setParams({
                "phaseIndex": component.get('v.phaseIndex'),
                "index": component.get('v.index')
            });
            cmpEvent.fire();
        }
        
    }
})