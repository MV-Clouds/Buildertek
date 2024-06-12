({
    helperMethod: function () {

    },

    fetchChecklists : function(component) {
        // Mock data for demonstration
        let checklists = [
            {Name: 'test contact Checklist', ObjectName: 'Contact', CreatedDate: '04/07/2024, 03:59 AM'},
            {Name: 'Account New Checklist', ObjectName: 'Account', CreatedDate: '05/07/2024, 10:59 AM'},
            {Name: 'Test', ObjectName: 'Account', CreatedDate: '06/07/2024, 03:59 AM'},
            {Name: 'Account Checklist', ObjectName: 'Account', CreatedDate: '09/07/2024, 07:59 PM'},
            {Name: 'Contractor Onboarding', ObjectName: 'buildertek_Project__c', CreatedDate: '10/07/2024, 03:59 AM'},
            {Name: 'Quote checklist', ObjectName: 'buildertek_Quote__c', CreatedDate: '11/07/2024, 03:59 AM'},
            {Name: 'Onboarding Checklist', ObjectName: 'buildertek_Project__c', CreatedDate: '12/07/2024, 03:59 AM'}
        ];
        component.set("v.checklists", checklists);
    },
    
    refreshList: function (component, event) {

        var availableMenus = document.getElementById('available').childNodes;
        var selectedIdsMenus = document.getElementById('Selected').childNodes;
        var selectedIds = [];
        for (var i = 0; i < selectedIdsMenus.length; i++) {
            selectedIds[i] = selectedIdsMenus[i].getAttribute('id');
        }

        component.set("v.selectedIds", selectedIds);

    },
    showToast: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Success',
            message: 'The record has been updated successfully',
            duration: ' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    }

})