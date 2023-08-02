({
	nextToRFQReview : function(component, event, helper) {
		$A.createComponent(
            "c:BT_RFQ_Review",
            {
                
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
        );
	},
    backToRFQItems : function(component, event, helper) {
		$A.createComponent(
            "c:BT_New_RFQ_Items",
            {
                
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
        );
	}
})