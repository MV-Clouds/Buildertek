({
    getVendors : function(component, event, helper) {
        console.log('getVendors');
        var action = component.get("c.getVendors");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var vendors = response.getReturnValue();
                console.log('vendors: ', vendors);
                component.set("v.MainvendorList", vendors);
                component.set("v.ItervendorList", vendors);
            }
        });
        $A.enqueueAction(action);
    },
    
    goToProdModalHelper: function(component, event, helper) {
        
        var vendorId = component.get('v.vendorId');
        console.log('vendorId--->',vendorId);
        var action = component.get("c.getProductsthroughVendor");
            action.setParams({
                "vendorId": vendorId 
            });
            action.setCallback(this, function(response) {
                var rows = response.getReturnValue();
                if (response.getState() == "SUCCESS" && rows != null) {
                    console.log('quoteLineList ==> ',{rows});
                    console.log('updatedRows--->',rows);

                    component.set("v.quoteLineList", rows);
                    component.set("v.tableDataList", rows);
                    var productFamilySet = new Set();
                    rows.forEach(element => {
                        if (element.Family != undefined && element.Family != '') {
                            productFamilySet.add(element.Family);
                        }
                    });
                    var productFamilyList = [];
                    productFamilyList.push({
                        key: '-- All Product Family --',
                        value: ''
                    });
                    productFamilySet.forEach(function(value) {
                        productFamilyList.push({
                            key: value,
                            value: value
                        });
                    });
                    console.log('productFamilyList ==> ',{productFamilyList});
                    component.set("v.productFamilyOptions", productFamilyList);
                }
            });
            $A.enqueueAction(action);
    },

    goToEditModalHelper: function(component, event, helper){
        
        
    },
})