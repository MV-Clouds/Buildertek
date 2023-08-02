({
    doInit: function (component, event, helper) {
        // console.log('bt_fieldSetMassUpdate Controller callled===');
        var record = component.get("v.record");
        // console.log('record=='+record);
        // console.log({record});
        var field = component.get("v.field");
        if(field.name == 'buildertek__Contractor__c'){
            if (record != undefined) {
                if(record.buildertek__Contractor__c){
                    component.set("v.contractor",record.buildertek__Contractor__c);
                }
            }
            
        }
        var objectname = component.get("v.childObjectName");
        var mainobjectname = component.get("v.ObjectName");
        if (record != undefined) {
            component.set("v.cellValue", record[field.name]);
            component.set("v.fieldName", field.name);
            // console.log('cellValue=='+record[field.name]);
            // console.log('field.Name==='+field.name);
            // console.log('field.type==='+field.type);
            // console.log('percentageValue=='+component.get("v.percentageValue"));
            if (field.type == 'STRING') {
                component.set("v.isTextField", true);
                //alert('hai');
                if(objectname != 'buildertek__Select_Sheet__c'){
                    if (field.readOnly != undefined) {
                        component.set('v.readOnly', field.readOnly);
                    }
                } 
                if(mainobjectname=='buildertek__Select_Sheet__c'){
                    if (field.readOnly != undefined) {
                        component.set('v.readOnly', field.readOnly);
                    }
                } 
                
                
            } else if (field.type == 'TEXTAREA') {
                component.set("v.isTextAreaField", true);
            } else if (field.type == 'PICKLIST') {
                component.set("v.isDropDownField", true);
                component.set("v.dropDownValue", record[field.name]);
                if (field.pickListValuesList != undefined) {
                    var cellValue = component.get("v.cellValue");
                    if (cellValue != undefined) {
                        if (!field.pickListValuesList.includes(cellValue)) {
                            field.pickListValuesList.push(cellValue);
                        }
                    }
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
                if (percentage == undefined || percentage == '') {
                    percentage = 0;
                    component.set("v.percentageValue", percentage.toFixed(2));
                } else {
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
        if(selectedRecordId){
            record[fieldName] = selectedRecordId[0];
            if(fieldName == 'buildertek__Contractor_Resource__c'){
                if(record['buildertek__Contractor_Resource__r']){
                    record['buildertek__Contractor_Resource__r']['Id'] = selectedRecordId.Id;
                    record['buildertek__Contractor_Resource__r']['Name'] = selectedRecordId.Name;
                    if(record['buildertek__Contractor_Resource__r']['attributes']){
                        record['buildertek__Contractor_Resource__r']['attributes']['url'] = '/services/data/v51.0/sobjects/Contact/'+selectedRecordId.Id;
                    }else{
                        record['buildertek__Contractor_Resource__r']['attributes'] = {};
                        record['buildertek__Contractor_Resource__r']['attributes']['url'] = '/services/data/v51.0/sobjects/Contact/'+selectedRecordId.Id;
                        
                    }
                }else{
                    record['buildertek__Contractor_Resource__r'] = {};
                    record['buildertek__Contractor_Resource__r']['Id'] = selectedRecordId.Id;
                    record['buildertek__Contractor_Resource__r']['Name'] = selectedRecordId.Name;
                    if(record['buildertek__Contractor_Resource__r']['attributes']){
                        record['buildertek__Contractor_Resource__r']['attributes']['url'] = '/services/data/v51.0/sobjects/Contact/'+selectedRecordId.Id;
                    }else{
                        record['buildertek__Contractor_Resource__r']['attributes'] = {};
                        record['buildertek__Contractor_Resource__r']['attributes']['url'] = '/services/data/v51.0/sobjects/Contact/'+selectedRecordId.Id;
                    }
                }
                record[fieldName] = selectedRecordId.Id;
            }
            if(fieldName == 'buildertek__Dependency__c'){
                var selectedParsedRecord = JSON.parse(JSON.stringify(selectedRecordId));
                if(Object.keys(selectedParsedRecord).length){
                    if(record['buildertek__Dependency__r']){
                        record['buildertek__Dependency__r']['Id'] = selectedRecordId.Id;
                        record['buildertek__Dependency__r']['Name'] = selectedRecordId.Name;
                        if(record['buildertek__Dependency__r']['attributes']){
                            record['buildertek__Dependency__r']['attributes']['url'] = '/services/data/v51.0/sobjects/Contact/'+selectedRecordId.Id;
                        }else{
                            record['buildertek__Dependency__r']['attributes'] = {};
                            record['buildertek__Dependency__r']['attributes']['url'] = '/services/data/v51.0/sobjects/Contact/'+selectedRecordId.Id;
                            
                        }
                    }else{
                        record['buildertek__Dependency__r'] = {};
                        record['buildertek__Dependency__r']['Id'] = selectedRecordId.Id;
                        record['buildertek__Dependency__r']['Name'] = selectedRecordId.Name;
                        if(record['buildertek__Dependency__r']['attributes']){
                            record['buildertek__Dependency__r']['attributes']['url'] = '/services/data/v51.0/sobjects/buildertek__Project_Task__c/'+selectedRecordId.Id;
                        }else{
                            record['buildertek__Dependency__r']['attributes'] = {};
                            record['buildertek__Dependency__r']['attributes']['url'] = '/services/data/v51.0/sobjects/buildertek__Project_Task__c/'+selectedRecordId.Id;
                        }
                    }
                    record[fieldName] = selectedRecordId.Id;
                }else{
                    record['buildertek__Dependency__r'] = {};
                    record['buildertek__Dependency__r']['Id'] ='';
                    record['buildertek__Dependency__r']['Name'] = '';
                    if(record['buildertek__Dependency__r']['attributes']){
                        record['buildertek__Dependency__r']['attributes']['url'] = '';
                    }else{
                        record['buildertek__Dependency__r']['attributes'] = {};
                        record['buildertek__Dependency__r']['attributes']['url'] = '';
                    }
                    record[fieldName] = null;
                }
                
            }
            component.set('v.record', record);
            if(fieldName == 'buildertek__Contractor__c'){
                component.set("v.contractor",record[fieldName]);
            }
            
            if(component.get("v.fromcustomDataTable")){
                var compEvent = component.getEvent("dataTableRow");
                compEvent.setParams({
                    "isdelete" : false,
                    "message" : {
                        fieldName : event.getParam("fieldName"),
                        selectedRecordId : event.getParam("selectedRecordId"),
                        index : component.get("v.index"),// event.getParam("index"),
                        phaseIndex : component.get("v.phaseIndex"),
                    }
                });
                compEvent.fire();
            }
        }
        
        
    },
    
    onInputChange: function (component, event, helper) {
        var fieldName = event.getSource().get("v.name").split('-');
        var fieldLabel = fieldName[1];
        // debugger;
        var selectedValue = event.getSource().get("v.value");
        //alert(selectedValue);
        var record = component.get('v.record');
        record[fieldLabel] = selectedValue != '' && selectedValue != 'None' ? selectedValue : '';
        if (fieldLabel == 'buildertek__Finish__c') {
            if (record.buildertek__Start__c != null && record.buildertek__Start__c != '' && record.buildertek__Finish__c != null && record.buildertek__Finish__c != '') {
                var startData = new Date(record.buildertek__Start__c);
                var finishDate = new Date(record.buildertek__Finish__c);
                finishDate.setDate(finishDate.getDate() + 1)
                var diffTime = Math.abs(finishDate - startData);
                var diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                if (diffDays > 0) {
                    record.buildertek__Duration__c = diffDays;
                }
            }
        }
        component.set('v.record', record);
    },
    
    onPercentageChange: function (component, event, helper) {
        //var fieldName = event.getSource().get("v.name").split('-');
        var fieldName = event.target.name.split('-');
        var fieldLabel = fieldName[1];
        //var selectedValue = parseFloat(event.getSource().get("v.value"));
        var selectedValue = parseFloat(event.target.value);
        var record = component.get('v.record');
        record[fieldLabel] = selectedValue != undefined && selectedValue != '' && selectedValue != '' ? selectedValue.toFixed(2) : 0;
        component.set('v.record', record);
    },
    
    onCheckBoxChange: function (component, event, helper) {
        var fieldLabel = event.getSource().get("v.name").split('-');
        var selectedValue = event.getSource().get("v.checked");
        var record = component.get('v.record');
        record[fieldLabel] = selectedValue ? true : false;
        
        var index = JSON.stringify(component.get("v.index"));
        if(fieldLabel != 'buildertek__Tax__c'){
           if(selectedValue){
            record['buildertek__Completion__c'] = 100;
            var ele = document.getElementById(index+'_completion');
          //  console.log(ele.children[0])
            ele.value = 100;
            
            component.set("v.percentageValue", 100);
        }else{
            record['buildertek__Completion__c'] = 0;
            var ele = document.getElementById(index+'_completion');
            ele.value = 0;
            
            component.set("v.percentageValue", 0);
        }
        //  console.log(JSON.parse(JSON.stringify(record))); 
        }
        component.set('v.record', record);
    },
    handleContractorChange :function (component, event, helper) {
        //component.set("v.contractorChange",true);
        component.set("v.isReferenceField", true);
        $A.enqueueAction(component.get('c.doInit'));
        
    }
})