({
    doInit: function (component, event, helper) {
        var start = new Date().getTime();
        helper.getRecords(component, event, helper, start);
    },

    onClickMassUpdate: function (component, event, helper) {
        var start = new Date().getTime();
        component.set('v.isLoading', true);
        if (!component.get('v.massUpdateEnable')) {
            component.set('v.massUpdateEnable', true);
            component.set('v.isLoading', false);
        } else {
            component.set('v.massUpdateEnable', false);
            var listOfRecords = component.get('v.listOfRecords');
            var records = [];
            for (var i in listOfRecords) {
                for (var j in listOfRecords[i].groupedRecords) {
                    records.push(listOfRecords[i].groupedRecords[j]);
                }
            }
            component.set('v.listOfRecordsClone', []);
            component.set('v.listOfRecords', []);
            helper.updateQuoteItems(component, event, helper, records, start);
        }
    },

    onClickMassUpdateCancel: function(component,event,helper){
        component.set('v.isLoading', true);
        component.set('v.massUpdateEnable', false);
        component.set('v.isLoading', false);
    },
})