import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NewQuoteItemcmp extends LightningElement {
    isInitalRender = true;
    @track data = [
        {
            groupName: 'Administration',
            items: [
                {
                    id: 1,
                    productName: 'ABC',
                    costCode: 'B2010.21',
                    quantity: 1,
                    unitCost: 100.00,
                    markup: 75,
                    unitSalesPrice: 175.00,
                    totalPreTax: 175.00,
                    tax: 0.00
                }
            ]
        },
        {
            groupName: 'No Grouping',
            items: [
                {
                    id: 2,
                    productName: 'BCD',
                    costCode: 'B2010.21',
                    quantity: 1,
                    unitCost: 100.00,
                    markup: 75,
                    unitSalesPrice: 175.00,
                    totalPreTax: 175.00,
                    tax: 0.00
                }
            ]
        }
    ];

    columns = [
        {
            type: 'action',
            typeAttributes: { rowActions: this.getRowActions },
            fixedWidth: 75
        },
        { label: 'Product Name', fieldName: 'productName' },
        { label: 'Cost Code', fieldName: 'costCode' },
        { label: 'Quantity', fieldName: 'quantity', type: 'number' },
        { label: 'Unit Cost', fieldName: 'unitCost', type: 'currency' },
        { label: 'Markup (%)', fieldName: 'markup', type: 'percent' },
        { label: 'Unit Sales Price', fieldName: 'unitSalesPrice', type: 'currency' },
        { label: 'Total Pre-Tax', fieldName: 'totalPreTax', type: 'currency' },
        { label: 'Tax', fieldName: 'tax', type: 'currency' }
    ];
        renderedCallback() {
        if (this.isInitalRender) {
            const body = document.querySelector("body");

            const style = document.createElement('style');
            style.innerText = `
                .quote-table .slds-cell-fixed{
                    background: #e0ebfa !important;
                    color:#0176d3;
                }
            `;

            body.appendChild(style);
            this.isInitalRender = false;
        }

    }

    getRowActions(row, doneCallback) {
        const actions = [
            { label: 'Edit', name: 'edit', iconName: 'utility:edit' },
            { label: 'Delete', name: 'delete', iconName: 'utility:delete' }
        ];
        doneCallback(actions);
    }

    groupSubtotal(items) {
        return items.reduce((acc, item) => acc + item.totalPreTax, 0);
    }

    get grandTotal() {
        return this.data.reduce((acc, group) => acc + this.groupSubtotal(group.items), 0);
    }

    handleAddItem() {
        const evt = new ShowToastEvent({
            title: 'Add Item',
            message: 'Add Item button clicked!',
            variant: 'info'
        });
        this.dispatchEvent(evt);
    }
}
