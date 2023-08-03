({
    doInit: function(component, event) {
        
        //projName
        var action = component.get("c.getProject");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                if(response.getReturnValue()){
                    var scheduleData = response.getReturnValue();
                    if(scheduleData.buildertek__Description__c.length > 100){
                        scheduleData.buildertek__Description__c =  scheduleData.buildertek__Description__c.slice(0,100) + "...";
                      }
                    component.set("v.projName", scheduleData);
                }
                
            }
        })
        $A.enqueueAction(action);
        
        //ObjNameOnInit
        var workspaceAPI = component.find("workspace");
         workspaceAPI.getFocusedTabInfo().then(function(response) {
             var focusedTab = JSON.parse(JSON.stringify(response));
             var recId = focusedTab['recordId']
             console.log(component.get("v.sobjecttype"))
             var action1 = component.get("c.getObjectTypeName");
             action1.setParams({
                 recorId: recId,
             });
             action1.setCallback(this, function (response) {
                 if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                     if('buildertek__Schedule__c' == response.getReturnValue() && component.get("v.sobjecttype") == 'buildertek__Schedule__c'){
                         component.set("v.isSchedulePage",true)
                     }
                 }
             })
             if(focusedTab.url.indexOf('buildertek__Schedule__c') > -1 && component.get("v.sobjecttype") == 'buildertek__Schedule__c' && recId) { //focusedTab.title.indexOf('SC-')
                 $A.enqueueAction(action1);
             }
            /*if(focusedTab.title.indexOf('SC-') == 0 && {
                
            }*/
       })
        .catch(function(error) {
            console.log(error);
             component.set("v.isSchedulePage",true)
        });
    },
    handleFilterChange: function(component, event) {
        var filters = event.getParam('message');
        component.set('v.message', filters);
        
        window.setTimeout(
            $A.getCallback(function() {
                var appEvent = $A.get("e.c:refresheventForGantt");
                appEvent.setParams({
                    "refreshmessageevent" : "Refresh Component from gantt"
                });
                appEvent.fire();
            }), 200
        );
        
    },
    handleRefreshFromTable :  function(component, event) {
        if(event.getParam('refreshmessage') == 'Refresh Component from table'){
            if(component.find('ganttchildfromaura')){
                component.find('ganttchildfromaura').getFiredFromAura();
            }
            
           // $A.get('e.force:refreshView').fire()
        }
    },
    
    /*onTabClosed  :  function(component, event) {
        component.set("v.tabClosedAtt",true);
        
       // component.destroy()
    },*/
     onTabFocused : function(component, event, helper) {
        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");
         workspaceAPI.getFocusedTabInfo().then(function(response) {
             var focusedTab = JSON.parse(JSON.stringify(response));
             var recId = focusedTab['recordId']
             console.log(component.get("v.sobjecttype"))
             var action = component.get("c.getObjectTypeName");
             action.setParams({
                 recorId: recId,
             });
             action.setCallback(this, function (response) {
                 if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                     if('buildertek__Schedule__c' == response.getReturnValue() && component.get("v.sobjecttype") == 'buildertek__Schedule__c'){
                         component.set("v.isSchedulePage",true)
                     }
                 }
             })
             if(((focusedTab && focusedTab.url) ? focusedTab.url.indexOf('buildertek__Schedule__c') > -1 : location.href.indexOf('buildertek__Schedule__c') > -1) && component.get("v.sobjecttype") == 'buildertek__Schedule__c' && recId) {
                 $A.enqueueAction(action);
             }
            /*if(focusedTab.title.indexOf('SC-') == 0 && {
                
            }*/
       })
        .catch(function(error) {
            console.log(error);
        });
    }
    
})