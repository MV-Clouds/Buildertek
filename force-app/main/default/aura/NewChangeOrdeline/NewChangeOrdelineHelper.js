({
	getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
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
            var getProductDetails = component.get("v.newCoitem");
            ////console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Change_Order__c = component.get("v.mainObjectId");
            //alert('getProductDetails.buildertek__Change_Order__c----'+getProductDetails.buildertek__Change_Order__c);
            getProductDetails.Name = productName;
            if(res.length>=1) {
			if(res[0].buildertek__Unit_Cost__c !=null){
                getProductDetails.buildertek__Unit_Price__c = res[0].buildertek__Unit_Cost__c;
				}
				if(res[0].buildertek__Markup__c !=null){
				getProductDetails.buildertek__Markup__c = res[0].buildertek__Markup__c;
				}
                if(res[0].buildertek__Discount__c !=null){
                getProductDetails.buildertek__Discount__c = res[0].buildertek__Discount__c; 
                }
            }else{
                getProductDetails.buildertek__Unit_Price__c = 0;
				getProductDetails.buildertek__Markup__c  =0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            component.set("v.newCoitem",getProductDetails);
        });
        $A.enqueueAction(action);
    },
    
	fetchpricebooks:function(component,event,helper){
        var action = component.get("c.getpricebook");
    	action.setParams({
    		"BudgetId": component.get("v.recordId")
    	});
    	var opts = [];
    	action.setCallback(this, function(response) {
    		if (response.getState() == "SUCCESS") {
    		    
    			component.set("v.pricebookName", response.getReturnValue());
    		}
    	});
    	$A.enqueueAction(action);
        var actions = component.get("c.getpricebooks");
    	
    	var opts = [];
    	actions.setCallback(this, function(response) {
    		if (response.getState() == "SUCCESS") {
    		    var result  = response.getReturnValue();
    			var opts = [];
    			opts.push({key: "None", value: "" });
                for(var key in result){
                    opts.push({key: key, value: result[key]});
                }
    			component.set("v.pricebookoptions", opts);
    			component.set("v.Spinner", false);
    		}
    	});
    	$A.enqueueAction(actions);
    },
})