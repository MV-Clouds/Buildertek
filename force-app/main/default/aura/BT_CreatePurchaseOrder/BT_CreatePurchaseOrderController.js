({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
	    //alert("recordId --> "+recordId);
	    var action = component.get("c.getAllProducts");
	    action.setParams({
	        recordId : recordId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        //alert('state --> '+state);
	        if(state === "SUCCESS"){
	           var result = response.getReturnValue();
	           //alert('result --> '+JSON.stringify(result));
	           if(result != null){
	              //alert('Hiiiiiiii');
	              result = JSON.parse(JSON.stringify(result)); 
	              //alert('Parsed result -->'+result);
	              component.set("v.objInfo",result);
	              //alert('Obj Info -->'+component.get("v.objInfo"));
	           }
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	selectAll : function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
		var products = component.get("v.objInfo");
        var getAllId = component.find("checkContractor"); 
        if(! Array.isArray(getAllId)){
           if(selectedHeaderCheck == true){ 
              component.find("checkContractor").set("v.value", true); 
              //component.set("v.selectedCount", 1);
           }else{
               component.find("checkContractor").set("v.value", false);
               //component.set("v.selectedCount", 0);
           }
        }
        else{ 
            if (selectedHeaderCheck == true) {
                for (var i = 0; i < getAllId.length; i++) {
					component.find("checkContractor")[i].set("v.value", true); 
					var checkbox = component.find("checkContractor")[i].get("v.text");  
            	        products[i].ProductCheck = true;
            	    
                }
            } 
            else{
                for (var i = 0; i < getAllId.length; i++) {
    				component.find("checkContractor")[i].set("v.value", false); 
    				var checkbox = component.find("checkContractor")[i].get("v.text"); 
    				var products = component.get("v.objInfo");
    	                products[i].ProductCheck = false;
               }
           } 
        } 
     
     
    },
    
    handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();  
        var products = component.get("v.objInfo");
        var listproducts = [];
	    for(var i=0 ; i < products.length;i++){
	        if(products[i].product.Id == checkbox.get("v.text") && products[i].ProductCheck == false){
	            products[i].ProductCheck = false;
	            products[i].POQuantity = 0;
	        }
	        else if(products[i].product.Id == checkbox.get("v.text") && products[i].ProductCheck == true){
	             products[i].ProductCheck = true;
	             products[i].POQuantity = null;
	        }
	        listproducts.push(products[i]);
	    }
	     component.set("v.objInfo",listproducts);
    },
    
    closeModel: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({ 
            "recordId": recordId, 
            "slideDevName": "detail"
        }); 
        navEvt.fire();
    },
    
    saveModel: function(component, event, helper) {
        helper.createPurchaseOrder(component, event, helper);
       
    },
})