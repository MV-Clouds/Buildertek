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
            console.log('res ==> ',{res});
            var getProductDetails = component.get("v.newQuoteItem");
            ////console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Quote__c = component.get("v.mainObjectId");
            getProductDetails.Name = productName;
            //getProductDetails.buildertek__Quantity__c = 1;
            if(res.length>=1) {
           
            if(res[0].buildertek__Unit_Cost__c !=null){
                getProductDetails.buildertek__Unit_Cost__c = res[0].buildertek__Unit_Cost__c;
            }
            if(res[0].UnitPrice !=null){
                getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice; 
            }
            if(res[0].buildertek__Markup__c !=null ){
                getProductDetails.buildertek__Markup__c = res[0].buildertek__Markup__c;
            }
              if(res[0].buildertek__Discount__c !=null ){
                getProductDetails.buildertek__Additional_Discount__c = res[0].buildertek__Discount__c;
            }
            }else{
                getProductDetails.buildertek__Unit_Cost__c = 0;
                getProductDetails.buildertek__Unit_Price__c = 0;
                getProductDetails.buildertek__Markup__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            console.log('getProductDetails ==> ',{getProductDetails});
            console.log('getProductDetails.buildertek__Unit_Cost__c' ,getProductDetails.buildertek__Unit_Cost__c);
            component.set("v.newQuoteItem",getProductDetails);
        });
        $A.enqueueAction(action);
    },
    
	fetchpricebooks:function(component,event,helper){
        var action = component.get("c.getpricebook");
    	action.setParams({
    		"quotid": component.get("v.recordId")
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

    fetchfields:function(component,event,helper){
        var action = component.get("c.getfield");
        action.setParams({
            "objectName" : 'buildertek__Quote_Item__c',
            "fieldSetName" : 'buildertek__BT_Detail_Page_Fields'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var result  = response.getReturnValue();
                console.log('result',result);
                component.set("v.fieldLst", result);
                //loop through the result and store fAPIName into reqList
                var reqList = [];
                for(var i=0; i<result.length; i++){
                    reqList.push(result[i].fAPIName);
                }
                component.set("v.reqList", reqList);
                console.log('reqList',reqList);
                component.set("v.loading", false);
            }
        })
        $A.enqueueAction(action);
    },
    
     
})