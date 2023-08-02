({
    doInit : function(component, event, helper) {
        console.log('doInit Call');
        
        var action1 = component.get("c.insertProjects");
        action1.setParams({
            projectId: component.get("v.recordId")
        });
        
        action1.setCallback(this, function (response) {
            var fieldname = response.getReturnValue();
            //alert('&&'+ JSON.stringify(fieldname));
            if(fieldname.buildertek__Stage__c == 'Completed' && fieldname.buildertek__Actual_Completion_Date__c != '' && fieldname.buildertek__Project_Completion__c == 100){
                //alert("1");
                //$A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                component.find('notifLib').showNotice({
                    "variant": "Error",
                    "header": "Error",
                    "message": "Project is  already completed.",
                    
                });
            }  else{
                //helper.getprojectRecord(component);
                helper.getprojectRecord(component, event, helper);
            }
            
        });
        $A.enqueueAction(action1);
        
        
        
    }
})