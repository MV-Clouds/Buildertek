({
    validateRequiredField : function(component){
        var Items = component.get("v._items");
        var isValid = true;
        for(var index in Items){
            var Item = Items[index];
            console.log(Item);
            Item.errors["quantity"] = "";
            Item.errors["salesPrice"] = "";
            Item.errors["serviceDate"] = "";
            Item.errors["description"] = "";
            Item.errors["Discount"] = "";
            
            if(!Item.quantity){
                isValid = false;
                Item.errors["quantity"] = "requiredErrorField";
            }
            if(!Item.salesPrice){
                isValid = false;
                Item.errors["salesPrice"] = "requiredErrorField";
            }
            if((Item.errors["salesPrice"] 
               && Item.errors["salesPrice"].length > 0) 
               || (Item.errors["quantity"] 
               	&& Item.errors["quantity"].length > 0)){
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
    handleErrorOfOppItemsCreation : function(response, component){
    	var results = response.getReturnValue().errorResults;
        var Items = component.get("v._items");
        for(var key in results){
        	var result = results[key];
            var fields = result.fields;
            fields = fields.replace('(','');
            fields = fields.replace(')','');
			var Item = Items[result.index];
            Item.errors["quantity"] = "";
            Item.errors["salesPrice"] = "";
            Item.errors["serviceDate"] = "";
            Item.errors["description"] = "";
            Item.errors["Discount"] = "";
            
            if(fields.indexOf('Quantity') !== -1){
            	Item.errors.quantity = 'requiredErrorField';
            }
            if(fields.indexOf('UnitPrice') !== -1){
                Item.errors.salesPrice = 'requiredErrorField';
            }
            if(fields.indexOf('ServiceDate') !== -1){
                Item.errors.serviceDate = 'requiredErrorField';
            }
            if(fields.indexOf('Description') !== -1){
                Item.errors.description = 'requiredErrorField';
            }
            if(fields.indexOf('Discount') !== -1){
                Item.errors.Discount = 'requiredErrorField';
            }
            Item.errors.message = result.message;
	    }
        this.renderErrors(component, Items);
	},
	fireHandleOppProductsEvent : function(component, command) {
        var handleOppProducts = component.getEvent("handleProducts"); 
        handleOppProducts.setParams({
            "command": command
        });
        handleOppProducts.fire();
	}
})