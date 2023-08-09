({
    showDropDown : function(component, event, helper) {
        var x = document.getElementById("myTopnav");
        // alert(x.className);
        if (x.className.includes("responsive")) {
            x.className = x.className.replace("responsive","");
        }
        else if (x.className.includes("topnav")) {
            //alert('in responsive');
            x.className += " responsive";
        } 
    },
    doInit : function(component, event, helper) {              
        helper.getPrefix(component);
        helper.getDepartmentNavigations(component);
        
        var action = component.get("c.getUserInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var a = response.getReturnValue();
                console.log('a'+a);               
                component.set("v.profileName",a);
            }
        });
        $A.enqueueAction(action); 
        
    },
    navigateToUserProfile: function(component)
    {	
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": userId
        });
        navEvt.fire();              
    },
    navigateToHRPage: function(component)
    {	
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/human-resource"
        });
        navEvt.fire();          
    },
    
    navigateToRespectivePage: function(component, event) {
        console.log('current val'+event.currentTarget.dataset.deptval);
        var url = '';
        if (event.currentTarget.dataset.deptval && component.get('v.AllDepartmentWithNav')) {
            url = component.get('v.AllDepartmentWithNav')[event.currentTarget.dataset.deptval];
        }
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": url
        });
        navEvt.fire();
    }
    
})