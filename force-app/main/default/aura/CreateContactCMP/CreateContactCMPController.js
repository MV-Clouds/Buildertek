({
    doInit : function(component, event, helper) {
       // alert("doinit");
         /*var navService = component.find("navService");     
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
            
        };
        navService.navigate(pageReference);*/
        //var windowHash = window.location.hash;
    var createEvent = $A.get("e.force:createRecord");
        

    createEvent.setParams({
        "entityApiName": "Contact",
         "navigationLocation": "LOOKUP",
        "panelOnDestroyCallback": function(event) {
           // alert("Contact");
            $A.get("e.force:closeQuickAction").fire();
            window.close();
           // window.location.href = "https://salesforce.stackexchange.com/questions/198168/lightning-forcecreaterecord-capture-redirect-after-save";
        }
    });
    createEvent.fire();
    }
})