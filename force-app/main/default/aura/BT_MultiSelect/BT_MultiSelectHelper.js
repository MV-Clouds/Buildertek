/* Lightning Component helper.
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
    
    // Set the into text message based on selected items
    setInfoText: function(component, values) {
        if (values.length == 0) {
            component.set("v.infoText", "");
        } else if (values.length == 1) {
            component.set("v.infoText", values[0]);
        } else if (values.length > 1) {
            component.set("v.infoText", values.length + " options selected");
        }
    },
    
    // Get selected item values
    getSelectedValues: function(component){
        var options = component.get("v.options");
        var values = [];
        options.forEach(function(element) {
            if (element.selected) {
                values.push(element.value);
            }
        });
        return values;
    },
    
    // Get selected items labels
    getSelectedLabels: function(component){
        var options = component.get("v.options");
        var labels = [];
        options.forEach(function(element) {
            if (element.selected) {
                labels.push(element.label);
            }
        });
        return labels;
    }
})