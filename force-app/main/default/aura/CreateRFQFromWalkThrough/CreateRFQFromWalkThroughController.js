({
    doInit : function(component, event, helper) {
        // helper.createRFQ(component, helper);
        var options = [
            { value: 'All', label: 'All', description: 'Create all RFQ lines' },
            { value: 'tradeType', label: 'Trade Type', description: 'Create RFQ lines with Trade Type only' },
            { value: 'costCode', label: 'Cost Code', description: 'Create RFQ lines with Cost Code only' },
            { value: 'section', label: 'Section', description: 'Create RFQ lines with Section only' }
        ];
        component.set("v.statusOptions", options);
	},

    handleOptionSelected: function (cmp, event) {
        cmp.set("v.optionSelected", true);
    }
})