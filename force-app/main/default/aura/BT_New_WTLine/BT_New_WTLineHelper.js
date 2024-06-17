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
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },

    getFields : function(component) {
        console.log('getFields');
        var action = component.get("c.getFieldSet");
        action.setParams({
            objName: 'buildertek__Walk_Through_Line_Items__c',
            fieldSetName: 'buildertek__NewFromParentQuickAction'
        });
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            console.log('fieldSetObj::',fieldSetObj);
            component.set("v.fieldSetValues", fieldSetObj);
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
                console.log('defaulutPriceBook-->',defaulutPriceBook);
                if(defaulutPriceBook === undefined){
                    component.set("v.pricebookName", '');
                }else{
                    component.set("v.pricebookName", defaulutPriceBook.Id);
                }
                result[0].priceWrapList.forEach(function(element){
                    pricebookList.push({key: element.Name, value: element.Id});
                });
                component.set("v.pricebookoptions", pricebookList);
                this.changeEvent(component);
            }
        });
        $A.enqueueAction(action);
    },

    changeEvent: function (component) {
        console.log('inside changeevent');
        component.set('v.Spinner', true);
        var pribooknames = component.get("v.pricebookName");
        console.log({pribooknames});
        var action = component.get("c.getProductfamilyRecords");
        
        action.setParams({
            'ObjectName': "Product2",
            'parentId': component.get("v.pricebookName")
        });
        action.setCallback(this, function (response) {
            component.set('v.Spinner', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue(); 
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listofproductfamily", storeResponse);

                if (component.get("v.listofproductfamily").length > 0) {
                    component.set("v.productfamily", component.get("v.listofproductfamily")[0].productfamilyvalues);
                }

            }

        }); 
        $A.enqueueAction(action);
    },

    getProductDetails: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var priceookId = component.get("v.pricebookName");
        console.log('productId-->',productId);
        action.setParams({
            "productId": productId,
            "pricebookId": priceookId
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            component.set("v.Spinner", false);
            console.log('res-->',res);
            if (res.length > 0) {
                component.set("v.UnitPrice", res[0].buildertek__Unit_Cost__c ? res[0].buildertek__Unit_Cost__c : (res[0].UnitPrice ? res[0].UnitPrice : 0));
                component.set("v.description", res[0].Product2.Description ? res[0].Product2.Description : res[0].Product2.Name);
                component.set("v.notes", res[0].Product2.buildertek__Instructions__c ? this.convertToPlain(res[0].Product2.buildertek__Instructions__c) : '');
            } else {
                component.set("v.UnitPrice", '0');
            }
        });
        $A.enqueueAction(action);
    },

    convertToPlain: function(html){
        var tempDivElement = document.createElement("div");
        tempDivElement.innerHTML = html;
        return tempDivElement.textContent || tempDivElement.innerText || "";
    }
})