({
    validateRequiredField : function(component){
        var Items = component.get("v._items");
        var isValid = true;
        for(var index in Items){
            var Item = Items[index];
            Item.errors["buildertek__quantity__c"] = "";
            Item.errors["buildertek__unit_price__c"] = "";
            Item.errors["buildertek__product__c"] = "";         
            if(!Item.buildertek__quantity__c){
                isValid = false;
                Item.errors["buildertek__quantity__c"] = "requiredErrorField";
            }
            if(!Item.buildertek__unit_price__c){
                isValid = false;
                Item.errors["buildertek__unit_price__c"] = "requiredErrorField";
            }
            if((Item.errors["buildertek__unit_price__c"] 
               && Item.errors["buildertek__unit_price__c"].length > 0) 
               || (Item.errors["buildertek__quantity__c"] 
               	&& Item.errors["buildertek__quantity__c"].length > 0)){
                Item.errors.message = "This field is required";
            }else{
                Item.errors.message = "";
            }
        }
        if(!isValid){
      		this.renderErrors(component, Items);
        }
       	return isValid;
    },
    renderErrors: function(component, Items){
            var errorMessage = "There were errors whilst saving your records";
            component.set("v._error", errorMessage);
            component.set("v._items", Items);  
    },
    handleErrorOfItemsCreation : function(response, component){
    	var results = response.getReturnValue().errorResults;
        var opportunityItems = component.get("v._items");
        for(var key in results){
        	var result = results[key];
            var fields = result.fields;
            fields = fields.replace('(','');
            fields = fields.replace(')','');
			var Item = Items[result.index];
            Item.errors["buildertek__unit_price__c"] = "";
            Item.errors["buildertek__quantity__c"] = "";
            if(fields.indexOf('buildertek__quantity__c') !== -1){
            	Item.errors.buildertek__quantity__c = 'requiredErrorField';
            }
            if(fields.indexOf('buildertek__unit_price__c') !== -1){
                Item.errors.buildertek__unit_price__c = 'requiredErrorField';
            }
            
            Item.errors.message = result.message;
	    }
        this.renderErrors(component, opportunityItems);
	},
	saveItems : function(component) {
        
	}
})