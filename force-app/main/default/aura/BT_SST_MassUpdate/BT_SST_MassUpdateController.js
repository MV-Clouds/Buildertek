({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        helper.getTableFieldSet(component, event, helper);
        window.setTimeout(
            $A.getCallback(function () {
                helper.getQuoteName(component, event, helper);
                helper.getTableRows(component, event, helper);
                component.set('v.isLoading', false);
            }), 1000
        );
    },

    onAddClick: function (component, event, helper) {
        var fields = component.get('v.fieldSetValues');
        var list = component.get('v.listOfRecords');
        var obj = {};
        for (var i in fields) {
            obj[fields[i].name] = '';
        }
        list.unshift(obj);
        component.set('v.listOfRecords', list);
    },

    onMassUpdate: function (component, event, helper) {
        component.set('v.isLoading', true);
        if (!component.get('v.massUpdateEnable')) {
            component.set('v.massUpdateEnable', true);
            component.set('v.isLoading', false);
        } else if (component.get('v.massUpdateEnable')) {
            component.set('v.isLoading', true);
            component.set('v.massUpdateEnable', false);
            helper.updateMassRecords(component, event, helper);
        }
    },

    onMassUpdateCancel: function (component, event, helper) {
        if (component.get('v.massUpdateEnable')) {
            component.set('v.listOfRecords', JSON.parse(JSON.stringify(component.get('v.cloneListOfRecords'))));
            component.set('v.massUpdateEnable', false);
        }
    },

    deleteRecord: function (component, event, helper) {
        var target = event.target;
        var index = target.getAttribute("data-index");
        var records = component.get('v.listOfRecords');
        if (records[index].Id != undefined) {
            component.set('v.selectedRecordIndex', index);
            component.set('v.quoteLineName', records[index].Name);
            component.set('v.isModalOpen', true);
        } else if (records[index].Id == undefined) {
            records.splice(index, 1);
            component.set('v.listOfRecords', records);
        }
    },

    handleCancel: function (component, event, helper) {
        component.set('v.isModalOpen', false);
    },

    handleDelete: function (component, event, helper) {
        var records = component.get('v.listOfRecords');
        var index = component.get('v.selectedRecordIndex');
        if (records[index].Id != undefined) {
            //records.splice(index, 1);
            //component.set('v.listOfRecords', records);
            helper.delete(component,event,helper,records[index].Id);
            component.set('v.isModalOpen', false);
        }
    }
})