({
    doInit: function (component, event, helper) {
        // helper.createRFQ(component, helper);
        var options = [
            { value: 'all', label: 'All' },
            { value: 'tradeType', label: 'Trade Type' },
            { value: 'costCode', label: 'Cost Code' },
            { value: 'section', label: 'Section' }
        ];
        component.set("v.statusOptions", options);
    },

    handleOptionSelected: function (cmp, event) {
        cmp.set("v.optionSelected", true);
        let selectedOptionValue = event.getParam("value");
        switch (selectedOptionValue) {
            case 'all':
                //   calling apex for all
                break;
            case 'tradeType':
                // calling apex for tradeType
                break;
            case 'costCode':
                // calling apex for costCode
                break;
            case 'section':
            // calling apex for section
        }
    }
})