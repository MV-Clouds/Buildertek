({
	doInit : function(component, event, helper) {
	    $A.createComponent(
             "c:VG_NewsFeedHeader",
            {},
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var firstPanel = component.get('v.Row3Col2');
                    firstPanel.unshift(newButton);
                    //firstPanel.push(newButton);
                    component.set("v.Row3Col2", firstPanel);
                }

            }
        );
	}
})