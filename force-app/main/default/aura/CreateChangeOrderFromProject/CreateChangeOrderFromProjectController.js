({
    doInit:function(component, event, helper) {
        console.log('init');
        helper.tabName(component, event, helper);
	},
    showMessage: function(component, event, helper) {
        console.log('Message from Lightning Component');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '#/sObject/a081K00000yjO3dQAE/view',
            focus: true
        });
	},
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
     },
    
     closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
     },
    
     submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.isModalOpen", false);
     },

	
})