({
	helperMethod : function() {
		
	},
    // auto popuplate the product values of unitprice
    // Developer : laxman 24/07/2020.
    productselectedprice:function (component, event, helper, productid) {
    var action = component.get("c.getProductPricevalues");
        action.setParams({
            productId: JSON.stringify(productid)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                 var result = response.getReturnValue();
                 var coItemsToInsert = component.get("v.coItemsToInsert");
                 var lstOfFilters = JSON.stringify(coItemsToInsert);
                 var i;
                 var coinsertlist = [];
                 if(result != null){
                for(i = 0; i < coItemsToInsert.length; i++){
                   
                        
                        if(coItemsToInsert[i].changeOrderItem.buildertek__Product__c == result.Product2Id ){
                             coItemsToInsert[i].changeOrderItem.buildertek__Quantity__c = 1;
                             coItemsToInsert[i].changeOrderItem.buildertek__Unit_Price__c = result.UnitPrice ;
                             coItemsToInsert[i].changeOrderItem.buildertek__Description__c = result.Product2.Name ; 
                            //coinsertlist.push( coItemsToInsert[i]);  
                        }
                    }
                     
                     component.set("v.coItemsToInsert", coItemsToInsert); 
                 }	
            }
        });
    
        $A.enqueueAction(action);
    },
    fetchPickListVal: function (component, event, helper) {
        var actions = component.get("c.getselectOptions");
        actions.setParams({
            budgetObject: component.get("v.newCO"),
            budgetField: "buildertek__Status__c",
        });
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({
                    key: "Pending",
                    value: "",
                });
                for (var key in result) {
                    if(key != "Pending"){
                        opts.push({
                        key: key,
                        value: result[key],
                    });
                    }
                   
                }
                component.set("v.options", opts);
            }
        });
        $A.enqueueAction(actions);
    },
    fetchRecordTypes: function (component, event, helper) {
        var actions = component.get("c.getCORecordTypes");         
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key],
                    });                   
                }
                component.set("v.RecordTypes", opts);
            }
        });
        $A.enqueueAction(actions);
    },
})