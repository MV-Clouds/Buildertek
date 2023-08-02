({
	doInit : function(component, event, helper) {
        /*var myPageRef = component.get("v.pageReference");*/
        var recordId = component.get("v.recordId");
        console.log(recordId)
		console.log('created');
        console.log(component.get("v.recordId"));
        /*if(recordId){
            var appEvent = $A.get("e.c:GanttAndTableEvent");
            appEvent.setParams({
                "message" : recordId
            });
            appEvent.fire();
        }*/
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        })
        .catch(function(error) {
            console.log(error);
        });
        
           /*var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Mass Update"
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "custom:custom70"
                });
            })
            .catch(function (error) {
                console.log('sub tab error::', error);
            });*/

	}
})