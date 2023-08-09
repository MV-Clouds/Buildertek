({
    cancel: function(component, event, helper){
       
    },
    save: function(component, event, helper){
        if(helper.validateRequiredField(component)){
            var Items = component.get("v._items");
            for(var index in Items){
            	var Item = Items[index];
                delete Item["errors"];
                Item.buildertek__Group__c = component.get("v.newBi").buildertek__Group__c;
            }
            component.get("v.saveCallback")(Items);
            $A.enqueueAction(component.get("v.cancelCallback"));
        }
    },
    handleErrors: function(component, event, helper){
        var response =event.getParam('arguments')._server_response;
        helper.handleErrorOfItemsCreation(response, component);
    }
})