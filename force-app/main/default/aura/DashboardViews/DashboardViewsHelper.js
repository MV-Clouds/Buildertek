({
	
    gettabname : function(component, event, helper) {
        var workspaceAPI = component.find("workspaceDashboardview");
        workspaceAPI.openTab({
            url : '/lightning/n/buildertek__Dashboard_View',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response ,
                label: "Resource Center"
            });
            workspaceAPI.setTabIcon({
                tabId: response,
                icon: 'custom:custom70',
            })
        })
     },
	
})