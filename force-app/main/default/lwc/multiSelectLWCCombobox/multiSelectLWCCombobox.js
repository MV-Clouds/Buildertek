import { LightningElement, track, api } from 'lwc';

export default class MultiSelectLWCCombobox extends LightningElement {

    @api options;
    @api selectedValue;
    @api selectedValues = [];
    @api label;
    @api iterId;
    @api minChar = 2;
    @api disabled = false;
    @api multiSelect = false;
    @track value;
    @track values = [];
    @track optionData;
    @track searchString;
    @track message;
    @track showDropdown = false;

    connectedCallback() {
        this.showDropdown = false;
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        var value = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
        var values = this.selectedValues ? (JSON.parse(JSON.stringify(this.selectedValues))) : null;
        if (value || values) {
            var searchString;
            var count = 0;
            for (var i = 0; i < optionData.length; i++) {
                if (this.multiSelect) {
                    if (values.includes(optionData[i].value)) {
                        optionData[i].selected = true;
                        count++;
                    }
                } else {
                    if (optionData[i].value == value) {
                        searchString = optionData[i].label;
                    }
                }
            }
            if (this.multiSelect)
                this.searchString = count + ' Option(s) Selected';
            else
                this.searchString = searchString;
        }
        this.value = value;
        this.values = values;
        this.optionData = optionData;
        console.log(`this.optionData: ${JSON.stringify(this.optionData)}`);
        
    }

    filterOptions(event) {
        this.searchString = event.target.value;
        if (this.searchString && this.searchString.length > 0) {
            this.message = '';
            if (this.searchString.length >= this.minChar) {
                var flag = true;
                for (var i = 0; i < this.optionData.length; i++) {
                    if (this.optionData[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                        this.optionData[i].isVisible = true;
                        flag = false;
                    } else {
                        this.optionData[i].isVisible = false;
                    }
                }
                if (flag) {
                    this.message = "No results found for '" + this.searchString + "'";
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
        console.log(`this.optionData: ${JSON.stringify(this.optionData)}`);
    }

    selectItem(event) {
        var selectedVal = event.currentTarget.dataset.id;
        if (selectedVal) {
            var count = 0;
            var options = JSON.parse(JSON.stringify(this.optionData));
            for (var i = 0; i < options.length; i++) {
                if (options[i].value === selectedVal) {
                    if (this.multiSelect) {
                        if (this.values.includes(options[i].value)) {
                            this.values.splice(this.values.indexOf(options[i].value), 1);
                        } else {
                            this.values.push(options[i].value);
                        }
                        options[i].selected = options[i].selected ? false : true;
                    } else {
                        this.value = options[i].value;
                        this.searchString = options[i].label;
                    }
                }
                if (options[i].selected) {
                    count++;
                }
            }
            this.optionData = options;
            if (this.multiSelect)
                this.searchString = count + ' Option(s) Selected';
            if (this.multiSelect)
                event.preventDefault();
            else
                this.showDropdown = false;
            console.log(`this.value: ${JSON.stringify(this.values)}`);
        }


        this.dispatchEvent(new CustomEvent('select', {
            detail: {
                'payloadType': 'multi-select',
                'payload': {
                    'value': this.value,
                    'values': this.values,
                    'iterId': this.iterId
                }
            }
        }));
    }

    showOptions() {
        if (this.disabled == false && this.options) {
            this.message = '';
            this.searchString = '';
            var options = JSON.parse(JSON.stringify(this.optionData));
            for (var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            if (options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }

    removePill(event) {
        var value = event.currentTarget.name;
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        for (var i = 0; i < options.length; i++) {
            if (options[i].value === value) {
                options[i].selected = false;
                this.values.splice(this.values.indexOf(options[i].value), 1);
            }
            if (options[i].selected) {
                count++;
            }
        }
        this.optionData = options;
        if (this.multiSelect)
            this.searchString = count + ' Option(s) Selected';
        
        this.dispatchEvent(new CustomEvent('select', {
            detail: {
                'payloadType': 'multi-select',
                'payload': {
                    'value': this.value,
                    'values': this.values,
                    'iterId': this.iterId
                }
            }
        }));
        
    }

    blurEvent() {
        var previousLabel;
        var count = 0;
        for (var i = 0; i < this.optionData.length; i++) {
            if (this.optionData[i].value === this.value) {
                previousLabel = this.optionData[i].label;
            }
            if (this.optionData[i].selected) {
                count++;
            }
        }
        if (this.multiSelect)
            this.searchString = count + ' Option(s) Selected';
        else
            this.searchString = previousLabel;

        this.showDropdown = false;

        // this.dispatchEvent(new CustomEvent('select', {
        //     detail: {
        //         'payloadType': 'multi-select',
        //         'payload': {
        //             'value': this.value,
        //             'values': this.values
        //         }
        //     }
        // }));
    }
}