({
    renderCmp: function(component, event, helper){

        var params = event.getParam('arguments');
        if (params) {
            var displayCmp = params.displayCmp;
            var recordId = params.recordId;
            var groupFieldList = params.groupFieldList;

            component.set("v.displayCmp", displayCmp);
            component.set("v.recordId", recordId);
            component.set("v.groupFieldList", groupFieldList);
        }

        if (component.get("v.displayCmp")) {
            helper.renderCmpHelper(component, event, helper);
        }
    }, 

    expandCollapeAll: function(component, event, helper){
        var QuoteLineWrapper = component.get("v.QuoteLineWrapper");

        var iconName = event.currentTarget.dataset.iconname;
        var recordId = component.get("v.recordId");

        var expandallIcon = document.getElementById("expandAllBtn_" + recordId);
        var collapeallIcon = document.getElementById("collapeseAllBtn_" + recordId);

        let group1 = QuoteLineWrapper.groupWrapper;

        if (iconName == 'Expand All') {
            collapeallIcon.style.display = 'block';
            expandallIcon.style.display = 'none';

            if (component.get("v.forthGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let group3 = group2[j-1].quoteLineList;
                        for (let k = 1; k <= group3.length; k++) {
                            let group4 = group3[k-1].quoteLineList;
                            for (let l = 1; l <= group4.length; l++) {
                                let spanGroupId = i+''+j+''+k+''+l;
                                helper.expandRecordsHelper(component, event, helper, spanGroupId);
                            }
                        }
                    }
                }
            } else if (component.get("v.thirdGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let group3 = group2[j-1].quoteLineList;
                        for (let k = 1; k <= group3.length; k++) {
                            let spanGroupId = i+''+j+''+k;
                            helper.expandRecordsHelper(component, event, helper, spanGroupId);
                        }
                    }
                }
            } else if (component.get("v.secondGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let spanGroupId = i+''+j;
                        helper.expandRecordsHelper(component, event, helper, spanGroupId);
                    }
                }
            } else if(component.get("v.firstGrouping")){
                for (let i = 1; i <= group1.length; i++) {
                    let spanGroupId = i;
                    helper.expandRecordsHelper(component, event, helper, spanGroupId);
                }
            }
            component.set("v.CollapeCount", 0);
        } else if (iconName == 'Collapse All') {
            collapeallIcon.style.display = 'none';
            expandallIcon.style.display = 'block';

            if (component.get("v.forthGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let group3 = group2[j-1].quoteLineList;
                        for (let k = 1; k <= group3.length; k++) {
                            let group4 = group3[k-1].quoteLineList;
                            for (let l = 1; l <= group4.length; l++) {
                                let spanGroupId = i+''+j+''+k+''+l;
                                helper.collapeRecordsHelper(component, event, helper, spanGroupId);
                            }
                        }
                    }
                }
            } else if (component.get("v.thirdGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let group3 = group2[j-1].quoteLineList;
                        for (let k = 1; k <= group3.length; k++) {
                            let spanGroupId = i+''+j+''+k;
                            helper.collapeRecordsHelper(component, event, helper, spanGroupId);
                        }
                    }
                }
            } else if (component.get("v.secondGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let spanGroupId = i+''+j;
                        helper.collapeRecordsHelper(component, event, helper, spanGroupId);
                    }
                }
            } else if(component.get("v.firstGrouping")){
                for (let i = 1; i <= group1.length; i++) {
                    let spanGroupId = i;
                    helper.collapeRecordsHelper(component, event, helper, spanGroupId);
                }
            }
            component.set("v.CollapeCount", component.get("v.TotalRecordCount"));
        }
    },

    expandCollapeGroup: function(component, event, helper){
        var recordId = component.get("v.recordId");

        var expandallIcon = document.getElementById("expandAllBtn_" + recordId);
        var collapeallIcon = document.getElementById("collapeseAllBtn_" + recordId);

        var iconName = event.currentTarget.dataset.iconname;
        var spanId = event.target.id;

        var totalRecordCount = component.get("v.TotalRecordCount");
        var collapeCount = component.get("v.CollapeCount");
    
        if (iconName == 'Expand Group') {
            let spanGroupId = spanId.replace('expandGroupBtn_','');
            helper.expandRecordsHelper(component, event, helper, spanGroupId);

            let recordDivList = document.getElementsByClassName('record_'+spanGroupId);
            let selectedRecord = recordDivList.length;
            collapeCount -= selectedRecord;
        } else if (iconName == 'Collapse Group') {
            let spanGroupId = spanId.replace('collapeseGroupBtn_','');
            helper.collapeRecordsHelper(component, event, helper, spanGroupId);

            let recordDivList = document.getElementsByClassName('record_'+spanGroupId);
            let selectedRecord = recordDivList.length;
            collapeCount += selectedRecord;
        }
        component.set("v.CollapeCount", collapeCount);

        if(collapeCount == totalRecordCount){
            collapeallIcon.style.display = 'none';
            expandallIcon.style.display = 'block';
        } else{
            collapeallIcon.style.display = 'block';
            expandallIcon.style.display = 'none';
        }

    }
})