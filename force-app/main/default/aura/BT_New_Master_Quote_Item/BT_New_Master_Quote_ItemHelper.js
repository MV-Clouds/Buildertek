({
	
     getProductDetails:function(component,event,helper){
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({"productId":productId});
        action.setCallback(this,function(respo){
            var res = respo.getReturnValue();
            var getProductDetails = component.get("v.newQuoteItem");
            ////console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Master_Quote__c = component.get("v.mainObjectId");
            getProductDetails.Name = productName;
            if(res.length>=1) {
                getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
            }else{
                getProductDetails.buildertek__Unit_Price__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            component.set("v.newQuoteItem",getProductDetails);
        });
        $A.enqueueAction(action);
    },
})