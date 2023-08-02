({
    helperMethod : function() {
        
    },
    /* Get the default query string for the section tree. */
    defaultTreeFilterCondition : function(component) {
        console.log('Selection Record Id ::',component.get("v.recordId"));
        var action = component.get("c.getTreeQueryParamters");
        var adId = component.get("v.recordId");
        action.setParams({selectionSheetId : adId});
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.defaultTreeFilterCondition",response.getReturnValue());
                console.log("defaultTreeFilterCondition"+JSON.parse(JSON.stringify(response.getReturnValue())));
                /*var selectionrec = JSON.parse(JSON.stringify(response.getReturnValue()));
                if(selectionrec != undefined && selectionrec.buildertek__Section__c != undefined){
                    for(var i in selectionrec.buildertek__Section__c){
                        if(selectionrec.buildertek__Section__c[i].fieldValue != undefined ){
                            console.log('selectionID::::'+selectionrec.buildertek__Section__c[i].fieldValue);
                        }
                    }
                }*/
                
                component.set("v.isJsLoad", true);
            }
        });
        $A.enqueueAction(action);
        var act = component.get("c.getProjectName");
        act.setParams({selectionSheetId : adId});
        
        act.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('Projectname:::'+response.getReturnValue());
                component.set("v.projectName", response.getReturnValue());
            }
        });
        $A.enqueueAction(act);
    }
})