({

    bomRelatedInfo: function (component, event, helper) {
        if(component.get('v.recordId') != undefined){
            var action = component.get("c.getBOMInfo");
            action.setParams({
                recordId: component.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                if (result.status == 'SUCCESS') {
                    component.set("v.TotalRecords", result.count);
                    component.set('v.parentId', result.parentId);
                    component.set('v.bom', result.name);
                }
            })
            $A.enqueueAction(action);
        }
    },

    helpergetProductPhase_BuildPhase: function(component, event, helper){
        var action = component.get("c.get_ProductPhase_BuildPhase");
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            console.log('helpergetProductPhase_BuildPhase : ', result);
            if(result !=  null){
                component.set("v.ProductPhase_Vs_BuildPhase", result);
            }
        })
        $A.enqueueAction(action);
    },

    getTableFieldSet: function (component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            console.log('@@fieldSetValues-- ', JSON.parse(JSON.stringify(fieldSetValues)));
        })
        $A.enqueueAction(action);
    },

    getTableRows: function (component, event, helper, pageNumber, pageSize, productType, searchLocation, searchCategory, searchTradeType) {
        component.set('v.isLoading', true);
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var arrfieldNames = [];
        action.setParams({
            recordId: component.get('v.recordId'),
            fieldNameJson: JSON.stringify(arrfieldNames),
            pageNumber: pageNumber,
            pageSize: pageSize,
            productType: productType,
            searchLocation: searchLocation,
            searchCategory: searchCategory,
            searchTradeType: searchTradeType
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var list = JSON.parse(response.getReturnValue());
                if (list.length > 0) {
                    console.log('@@list-- ', list);
                    component.set("v.listOfRecords", list);
                    component.set("v.cloneListOfRecords", list);
                    component.set('v.numberOfItems', list.length);
                    component.set("v.PageNumber", pageNumber);
                    component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                    component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                  
                    if (component.get('v.TotalRecords') < pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                } else {
                    component.set("v.listOfRecords", []);
                    component.set("v.cloneListOfRecords", []);
                    component.set('v.numberOfItems', 0);
                    component.set("v.PageNumber", 1);
                    component.set("v.RecordStart", 0);
                    component.set("v.RecordEnd", 0);
                    component.set("v.TotalPages", 0);
                    component.set("v.isNextVisible", true);

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'This BOM doesn\'t have any BOM line!',
                        "type": 'Error',
                        "duration" : 5000
                    });
                    toastEvent.fire();
                }
                window.setTimeout(
                    $A.getCallback(function () {
                      component.set('v.isLoading', false);
                    }),
                    3000
                );
            } else {
                component.set("v.listOfRecords", []);
                component.set("v.cloneListOfRecords", []);
            }
        })
        $A.enqueueAction(action);
    },

    updateMassRecords: function (component, event, helper, productType, searchLocation, searchCategory, searchTradeType) {
        component.set('v.isLoading', true);
        var listOfRecords = component.get('v.listOfRecords');
        var action = component.get("c.updateRecords");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        component.set('v.listOfRecords', []); 
        action.setParams({
            recordId: component.get('v.recordId'),
            updatedRecords: JSON.stringify(listOfRecords),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize,
            productType: productType,
            searchLocation: searchLocation,
            searchCategory: searchCategory,
            searchTradeType: searchTradeType
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() == 'Success') {
                component.set('v.isCancelModalOpen', false);
                $A.get("e.force:refreshView").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": 'Record Save Successfully.',
                    "type": 'Success'
                });
                toastEvent.fire(); 
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": 'Something went wrong!',
                    "type": 'error'
                });
                toastEvent.fire();
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },

    deleteRecord: function (component, event, helper, deleteRecordId, productType, searchLocation, searchCategory, searchTradeType) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");

        var action = component.get("c.deleteBomLines");
        action.setParams({
            deleteRecordId: deleteRecordId,
            recordId: component.get('v.recordId'),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize,
            productType: productType,
            searchLocation: searchLocation,
            searchCategory: searchCategory,
            searchTradeType: searchTradeType
        });

        action.setCallback(this, function (response) {
            var state = response.getState();      
            if (state === "SUCCESS") {
                var list = JSON.parse(response.getReturnValue());
                if(list){
                     component.set('v.listOfRecords', list);
                component.set('v.numberOfItems', list.length);
                component.set('v.cloneListOfRecords', list);
                component.set('v.isLoading', false);
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                }
                $A.get('e.force:refreshView').fire();
               
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },

    setProduct: function(component, event, helper, setProduct, index){
        try {
            var listOfRecords = component.get("v.listOfRecords");
            if(setProduct){
                var product = event.getParam("recordByEvent");
                var pricebookEntry = event.getParam("PricebookEntryrecordByEvent");
                console.log("Price book Entries :-> " ,JSON.parse(JSON.stringify(pricebookEntry)));
                if(product){
                    var ProductPhase_Vs_BuildPhase = component.get("v.ProductPhase_Vs_BuildPhase");

                    listOfRecords[index].buildertek__Product__r = product;
                    listOfRecords[index].buildertek__Product__c = product.Id;
                    listOfRecords[index].buildertek__Description__c = product.Name;
                    listOfRecords[index].Name = product.Name;
                    listOfRecords[index].buildertek__Vendor__c = product.buildertek__Vendor__c;
                    listOfRecords[index].buildertek__Cost_Code__c = product.buildertek__Cost_Code__c;
                    listOfRecords[index].buildertek__Build_Phase__c = ProductPhase_Vs_BuildPhase[product.buildertek__Quote_Group__c] ? ProductPhase_Vs_BuildPhase[product.buildertek__Quote_Group__c] : null;
                    listOfRecords[index].buildertek__Quantity__c = 1;
                    listOfRecords[index].buildertek__Category__c = product.buildertek__Category__c;
                    if(pricebookEntry.buildertek__Unit_Cost__c){
                        listOfRecords[index].buildertek__BL_UNIT_COST__c = pricebookEntry.buildertek__Unit_Cost__c;
                    }else{
                        listOfRecords[index].buildertek__BL_UNIT_COST__c = 0;                    
                    }
                }
            }
            else {
                listOfRecords[index].buildertek__Product__r = null;
                listOfRecords[index].buildertek__Product__c = null;
                listOfRecords[index].buildertek__Description__c = null;
                listOfRecords[index].Name = null;
                listOfRecords[index].buildertek__Vendor__c = null;
                listOfRecords[index].buildertek__Cost_Code__c = null;
                listOfRecords[index].buildertek__Build_Phase__c = null;
                listOfRecords[index].buildertek__Quantity__c = 0;
                listOfRecords[index].buildertek__Category__c = null;
                listOfRecords[index].buildertek__BL_UNIT_COST__c = 0;

            }
            component.set("v.currectModifiedIndex", index);
            component.set("v.rerender", true);
            component.set("v.listOfRecords", listOfRecords);
            component.set("v.rerender", false);
          window.setTimeout(
              $A.getCallback(function () {
                  component.set("v.isLoading", false);
            }),500
        );
        } catch (error) {
            console.log('error in setProduct : ', error.stack);
        }
    },
})