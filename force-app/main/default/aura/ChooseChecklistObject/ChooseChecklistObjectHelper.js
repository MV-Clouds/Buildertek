({
	helperMethod : function(component, event, helper) {
        component.set("v.Spinner",true);
		 var action =component.get("c.getChecklistControllerRecords");
          action.setCallback(this, function(a){
            if (a.getState() === "SUCCESS") {
                component.set("v.Spinner",false);
                component.set('v.manageView',a.getReturnValue());
                //(JSON.stringify(component.get("v.manageView")));
            }
        });
        $A.enqueueAction(action);
	},
    search : function(component, event, helper) {
        var input, filter, ul, li, a, i, txtValue;
        input = document.getElementById("myInput");
        filter = input.value.toUpperCase();
        ul = document.getElementById("myUL");
        li = ul.getElementsByTagName("li");
        for (i = 0; i < li.length; i++) {
            a = li[i].getElementsByTagName("span")[2];
            txtValue = a.textContent || a.innerText;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                li[i].style.display = "";
            } else {
                li[i].style.display = "none";
            }
        }
    }
})