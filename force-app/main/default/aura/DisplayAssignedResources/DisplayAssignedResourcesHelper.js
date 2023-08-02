({
    getDataFromFieldSet : function(component, event, helper) {
        var objectName = "AssignedResource";
        var fieldSetName = "Assigned_Resources";

        var FiledSetMember = component.get('c.getFieldSetMember');
        FiledSetMember.setParams({
            "objectName" : objectName,
            "fieldSetName" : fieldSetName
        });
        FiledSetMember.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var fieldSetMember = response.getReturnValue();
                component.set("v.wraaperValue",response.getReturnValue());
            }
        });
        $A.enqueueAction(FiledSetMember);
    },
    getAssignedResources : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        
        var assignedResource = component.get('c.getAssignedResources');
        assignedResource.setParams({
            "worOrderId" : recordId
        });
        assignedResource.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var numberOfRows = component.get("v.rowsDisplayed");
                var filteredRecord = component.get("v.filteredRecord");
                component.set("v.sObjectData",response.getReturnValue());
                console.log(response.getReturnValue());
                if(response.getReturnValue().length == 0){
                    component.set("v.emptyList",true);
                }
                else{
                    component.set("v.emptyList",false);
                    if(response.getReturnValue().length > numberOfRows){
                        component.set("v.displayAll",false); 
                        for(var count=0;count<numberOfRows;count++){
                            filteredRecord.push(response.getReturnValue()[count]);
                        }
                        component.set("v.filteredRecord",filteredRecord); 
                    }
                    else{
                        for(var count=0;count<response.getReturnValue().length;count++){
                            filteredRecord.push(response.getReturnValue()[count]);
                        }
                        component.set("v.filteredRecord",filteredRecord);                         component.set("v.displayAll",true); 
                    }
                }
                component.set("v.loadComponent",true); 
            }
        });
        $A.enqueueAction(assignedResource);
    }
})