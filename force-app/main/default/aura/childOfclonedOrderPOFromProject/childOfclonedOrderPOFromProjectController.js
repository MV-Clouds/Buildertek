({
	doInit : function(component, event, helper) {
        var a = component.get("v.apiName")
        var c = a.name;
        var b = component.get("v.Record");
      	component.set("v.data",b[c])
      
		
	}
})