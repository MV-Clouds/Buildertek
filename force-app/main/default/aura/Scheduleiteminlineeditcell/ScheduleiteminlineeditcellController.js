({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
     inlineEdit : function(component, event, helper){
       var recordId = event.currentTarget.dataset.id;
        var fieldName = event.currentTarget.dataset.label;
         component.set("v.isEditMode", true);
     },
    onblur : function(component, event, helper){
        component.set("v.isEditMode", false);
        
    },
})