({
    doInit : function(component, event, helper) {

        console.log('RelatedTasksVendorSiteController > doInit');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('RelatedTasksVendorSiteController > doInit > userId: ' + userId);
        helper.getAccountId(component, userId);      
    }

    
})
