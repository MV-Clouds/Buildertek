({
	doInt : function(component, event, helper) {
       
		component.set("v.SuccessMsg", event.getParam("SuccessMsg"));
        component.set("v.isSuccess", event.getParam("isSuccess"));
        setTimeout(function(){
           component.set("v.isSuccess",false);
        }, 10000);
	},
    close : function(component, event, helper) {
         component.set("v.isSuccess",false);
    }
})