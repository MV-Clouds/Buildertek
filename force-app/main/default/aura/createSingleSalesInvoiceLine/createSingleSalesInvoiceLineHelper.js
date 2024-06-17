({
    fetchpricebooks: function (component, event, helper) {
        var action = component.get("c.getpricebook");
        action.setParams({
            "SaleInvoiceId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                component.set("v.pricebookName", response.getReturnValue());
                var action1 = component.get('c.changeEvent');
                $A.enqueueAction(action1);
            }
        });
        $A.enqueueAction(action);
        var actions = component.get("c.getpricebooks");
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({ key: "None", value: "" });
                for (var key in result) {
                    opts.push({ key: key, value: result[key] });
                }
                component.set("v.pricebookoptions", opts);
            }
        });
        $A.enqueueAction(actions);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
    },

    getProductDetails: function (component, event, helper) {
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        console.log(`Product Id: ${productId} and Product Name: ${productName}`);
        action.setParams({ "productId": productId });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            console.log(`Product response: ${JSON.stringify(res)}`);
            var getProductDetails = component.get("v.newSalesInvoiceLine");
            getProductDetails.buildertek__Billings__c = component.get("v.recordId");
            if (res.length >= 1) {
                if (res[0].buildertek__Unit_Cost__c != null) {
                    getProductDetails.buildertek__Unit_Price__c = res[0].buildertek__Unit_Cost__c;
                }
                getProductDetails.buildertek__Cost_Code__c = res[0].Product2.buildertek__Cost_Code__c;
                component.set("v.costCode", res[0].Product2.buildertek__Cost_Code__r.Name);
            } else {
                getProductDetails.buildertek__Unit_Price__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            getProductDetails.buildertek__Item_Name__c = productName;
            component.set("v.newSalesInvoiceLine", getProductDetails);
        });
        $A.enqueueAction(action);
    },
})
