({
	nextToSearchVendor : function(component, event, helper) {
		 $A.createComponent(
            "c:BT_Search_And_Invite_Vendor",
            {
                
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
        );
	},
    nextToRFQ : function(component, event, helper) {
		 $A.createComponent(
            "c:BT_New_RFQ",
            {
                
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
        );
	}
})