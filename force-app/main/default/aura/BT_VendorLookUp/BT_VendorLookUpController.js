({
    setSelectedRecordId: function (component, event, helper) {
        debugger;
        var selectedRecordId = component.get("v.selectedRecordId");
        console.log('selectedRecordId:::'+selectedRecordId);
        component.find("lookupField").set("v.value", selectedRecordId);
    },

    fireOnSelectEvt: function (component, event, helper) {
       var fieldName =  component.get("v.fieldName");
        if(fieldName == 'buildertek__Vendor__c'){
            var vendorId = component.find("lookupField").get("v.value");
            if (vendorId != '') {
                helper.getAllPO(component, event, helper, vendorId);
            }  
        }else{
            var cmpEvent = component.getEvent("onSelectEvt");
            cmpEvent.setParams({
                "childObjectName": component.get("v.childObjectName"),
                "fieldName": component.get("v.fieldName"),
                "selectedRecordId": component.find("lookupField").get("v.value"),
                "index": component.get('v.index')
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
    }
})