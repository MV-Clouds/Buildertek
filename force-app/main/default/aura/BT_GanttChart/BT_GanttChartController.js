({
	doInit : function(component, event, helper) {
	    var url = location.href;
        var recordId = component.get("v.recordId");
        var baseURL = url.substring(0, url.indexOf('/', 14));
        console.log('Base URL::',baseURL);
        component.set("v.BaseURL",baseURL);
	}
})