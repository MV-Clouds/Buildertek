({
	getGroups : function(component, event, helper, page) {
        if(component.get("v.recordId")) {
            // Retrieve all the section of related Ad
            var action = component.get("c.retrieveGroups");
            action.setParams({ 
                contractId : component.get("v.recordId"), 
                pageNumber : page,
                recordToDisply : 50
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue()
                    console.log("result",result);
                    component.set("v.TotalRecords", result);
                    component.set("v.columns", result.columns);
                    component.set("v.page", result.page);
                    component.set("v.total", result.total);
                    if(result.total == 0){
                        component.set("v.pages", 1);    
                    }else{
                        component.set("v.pages", Math.ceil(result.total / 50));    
                    }
                    
                    component.set("v.Spinner", false);
                }
            });
            $A.enqueueAction(action);
        }
	},
	
    getProductDetails:function(component,event,helper){
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        //console.log("----productId",productId);
        action.setParams({"productId":productId});
        action.setCallback(this,function(respo){
            var res = respo.getReturnValue(); 
            //console.log("----respo---",res.length);
            var getProductDetails = component.get("v.newContractLine");
            delete getProductDetails.buildertek__Grouping__r;
            //console.log("@Contract@",component.get("v.recordId"));
            getProductDetails.buildertek__Contract__c = component.get("v.recordId");
           // alert("getprodct----",res[0].UnitPrice); 
            if(res.length>=1) {
                if(res[0].UnitPrice != null){
                getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
                }
                if(res[0].buildertek__Discount__c !=null){
                getProductDetails.buildertek__Discount__c = res[0].buildertek__Discount__c;
                }
            }else{
                getProductDetails.buildertek__Unit_Price__c = 0;
                 getProductDetails.buildertek__Discount__c =0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            component.set("v.newContractLine",getProductDetails);
            
            //console.log("getprodct----",JSON.stringify(getProductDetails));
			
            //console.log("----log",res);
        });
        $A.enqueueAction(action);
    },
    
    updateData: function(component, event, helper, dataToUpdate){
			var groupId = component.get("v.group").Id;
            var action = component.get("c.updateLineFromDataTable");
            action.setParams({ items : dataToUpdate, groupId:groupId, contractId : component.get("v.recordId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //console.log(state);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                if (state === "SUCCESS") {
                    component.set("v.group",response.getReturnValue());
                    component.set("v.lines",response.getReturnValue().buildertek__Contract_Lines__r);
                    
                    if(component.find("lineTable")){
                    	component.find("lineTable").set("v.draftValues", null);
                    }
                     $A.get('e.force:refreshView').fire();
                     helper.getSummary(component, event, helper);
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                }
            });
            $A.enqueueAction(action);
	},
    fetchpricebooks:function(component,event,helper){
        var action = component.get("c.getpricebook");
    	action.setParams({
    		"ContractId": component.get("v.recordId")
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
    		}
    	});
    	$A.enqueueAction(actions);
    },
    
})