({
	helperMethod : function() {
		
	},
    // auto popuplate the product values of unitprice
    // Developer : laxman 24/07/2020.
    productselectedprice:function (component, event, helper, productid) {
    var action = component.get("c.getProductPricevalue");
        action.setParams({
            productId: JSON.stringify(productid)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
               var result = response.getReturnValue();
                 var poItemsToInsert = component.get("v.poItemsToInsert");
                 var lstOfFilters = JSON.stringify(poItemsToInsert);
                 var i;
                 var Poinsertlist = [];
                if(result != null){
                for(i = 0; i < poItemsToInsert.length; i++){
                   
                        //alert('poinsert--'+poItemsToInsert[i].purchaseOrderItem.buildertek__Product__c);
                        
                        if(poItemsToInsert[i].purchaseOrderItem.buildertek__Product__c == result.Product2Id ){
                             poItemsToInsert[i].purchaseOrderItem.buildertek__Quantity__c = 1;
                             poItemsToInsert[i].purchaseOrderItem.buildertek__Unit_Price__c = result.UnitPrice ;
                             poItemsToInsert[i].purchaseOrderItem.buildertek__Description__c = result.Product2.Name ; 
                            //Poinsertlist.push( poItemsToInsert[i]);  
                        }
                    }
                     
                     component.set("v.poItemsToInsert", poItemsToInsert);
                }
               
					
            }
        });
    
        $A.enqueueAction(action);
    },
    fetchPickListVal: function (component, event, helper) {
        var actions = component.get("c.getselectOptions");
        actions.setParams({
            budgetObject: component.get("v.newPO"),
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
                    if(key != 'Pending'){
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
})