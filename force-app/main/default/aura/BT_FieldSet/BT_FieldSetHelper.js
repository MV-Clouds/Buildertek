({
	onInit : function(component, event, helper) {
        var mode = component.get('v.mode');
        if(mode=='Input')component.set('v.inputModeBool', true);
        var action = component.get("c.getFields");
        var objectApiName = component.get("v.objectApiName");
        var fieldsetName = component.get("v.fieldSetName");
        //alert('fsName '+fsName);
        action.setParams({
            objectName: objectApiName, 
            fieldSetName: fieldsetName
            
        });
        action.setCallback(this, function(a) {
            var fields = a.getReturnValue();
            component.set("v.fields", fields);
        });
        $A.enqueueAction(action);        
    }
})