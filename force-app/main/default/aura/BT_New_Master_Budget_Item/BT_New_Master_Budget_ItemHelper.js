({
	getProductDetails:function(component,event,helper){
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({"productId":productId});
        action.setCallback(this,function(respo){
            var res = respo.getReturnValue();
            var getProductDetails = component.get("v.newBudgetItem"); 
            ////console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Master_Budget__c = component.get("v.mainObjectId");
            getProductDetails.Name = productName;
            if(res.length>=1) {
                getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
            }else{
                getProductDetails.buildertek__Unit_Price__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.buildertek__Budget_Item_Name__c = productName;
            component.set("v.newBudgetItem",getProductDetails);
        });
        $A.enqueueAction(action);
    },
})