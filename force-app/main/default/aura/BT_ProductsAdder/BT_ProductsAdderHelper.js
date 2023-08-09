({
	
    toggleProductSelection : function(component){
        var oppItems = component.get("v._items");
        if(oppItems.length > 0){
        	component.set("v.showProductSelection", false);
        	component.set("v.showSpinner", false);
        }else{
            component.set("v.showProductSelection", true);
            component.set("v.showSpinner", false);
        }
    } 
   
})