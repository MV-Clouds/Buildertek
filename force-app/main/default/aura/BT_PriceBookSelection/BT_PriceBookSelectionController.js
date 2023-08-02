({
	cancel : function(component, event, helper) {
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
	},
    saveOpportunity : function(component, event, helper){
        helper.saveChangesInPricebook(component);
    },
    init:function(component, event, helper){
       //Call remote action to query result
        var getPriceBook = component.get("c.getPriceBook");
        var inputsel = component.find("InputSelectDynamic");
        getPriceBook.setCallback(this, function(response){
            var state = response.getState();
            var opts = [];
            opts.push({"class": "optionClass", label: '--- Select Pricebook ---', value:''});
            if(component.isValid() && state === "SUCCESS"){
	            for(var i=0;i< response.getReturnValue().length;i++){
		            opts.push({"class": "optionClass", label: response.getReturnValue()[i].Name, value: response.getReturnValue()[i].Id});
		        }
		        inputsel.set("v.options", opts);
            }else{
                console.log("Failed with state: "+ state);
            } 
        });
        
        $A.enqueueAction(getPriceBook);		
    }
})