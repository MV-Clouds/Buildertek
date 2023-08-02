({
    afterLoads: function(component, event, helper){
        component.set("v.showSpinner", false);
    },
    init : function(component, event, helper){
    	  
        var getPB = component.get("c.getPriceBookId");
        getPB.setParams({
            "recordId":component.get("v.recordId")
        });
        
        getPB.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
            	if(response.getReturnValue()){
            		var pricebook2Id = response.getReturnValue();
            		component.set("v.pricebook2Id",pricebook2Id);
            	} 
            }else{
                console.log("Failed with state: "+ state);
            }
        });
        
        $A.enqueueAction(getPB);
    },
    createProd : function(component, event, helper) {
		var selectedProducts = event.getParam("_selected_products");
        component.set("v._items", selectedProducts);
        helper.toggleProductSelection(component);
	},
    handleProducts : function(component, event, helper){
    	var command = event.getParam("command");
        if(command === "save"){
            var Items = component.get("v._items");
            var recordId = component.get("v.recordId");
            console.log(Items);
            component.get("v.saveCallback")(Items);
        }else if (command === "cancel"){
            component.set("v._items",[]);
            component.set("v.showProductSelection", true);
        }
    },
    
    /*parentComponentEvent : function(component, event, helper){
        $A.enqueueAction(component.get('c.init'));
    }*/
      
})