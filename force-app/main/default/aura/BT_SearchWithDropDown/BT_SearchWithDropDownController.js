({
    searchAll : function (component, event, helper) {
       event.currentTarget.setAttribute('autocomplete', 'off');
        component.set("v.openDropDown", false);
        window.setTimeout(
            $A.getCallback(function() {
                var showButton = component.get("v.showButton");
                if(showButton == true){
                    component.set("v.showButton", false);	    
                }
                //$("#listbox-id-11").show();
                component.set("v.openDropDown", true);
                component.set("v.showIcon", true);
                document.getElementsByClassName('wrapper')[0].addEventListener("click",function(){
                    component.set("v.openDropDown", false);
                })
                event.stopPropagation()
                //document.getElementById(inputId).focus();
            }), 1
        );
        
    },
    
    
    
    searchHandler : function (component, event, helper) {
        helper.search(component, event, helper);
    },

    optionClickHandler : function (component, event, helper) {
        const selectedValue = event.target.closest('li').dataset.value;
        const selectedName = event.target.closest('li').dataset.name;
        component.set("v.inputValue", selectedName);
        component.set("v.openDropDown", false);
        component.set("v.showIcon", false);
        component.set("v.selectedOption", selectedValue);
        var compEvent = component.getEvent("selectedSearchValue");
        compEvent.setParams({"seletcedOption" :  selectedValue+'_'+selectedName+'_'+event.target.closest('ul').id});
        compEvent.fire();
    },
    
    clearValue : function (component, event, helper) {
        var inputId = component.get("v.myInputId");
        document.getElementById(inputId).value = '';
        document.getElementById(inputId).focus();
        component.set("v.showIcon", false);
        component.set("v.inputValue", '');
        var compEvent = component.getEvent("selectedSearchValue");
        compEvent.setParams({"seletcedOption" :  ''+'_'+''+'_'+inputId});
        compEvent.fire();
        window.setTimeout(
            $A.getCallback(function() {
            	component.set("v.openDropDown", true);
                helper.search(component, event, helper);
                component.set("v.showIcon", true);
                //document.getElementById(inputId).focus();
            }), 100
        );
    },
    
    closeMenu : function(component, event, helper){
        var elementId = event.target.id;
        //alert('elementId -------> '+elementId);
        //alert('input value -------> '+component.get("v.inputValue"));
        var inputId = component.get("v.myInputId");
        window.setTimeout(
            $A.getCallback(function() {
                if(inputId == elementId){
                    component.set("v.openDropDown", false);
                    component.set("v.showIcon", false);
                }
            }), 300
        );
    },
    onclickDrop : function(component, event, helper){
        component.set("v.openDropDown", false);
    }
    
})