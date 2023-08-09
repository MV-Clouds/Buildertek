({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        component.set("v.baseURLs", baseURL);
        helper.getRecords(component, event, helper, pageNumber, pageSize);
    },

    onCheckAll: function (component, event, helper) {
        var list = component.get('v.listOfRecords');
        var selectedCheckBox = event.getSource();
        var isSelected = selectedCheckBox.get("v.value");
        for (var i in list) {
            list[i].isSelected = isSelected ? true : false;
        }
        component.set('v.listOfRecords', list);
    },

    handleNext: function (component, event, helper) {
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        helper.getRecords(component, event, helper, pageNumber, pageSize);
    },

    handlePrev: function (component, event, helper) {
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        helper.getRecords(component, event, helper, pageNumber, pageSize);
    },

    importMasterWarranty: function (component, event, helper) {
        component.set('v.isLoading', true);
        var list = component.get('v.listOfRecords');
        var recordToImport = '';
        for (var i in list) {
            if (list[i].isSelected) {
                recordToImport += list[i].Id + ';';
            }
        }
        helper.importRecords(component, event, helper, recordToImport);
    },

    closeModel: function (component, event, helper) {
        var baseURL = component.get("v.baseURLs");
        var recordId = component.get("v.recordId");
        window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Project__c/' + escape(recordId) + '/view', '_self');
    },
})