/* Lightning Component Controller.
 * Copyright 2018-2019, Riskonnect Inc.
 * All rights reserved
 *
 * Created by - Sagar Thoriya
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global $ sforce*/
/* eslint-disable no-console, no-alert */

({
         
    handleClick: function(component, event, helper) {
        var mainDiv = component.find('main-div');
        $A.util.addClass(mainDiv, 'slds-is-open');
    },
    
    handleSelection: function(component, event, helper) {
        var item = event.currentTarget;
        if (item && item.dataset) {
            var value = item.dataset.value;
            var selected = item.dataset.selected;
            console.log('Values::',value);
            console.log('Selected::',selected);
            var additionalCost = parseInt(component.get('v.additionalCost'));
            var options = component.get("v.options");
            var totalCost = 0;
            console.log('additionalCost::',additionalCost);
            console.log('Options::',options);
            
            options.forEach(function(element) {
                if (element.selected) {
                    if(element.buildertek__Additional_Cost__c!=undefined){
                        totalCost += element.buildertek__Additional_Cost__c;
                    }
                }
            });
            additionalCost = additionalCost - totalCost;
            
            options.forEach(function(element) {
                if (element.value == value) {
                    element.selected = selected == "true" ? false : true; 
                    //element.selected = selected == true ? additionalCost += element.buildertek__Additional_Cost__c : '';
                }
            });
            
            options.forEach(function(element) { 
                element.selected == true ? additionalCost += element.buildertek__Additional_Cost__c : '';
            });
            
            component.set("v.additionalCost", additionalCost.toString());
            console.log('Additional Cost::',component.get('v.additionalCost'));
            component.set("v.options", options);
            var values = helper.getSelectedValues(component);
            component.set("v.values",values);
            var labels = helper.getSelectedLabels(component);
            
            console.log(labels);
            helper.setInfoText(component, labels);
        }
    },
    
    handleMouseLeave: function(component, event, helper) {
        component.set("v.dropdownOver", false);
        var mainDiv = component.find('main-div');
        $A.util.removeClass(mainDiv, 'slds-is-open');
    },
    
    handleMouseEnter: function(component, event, helper) {
        component.set("v.dropdownOver", true);
    },
    
    handleMouseOutButton: function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {
                    //if dropdown over, user has hovered over the dropdown, so don't close.
                    if (component.get("v.dropdownOver")) {
                        return;
                    }
                    var mainDiv = component.find('main-div');
                    $A.util.removeClass(mainDiv, 'slds-is-open');
                }
            }), 200
        );
    }
    
})