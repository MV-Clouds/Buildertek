import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import insertData from "@salesforce/apex/importScheduleLineController.insertData";
import PARSER from "@salesforce/resourceUrl/PapaParse";
export default class importScheduleLine extends LightningElement {
    fileName;
    fileContent;
    showError = false;
    Spinner;
    showMessage;
    @track files;
    @track isOpen;
    @api recordid;
    @api showImportPopup
    // @track BaseURLs;
    // @track isNewGantt;

    get acceptedFormats() {
        return [".csv"];
    }

    renderedCallback() {
        Promise.all([
            loadScript(this, PARSER + "/PapaParse/papaparse.js"),
        ])
        .then(() => {})
        .catch((error) => {
            console.log('error in renderedCallback:',error);
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error loading papa parse library",
              message: error,
              variant: "error",
            })
          );
        });
    }

    handleFileChange(event) {
        this.files = event.target.files;
        this.errorMessage = '';
        if (this.files.length === 1) {
            const file = this.files[0];
            const reader = new FileReader();
            reader.onload = () => {
                const contents = reader.result.split(",")[1];
                this.fileName = file.name;
                this.fileContent = contents;
                this.showError = false;

                console.log("fileContent:", this.fileContent);
            };
            reader.readAsDataURL(file);
        } else {
            this.showError = true;
            this.fileName = "";
            this.fileContent = "";
        }
    }

    downloadCsv() {
        const csv = this.convertArrayOfObjectsToCSV();

        if (csv == null) {
            return;
        }
        const hiddenElement = document.createElement("a");
        hiddenElement.href = "data:text/csv;charset=utf-8," + encodeURI(csv);
        hiddenElement.target = "_self";
        hiddenElement.download = "Import Schedules.csv";
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    }

    convertArrayOfObjectsToCSV() {
        const keys = [
            "Name",
            "Dependency",
            "StartDate",
            "Duration",
            "% Complete",
            "Phase",
            "Phase2",
            "Phase3",
            "Notes",
            "Lag",
            "Cost Code",
            "Trade Type",
            "Vendor",
        ];
        const columnDivider = ",";
        let csvStringResult = "";
        csvStringResult += keys.join(columnDivider);
        return csvStringResult;
    }

    CSV2JSON(csv) {
        try {
            let arr = [];
            let modifiedCsvData = this.trimCSVData(csv);
            let cleanCsv = Papa.parse(modifiedCsvData, {skipEmptyLines:'greedy'});
            let newCleanCsv = Papa.unparse(cleanCsv.data);
            arr = newCleanCsv.split("\n");

            if (
                arr[arr.length - 1] === "" ||
                arr[arr.length - 1] === undefined ||
                arr[arr.length - 1] === null
            ) {
                arr.pop();
            }

            let jsonObj = [];
            let headers = arr[0].split(",");
            console.log("headers:", headers);
            if (
                headers[0] !== "Name" ||
                headers[1] !== "Dependency" ||
                headers[2] !== "StartDate" ||
                headers[3] !== "Duration" ||
                headers[4] !== "% Complete" ||
                headers[5] !== "Phase" ||
                headers[6] !== "Phase2" ||
                headers[7] !== "Phase3" ||
                headers[8] !== "Notes" ||
                headers[9] !== "Lag" ||
                headers[10] !== "Cost Code" ||
                headers[11] !== "Trade Type" ||
                headers[12] !== "Vendor\r" 
            ) {
                this.Spinner = false;
                this.isErrorOccured = true;
                // this.errorMessage = "File Header Format is Invalid!";
                // const event = new ShowToastEvent({
                //     title: 'Error',
                //     message: 'File Header Format is Invalid !!!',
                //     variant: 'error',
                //     mode: 'dismissable'
                // });
                // this.dispatchEvent(event);
                return "Error";
            }

            let startIndex;
            let endIndex;

            for (let i = 1; i < arr.length; i++) {
                console.log('arr[i]:',arr[i]);
                if (arr[i] !== undefined) {
                    while (arr[i].indexOf('"') > -1) {
                        console.log('while loop');
                        if (startIndex === null) {
                            startIndex = arr[i].indexOf('"');
                            arr[i] =
                                arr[i].substring(0, startIndex) +
                                ":quotes:" +
                                arr[i].substring(startIndex + 1, arr[i].length);
                        } else {
                            if (endIndex === null) {
                                endIndex = arr[i].indexOf('"');
                                arr[i] =
                                    arr[i].substring(0, endIndex) +
                                    ":quotes:" +
                                    arr[i].substring(endIndex + 1, arr[i].length);
                            }
                        }

                        if (startIndex !== null && endIndex !== null) {
                            let sub = arr[i].substring(startIndex, endIndex);
                            sub = sub.replaceAll(",", ":comma:");
                            arr[i] = arr[i].substring(0, startIndex) + sub + arr[i].substring(endIndex, arr[i].length);
                            startIndex = null;
                            endIndex = null;
                        }
                    }

                    let data = arr[i].split(",");
                    let obj = {};
                    let month = "";
                    let day = "";
                    for (let j = 0; j < data.length; j++) {
                        let myStr = data[j];
                        let newStr = myStr.replace(/:comma:/g, ",");
                        newStr = newStr.replace(/:quotes:/g, "");
                        data[j] = newStr;
                        console.log('headers [j ] :', headers[j]);
                        console.log('headers:', headers);
                        if (headers[j]) {
                            if (headers[j].trim() === "StartDate" && data[j].trim() !== "") {
                                let dateFormatToChange = data[j];
                                console.log('dateFormatToChange :',dateFormatToChange);
                                let convertedDate = this.convertDateFormat(dateFormatToChange);
                                if(convertedDate == 'Invalid'){
                                    return "Invalid";
                                } else{
                                    obj[headers[j].trim()] = convertedDate;
                                    console.log('convertedDate: ',convertedDate);
                                }

                            } else {
                                console.log('Date Loop Else');
                                if (headers[j].trim() === "% Complete") {
                                    obj["percentComplete"] = data[j].trim();
                                } else if (headers[j].trim() === "Cost Code") {
                                    obj["costCode"] = data[j].trim();
                                } else if (headers[j].trim() === "Trade Type") {
                                    obj["tradeType"] = data[j].trim();
                                } else {
                                    console.log('data[j].trim() :',data[j].trim());
                                    obj[headers[j].trim()] = data[j].trim();
                                }
                            }
                        }
                        console.log('j:',j,'data.length:',data.length);
                    }

                    if (obj.StartDate !== undefined && obj.StartDate !== "") {
                        console.log('StartDate:',obj.StartDate);
                        jsonObj.push(obj);
                    } else {
                        console.log('obj: ',{obj});
                        console.log('obj.StartDate: ',obj.StartDate);
                        debugger
                        let today = new Date();
                        let dd = String(today.getDate()).padStart(2, "0");
                        let mm = String(today.getMonth() + 1).padStart(2, "0");
                        let yyyy = today.getFullYear();
                        today = yyyy + "-" + mm + "-" + dd;
                        obj.StartDate = today;
                        console.log('obj.StartDate:',obj.StartDate);
                        jsonObj.push(obj);

                        this.startdateError = true;
                        this.Spinner = false;
                    }
                    if (obj.percentComplete !== "" && obj.percentComplete !== undefined) {
                        // Perform necessary operations
                    } else {
                        obj.percentComplete = 0;
                    }
                }
            }

            const taskMap = new Map();
            for (let i = 0; i < jsonObj.length; i++) {
                let element = jsonObj[i];
                taskMap.set("PT - " + i, element.Name);
            }

            for (let i = 0; i < jsonObj.length; i++) {
                let e = jsonObj[i];
                e.ID = "PT - " + i;
            }

            jsonObj.forEach((ele) => {
                for (let [key, value] of taskMap.entries()) {
                    if (ele.Dependency === value) {
                        ele.parentID = key;
                    }
                }
            });

            let parentMap = new Map();
            jsonObj.forEach((element) => {
                parentMap.set(element.ID, element.parentID);
            });

            let circularDependency = false;
            let totalLoop = 0;
            let dependentRecord;
            jsonObj.every((ele) => {
                let currentId = ele.ID;
                for (let index = 0; index <= jsonObj.length + 1; index++) {
                    totalLoop++;
                    if (parentMap.has(currentId)) {
                        currentId = parentMap.get(currentId);
                        if (index > jsonObj.length) {
                            circularDependency = true;
                            console.log("ele.Name:", ele.Name);
                            this.CircularDependencyName = ele.Name;
                            dependentRecord = ele;
                            break;
                        }
                    } else {
                        break;
                    }
                }
                return !circularDependency;
            });

            if (circularDependency) {
                console.log("dependentRecord:", dependentRecord);
                return "";
            } else {
                let json = JSON.stringify(jsonObj);
                return json;
            }
        } catch (error) {
            console.log('error in CSV2JSON:',error);
            return 'Error';
        }
    }

    CreateAccount(jsonstr) {
        const jsonData = JSON.parse(jsonstr);

        insertData({
            recordId: this.recordid,
            strFileData: JSON.stringify(jsonData),
        })
            .then((response) => {
                const state = response;
                console.log('State Response:',state);
                console.log({ state });
                if (state === "SUCCESS") {
                    if (response === "SUCCESS") {
                        this.showMessage = false;
                        this.isOpen = false;

                        const toastEvent = new ShowToastEvent({
                            title: "Success",
                            message: "Schedule lines Imported Successfully.",
                            duration: "10000",
                            key: "info_alt",
                            variant: "success",
                            mode: "dismissible",
                        });
                        this.dispatchEvent(toastEvent);
                        document.location.reload(true)
                    } else {
                        this.Spinner = false;
                        this.showMessage = false;
                        console.log("error--->", response);
                        const toastEvent = new ShowToastEvent({
                            title: "Error",
                            message:
                                "There was an error uploading your file. Please Contact your Administrator for assistance",
                            duration: "10000",
                            key: "info_alt",
                            variant: "error",
                            mode: "dismissible",
                        });
                        this.dispatchEvent(toastEvent);
                        return '';
                    }
                } else {
                    console.log('state ==> ',state);
                    const evt = new ShowToastEvent({
                        title: 'Toast Error',
                        message: 'Some unexpected error',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.Spinner = false;
                    return '';
                }
            })
            .catch((error) => {
                this.Spinner = false;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error occured importing schedule !!!',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                console.error(error);
                return '';
            });

        let ph = false;
        let du = false;
        let nam = false;
        if (JSON.stringify(jsonData).includes('"Phase":""')) {
            ph = true;
        }
        if (JSON.stringify(jsonData).includes('"Duration":""')) {
            du = true;
        }
        if (JSON.stringify(jsonData).includes('"Name":""')) {
            nam = true;
        }

        if (du && nam) {
            const toastEvent = new ShowToastEvent({
                title: "Error",
                message: "You are missing Name, Duration in your CSV file.",
                duration: "10000",
                key: "info_alt",
                variant: "error",
                mode: "dismissible",
            });
            this.dispatchEvent(toastEvent);
            this.Spinner = false;
        } else if (du && !nam) {
            const toastEvent = new ShowToastEvent({
                title: "Error",
                message: "You are missing the Duration value in your CSV file.",
                duration: "10000",
                key: "info_alt",
                variant: "error",
                mode: "dismissible",
            });
            this.dispatchEvent(toastEvent);
            this.Spinner = false;
        } else if (!du && nam) {
            const toastEvent = new ShowToastEvent({
                title: "Error",
                message: "You must have a Name value on all records.",
                duration: "10000",
                key: "info_alt",
                variant: "error",
                mode: "dismissible",
            });
            this.dispatchEvent(toastEvent);
            this.Spinner = false;
        }
    }

    CreateRecord(event) {
        this.Spinner = true;
        this.showMessage = true;
        const fileInput = this.files;

        console.log("fileInput", fileInput);
        if (!fileInput || fileInput.length === 0) {
            this.Spinner = false;
            this.showMessage = false;
            this.showError = true;
        } else {
            const file = fileInput[0];
            this.showError = false;
            if (file) {
                const reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                reader.onload = (evt) => {
                    const csv = evt.target.result;
                    console.log("csv ----> " + csv);
                    const result = this.CSV2JSON(csv);
                    console.log('result :',result);
                    if (result !== undefined && result !== "" && result !== 'Error' && result !== 'Invalid') {
                        window.setTimeout(() => {
                            this.CreateAccount(result);
                        }, 100);
                    } else if (result == 'Error') {
                        const toastEvent = new ShowToastEvent({
                            title: "Error",
                            message: `There was an issue trying to import your file. Please review your file and try again. If this problem persists, please contact your Administrator for assistance.`,
                            duration: "5000",
                            key: "info_alt",
                            variant: "error",
                            mode: "dismissible",
                        });
                        this.dispatchEvent(toastEvent);
                        this.Spinner = false;
                        return '';
                    } else if (result == 'Invalid') {
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Invalid Date format !!!',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this.Spinner = false;
                        return '';
                    } else {
                        const CircularDependencyName = this.CircularDependencyName;
                        const toastEvent = new ShowToastEvent({
                            title: "Error",
                            message: `Circular Dependency!`,
                            duration: "5000",
                            key: "info_alt",
                            variant: "error",
                            mode: "dismissible",
                        });
                        this.dispatchEvent(toastEvent);
                        this.Spinner = false;
                        return '';
                    }
                };
                reader.onerror = (evt) => {
                    console.log("error reading file");
                };
            }
        }
    }

    hideModalBox1() {
        this.dispatchEvent(new CustomEvent('hidemodel', {
            detail: {
                message: false
            }
        }));
    }

    //* auther : Nishit Suthar
    //* Date : 10/09/2021
    //* Description : Convert Date Format into YYYY-MM-DD
    convertDateFormat(dateString) {
        try {
            // dateString = dateString.trim().replace(/\//g, "-")
            var dateParts = dateString.split('/'); // Split the date string by '/'
            var year = dateParts[2];
            var month = dateParts[0]?.padStart(2, '0'); // Pad the month with leading zeros if necessary
            var day = dateParts[1]?.padStart(2, '0'); // Pad the day with leading zeros if necessary

            if (year?.length === 2) {
            // Convert YY format to YYYY format
            var currentYear = new Date().getFullYear().toString();
            var currentCentury = currentYear.slice(0, 2);
            year = currentCentury + year;
            }

            var convertedDate = `${year}-${month}-${day}`; // Combine the date parts in the desired format
            return convertedDate;
        } catch (error) {
            console.log('error:',error);
            return 'Invalid';
        }
    }

    trimCSVData(csvData) {
        try {
            const rows = csvData.split('\n');
            const processedRows = rows.map(row => {
                const fields = row.split(',');
                const trimmedFields = fields.map(field => field.trim());
                return trimmedFields.join(',');
            });
            const modifiedCsvData = processedRows.join('\n');
            return modifiedCsvData;
        } catch (error) {
            console.log('error in trimCSVData:',error);
            return '';
        }
    }
}