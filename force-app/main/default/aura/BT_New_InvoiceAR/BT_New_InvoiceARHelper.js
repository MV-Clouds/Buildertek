({
    showToast: function(type, title, message, time) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message,
            "duration": time
        });
        toastEvent.fire();
    },

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
})