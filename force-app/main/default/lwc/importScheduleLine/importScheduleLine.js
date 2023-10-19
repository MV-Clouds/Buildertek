import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import insertData from "@salesforce/apex/importScheduleLineController.insertData";
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

    handleFileChange(event) {
        this.files = event.target.files;

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
            "Notes",
            "Lag",
        ];
        const columnDivider = ",";
        let csvStringResult = "";
        csvStringResult += keys.join(columnDivider);
        return csvStringResult;
    }

    CSV2JSON(csv) {
        let arr = [];
        arr = csv.split("\n");

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
            headers[6] !== "Notes" ||
            headers[7] !== "Lag\r"
        ) {
            this.Spinner = false;
            this.isErrorOccured = true;
            this.errorMessage = "File Header Format is Invalid!";
            return "";
        }

        let startIndex;
        let endIndex;

        for (let i = 1; i < arr.length; i++) {
            if (arr[i] !== undefined) {
                while (arr[i].indexOf('"') > -1) {
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
                    // console.log('newStr:', newStr);
                    if (headers[j].trim() === "StartDate" && data[j].trim() !== "") {
                        let date = data[j].trim();
                        let splitDate = date.split("/");
                        if (
                            parseInt(splitDate[0]) < 10 &&
                            String(parseInt(splitDate[0])).length < 2
                        ) {
                            month = "0" + splitDate[0];
                        } else {
                            month = splitDate[0];
                        }
                        if (
                            parseInt(splitDate[1]) < 10 &&
                            String(parseInt(splitDate[1])).length < 2
                        ) {
                            day = "0" + splitDate[1];
                        } else {
                            day = splitDate[1];
                        }
                        // obj[headers[j].trim()] = month.split("-").reverse().join("-");
                        obj[headers[j].trim()] = data[j].trim().replace(/\//g, "-");
                        console.log('obj[headers[j].trim()]:',obj[headers[j].trim()]);
                    } else {
                        console.log('Date Loop Else');
                        if (headers[j].trim() === "% Complete") {
                            obj["percentComplete"] = data[j].trim();
                        } else {
                            obj[headers[j].trim()] = data[j].trim();
                        }
                    }
                    console.log('j:',j,'data.length:',data.length);
                }

                if (obj.StartDate !== undefined && obj.StartDate !== "") {
                    console.log('StartDate:',obj.StartDate);
                    jsonObj.push(obj);
                } else {
                    let today = new Date();
                    let dd = String(today.getDate()).padStart(2, "0");
                    let mm = String(today.getMonth() + 1).padStart(2, "0");
                    let yyyy = today.getFullYear();
                    today = yyyy + "-" + mm + "-" + dd;
                    obj.StartDate = today;
                    console.log('obj.StartDate:',obj.StartDate);
                    // console.log('today:', today);
                    // console.log('obj.StartDate:', obj.StartDate);
                    jsonObj.push(obj);

                    const toastEvent = new ShowToastEvent({
                        title: "Error",
                        message: "StartDate should not be null",
                        duration: "10000",
                        key: "info_alt",
                        variant: "error",
                        mode: "dismissible",
                    });
                    this.dispatchEvent(toastEvent);
                    this.startdateError = true;
                    this.Spinner = false;
                }
                if (obj.percentComplete !== "" && obj.percentComplete !== undefined) {
                    // Perform necessary operations
                } else {
                    // const toastEvent = new ShowToastEvent({
                    //     title: 'Error',
                    //     message: 'Percent Complete should not be null',
                    //     duration: '10000',
                    //     key: 'info_alt',
                    //     variant: 'error',
                    //     mode: 'dismissible'
                    // });
                    // this.dispatchEvent(toastEvent);
                    // this.startdateError = true;
                    // this.Spinner = false;
                    obj.percentComplete = 0;
                }
            }
        }

        console.log("jsonObj:", jsonObj);
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
        console.log("parentMap:", parentMap);

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

        console.log("Total Loop:", totalLoop);
        if (circularDependency) {
            console.log("dependentRecord:", dependentRecord);
            console.log("Circular Dependency");
            return "";
        } else {
            let json = JSON.stringify(jsonObj);
            return json;
        }
    }

    CreateAccount(jsonstr) {
        const jsonData = JSON.parse(jsonstr);
        // const action = this.insertData;
        console.log("CSV File:", JSON.stringify(jsonData));
        console.log('Create Account Sch recordId',this.recordid);
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
                        this.Spinner = false;
                        this.showMessage = false;
                        this.isOpen = false;

                        // const baseURL = this.BaseURLs;
                        // const url = location.href;
                        // baseURL = url.substring(0, url.indexOf('--', 0));

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
                        // if (this.isNewGantt) {
                        //     const workspaceAPI = this.template.querySelector(
                        //         "lightning-navigation"
                        //     );
                        //     if (workspaceAPI) {
                        //         workspaceAPI
                        //             .getFocusedTabInfo()
                        //             .then((response) => {
                        //                 const focusedTabId = response.tabId;
                        //                 workspaceAPI
                        //                     .closeTab({ tabId: focusedTabId })
                        //                     .then((res) => {
                        //                         window.setTimeout(() => {
                        //                             window.open("/" + recordId, "_top");
                        //                             location.reload();
                        //                         }, 2000);
                        //                         if (workspaceAPI.getFocusedTabInfo()) {
                        //                             workspaceAPI
                        //                                 .getFocusedTabInfo()
                        //                                 .then((response) => {
                        //                                     const focusedTabId = response.tabId;
                        //                                     window.setTimeout(() => {
                        //                                         window.open("/" + recordId, "_top");
                        //                                         location.reload();
                        //                                     }, 2000);
                        //                                 })
                        //                                 .catch((error) => {
                        //                                     console.log(error);
                        //                                 });
                        //                         }
                        //                     });
                        //             })
                        //             .catch((error) => {
                        //                 console.log(error);
                        //                 const navEvt = new CustomEvent("navigate", {
                        //                     detail: {
                        //                         recordId: recordId,
                        //                         slideDevName: "detail",
                        //                     },
                        //                 });
                        //                 window.setTimeout(() => {
                        //                     location.reload();
                        //                 }, 500);
                        //                 this.dispatchEvent(navEvt);
                        //             });
                        //     } else {
                        //         window.open("/" + recordId, "_top");
                        //     }
                        // } else {
                        //     // window.open('/apex/BT_Task_Manager?recordId=' + escape(recordId), '_self');
                        //     debugger;
                        //     window.open("/"+dummyRecordId, "_self");
                        // }
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
                    // console.error('response:',response);
                }
            })
            .catch((error) => {
                this.Spinner = false;
                console.error(error);
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
            if (file) {
                this.showError = false;
                const reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                reader.onload = (evt) => {
                    const csv = evt.target.result;
                    console.log("csv ----> " + csv);
                    const result = this.CSV2JSON(csv);
                    if (result !== undefined && result !== "") {
                        window.setTimeout(() => {
                            this.CreateAccount(result);
                        }, 100);
                    } else {
                        const CircularDependencyName = this.CircularDependencyName;
                        const toastEvent = new ShowToastEvent({
                            title: "Error",
                            message: `Circular Dependency due to '${CircularDependencyName}' Record`,
                            duration: "5000",
                            key: "info_alt",
                            variant: "error",
                            mode: "dismissible",
                        });
                        this.dispatchEvent(toastEvent);
                        this.Spinner = false;
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
}