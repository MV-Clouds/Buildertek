({
	
    doInit: function(component, event, helper) {
        //alert('hello1');
        component.set("v.Spinner", true);
        var showPoDetails = component.get("v.isFromExistingPOs");
        var selectedPO = component.get("v.selectedPO");
        component.set("v.selectedExistingPO",selectedPO);
        component.set("v.showPODetails",showPoDetails);
        var action = component.get("c.getProduct");
        var poItem = JSON.stringify(component.get("v.newPOItems"));
        action.setParams({
            poItems: poItem
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.poItemsToInsert", result);
                component.set("v.Spinner", false);
                if(component.get("v.showPODetails") == true){
                    var action = component.get('c.doSave');
                    $A.enqueueAction(action);
                }
            }
        });
        $A.enqueueAction(action);
         helper.fetchPickListVal(component, event, helper);
        //var budgetlineitem = component.get("v.budgetlineid");
    },
    
    removeProduct : function(component, event, helper) {
        var rowIndex = event.target.dataset.name;
         //alert('rowIndex--->'+rowIndex);
        var FiltersList = component.get("v.poItemsToInsert"); 
        FiltersList.splice(rowIndex,1);
        //alert('FiltersList--->'+FiltersList);
        for(var i=0;i<FiltersList.length;i++){
            FiltersList[i].rowIndex = i;
        }
        component.set("v.poItemsToInsert", FiltersList);
    },
    updateProductInfo: function(component, event, helper) {
        var indexOfElementChanged = event.getParam('value'); 
        helper.productselectedprice(component, event, helper,indexOfElementChanged);
        //alert('indexOfElementChanged---'+indexOfElementChanged);
        
    },
    addProduct : function(component, event, helper) {
        var poItemsToInsert = component.get("v.poItemsToInsert");
        var lstOfFilters = JSON.stringify(poItemsToInsert);
	    var action = component.get("c.addProductsToList");
	    action.setParams({
	        POItems : lstOfFilters,
	        POItem : component.get("v.newPOItem"),
	        count : poItemsToInsert.length
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            component.set("v.poItemsToInsert", result);
	        }
	    });
        $A.enqueueAction(action);
    },
    
    onChangeproduct: function (component, event, helper) {
      //  alert('test');
        var rowIndex = event.target.dataset.name;
      //  alert('rowIndex--->'+rowIndex); 
    },
    
    doSave:function(component, event, helper) {
    
        var poItem = JSON.stringify(component.get("v.newPOItems"));
        
        component.set("v.Spinner", true);
        // Check:- Product inside the list of the PO Item is empty or not
        let jsonArray=JSON.stringify(component.get("v.poItemsToInsert"));
        let parseJson = JSON.parse(jsonArray);
        console.log({parseJson});
        let listCOItem=[];
        parseJson.forEach(function(value){
            // If the product is empty then remove it from the Json 
            if(typeof(value.purchaseOrderItem.buildertek__Product__c) != 'string'){
                delete value.purchaseOrderItem.buildertek__Product__c;
            }
            listCOItem.push(value);

        });
        jsonArray=JSON.stringify(listCOItem);

       var isExisted = component.get("v.showPODetails");
    	var action;
        console.log('New PO FIELD ::::',JSON.stringify(component.get("v.newPO")));
        console.log({isExisted});
        if(!isExisted){
            action = component.get("c.createPO");
            action.setParams({
                poJson:  component.get("v.newPO"),
                poItemsJson: jsonArray,
                budgetlineid : component.get("v.budgetlineid")
            });
        }else if(isExisted){
            
            
            var poItem = JSON.stringify(component.get("v.poItemsToInser"));
            var selectedPO = component.get("v.selectedExistingPO");
            action = component.get("c.createLinesForExistedPO");
            action.setParams({
                "poRecordID" : component.get("v.selectedExistingPO"),
                "poItemsJson": jsonArray, //poItem,
                "budgetlineid" : component.get("v.budgetlineid"),
                "addbudgetlineids" : component.get("v.selectedbudgetRecs"),
            });
        }
		
        action.setCallback(this, function (response) {
            console.log(response.getState());
            console.log(response.getError());

            if (component.isValid() && response.getState() === "SUCCESS") {
            	var result = response.getReturnValue();
                console.log({result});
            	if(result.isSuccess === true){
            	  
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                            sObjectEvent.setParams({
                                "recordId": result.strRecordId,
                            })
                            
                        var isFromExistingPOs = component.get("v.isFromExistingPOs");
                   
                    
                    if(isFromExistingPOs == false){
                        sObjectEvent.fire();
                    }else{
                         $A.enqueueAction(component.get("v.saveCallback"));
                       
                     
                        
                    }
                        
                      component.set("v.Spinner", false);
                    
                
            	}else{
            	    component.set("v.Spinner", false);
            	    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error",
                        "message": result.strMessage,
                        closeCallback: function() {
                        }
                    });   
            	} 
			}
        }); 
        
        $A.enqueueAction(action);
	},
	
	doCancel:function(component, event, helper) {
		component.get("v.cancelCallback")();
	}
})