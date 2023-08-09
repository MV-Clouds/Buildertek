({
	doInit : function(component, event, helper) {
        component.set("v.Spinner",true);
        window.setTimeout(
            function() {
                component.set("v.Spinner", false); 
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('--', 0));
                var recordId = component.get("v.recordId");
                window.open(baseURL+'.lightning.force.com/lightning/r/buildertek__Schedule__c/'+escape(recordId)+'/view', '_self');
            }, 7000
        );
    }
})