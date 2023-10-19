function populateIcons(record) {
    // console.log('popluate record-->',record.record._data);
    if (record.row) {
        if (record.row._allCells.length) {
            if (
                record.record._data.type == "Project" &&
                record.row._allCells[2].innerHTML
            ) {
                var iconElement = `<span class="slds-icon_container slds-icon-custom-custom70" >
                                            <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: white !important;height:1.3rem;width:1.3rem;">
                                                <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom70">
                                                </use>
                                            </svg>
                                        </span>`;
                if (record.row._allCells[2].children[0]) {
                    if (
                        record.row._allCells[2].children[0].innerHTML.indexOf(
                            "custom70"
                        ) == -1
                    ) {
                        record.row._allCells[2].children[0].innerHTML =
                            iconElement + record.row._allCells[2].children[0].innerHTML;
                    }
                }
            }
            if (
                record.record._data.type == "Phase" &&
                record.row._allCells[2].innerHTML
            ) {
                var iconElement = `<span class="slds-icon_container slds-icon-custom-custom62" >
                <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: white !important;height:1.3rem;width:1.3rem;">
                <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom62">
                </use>
            </svg>
                                        </span>`;
                if (record.row._allCells[2].children[0]) {
                    if (
                        record.row._allCells[2].children[0].innerHTML.indexOf(
                            "slds-icon-custom-custom62"
                        ) == -1
                    ) {
                        record.row._allCells[2].children[0].innerHTML =
                            iconElement + record.row._allCells[2].children[0].innerHTML;
                    }
                }
            }
            if (
                record.record._data.type == "Task" &&
                record.row._allCells[2].innerHTML
            ) {
                if (
                    record.record._data.iconCls == "b-fa b-fa-arrow-left indentTrue" &&
                    record.row._allCells[2].children[0].classList.contains(
                        "indentCellTrue"
                    ) == false
                ) {
                    if (record.row._allCells[2].children[0]) {
                        record.row._allCells[2].children[0].classList.add(
                            "indentCellTrue"
                        );
                    }
                    if (
                        record.record._data.name == "Milestone Complete" ||
                        record.record._data.customtype == "Milestone"
                    ) {
                        var iconElement = `<span class="slds-icon_container slds-icon-custom-custom8" style="background:white;">
                                                    <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: #e56798 !important;height:1.3rem;width:1.3rem;">
                                                        <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom8">
                                                        </use>
                                                    </svg>
                                                </span>`;
                        if (record.row._allCells[2].children[0]) {
                            if (
                                record.row._allCells[2].children[0].innerHTML.indexOf(
                                    "slds-icon-utility-multi_select_checkbox"
                                ) == -1
                            ) {
                                record.row._allCells[2].children[0].innerHTML =
                                    iconElement + record.row._allCells[2].children[0].innerHTML;
                            }
                        }
                    } else {
                        var iconElement = `<span class="slds-icon_container slds-icon-utility-multi_select_checkbox" style="background:rgb(1 82 134 / 62%);">
                                                    <svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"
                                                            width="1.3rem" height="1.4rem" viewBox="0 0 100 100" enable-background="new 0 0 100 100" xml:space="preserve">
                                                    <path fill="#FFFFFF" d="M73,20H41c-3.3,0-6,2.7-6,6v1c0,0.6,0.4,1,1,1h29c3.3,0,6,2.7,6,6v31c0,0.6,0.4,1,1,1h1c3.3,0,6-2.7,6-6V26
                                                        C79,22.7,76.3,20,73,20z"/>
                                                    <path fill="#FFFFFF" d="M59,34H27c-3.3,0-6,2.7-6,6v34c0,3.3,2.7,6,6,6h32c3.3,0,6-2.7,6-6V40C65,36.7,62.3,34,59,34z M56.3,51
                                                        L41,66.3c-0.6,0.6-1.3,0.9-2.1,0.9c-0.7,0-1.5-0.3-2.1-0.9l-7.4-7.4c-0.6-0.6-0.6-1.5,0-2.1l2.1-2.1c0.6-0.6,1.5-0.6,2.1,0l5.3,5.3
                                                        l13.2-13.2c0.6-0.6,1.5-0.6,2.1,0l2.1,2.1C56.8,49.5,56.8,50.5,56.3,51z"/>
                                                    </svg>
                                                </span>`;
                        if (record.row._allCells[2].children[0]) {
                            if (
                                record.row._allCells[2].children[0].innerHTML.indexOf(
                                    "slds-icon-utility-multi_select_checkbox"
                                ) == -1
                            ) {
                                record.row._allCells[2].children[0].innerHTML =
                                    iconElement + record.row._allCells[2].children[0].innerHTML;
                            }
                        }
                    }
                } else if (
                    record.record._data.iconCls != "b-fa b-fa-arrow-left indentTrue"
                ) {
                    if (
                        record.record._data.name == "Milestone Complete" ||
                        record.record._data.customtype == "Milestone"
                    ) {
                        var iconElement = `<span class="slds-icon_container slds-icon-custom-custom8" style="background:white;">
                                                    <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: #e56798 !important;height:1.3rem;width:1.3rem;">
                                                        <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom8">
                                                        </use>
                                                    </svg>
                                                </span>`;
                        if (record.row._allCells[2].children[0]) {
                            if (
                                record.row._allCells[2].children[0].innerHTML.indexOf(
                                    "slds-icon-custom-custom8"
                                ) == -1
                            ) {
                                record.row._allCells[2].children[0].innerHTML =
                                    iconElement + record.row._allCells[2].children[0].innerHTML;
                            }
                        }
                    } else {
                        var iconElement = `<span class="slds-icon_container slds-icon-custom-custom83" style="background:orange;">
                        <svg aria-hidden="true" class="slds-icon slds-icon-text-default" style="fill: #FFFFFF !important; background: #8ee997 !important; border-radius:20% !important;height:1.3rem;width:1.3rem;">
                        <use xmlns:xlink=" http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/custom-sprite/svg/symbols.svg#custom83">
                        </use>
                    </svg>
                                                </span>`;
                        if (record.row._allCells[2].children[0]) {
                            if (
                                record.row._allCells[2].children[0].innerHTML.indexOf(
                                    "slds-icon-custom-custom83"
                                ) == -1
                            ) {
                                record.row._allCells[2].children[0].innerHTML =
                                    iconElement + record.row._allCells[2].children[0].innerHTML;
                            }
                        }
                    }
                }
            }
        }
    }
}

export {
    populateIcons
};