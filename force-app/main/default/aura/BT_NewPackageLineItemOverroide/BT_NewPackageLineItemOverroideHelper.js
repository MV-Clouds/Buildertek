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
            var getProductDetails = component.get("v.newPackageItem");
            getProductDetails.Name = productName;
                if(res == undefined){
            if(res.length>=1) {
            if(res[0].buildertek__Unit_Cost__c !=null){
                getProductDetails.buildertek__Unit_Price__c = res[0].buildertek__Unit_Cost__c;
            }
            if(res[0].UnitPrice !=null){
                getProductDetails.buildertek__Sales_Price__c = res[0].UnitPrice; 
            }
            if(res[0].buildertek__Discount__c !=null){
                getProductDetails.buildertek__Discount__c = res[0].buildertek__Discount__c; 
            }
           
            }else{
                getProductDetails.buildertek__Unit_Cost__c = 0;
                getProductDetails.buildertek__Unit_Price__c = 0;
               getProductDetails.buildertek__Sales_Price__c = 0;
            }
            getProductDetails.buildertek__Products__c = productId;
            getProductDetails.Name = productName;
            component.set("v.newPackageItem",getProductDetails);
                }
        });
        $A.enqueueAction(action);
    
    },
    fetchpricebooks:function(component,event,helper){
        var action = component.get("c.getpricebook");
    	action.setParams({
    		"budgetid": component.get("v.recordId")
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
    getIndustryPicklist: function(component, event, helper) {
        var action = component.get("c.getIndustry");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var locationMap = [];
                for(var key in result){
                    locationMap.push({key: key, value: result[key]});
                }
                component.set("v.locationMap", locationMap);
            }
        });
        $A.enqueueAction(action);
    }, 
    
     getUOMPicklist: function(component, event, helper) {
        var action = component.get("c.getUOM");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var UOMMap = [];
                for(var keys in result){
                    UOMMap.push({key: keys, value: result[keys]});
                }
                component.set("v.UOMMap", UOMMap);
            }
        });
        $A.enqueueAction(action);
    }, 
    
    
    
    
})