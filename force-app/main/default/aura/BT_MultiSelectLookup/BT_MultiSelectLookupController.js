({
    doInit: function(component, event, helper) {
        // console.log(component.get('v.recordId'));
        // console.log('multi select obj' + component.get('v.lstSelectedRecords'));
        // console.log('multi select string' + JSON.stringify(component.get('v.lstSelectedRecords')));
        if (component.get('v.lstSelectedRecords').length) {
            //alert(JSON.stringify(component.get('v.lstSelectedRecords')));
            //console.log(JSON.stringify(component.get('v.lstSelectedRecords')));
            if (component.get('v.lstSelectedRecords').toString().indexOf('[object Object]') > -1) {
                // console.log('object object true');
                component.set('v.lstSelectedRecords', component.get('v.lstSelectedRecords'));
            } else {
                // console.log('object object false');
                component.set('v.lstSelectedRecords', JSON.parse(component.get('v.lstSelectedRecords')));

            }

            //console.log(JSON.stringify(component.get('v.lstSelectedRecords')));
        } else {

        }

        //alert(component.get('v.lstSelectedRecords'));

    },
    onblur: function(component, event, helper) {
        helper.onblur(component, event, helper);
    },
    onmouseLeave: function(component, event, helper) {
        // on mouse leave clear the listOfSeachRecords & hide the search result component 
        window.setTimeout(
            $A.getCallback(function() {
                helper.onblur(component, event, helper);
            }), 3000
        );
    },
    onfocus: function(component, event, helper) {
        // show the spinner,show child search result component and call helper function
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        component.set("v.listOfSearchRecords", null);
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC 
        var getInputkeyWord = '';
        helper.searchHelper(component, event, getInputkeyWord);
    },

    keyPressController: function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        console.log('getInputkeyWord' + getInputkeyWord);
        if (getInputkeyWord.length > 0) {
            //alert(getInputkeyWord);
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        } else {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // function for clear the Record Selaction 
    clear: function(component, event, heplper) {
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords");

        for (var i = 0; i < AllPillsList.length; i++) {
            if (AllPillsList[i].Id == selectedPillId) {
                AllPillsList.splice(i, 1);
                component.set("v.lstSelectedRecords", AllPillsList);
            }
        }
        component.set("v.SearchKeyWord", null);
        component.set("v.listOfSearchRecords", null);
    },

    // This function call when the end User Select any record from the result list.   
    handleComponentEvent: function(component, event, helper) {
        component.set("v.SearchKeyWord", null);
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems = component.get("v.lstSelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        if (listSelectedItems != null) {
            listSelectedItems.push(selectedAccountGetFromEvent);
        } else {
            listSelectedItems = [];
            listSelectedItems.push(selectedAccountGetFromEvent);
        }
        console.log('selectedAccountGetFromEvent' + selectedAccountGetFromEvent);
        console.log('listSelectedItems' + listSelectedItems);

        component.set("v.lstSelectedRecords", listSelectedItems);

        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    searchBar: function(component, event, helper) {
        var getInputkeyWord = '';
        helper.searchHelper(component, event, getInputkeyWord);
        window.setTimeout(
            $A.getCallback(function() {
                console.log(component.get("v.listOfSearchRecords"));
                var listSelectedItems = component.get("v.listOfSearchRecords");
                if (listSelectedItems != null) {
                    component.set("v.lstSelectedRecords", listSelectedItems);
                    var forclose = component.find("lookup-pill");
                    $A.util.addClass(forclose, 'slds-show');
                    $A.util.removeClass(forclose, 'slds-hide');
                    var forclose = component.find("searchRes");
                    $A.util.addClass(forclose, 'slds-is-close');
                    $A.util.removeClass(forclose, 'slds-is-open');
                }

            }), 2000
        );
    }
})