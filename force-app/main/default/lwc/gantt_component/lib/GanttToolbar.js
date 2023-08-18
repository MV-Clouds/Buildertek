/* globals bryntum : true */
import  insertUpdateTask from '@salesforce/apex/BT_NewGanttChartCls.insertUpdateTask';
import  updateTaskRecord from '@salesforce/apex/BT_NewGanttChartCls.updateTaskRecord';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';
export default base => class GanttToolbar extends base {
    static get $name() {
        return 'GanttToolbar';
    }
   /*  doDestroy() {
        // perform custom cleanup

        super.doDestroy();
    } */

    // Called when toolbar is added to the Gantt panel
    set parent(parent) {
        super.parent = parent;
        const me = this;

        me.gantt = parent;
        parent.project.on({

            /*commented by sai */
            //load: 'zoomInOnLoad',
            load    : 'updateStartDateField',
            //refresh    :  this.gantt.scrollToDate(this.widgetMap.startDateField, { block : 'center', animate : 500 }),
            refresh : 'refreshData',
           /*commented by sai */
            thisObj : me
        });
        parent.project.stm.on({
            recordingStop : 'updateUndoRedoButtons',
            restoringStop : 'updateUndoRedoButtons',
            stmDisabled   : 'updateUndoRedoButtons',
            queueReset    : 'updateUndoRedoButtons',
            thisObj       : me
        });
        me.styleNode = document.createElement('style');
        document.head.appendChild(me.styleNode);
    }
    get parent() {
        return super.parent;
    }

    static get defaultConfig() {
        console.log(parent)
        var centerDate = parent; //new Date(); //this.gantt.project.startDate;
        return {
            items : [
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type     : 'button',
                            color    : 'b-green',
                            ref      : 'addTaskButton',
                            icon     : 'b-fa b-fa-plus',
                            text     : 'Create',
                            tooltip  : 'Create new task',
                            onAction : 'up.onAddTaskClick'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'undoBtn',
                            icon     : 'b-icon b-fa b-fa-undo',
                            tooltip  : 'Undo',
                            disabled : true,
                            width    : '2em',
                            onAction : 'up.onUndoClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'redoBtn',
                            icon     : 'b-icon b-fa b-fa-redo',
                            tooltip  : 'Redo',
                            disabled : true,
                            width    : '2em',
                            onAction : 'up.onRedoClick'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'expandAllButton',
                            icon     : 'b-fa b-fa-angle-double-down',
                            tooltip  : 'Expand all',
                            onAction : 'up.onExpandAllClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'collapseAllButton',
                            icon     : 'b-fa b-fa-angle-double-up',
                            tooltip  : 'Collapse all',
                            onAction : 'up.onCollapseAllClick'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [

                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'zoomInButton',
                            icon     : 'b-fa b-fa-search-plus',
                            tooltip  : 'Zoom in',
                            onAction : 'up.onZoomInClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'zoomOutButton',
                            icon     : 'b-fa b-fa-search-minus',
                            tooltip  : 'Zoom out',
                            onAction : 'up.onZoomOutClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'previousButton',
                            icon     : 'b-fa b-fa-angle-left',
                            tooltip  : 'Previous time span',
                            onAction : 'up.onShiftPreviousClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'nextButton',
                            icon     : 'b-fa b-fa-angle-right',
                            tooltip  : 'Next time span',
                            onAction : 'up.onShiftNextClick'
                        }
                    ]
                },
                 {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : 'featuresButton',
                            icon       : 'b-fa b-fa-tasks',
                            text       : 'Features',
                            tooltip    : 'Toggle features',
                            toggleable : true,
                            menu       : {
                                onItem       : 'up.onFeaturesClick',
                                onBeforeShow : 'up.onFeaturesShow',
                                items        : [
                                    {
                                        text    : 'Draw dependencies',
                                        feature : 'dependencies',
                                        checked : false
                                    },
                                    {
                                        text    : 'Task labels',
                                        feature : 'labels',
                                        checked : false
                                    },
                                    {
                                        text    : 'Project lines',
                                        feature : 'projectLines',
                                        checked : false
                                    },
                                    {
                                        text    : 'Highlight non-working time',
                                        feature : 'nonWorkingTime',
                                        checked : false
                                    },
                                    {
                                        text    : 'Hide schedule',
                                        cls     : 'b-separator',
                                        subGrid : 'normal',
                                        checked : false
                                    }
                                ]
                            }
                        },
                        {
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : 'settingsButton',
                            icon       : 'b-fa b-fa-cogs',
                            text       : 'Settings',
                            tooltip    : 'Adjust settings',
                            toggleable : true,
                            menu       : {
                                type        : 'popup',
                                anchor      : true,
                                cls         : 'settings-menu',
                                layoutStyle : {
                                    flexDirection : 'column'
                                },
                                onBeforeShow : 'up.onSettingsShow',
                                items : [
                                    {
                                        type      : 'slider',
                                        ref       : 'rowHeight',
                                        text      : 'Row height',
                                        width     : '12em',
                                        showValue : true,
                                        min       : 30,
                                        max       : 70,
                                        onInput   : 'up.onSettingsRowHeightChange'
                                    },
                                    {
                                        type      : 'slider',
                                        ref       : 'barMargin',
                                        text      : 'Bar margin',
                                        width     : '12em',
                                        showValue : true,
                                        min       : 0,
                                        max       : 10,
                                        onInput   : 'up.onSettingsMarginChange'
                                    }
                                ]
                            }
                        }
                        /*,{
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : 'criticalPathsButton',
                            icon       : 'b-fa b-fa-fire',
                            text       : 'Critical paths',
                            tooltip    : 'Highlight critical paths',
                            toggleable : true,
                            onAction   : 'up.onCriticalPathsClick'
                        }*/
                    ]
                },
                {
                    label      : 'Scroll to date',
                    inputWidth : '5em',
                    width      : 'auto',
                    type       : 'datefield',
                    value      : new Date(),
                    step       : '1w',
                    listeners  : {
                        change : 'up.onscrollToDate'

                    },
                    highlightExternalChange : false
                },
                {
                    type                 : 'textfield',
                    ref                  : 'filterByName',
                    cls                  : 'filter-by-name',
                    flex                 : '0 0 20em' ,//'1 1 8.5em',
                    // Label used for material, hidden in other themes
                    label                : 'Task Name',
                    // Placeholder for others
                    placeholder          : 'Search...',
                    clearable            : true,
                    keyStrokeChangeDelay : 100,
                    triggers             : {
                        filter : {
                            align : 'end',
                            cls   : 'b-fa b-fa-filter'
                        }
                    },
                    onChange : 'up.onFilterChange'
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : 'saveDataButton',
                            icon       : 'b-fa b-fa-save',
                            text       : 'Save Changes',
                            onAction : 'up.onSaveClick'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : 'importScheduleLines',
                            cls        : 'importScheduleLinesBtn',
                            icon       : 'b-fa b-fa-file-import', //file-upload
                            text       : 'Import Schedule Lines',
                            onAction : 'up.onImportScheduleLines'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : 'importMasterSchedule',
                            cls        : 'importMasterBtn',
                            icon       : 'b-fa b-fa-download',
                            text       : 'Import Master Schedule',
                            onAction : 'up.onImportMasterSchedule'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : '',
                            cls        : '',
                            icon       : 'b-fa b-fa-calendar',
                            text       : 'Set Original Dates',
                            onAction   : 'up.onEditOriginalDate'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : 'exportButton',
                            cls        : 'exportSchButton',
                            icon       : 'b-fa b-fa-file-export',
                            text       : 'Export to CSV',
                            onAction : 'up.onExportToCSV'
                        }
                    ]
                }

            ]
        };
    }
    updateUndoRedoButtons() {
        const
            { stm }              = this.gantt.project,
            { undoBtn, redoBtn } = this.widgetMap,
            redoCount            = stm.length - stm.position;
        undoBtn.badge = stm.position || '';
        redoBtn.badge = redoCount || '';
        undoBtn.disabled = !stm.canUndo;
        redoBtn.disabled = !stm.canRedo;
    }
    updateStartDateField() {
        try{
            this.gantt.zoomIn();
            this.gantt.zoomIn();
            const startDateField = this.widgetMap.startDateField;
            if(this.gantt.project.startDate){
                this.gantt.scrollToDate(this.gantt.project.startDate, { block : 'center', animate : 0 });
            }
        }
        catch(error){
            console.log(error)
        }


    }
    refreshData() {
        const startDateField = this.widgetMap.startDateField;
        if(startDateField){
            startDateField.value = this.gantt.project.startDate;
        startDateField.required = false; //true
        }
        console.log(this.gantt)
        if(this.gantt){
            if(this.gantt.callGanttComponent){
                if( this.gantt.subGrids['normal']){
                    this.gantt.subGrids['normal']['collapsed'] = this.gantt.callGanttComponent.hideSchedule;
                }
               /*  if(this.gantt.callGanttComponent.schedulerVar){
                    if(this.gantt.callGanttComponent.schedulerVar.subGrids){
                        this.gantt.callGanttComponent.schedulerVar.subGrids['normal']['collapsed'] = this.gantt.callGanttComponent.hideSchedule;
                    }
                } */

            }
        }
    }
    onSaveClick(){
        console.log(this.gantt.data)
        var data = this.gantt.data;
        console.log('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
        console.log('Data => ',{data});
        var ganttRowData = [];
        var taskData = JSON.parse(this.gantt.taskStore.json)
        var dependenciesData = JSON.parse(this.gantt.dependencyStore.json)
        var resourceData = JSON.parse(this.gantt.assignmentStore.json)
        console.log('taskData-->',taskData)
        console.log('dependenciesData-->',dependenciesData)
        console.log('resourceData-->',resourceData)

    //     var newtaskMap = [];
    //    var taskzero = taskData[0];
    //    taskzero.children.forEach(element => {
    //       element.children.forEach(ele => {
    //         // console.log('Ele ==> ',{ele});
    //         var taskId = ele.id;
    //         // console.log('taskId  ==> '+taskId);
    //         var startDate = ele.startDate;

    //         var fr = startDate.substring(8,10);
    //         var gh = Number(fr)-1;
    //         var jk = gh.toString().padStart(2, '0');
    //         // console.log(gh);

    //         if(jk == "00"){
    //           jk = "01";
    //         }

    //         var de = startDate.substring(0,8)+jk+"T"+startDate.substring(11,25);
    //         const mmp = [taskId, de];
    //         newtaskMap.push(mmp);
    //       });
    //     });

        // console.log('newtaskMap => ',{newtaskMap});
        // console.log('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Start');
        // var tempN = this.gantt.taskStore.json;
        // console.log('tempN ==>' + tempN);
        //   updateTaskRecord({taskData: newtaskMap})
        //    .then((result) => {
        //     console.log("Res N -->>");
        //       console.log({result});
        //    })
        //    .catch((error) => {
        //       console.log("logn Error -->>");
        //       console.log({error});
        //    });
        // console.log('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& End');



        var rowData = [];
        if(this.gantt.data){
            if(this.gantt.data.length > 1){
                function getChildren(data){
                    if(data.children){
                        for(var i=0;i<data.children.length;i++){
                         getChildren(data.children[i])
                        }
                    }else{
                     rowData.push(data)
                    }
                }
                getChildren(taskData[0])
                console.log(rowData)
                var updateDataList = [];
                var updateDataCloneList = [];
                var insertData = [];
                for(var i=0;i<rowData.length;i++){
                    var updateData = {}
                    var updateDataClone = {}
                    var endDate
                    if(rowData[i]['name'] != 'Milestone Complete'){
                        endDate = new Date(rowData[i].endDate);
                        endDate.setDate(endDate.getDate() - 1)
                    }else{
                        endDate= new Date(rowData[i].endDate);
                        //endDate.setDate(endDate.getDate() + 1)
                    }

                    rowData[i].endDate = endDate;
                    if(rowData[i]['id'].indexOf('_generate') == -1){
                    updateData['Id'] = rowData[i]['id']
                    }
                    updateData['buildertek__Schedule__c'] = taskData[0].id;
                    updateData['Name'] = rowData[i]['name']
                    updateData['buildertek__Order__c'] = i+1;
                    //var startdate = new Date(rowData[i]['startDate'])
                    // console.log('test',new Date(rowData[i]['endDate']).toLocaleDateString())
                    var enddate = new Date(rowData[i]['endDate']).toLocaleDateString().split('/')
                    //var enddate = new Date(rowData[i]['endDate']).toJSON();
                    var enddate = new Date(rowData[i]['endDate'])
                    // console.log('test', rowData[i]['startDate'])
                    updateData['buildertek__Start__c'] = rowData[i]['startDate'].split('T')[0]
                    //updateData['buildertek__Finish__c'] = enddate[2] + '-'+ enddate[1] + '-'+enddate[0]
                    //updateData['buildertek__Finish__c'] = enddate.split('T')[0]
                    updateData['buildertek__Finish__c'] = enddate.getFullYear() + '-' + Number(enddate.getMonth()+1) + '-' + enddate.getDate();
                    updateData['buildertek__Duration__c'] = rowData[i]['duration']
                    updateData['buildertek__Completion__c'] = rowData[i]['percentDone']
                    updateData['buildertek__Type__c'] = rowData[i]['customtype']

                    if(rowData[i]['cls']){
                        var check = rowData[i]['cls']
                        if(check.includes('milestoneCompleteColor')){
                            updateData['buildertek__Milestone__c'] = true;
                        }
                    }
                    if(rowData[i]['iconCls'] == 'b-fa b-fa-arrow-left indentTrue'){
                        updateData['buildertek__Indent_Task__c'] = true
                    }else{
                        updateData['buildertek__Indent_Task__c'] = false;
                    }
                    //updateData['buildertek__Indent_Task__c'] = rowData[i]['iconCls'].includes('indentTrue')
                    if(rowData[i]['parentId']){
                        // console.log(rowData[i]['parentId'])
                        if(rowData[i]['parentId'].split('_')[1]){
                            updateData['buildertek__Phase__c'] = rowData[i]['parentId'].split('_')[1]
                        }
                    }

                    if(rowData[i]['id']){
                        var taskbyid = this.gantt.taskStore.getById(rowData[i]['id'])._data
                        // console.log(taskbyid)
                        if(!taskbyid.predecessor){
                            updateData['buildertek__Dependency__c'] = null;
                        }
                    }

                    var filledDependency = false
                    for(var j=0;j<dependenciesData.length;j++){
                        if(dependenciesData[j]['to'] == rowData[i]['id']){
                            if(dependenciesData[j]['id'].indexOf('_generated') >= 0){
                                updateData['buildertek__Dependency__c'] = dependenciesData[j]['from']
                            }else{
                                updateData['buildertek__Dependency__c'] = dependenciesData[j]['from']
                            }
                            filledDependency = true;
                        }
                        if(!filledDependency){
                            updateData['buildertek__Dependency__c'] = null;
                        }
                    }
                    updateDataClone = Object.assign({},updateData);
                    // console.log(updateDataClone);
                    for(var j=0;j<resourceData.length;j++){
                        if(resourceData[j]['event'] == rowData[i]['id']){
                            if(resourceData[j]['id'].indexOf('ContractorResource') >= 0){
                                var conresName = resourceData[j]['id'].split('ContractorResource_Name')[1];
                                var obj = {'Name' : conresName}
                                updateData['buildertek__Contractor_Resource__r']= obj;
                                updateData['buildertek__Contractor_Resource__c'] = resourceData[j]['resource']
                                updateDataClone['buildertek__Contractor_Resource__c'] = resourceData[j]['resource']
                            }else if(resourceData[j]['id'].indexOf('Resource') >= 0){
                                var resName = resourceData[j]['id'].split('Resource_Name')[1];
                                var obj = {'Name' : resName}
                                updateData['buildertek__Resource__c'] = resourceData[j]['resource']
                                updateData['buildertek__Resource__r']= obj;
                                updateDataClone['buildertek__Resource__c'] = resourceData[j]['resource']
                            }
                        }
                    }
                    if(rowData[i]['id'].indexOf('_generate') == -1){
                        updateDataCloneList.push(updateDataClone)
                    }
                    updateDataList.push(updateData)
                }
                debugger;
                console.log('updateDataList ==> ',{updateDataList});

                if(this.gantt.callGanttComponent){
                    if(this.gantt.callGanttComponent.scheduleData){

                        this.gantt.callGanttComponent.hideSchedule = this.gantt.subGrids['normal']['collapsed'] ;
                        if(this.gantt.subGrids['normal']){
                            if(this.gantt.subGrids['normal']['collapsed']){
                                this.gantt.callGanttComponent.hideSchedule = this.gantt.subGrids['normal']['collapsed']
                            }else{
                                this.gantt.callGanttComponent.hideSchedule = false
                            }
                        }

                        //this.gantt.callGanttComponent.scheduleData.buildertek__Hide_Gantt_Schedule__c = this.gantt.callGanttComponent.hideSchedule;
                        this.gantt.callGanttComponent.hideScheduleFromUser = this.gantt.callGanttComponent.hideSchedule;
                        //this.gantt.callGanttComponent.updateValOnSch(this.gantt.callGanttComponent.hideSchedule);
                        this.gantt.callGanttComponent.updateValOnUser(this.gantt.callGanttComponent.hideSchedule);
                    }
                }

                // console.log('updateDataCloneList ==> ',{updateDataCloneList});

                // var taskMap =  new Map();
                // updateDataCloneList.forEach(element => {
                //     taskMap.set(element.buildertek__Dependency__c, element.buildertek__Start__c);
                // });

                // updateDataCloneList.forEach(element => {
                //     if(taskMap.get(element.Id) != undefined){
                //         element.buildertek__Finish__c = taskMap.get(element.Id) - 1;
                //         console.log('element => '+element);
                //     }
                // });

                // console.log('---------------------------------------');
                // console.log('updateDataCloneList ==> ',{updateDataCloneList});

                this.gantt.callGanttComponent.callinsertUpdateTaskList(updateDataCloneList)
                this.gantt.callGanttComponent.scheduleItemsDataList = updateDataList;

                if(this.gantt.callGanttComponent.template.querySelector('.container').children.length){
                    // this.gantt.callGanttComponent.template.querySelector('.container').innerHTML = '';
                    this.gantt.callGanttComponent.template.querySelector('.container').innerHTML = '<div  class="slds-spinner_container" style="position:fixed;opacity:1;">      <div class="slds-spinner--brand  slds-spinner slds-spinner--large slds-is-relative" role="alert"><span class="slds-assistive-text">Loading</span><div class="slds-spinner__dot-a"></div><div class="slds-spinner__dot-b"></div><div class="custom-loading-text"><b>Processing, Please Wait</b></div></div></div><div class="slds-backdrop slds-backdrop_open" style="opacity: 0;"></div>';
                    this.gantt.callGanttComponent.template.querySelector('.container1').innerHTML = '';
                    this.gantt.callGanttComponent.createGantt();
                    // this.GanttVar.crudManager.taskStore.refreshData()
                }else{
                    this.gantt.callGanttComponent.createGantt();
                }

                 console.log(this.gantt.taskStore);
                 console.log(this.gantt.dependencyStore);
            }
        }
        // eval("$A.get('e.force:refreshView').fire();");

        // window.location.reload();
        //send only task rows to apex and update/insert them
        //for newly added tasks we getting id="_generated+index" so while sending data to apex we can check to insert them
    }
    onImportMasterSchedule(){
        this.gantt.callGanttComponent.openMasterSchedule()
    }

    onExportToCSV(){
        this.gantt.callGanttComponent.exportData()
    }

    onImportScheduleLines(){
        this.gantt.callGanttComponent.openScheduleLines()
    }
    onExportToPdf(){
        this.gantt.features.pdfExport.showExportDialog();
    }
    onEditOriginalDate(){
        this.gantt.callGanttComponent.openOriginDateModal()
    }
    // region controller methods
    async onAddTaskClick() {
        /* const
            { gantt } = this,
            added = gantt.taskStore.rootNode.appendChild({ name : 'New task', duration : 1 });
        await gantt.project.propagate();
        await gantt.scrollRowIntoView(added);
        if (added) {
             gantt.editTask(added);
        }
        gantt.features.cellEdit.startEditing({
            record : added,
            field  : 'name'
        }); */
        this.gantt.callGanttComponent.addNewTask();
        //this.gantt.callGanttComponent.addStandardNew();
    }

    onExpandAllClick() {
        this.gantt.expandAll();
    }
    onCollapseAllClick() {
        this.gantt.collapseAll();
    }
    onZoomInClick() {
        this.gantt.zoomIn();
    }
    onZoomOutClick() {
        this.gantt.zoomOut();
    }
    onZoomToFitClick() {
        this.gantt.zoomToFit({
            leftMargin  : 50,
            rightMargin : 50
        });
    }
    onShiftPreviousClick() {
        this.gantt.shiftPrevious();
    }
    onShiftNextClick() {
        this.gantt.shiftNext();
    }

    /* onStartDateChange({ value, oldValue }) {
        if (!oldValue) { // ignore initial set
            return;
        }
        this.gantt.startDate = bryntum.gantt.DateHelper.add(value, -1, 'week');
        this.gantt.project.setStartDate(value);
    } */
    onscrollToDate({ userAction, value }) {
        if (userAction) {
            this.gantt.scrollToDate(value, { block : 'center', animate : 500 });
        }
    }

    onFilterChange({ value }) {
        if (value === '') {
            this.gantt.taskStore.clearFilters();
        }
        else {
            value = value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            this.gantt.taskStore.filter({
                filters : task => task.name && task.name.match(new RegExp(value, 'i')),
                replace : true
            });
        }
    }
     onFeaturesClick({ source : item }) {
        const { gantt } = this;
        if (item.feature) {
            const feature = gantt.features[item.feature];
            feature.disabled = !feature.disabled;
        }
        else if (item.subGrid) {
            const subGrid = gantt.subGrids[item.subGrid];
            subGrid.collapsed = !subGrid.collapsed;
            if(this.gantt){
                if(this.gantt.callGanttComponent){
                    this.gantt.callGanttComponent.hideSchedule = subGrid.collapsed;
                   /*  this.gantt.callGanttComponent.hideSchedule = this.gantt.subGrids['normal']['collapsed'] ;
                    if(this.gantt.subGrids['normal']){
                        if(this.gantt.subGrids['normal']['collapsed']){
                            this.gantt.callGanttComponent.hideSchedule = this.gantt.subGrids['normal']['collapsed']
                        }else{
                            this.gantt.callGanttComponent.hideSchedule = false
                        }
                    }
                     */
                    //this.gantt.callGanttComponent.scheduleData.buildertek__Hide_Gantt_Schedule__c = this.gantt.callGanttComponent.hideSchedule;
                    this.gantt.callGanttComponent.hideScheduleFromUser = this.gantt.callGanttComponent.hideSchedule;
                    //this.gantt.callGanttComponent.updateValOnSch(this.gantt.callGanttComponent.hideSchedule);
                    this.gantt.callGanttComponent.updateValOnUser(this.gantt.callGanttComponent.hideSchedule);

                }
            }

            /* if(this.gantt.callGanttComponent.scheduleData){
                this.gantt.callGanttComponent.scheduleData.buildertek__Hide_Gantt_Schedule__c = subGrid.collapsed;
                this.gantt.callGanttComponent.updateValOnSch(subGrid.collapsed);
            } */
        }
    }
     onFeaturesShow({ source : menu }) {
        const { gantt } = this;

         menu.items.forEach(item => {
            const { feature } = item;
            if (feature) {
                // a feature might be not presented in the gantt
                // (the code is shared between "advanced" and "php" demos which use a bit different set of features)
                if (gantt.features[feature]) {
                    item.checked = !gantt.features[feature].disabled;
                }
                // hide not existing features
                else {
                    item.hide();
                }
            }
            else {
                item.checked = gantt.subGrids[item.subGrid].collapsed;
            }
        });
    }
    onSettingsShow({ source : menu }) {
        const { gantt } = this,
            { widgetMap } = menu;
        widgetMap.rowHeight.value = gantt.rowHeight;
        widgetMap.barMargin.value = gantt.barMargin;
        widgetMap.barMargin.max = (gantt.rowHeight / 2) - 5;
    }
    onSettingsRowHeightChange({ value }) {
        this.gantt.rowHeight = value;
        this.widgetMap.settingsButton.menu.widgetMap.barMargin.max = (value / 2) - 5;
    }
    onSettingsMarginChange({ value }) {
        this.gantt.barMargin = value;
    }
    onCriticalPathsClick({ source }) {
        this.gantt.features.criticalPaths.disabled = !source.pressed;
    }
    onUndoClick() {
        if (this.gantt.project.stm.canUndo) {
            this.gantt.project.stm.undo();
        }
    }
    onRedoClick() {
        if (this.gantt.project.stm.canRedo) {
            this.gantt.project.stm.redo();
        }
    }
};