({
    doInit: function (component, event, helper) {
        var record = component.get("v.record");
        var field = component.get("v.field");
        if (record != undefined) {
            component.set("v.cellValue", record[field.name]);
            component.set("v.fieldName", field.name);
            if (field.type == 'STRING') {
                component.set("v.isTextField", true);
                if (field.readOnly != undefined) {
                    component.set('v.readOnly', field.readOnly);
                }
            } else if (field.type == 'TEXTAREA') {
                component.set("v.isTextAreaField", true);
            } else if (field.type == 'PICKLIST') {
                component.set("v.isDropDownField", true);
                component.set("v.dropDownValue", record[field.name]);
                if (field.pickListValuesList != undefined) {
                    component.set('v.dropDown', field.pickListValuesList);
                }
            } else if (field.type == 'DATE') {
                component.set("v.isDateField", true);
            } else if (field.type == 'DOUBLE') {
                component.set("v.isDoubleField", true);
            } else if (field.type == 'BOOLEAN') {
                component.set("v.isCheckBoxField", true);
                component.set("v.checkBoxValue", record[field.name]);
            } else if (field.type == 'PERCENT') {
                var percentage = parseFloat(record[field.name] != undefined && record[field.name] != '' ? record[field.name] : 0);
                if (percentage == undefined || percentage == '') {} else {
                    component.set("v.percentageValue", percentage.toFixed(2));
                }
                component.set("v.isPercentField", true);
            } else if (field.type == 'DATETIME') {
                component.set("v.isDateTimeField", true);
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
        }
    },

    getLookUpValues: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var selectedRecordId = event.getParam("selectedRecordId");
        var record = component.get('v.record');
        record[fieldName] = selectedRecordId[0];
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

    onPercentageChange: function (component, event, helper) {
        var fieldName = event.getSource().get("v.name").split('-');
        var fieldLabel = fieldName[1];
        var selectedValue = parseFloat(event.getSource().get("v.value"));
        var record = component.get('v.record');
        record[fieldLabel] = selectedValue != undefined && selectedValue != '' && selectedValue != '' ? selectedValue.toFixed(2) : 0;
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