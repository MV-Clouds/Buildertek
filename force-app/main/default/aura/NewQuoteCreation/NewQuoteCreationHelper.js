({
    onLoad : function(component, event, helper) {
        //Renaming opportunityId with entityId to re-use the same component for case and opportunity.
        //var opportunityId =component.get('v.recordId');
        var entityId =component.get('v.recordId');
        var pageLayout = component.get('v.pageLayout');
        var recordTypeName=component.get('v.recordTypeName');
        var sobjectName =component.get('v.sobjectName');
        if(entityId!=null && entityId!=undefined 
           && recordTypeName!=null && recordTypeName!= undefined
          && pageLayout!=null && pageLayout!= undefined
          && sobjectName!=null && sobjectName!= undefined){
            var action = component.get('c.getPageLayoutStructure');
            action.setParams({
                entityId:entityId,
                recordTypeName:recordTypeName,
                pageLayoutName : pageLayout,
                sobjectName : sobjectName,
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    
                    var custs = [];
                    var recordTypeId = response.getReturnValue();
                    for ( var key in recordTypeId ) {
                        custs.push({value:recordTypeId[key], key:key});
                    }
                    component.set("v.mapValues", custs);
                } else if(state === 'ERROR'){
                }
            });
            
            $A.enqueueAction(action); 
        }
    },
    handleSubmit: function(component, event, helper) {
        
        event.preventDefault();        
        var message = "These required fields must be completed:";
        var emptyFields="";
        
        var requiredFieldMap = new Map()
        var eventfields = event.getParam('fields');
        requiredFieldMap = component.get("v.mapValues");
        for (const v of requiredFieldMap.values()) {
            var fields = v.value;
            for(var i=0;i<fields.length;i++){
                if(fields[i].required){
                    var requiredfield = eventfields[fields[i].fieldName];
                    if(!requiredfield){
                        emptyFields += " "+ fields[i].fieldLabel +",";
                    }
                }
            }
            
        }
        if(emptyFields!=""){
            helper.showError(component,'Error','error',message+emptyFields.slice(0, -1));
        }
        else{
            component.find("editForm").submit();
        }
    },
    showError: function(component ,title, severity, errorMessage) {
        component.set("v.disableButton",false);
        component.set("v.title",title);
        component.set("v.severity",severity);
        component.set("v.errorMessage",errorMessage);
        component.set("v.showMessage",true);
    },
    
    navigateToDetailPage : function(component, event, helper) {
        var opportuityId = component.get("v.recordId",true);
        sforce.one.navigateToSObject(opportuityId,"RELATED"); 
    },
    redirectToQLIEditor : function(component, event, helper) {
        var record = event.getParam("response");
        var currentPageURL = component.get("v.currentPageURL");
        var splitURL = currentPageURL.split('/');
        var hostName = splitURL[2].split('--');
        if(hostName != undefined){
            var qliEditorURL = "https://"+hostName[0]+"--sbqq"+hostName[1].substr(1);
            qliEditorURL +="/apex/sb?newid="+record.id;
            window.open(qliEditorURL,"_self");
        }
    }
})