import { api, LightningElement, track, wire } from "lwc";
import { loadScript } from 'lightning/platformResourceLoader';

import PARSER from "@salesforce/resourceUrl/PapaParse";


export default class GanttCSVExportComponent extends LightningElement {
    @api scheduleDataToExport;
    @track fileName = 'Schedule-Gantt';

    renderedCallback() {
        try {
            Promise.all([
                loadScript(this, PARSER + "/PapaParse/papaparse.js"),
            ])
                .then(() => {
                    console.log('lib loaded');
                })
                .catch((error) => {
                    console.log('error in promise', { error });
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error loading Papa Parse",
                            message: error,
                            variant: "error",
                        })
                    );
                });
        } catch (error) {
            console.log('error ', JSON.parse(JSON.stringify(error)));
        }

    }

    changeFileName(event) {
        this.fileName = event.target.value;
    }

    hideModalBox() {
        this.dispatchEvent(new CustomEvent('hidemodel', {
            detail: {
                message: false
            }
        }));
    }

    exportScheduleData() {
        try {
            console.log('exportScheduleData');
            let temp = this.scheduleDataToExport;
            console.log('exportScheduleData', JSON.parse(JSON.stringify(temp)));

            let getColumns = [
                "Name",
                "buildertek__Dependency__r.Name",
                "buildertek__Start__c",
                "buildertek__Finish__c",
                "buildertek__Duration__c",
                "buildertek__Completion__c",
                "buildertek__Phase__c",
                "buildertek__Notes__c",
                "buildertek__Lag__c",
                "buildertek__BT_Grouping__r.Name",
                "buildertek__Cost_Code__r.Name",
                "buildertek__Trade_Type__r.Name"
            ];

            let object = [
                "Name",
                "Dependency",
                "StartDate",
                "FinishDate",
                "Duration",
                "% Complete",
                "Phase",
                "Notes",
                "Lag",
                "Grouping",
                "Cost Code",
                "Trade Type"
            ];

            this.scheduleDataToExport = this.scheduleDataToExport
                .filter((item) => item.buildertek__Type__c !== "Milestone")
                .map((item) => {
                    const newItem = { ...item };
                    if (
                        newItem.hasOwnProperty("buildertek__Start__c") &&
                        newItem.hasOwnProperty("buildertek__Finish__c") &&
                        Object.getOwnPropertyDescriptor(newItem, "buildertek__Start__c").writable &&
                        Object.getOwnPropertyDescriptor(newItem, "buildertek__Finish__c").writable
                    ) {
                        const startDate = new Date(newItem.buildertek__Start__c);
                        const finishDate = new Date(newItem.buildertek__Finish__c);

                        if (!isNaN(startDate.getTime()) && !isNaN(finishDate.getTime())) {
                            newItem.buildertek__Start__c = startDate.toLocaleDateString('en-US');
                            newItem.buildertek__Finish__c = finishDate.toLocaleDateString('en-US');
                        } else {
                            console.error("Invalid date format after parsing");
                        }
                    } else {
                        console.error("One or both properties are not writable or do not exist");
                    }

                    return newItem;
                });


            console.log('exportScheduleData', JSON.parse(JSON.stringify(this.scheduleDataToExport)));
            debugger;
            const convertedObject = this.scheduleDataToExport.map((item) => {
                const obj = {};
                getColumns.forEach((column, index) => {
                    if (item.hasOwnProperty(column)) {
                        obj[object[index]] = item[column];
                    } else {
                        obj[object[index]] = null;
                    }
                    if (item.hasOwnProperty("buildertek__Dependency__c")) {
                        obj["Dependency"] =
                            item.buildertek__Dependency__r.Name;
                    } else {
                        obj["Dependency"] = null;
                    }
                    if (item.hasOwnProperty("buildertek__BT_Grouping__c")) {
                        obj["Grouping"] = item.buildertek__BT_Grouping__r.Name;
                    } else {
                        obj["Grouping"] = null;
                    }
                    if (item.hasOwnProperty("buildertek__Cost_Code__c")) {
                        obj["Cost Code"] = item.buildertek__Cost_Code__r.Name;
                    } else {
                        obj["Cost Code"] = null;
                    }
                    if (item.hasOwnProperty("buildertek__Trade_Type__c")) {
                        obj["Trade Type"] = item.buildertek__Trade_Type__r.Name;
                    } else {
                        obj["Trade Type"] = null;
                    }
                });
                return obj;
            });

            var csvData = Papa.unparse(convertedObject);
            const element = document.createElement("a");
            element.setAttribute(
                "href",
                "data:text/csv;charset=utf-8," + encodeURIComponent(csvData)
            );
            element.setAttribute("download", this.fileName + ".csv");
            element.style.display = "none";
            document.body.appendChild(element);
            element.click();
            document.body.removeChild(element);
            this.hideModalBox();
        } catch (error) {
            console.log('error ', JSON.parse(JSON.stringify(error)));
        }
    }
}