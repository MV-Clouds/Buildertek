({
    doInit: function (component, event, helper) {
        var recordId = '';
        component.set('v.isLoading', true);
        helper.getTableFieldSet(component, event, helper);
        window.setTimeout(
            $A.getCallback(function () {
                helper.getToDoName(component, event, helper);
                helper.getTableRows(component, event, helper);
                component.set('v.isLoading', false);
            }), 2000
        );
    },

    onAddCancel: function (component, event, helper) {
        if (component.get('v.onSaveEnabled')) {
            component.set('v.onSaveEnabled', false);
        }
    },

    onAddClick: function (component, event, helper) {
        if (component.get('v.massUpdateEnable')) {
            var fields = component.get('v.fieldSetValues');
            var listOfToDoItems = component.get('v.listOfToDoItems');
            var obj = {};
            for (var i in fields) {
                obj[fields[i].name] = '';
            }
            listOfToDoItems.unshift(obj);
            component.set('v.listOfToDoItems', listOfToDoItems);
        }
    },

    onMassUpdate: function (component, event, helper) {
        component.set('v.isLoading', true);
        if (!component.get('v.massUpdateEnable')) {
            component.set('v.massUpdateEnable', true);
            component.set('v.isLoading', false);
        } else if (component.get('v.massUpdateEnable')) {
            component.set('v.isLoading', true);
            component.set('v.massUpdateEnable', false);
            helper.updateMassToDo(component, event, helper);
        }
    },

    onMassUpdateCancel: function (component, event, helper) {
        if (component.get('v.massUpdateEnable')) {
            component.set('v.listOfToDoItems', JSON.parse(JSON.stringify(component.get('v.cloneListOfToDoItems'))));
            component.set('v.massUpdateEnable', false);
        }
    },
})