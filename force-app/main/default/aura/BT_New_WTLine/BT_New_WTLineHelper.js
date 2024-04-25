({
    getRecordType : function(component) {
        console.log('getRecordType');
        var action = component.get("c.getRecordType");
        action.setParams({
            "ObjectAPIName": "buildertek__Walk_Through_Line_Items__c"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.recordTypeList", result);
                component.set("v.selectedRecordTypeId", result[0].Id);
            }
        });
        $A.enqueueAction(action);
    },

    getFields : function(component) {
        console.log('getFields');
        var action = component.get("c.getFieldSet");
        action.setParams({
            objName: 'buildertek__Walk_Through_Line_Items__c',
            fieldSetName: 'buildertek__NewfromParent'
        });
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            console.log('fieldSetObj::',fieldSetObj);
            component.set("v.fieldSetValues", fieldSetObj);
            component.set("v.spinner", false);
        })
        $A.enqueueAction(action);
    },

    getPriceBook :function(component){
        console.log('getPriceBook');
        var action = component.get("c.getPricebookList");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: ' , result);
                let pricebookList = [];
                let defaulutPriceBook = result[0].defaultValue;
                if(defaulutPriceBook === undefined){
                    component.set("v.pricebookName", '');
                }else{
                    component.set("v.pricebookName", defaulutPriceBook.Id);
                    // helper.changeEvent(component);
                }
                result[0].priceWrapList.forEach(function(element){
                    pricebookList.push({key: element.Name, value: element.Id});
                });
                component.set("v.pricebookoptions", pricebookList);
            }
        });
        $A.enqueueAction(action);
    },

    changeEvent : function(component, event, helper){
        console.log('changeEvent in helper');
        var selectedPriceBook = component.get("v.pricebookName");
        console.log('selectedPriceBook: ' , selectedPriceBook);
        component.set('v.Spinner', true);
        var action = component.get("c.getProductFamily");
        action.setParams({
            "pbookId": selectedPriceBook 
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            // component.set("v.productFamilySet", JSON.parse(JSON.stringify(result)));
            console.log('result: ' , result);

        });
        $A.enqueueAction(action);  
    },
})