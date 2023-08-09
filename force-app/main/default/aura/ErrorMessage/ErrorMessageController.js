({
	doInt : function(component, event, helper) {
        
		component.set("v.errMsg", event.getParam("errMsg"));
        component.set("v.iserrMsg", event.getParam("isMsg"));
        setTimeout(function(){
             component.set("v.iserrMsg",false);
        }, 10000);
	},
    close : function(component, event, helper) {
         component.set("v.iserrMsg",false);
    }
})