({
    doInit: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        helper.fetchpricebooks(component, event, helper);
    },
    changeEvent: function (component, event, helper) {
        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({ "recordByEvent": product });
        compEvent.fire();
        component.set('v.newSalesInvoiceLine.buildertek__Item_Name__c', '');
        component.set('v.newSalesInvoiceLine.buildertek__Cost_Code__c', null);
        component.set('v.newSalesInvoiceLine.buildertek__Unit_Price__c', null);
        component.set('v.newSalesInvoiceLine.buildertek__Quantity__c', 1);
        var pricebookId = component.get("v.pricebookName");
        var action = component.get("c.getProductfamilyRecords");
        action.setParams({
            'ObjectName': "Product2",
            'parentId': pricebookId
        });

        action.setCallback(this, function (response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
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

    handleSaveSuccess: function (component, event, helper) {
        if (event) {
            if (event.getParams().message && event.getParams().message.indexOf('was saved') != -1) {
                var page = component.get("v.page") || 1;
                helper.getGroups(component, event, helper, page);
                $A.get("e.force:refreshView").fire();
            }
        }
    },

    handleComponentEvent: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.newSalesInvoiceLine.buildertek__Item_Name__c", selectedAccountGetFromEvent.Name);
        component.set("v.newSalesInvoiceLine.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);

        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },

    changefamily: function (component, event, helper) {
        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({ "recordByEvent": product });
        compEvent.fire();
        component.set('v.newSalesInvoiceLine.buildertek__Item_Name__c', '');
        component.set('v.newSalesInvoiceLine.buildertek__Cost_Code__c', null);
        component.set('v.newSalesInvoiceLine.buildertek__Unit_Price__c', null);
        component.set('v.newSalesInvoiceLine.buildertek__Quantity__c', 1);
    },

    saveSalesInvoiceLineRecord: function (component, event, helper) {
        let salesinvoiceLineName = component.find('salesInvoiceLineID').get("v.value");
        if (!salesinvoiceLineName){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: "Please enter Sales Invoice Line name.",
                type: "error",
                duration: " 3000",
            });
            toastEvent.fire();
            return;
        }
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var salesInvoice = component.get("v.newSalesInvoiceLine");
        var recordId = component.get("v.recordId");
        component.set("v.newSalesInvoiceLine.buildertek__Billings__c", recordId);

        var action = component.get("c.saveSalesInvoiceLine");
        action.setParams({ "salesInvoice": JSON.stringify(salesInvoice) });
        action.setCallback(this, function (respo) {
            if (component.isValid() && respo.getState() === "SUCCESS") {
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var result = respo.getReturnValue();
                var costCode = component.find('costCodeId');
                costCode.set("v._text_value", '');
                var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({ "recordByEvent": product });
                compEvent.fire();
                component.find('salesInvoiceLineID').set("v.value", '');
                component.set('v.newSalesInvoiceLine.buildertek__Item_Name__c', '');
                component.set('v.newSalesInvoiceLine.buildertek__Unit_Price__c', null);
                component.set('v.newSalesInvoiceLine.buildertek__Cost_Code__c', null);
                component.set('v.newSalesInvoiceLine.buildertek__Quantity__c', 1);
                window.setTimeout(
                    $A.getCallback(function () {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'dismissible',
                            message: 'Sales Invoice Line created successfully',
                            messageTemplate: "Sales Invoice Line created successfully.",
                            messageTemplateData: [{
                                url: baseURL + '/lightning/r/buildertek__Billable_Lines__c/' + escape(result.Id) + '/view',
                                label: result.Name,
                            }],
                            type: 'success',
                            duration: '3000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }), 3000
                );
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                $A.get('e.force:refreshView').fire();

            }
        });
        $A.enqueueAction(action);
    },
})
