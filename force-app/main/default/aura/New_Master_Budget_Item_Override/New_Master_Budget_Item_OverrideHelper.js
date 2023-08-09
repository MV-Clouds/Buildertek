({
	getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        //alert('url -------> '+url);
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
     getProductDetails:function(component,event,helper){
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({"productId":productId});
        action.setCallback(this,function(respo){
            var res = respo.getReturnValue();
            var getProductDetails = component.get("v.newBudgetItem");
            ////console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Purchase_Order__c = component.get("v.mainObjectId");
            getProductDetails.Name = productName;
            if(res.length>=1) {
                getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
            }else{
                getProductDetails.buildertek__Unit_Price__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            component.set("v.newBudgetItem",getProductDetails);
        });
        $A.enqueueAction(action);
    },
})