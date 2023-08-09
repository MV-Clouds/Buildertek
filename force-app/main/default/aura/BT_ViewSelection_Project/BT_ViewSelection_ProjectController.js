({
    init: function (cmp, event, helper) {
        
        cmp.set('v.gridColumns', [
            {
                wrapText: true, type: 'button', label: 'Client Selections', fieldName: 'Name', typeAttributes: { label: { fieldName: 'Name' }, variant: 'base' }, 
                // For Display Icon and Extra Text In 1st Column
                // cellAttributes: {
                    // iconName: { fieldName: 'iconToUse' },
                    // iconLabel: { fieldName: 'iconLabelToUse' },
                    // iconAlternativeText: 'Add Selection',
                // },
            },
            { initialWidth: 220, label: 'Type', fieldName: 'SelectionType', type: 'text' },
            { initialWidth: 220, label: 'Selection Status', fieldName: 'SelectionStatus', type: 'text' },
        ]);
        helper.getClientSelections(cmp);
    },
    handleURLClick: function (cmp, event, helper) {
        var jString = JSON.parse(JSON.stringify(event));
        var recId = '';
        if (jString.hp.row.level == 1) {
            recId = jString.hp.row.selectionid;
        }
        else if (jString.hp.row.level == 2) {
            recId = jString.hp.row.Id;
        }
        else if (jString.hp.row.level == 3) {
            recId = jString.hp.row.Id;
        }
        else if (jString.hp.row.level == 4) {
            recId = jString.hp.row.Id;
        }
        var orgURL = window.location.origin;
        window.open((orgURL + '/' + recId), 'height=700,width=1200');
    }
})