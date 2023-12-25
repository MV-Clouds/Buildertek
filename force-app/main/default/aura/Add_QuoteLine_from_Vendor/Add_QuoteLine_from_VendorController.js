({
    doInit : function(component, event, helper) {
        var QuoteId = component.get("v.quoteId");
        console.log('QuoteId: ' + QuoteId);
        helper.getVendors(component, event, helper);
    },

    closeCmp : function(component, event, helper) {
        component.set("v.openProductBoxwithVendor", false); 
    },

    searchVendor : function(component, event, helper) {
        try {
            var keyword = event.getSource().get("v.value");

            //iterate over main vendor list and if keyword matches Name , add to ItervendorList
            var MainvendorList = component.get("v.MainvendorList");
            var ItervendorList = [];
            for(var i=0; i<MainvendorList.length; i++){
                if(MainvendorList[i].Name.toLowerCase().includes(keyword.toLowerCase())){
                    ItervendorList.push(MainvendorList[i]);
                }
            }
            component.set("v.ItervendorList", ItervendorList);
        } catch (error) {
            console.log('error in searchVendor controller :: ' + error);
        }
    },

    goToVenderPage : function(component, event, helper){
        component.set("v.selectedProduct", false);
        component.set("v.selectedVendor", true);
        component.set("v.disableBtnVen" , true);
        component.set("v.selectedRecords", []);
        component.set("v.sPricebookFamily" , '');
        component.set("v.sProductFamily", '');
        component.set("v.sProductName",'');
    },

    goToProductModal: function(component, event, helper) {
        component.set("v.selectedVendor", false);
        component.set("v.selectedProduct", true);
        helper.goToProdModalHelper(component, event, helper);
    },

    goToEditModal: function(component, event, helper){
        helper.goToEditModalHelper(component,event,helper);
    },

    checkboxChange : function(component, event, helper) {
        try {
            var selectedRecords = component.get("v.selectedRecords");
            console.log('selectedRecords--->',selectedRecords);
            var tableDataList = component.get("v.tableDataList");
            var selectedCheckbox = event.getSource(); // Get the checkbox that fired the event
            var productId = selectedCheckbox.get("v.id");
            var isChecked = selectedCheckbox.get("v.checked");
            
            // Find the selected record by its ID
            var selectedRecord = tableDataList.find(record => record.PriceBookEntryId === productId);
            
            if (isChecked) {
                selectedRecords.push(selectedRecord);
            } else {
                var indexToRemove = selectedRecords.indexOf(selectedRecord);
                if (indexToRemove !== -1) {
                    selectedRecords.splice(indexToRemove, 1);
                }
            }
            
            component.set("v.selectedRecords", selectedRecords);
            
            console.log('selectedRecordIds------>',component.get("v.selectedRecords"));
            var tableDataList = component.get("v.tableDataList");
            var checkAll = true;
            tableDataList.forEach(element => {
                if (!element.Selected) {
                    checkAll = false
                }
            });
        } catch (error) {
            console.log('error in checkboxChange controller :: ' + error);
        }
    },

    removeQuoteLine: function(component, event, helper) {
        try {
            var currentId = event.currentTarget.dataset.id;
            console.log('currentId :: ' + currentId);
            var productList = component.get('v.selectedProducts');
            console.log('selected :: ' + productList);
            var updatedList = [];
            productList.forEach(function(value) {
                console.log('listed"s id --> ' + value.PriceBookEntryId);
                if (value.PriceBookEntryId !== currentId) {
                    updatedList.push(value);
                }
            });
            console.log('updatedList :: ' + updatedList);
            component.set('v.selectedProducts', updatedList);
        
            // Remove the record from v.selectedRecords attribute
            var selectedRecords = component.get('v.selectedRecords');
            var updatedSelectedRecords = selectedRecords.filter(function(record) {
                return record.PriceBookEntryId !== currentId;
            });
            component.set('v.selectedRecords', updatedSelectedRecords);
        
            var quoteLineList = component.get('v.quoteLineList');
            quoteLineList.forEach(function(element) {
                if (element.PriceBookEntryId === currentId) {
                    element.Selected = false;
                }
            });
           
        } catch (error) {
            console.log('error in removeQuoteLine controller :: ' + error);
        }
    },

    radioButtonAction: function(component, event, helper) {
        var selected = event.getSource().get("v.text");
        console.log('selected--->',selected);
        component.set('v.vendorId',selected);
        
        component.set("v.disableBtnVen" , false);
    },
    
    backToProductModal: function(component, event, helper){
        try {
            component.set("v.selectedVendor", false);

            var quoteLineList = component.get("v.quoteLineList");
            component.set("v.sProductName", '');
            var selectedRecords = [];
            var remainingRecords = [];

            quoteLineList.forEach(element => {
                if (element.Selected) {
                    selectedRecords.push(element);
                } else {
                    remainingRecords.push(element);
                }
            });

            // Sort the remaining records in ascending order based on Family and then Name
            remainingRecords.sort(function(a, b) {
                if (!a.Family) {
                    a.Family = '';
                }
                if (!b.Family ) {
                    b.Family = '';
                }
                // Compare by Family first
                var familyComparison = a.Family.localeCompare(b.Family);
                
                // If Family is the same, compare by Name
                if (familyComparison === 0) {
                    return a.Name.localeCompare(b.Name);
                } else {
                    return familyComparison;
                }
            });

            // Concatenate selected records with sorted remaining records
            var sortedList = selectedRecords.concat(remainingRecords);

            component.set("v.tableDataList", sortedList);

            component.set("v.selectedProduct", true);
            component.set("v.selectedEdit", false);
        } catch (error) {
            console.log('error in backToProductModal controller :: ' + error);
        }
    },

    changePricebookFamily: function(component, event, helper) {
        try {
            var listOfAllRecords = component.get('v.quoteLineList');
            var searchPriceBookFilter = component.find("selectedPricebook").get("v.value");
            console.log('searchPriceBookFilter--->',searchPriceBookFilter);
            component.set("v.pbName" , searchPriceBookFilter);
            component.set("v.sProductFamily", '');
            component.set("v.sProductName", '');
            var tempArray = [];
            var i;
        
            if (searchPriceBookFilter != '') {
                for (i = 0; i < listOfAllRecords.length; i++) {
                    if (
                        listOfAllRecords[i].PriceBookName &&
                        listOfAllRecords[i].PriceBookName.toLowerCase().includes(searchPriceBookFilter.toLowerCase())
                    ) {
                        tempArray.push(listOfAllRecords[i]);
                    }
                }
                component.set("v.tableDataList", tempArray);
            } else {
                component.set("v.tableDataList", listOfAllRecords);
            }
        } catch (error) {
            console.log('error in changePricebookFamily controller :: ' + error);
        }
    },

    changeProductFamily: function(component, event, helper) {
        try {
            var listOfAllRecords = component.get('v.quoteLineList');
            var searchProductFamilyFilter = component.find("selectedProductFamily").get("v.value");
            console.log('searchProductFamilyFilter--->',searchProductFamilyFilter);
            var searchPriceBookFilter = component.find("selectedPricebook").get("v.value");
            console.log('searchPriceBookFilter--->',searchPriceBookFilter);
            component.set("v.sProductName", '');
            var tempArray = [];
            var i;
        
            if (searchProductFamilyFilter != '' && (searchPriceBookFilter == undefined || searchPriceBookFilter == '')) {
                console.log('in1');
                for (i = 0; i < listOfAllRecords.length; i++) {
                    if (
                        listOfAllRecords[i].Family &&
                        listOfAllRecords[i].Family.toLowerCase().includes(searchProductFamilyFilter.toLowerCase())
                    ) {
                        tempArray.push(listOfAllRecords[i]);
                    }
                }
                component.set("v.tableDataList", tempArray);
            } else if (searchPriceBookFilter != '' && (searchProductFamilyFilter == undefined || searchProductFamilyFilter == '')) {
                console.log('in2');
                for (i = 0; i < listOfAllRecords.length; i++) {
                    if (
                        listOfAllRecords[i].PriceBookName &&
                        listOfAllRecords[i].PriceBookName.toLowerCase().includes(searchPriceBookFilter.toLowerCase())
                    ) {
                        tempArray.push(listOfAllRecords[i]);
                    }
                }
                component.set("v.tableDataList", tempArray);
            } else if (searchProductFamilyFilter != '' && searchPriceBookFilter != ''){
                console.log('in3');
                for (i = 0; i < listOfAllRecords.length; i++) {
                    if (
                        listOfAllRecords[i].PriceBookName &&
                        listOfAllRecords[i].PriceBookName.toLowerCase().includes(searchPriceBookFilter.toLowerCase()) &&
                        listOfAllRecords[i].Family &&
                        listOfAllRecords[i].Family.toLowerCase().includes(searchProductFamilyFilter.toLowerCase())
                    ) {
                        tempArray.push(listOfAllRecords[i]);
                    }
                }
                component.set("v.tableDataList", tempArray);
            } else {
                console.log('in4');
                component.set("v.tableDataList", listOfAllRecords);
            }
        } catch (error) {
            console.log('error in changeProductFamily controller :: ' + error);
        }
    },

    filterProdctsRecords : function(component,event,helper){
        try {
            var listOfAllRecords = component.get('v.quoteLineList');
            var searchProductFamilyFilter = component.find("selectedProductFamily").get("v.value");
            console.log('searchProductFamilyFilter--->',searchProductFamilyFilter);
            var searchPriceBookFilter = component.find("selectedPricebook").get("v.value");
            console.log('searchPriceBookFilter--->',searchPriceBookFilter);
            var searchProdNameFilter = component.get("v.sProductName");
            var tempArray = [];
            var i;
        
            if ((searchProductFamilyFilter == '' || searchProductFamilyFilter == undefined) && (searchPriceBookFilter == '' || searchPriceBookFilter == undefined)){
                console.log('in1');
                for (i = 0; i < listOfAllRecords.length; i++) {
                    if (
                        listOfAllRecords[i].Name &&
                        listOfAllRecords[i].Name.toLowerCase().includes(searchProdNameFilter.toLowerCase())
                    ) {
                        tempArray.push(listOfAllRecords[i]);
                    }
                }
                component.set("v.tableDataList", tempArray);
            } else if (searchProductFamilyFilter != '' && (searchPriceBookFilter == undefined || searchPriceBookFilter == '')) {
                console.log('in2');
                for (i = 0; i < listOfAllRecords.length; i++) {
                    if (
                        listOfAllRecords[i].Family &&
                        listOfAllRecords[i].Family.toLowerCase().includes(searchProductFamilyFilter.toLowerCase()) &&
                        listOfAllRecords[i].Name &&
                        listOfAllRecords[i].Name.toLowerCase().includes(searchProdNameFilter.toLowerCase())
                    ) {
                        tempArray.push(listOfAllRecords[i]);
                    }
                }
                component.set("v.tableDataList", tempArray);
            } else if (searchPriceBookFilter != '' && (searchProductFamilyFilter == undefined || searchProductFamilyFilter == '')) {
                console.log('in3');
                for (i = 0; i < listOfAllRecords.length; i++) {
                    if (
                        listOfAllRecords[i].PriceBookName &&
                        listOfAllRecords[i].PriceBookName.toLowerCase().includes(searchPriceBookFilter.toLowerCase()) &&
                        listOfAllRecords[i].Name &&
                        listOfAllRecords[i].Name.toLowerCase().includes(searchProdNameFilter.toLowerCase())
                    ) {
                        tempArray.push(listOfAllRecords[i]);
                    }
                }
                component.set("v.tableDataList", tempArray);
            } else if (searchProductFamilyFilter != '' && searchPriceBookFilter != ''){
                console.log('in4');
                for (i = 0; i < listOfAllRecords.length; i++) {
                    if (
                        listOfAllRecords[i].PriceBookName &&
                        listOfAllRecords[i].PriceBookName.toLowerCase().includes(searchPriceBookFilter.toLowerCase()) &&
                        listOfAllRecords[i].Family &&
                        listOfAllRecords[i].Family.toLowerCase().includes(searchProductFamilyFilter.toLowerCase()) &&
                        listOfAllRecords[i].Name &&
                        listOfAllRecords[i].Name.toLowerCase().includes(searchProdNameFilter.toLowerCase())
                    ) {
                        tempArray.push(listOfAllRecords[i]);
                    }
                }
                component.set("v.tableDataList", tempArray);
            } else {
                console.log('in5');
                component.set("v.tableDataList", listOfAllRecords);
            }
        } catch (error) {
            console.log('error in filterProdctsRecords controller :: ' + error);
        }
    },

    saveQuoteLine : function(component, event, helper){
        helper.saveQuoteLine(component,event,helper);
    }
})