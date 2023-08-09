({
	search : function(component, event, helper) {
        var input, filter, ul, li, a, i, txtValue;
        var inputId = component.get("v.myInputId");
        var uLId = component.get("v.myULId");
        input = document.getElementById(inputId);
        filter = input.value.toUpperCase();
        ul = document.getElementById(uLId);
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