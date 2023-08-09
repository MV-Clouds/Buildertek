({
	doInit : function(component, event, helper) {
        component.set("v.isOpen", true);
	    
	},
	
	closeModel : function(component, event, helper) {
	    component.set("v.isOpen", false);
	    var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        var recordId = component.get("v.RecordId");
        window.open(baseURL+'.lightning.force.com/lightning/r/buildertek__Schedule__c/'+escape(recordId)+'/view', '_self');
	},
	DeleteRecord : function(component, event, helper) {
	    var action = component.get("c.deleteScheduleRecord");
	    
	    action.setParams({
	        recordId : component.get("v.RecordId")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        var recordId = component.get("v.RecordId");
	        var projectId = component.get("v.ProjectId");
	        //alert('recordId ---------> '+recordId);
	        if(state === "SUCCESS"){
	            /*var url = location.href;
	            //var baseURL = url.substring(0, url.indexOf('/', 14));
	            var baseURL = url.substring(0, url.indexOf('--', 0));
	            window.open(baseURL+'.lightning.force.com/lightning/r/'+recordId+'/related/buildertek__Schedules__r/view', '_self');*/
                //window.open(baseURL+'/one/one.app?source=aloha#/sObject/buildertek__Schedule__c/home', '_self');
                //window.open('/apex/RedirectToPrevious?recordId='+escape(recordId)+'&projectId='+escape(projectId), '_self');
                window.open('/lightning/r/'+projectId+'/related/buildertek__Schedules__r/view', '_self');
	        }
	    });
	    $A.enqueueAction(action);
	}
	
})