({
    doInit: function (component, event, helper) {
        var options = [
            { value: 'all', label: 'All' },
            { value: 'tradeType', label: 'Trade Type' },
            { value: 'costCode', label: 'Cost Code' },
            { value: 'section', label: 'Section' }
        ];
        component.set("v.statusOptions", options);
    },

    handleOptionSelected: function (component, event, helper) {
        component.set("v.optionSelected", true);
        let selectedOptionValue = event.getParam("value");
        console.log('selectedOptionValue: ', selectedOptionValue);
        if (selectedOptionValue === 'all') {
            helper.createRFQ(component, helper);
        } else {
            helper.groupTradeTypeHelper(component, selectedOptionValue, helper);
        }
    }
})