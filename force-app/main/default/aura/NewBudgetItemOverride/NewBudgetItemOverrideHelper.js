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

        console.log('productId',productId);
        // get price book id
        var pricebookId = component.get("v.pricebookName");

        console.log('pricebookId ---- valueesss',pricebookId);
        console.log('pricebookId',pricebookId);
        var productName = component.get("v.productName");

        if(pricebookId != null && pricebookId != undefined && pricebookId != ''){
            console.log('pricebookId ---- ',pricebookId);
            console.log('productId ---- ',productId);
            action.setParams({"productId":productId , "pricebookId":pricebookId});
            action.setCallback(this,function(respo){
                var res = respo.getReturnValue();
                var getProductDetails = component.get("v.newBudgetItem");
                ////console.log("@Budgetline@",component.get("v.recordId"));
                // alert('res'+res);
                getProductDetails.Name = productName;
                if(res.length>=1) {
                
                if(res[0].buildertek__Unit_Cost__c !=null || res[0].buildertek__Unit_Cost__c != undefined){
                    getProductDetails.buildertek__Unit_Price__c = res[0].buildertek__Unit_Cost__c;
                }
                else{
                    getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
                }
                if(res[0].UnitPrice !=null){
                    getProductDetails.buildertek__Sales_Price__c = res[0].UnitPrice; 
                }
                if(res[0].buildertek__Discount__c !=null){
                    getProductDetails.buildertek__Discount__c = res[0].buildertek__Discount__c; 
                }

            
                }else{
                    getProductDetails.buildertek__Unit_Price__c = 0;
                    getProductDetails.buildertek__Unit_Cost__c = 0;
                    getProductDetails.buildertek__Sales_Price__c = 0;
                }
                getProductDetails.buildertek__Product__c = productId;
                
                getProductDetails.Name = productName;
                component.set("v.newBudgetItem",getProductDetails);
            });
        $A.enqueueAction(action);
        }        
        // alert(productId);

        
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
})