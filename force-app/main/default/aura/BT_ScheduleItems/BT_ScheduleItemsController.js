({
    doInit: function (component, event, helper) {
        var record = component.get("v.record");
        var field = component.get("v.field");
        component.set("v.cellValue", record[field.name]);
        component.set("v.isRequired", field.required);
        component.set("v.fieldName", field.name);
        if (field.type == 'STRING') {
            if (field.name == 'Name') {
                component.set("v.isEditable", false);
            }
            component.set("v.isTextField", true);
        } else if (field.type == 'TEXTAREA') {
            component.set("v.isTextAreaField", true);
        } else if (field.type == 'BOOLEAN') {
            component.set("v.isBOOLEANField", true);
            component.set("v.checkBoxValue", record[field.name]);
        } else if (field.type == 'DATE') {
            component.set("v.isDateField", true);
            if (record[field.name] == undefined || record[field.name] == null || record[field.name] == '') {
                delete record[field.name];
            }
        } else if (field.type == 'PICKLIST') {
            component.set("v.isDropDownField", true);
            component.set("v.dropDownValue", record[field.name]);
            console.log('field.pickListValuesList::', record[field.name]);
            if (field.pickListValuesList != undefined) {
                component.set('v.dropDown', field.pickListValuesList);
            }
        } else if (field.type == 'DATETIME') {
            component.set("v.isDateTimeField", true);
            if (record[field.name] == undefined || record[field.name] == '') {
                delete record[field.name];
            }
        } else if (field.type == 'DOUBLE') {
            component.set("v.isDOUBLEField", true);
        } else if (field.type == 'CURRENCY') {
            component.set("v.isCurrencyField", true);
        } else if (field.type == 'REFERENCE') {
            component.set("v.isReferenceField", true);
            var relationShipName = '';
            if (field.name.indexOf('__c') == -1) {
                relationShipName = field.name.substring(0, field.name.indexOf('Id'));
            } else {
                relationShipName = field.name.substring(0, field.name.indexOf('__c')) + '__r';
            }
            component.set('v.fieldName', field.name);
            if (record[relationShipName] != undefined && record[relationShipName].Name != undefined) {
                component.set("v.cellLabel", record[relationShipName].Name);
            }
        }
    },

    getLookUpValues: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var selectedRecordId = event.getParam("selectedRecordId");
        var record = component.get('v.record');
        record[fieldName] = selectedRecordId;
        component.set('v.record', record);
    },

    onInputChange: function (component, event, helper) {
        var fieldName = event.getSource().get("v.name").split('-');
        var fieldLabel = fieldName[1];
        var selectedValue = event.getSource().get("v.value");
        var record = component.get('v.record');
        record[fieldLabel] = selectedValue != '' && selectedValue != 'None' ? selectedValue : '';
        component.set('v.record', record);
    },

    onCheckBoxChange: function (component, event, helper) {
        var fieldLabel = event.getSource().get("v.name").split('-');
        var selectedValue = event.getSource().get("v.checked");
        var record = component.get('v.record');
        record[fieldLabel] = selectedValue != '' && selectedValue != 'None' ? selectedValue : '';
        component.set('v.record', record);
    }
})